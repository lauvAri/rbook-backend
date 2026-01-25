# Spring Boot 后端开发指南 - 代码执行器模块

> **模块说明**：`code-runner` 模块负责管理 R 语言脚本元数据，并调用底层 R 环境执行脚本，处理文本与图片输出。
> **前置依赖**：服务器需预先安装 R 语言环境 (`sudo apt-get install r-base`)。

## 1. 模块目录结构

请在 `src/main/java/com/example/project/modules/` 下创建 `coderunner` 目录。

```text
com.example.project.modules.coderunner/
|-- controller/
|   `-- CodeRunnerController.java      # API 接口入口
|-- service/
|   |-- CodeRunnerService.java          # 业务逻辑接口
|   `-- impl/
|       `-- CodeRunnerServiceImpl.java  # 核心实现：脚本查找、参数组装
|-- component/
|   `-- RScriptExecutor.java            # 【核心】ProcessBuilder 调用 R 的底层工具
|-- model/
|   |-- dto/                            # 数据传输对象 (对应 API 请求/响应)
|   |   |-- ScriptDefinitionDTO.java
|   |   |-- ExecuteRequestDTO.java
|   |   `-- ExecutionResultDTO.java
|   `-- entity/                         # (可选) 如果脚本存数据库则需要
|       `-- RScriptEntity.java
`-- config/
    `-- CodeRunnerProperties.java       # 读取 application.yml 配置 (R路径, 超时等)

```

---

## 2. 数据模型 (DTO) 定义

利用 Lombok 简化代码，严格匹配 API 文档的 JSON 结构。

### 2.1 请求体 (`ExecuteRequestDTO`)

```java
package com.example.project.modules.coderunner.model.dto;

import lombok.Data;
import java.util.Map;

@Data
public class ExecuteRequestDTO {
    private String scriptId;
    
    // 对应 API 中的 variables，使用 Map 接收动态参数
    private Map<String, Object> variables;
    
    // CSV 内容字符串
    private String fileData;
    
    // 是否为直接文本输入
    private Boolean isRawInput;
}

```

### 2.2 响应体 (`ExecutionResultDTO`)

```java
package com.example.project.modules.coderunner.model.dto;

import lombok.Data;
import lombok.Builder;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;
import java.util.List;

@Data
@Builder
public class ExecutionResultDTO {
    private Boolean success;
    private List<OutputItem> outputs;
    private Long executionTime; // 毫秒
    private String error;       // 仅在 success=false 时有值

    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    public static class OutputItem {
        // "text" 或 "image"
        private String type; 
        
        // type="text" 时使用
        private String content; 
        
        // type="image" 时使用
        private String data;    // Base64 字符串
        private String format;  // "png", "jpeg"
        private String caption;
    }
}

```

---

## 3. Controller 层实现

负责处理 HTTP 请求，参数校验，并返回统一的 `Result<T>`。

```java
@RestController
@RequestMapping("/api/code-runner")
@RequiredArgsConstructor
public class CodeRunnerController {

    private final CodeRunnerService codeRunnerService;

    // 1. 获取脚本列表
    @GetMapping("/scripts")
    public Result<List<ScriptDefinitionDTO>> listScripts() {
        return Result.success(codeRunnerService.getAllScripts());
    }

    // 2. 获取脚本详情
    @GetMapping("/scripts/{id}")
    public Result<ScriptDefinitionDTO> getScript(@PathVariable String id) {
        ScriptDefinitionDTO script = codeRunnerService.getScriptById(id);
        if (script == null) {
            return Result.error(1002, "脚本不存在");
        }
        return Result.success(script);
    }

    // 3. 执行代码
    @PostMapping("/execute")
    public Result<ExecutionResultDTO> execute(@RequestBody ExecuteRequestDTO request) {
        // 简单校验
        if (StringUtils.isBlank(request.getScriptId())) {
            return Result.error(1001, "scriptId 不能为空");
        }

        try {
            ExecutionResultDTO result = codeRunnerService.executeScript(request);
            return Result.success(result);
        } catch (Exception e) {
            // 捕获预期外的系统错误
            return Result.error(5000, "执行过程发生系统错误: " + e.getMessage());
        }
    }
}

```

---

## 4. 核心组件：RScriptExecutor (难点攻克)

这是后端最关键的部分。需要解决：**传递变量**、**加载 CSV**、**捕获图片**。

**设计思路**：
不要试图直接在命令行拼接复杂的 R 代码。**最佳实践**是生成一个临时的 `.R` 包装脚本（Wrapper Script）。

1. 创建一个临时目录。
2. 如果有 `fileData`，将其写入 `input.csv`。
3. 生成一个 `wrapper.R`：
* 先定义用户传入的变量（如 `sample_size <- 100`）。
* 定义输入文件路径变量（如 `input_file <- "./input.csv"`）。
* 指定图片输出路径（如 `png("output.png")`）。
* `source("target_script.R")` 加载实际脚本。


4. 使用 `ProcessBuilder` 执行 `Rscript wrapper.R`。
5. 读取 stdout 作为文本日志，读取 `output.png` 转 Base64。

```java
@Component
@Slf4j
public class RScriptExecutor {

    @Value("${app.coderunner.r-executable:Rscript}")
    private String rCommand; // 允许在 yml 配置 Rscript 路径

    @Value("${app.coderunner.script-storage-path}")
    private String scriptStoragePath; // 原始 R 脚本存放位置

    public ExecutionResultDTO run(String scriptFilename, Map<String, Object> variables, String csvData) {
        long startTime = System.currentTimeMillis();
        Path workDir = null;

        try {
            // 1. 创建临时工作目录 (隔离每次执行)
            workDir = Files.createTempDirectory("r_exec_");
            
            // 2. 处理 CSV 输入
            if (StringUtils.hasText(csvData)) {
                Files.writeString(workDir.resolve("data.csv"), csvData);
            }

            // 3. 构建 Wrapper 脚本内容
            StringBuilder wrapperCode = new StringBuilder();
            
            // 3.1 注入变量
            if (variables != null) {
                variables.forEach((k, v) -> {
                    if (v instanceof Number) {
                        wrapperCode.append(String.format("%s <- %s\n", k, v));
                    } else {
                        // 字符串需要加引号，注意防注入
                        wrapperCode.append(String.format("%s <- \"%s\"\n", k, v.toString().replace("\"", "\\\"")));
                    }
                });
            }
            
            // 3.2 注入固定环境变量
            wrapperCode.append("input_file <- \"data.csv\"\n"); // 脚本内部通过读取这个变量知道文件在哪
            wrapperCode.append("output_image <- \"plot.png\"\n"); // 约定图片输出文件名
            
            // 3.3 设置图片捕获 (R语言绘图重定向)
            // 这样脚本里只需要调用 plot()，不需要自己写 png()
            wrapperCode.append("png(output_image, width=800, height=600)\n"); 
            
            // 3.4 调用实际脚本
            // 假设原始脚本在 /data/scripts/linear-regression.R
            Path targetScriptPath = Paths.get(scriptStoragePath, scriptFilename);
            if (!Files.exists(targetScriptPath)) {
                throw new RuntimeException("Script file not found: " + scriptFilename);
            }
            // 使用 source 运行目标代码
            // tryCatch 确保即使脚本出错也能关闭 device
            wrapperCode.append("tryCatch({ source(\"" + targetScriptPath.toAbsolutePath().toString().replace("\\", "/") + "\") }, finally = { dev.off() })");

            // 写入 wrapper.R
            Files.writeString(workDir.resolve("wrapper.R"), wrapperCode.toString());

            // 4. 调用系统进程执行
            ProcessBuilder pb = new ProcessBuilder(rCommand, "wrapper.R");
            pb.directory(workDir.toFile());
            pb.redirectErrorStream(true); // 合并 stdout 和 stderr
            
            Process process = pb.start();
            
            // 设置超时 (例如 30秒)
            boolean finished = process.waitFor(30, TimeUnit.SECONDS);
            if (!finished) {
                process.destroyForcibly();
                return ExecutionResultDTO.builder().success(false).error("Execution Timed Out").build();
            }

            // 5. 收集结果
            // 5.1 读取控制台输出
            String logs = new String(process.getInputStream().readAllBytes(), StandardCharsets.UTF_8);
            
            // 5.2 读取图片 (如果生成了的话)
            List<ExecutionResultDTO.OutputItem> outputs = new ArrayList<>();
            outputs.add(new ExecutionResultDTO.OutputItem("text", logs, null, null, null));

            Path imagePath = workDir.resolve("plot.png");
            if (Files.exists(imagePath) && Files.size(imagePath) > 0) {
                byte[] imgBytes = Files.readAllBytes(imagePath);
                String base64 = Base64.getEncoder().encodeToString(imgBytes);
                outputs.add(new ExecutionResultDTO.OutputItem("image", null, base64, "png", "Result Plot"));
            }
            
            // 6. 判断 R 脚本是否报错 (通过 exit code 或 logs 关键词)
            if (process.exitValue() != 0) {
                 return ExecutionResultDTO.builder()
                    .success(false)
                    .outputs(outputs) // 即使失败也返回日志
                    .error("R Process exited with code " + process.exitValue())
                    .build();
            }

            return ExecutionResultDTO.builder()
                    .success(true)
                    .outputs(outputs)
                    .executionTime(System.currentTimeMillis() - startTime)
                    .build();

        } catch (Exception e) {
            log.error("R execution failed", e);
            return ExecutionResultDTO.builder().success(false).error(e.getMessage()).build();
        } finally {
            // 7. 清理临时目录 (非常重要！)
            deleteDirectory(workDir);
        }
    }
    
    // 辅助方法：递归删除目录
    private void deleteDirectory(Path path) { ... }
}

```

---

## 5. 配置与环境要求

### 5.1 `application.yml`

```yaml
app:
  coderunner:
    r-executable: /usr/bin/Rscript  # Linux 下 Rscript 的路径
    script-storage-path: /var/data/r-scripts # 存放 .R 文件的物理路径
    timeout-seconds: 30
    max-file-size: 5MB

```

### 5.2 R 脚本编写规范 (Backend Internal)

为了配合上述 `RScriptExecutor`，你的 R 脚本 (`linear-regression.R`) 应该这样写：

```r
# === 由后端约定的变量 ===
# input_file (如果有文件上传)
# sample_size (如果有变量定义)

# 业务逻辑
data <- NULL

# 判断文件是否存在并读取
if (exists("input_file") && file.exists(input_file)) {
  print(paste("Loading data from", input_file))
  data <- read.csv(input_file)
} else {
  print("Generating random data...")
  # 使用传入的变量 sample_size
  if (!exists("sample_size")) sample_size <- 100 
  
  x <- 1:sample_size
  y <- 2 * x + rnorm(sample_size)
  data <- data.frame(x=x, y=y)
}

# 打印统计信息 (会被捕获为 Text Output)
print("=== Summary ===")
print(summary(data))

# 绘图 (会被捕获为 Image Output)
# 注意：不需要写 png()，因为 wrapper.R 已经打开了 device
plot(data$x, data$y, main="Regression Analysis")
abline(lm(y ~ x, data=data), col="red")

print("Analysis Complete.")

```

---

## 6. 开发注意事项

1. **安全性**：
* **注入攻击**：在 `Wrapper Code` 拼接字符串变量时，务必小心。建议只允许传递 `Number` 类型的变量，或者对 `String` 进行严格的正则校验（只允许字母数字），防止用户传入 `"; system('rm -rf /'); "` 这种恶意代码。


2. **并发性能**：
* `ProcessBuilder` 是起独立的 OS 进程，开销较大。
* 建议在 `CodeRunnerService` 中使用 Java 的 `Semaphore` 或线程池来限制同时运行的 R 进程数量（例如限制为 CPU 核心数），防止把服务器内存跑崩。


3. **异常处理**：
* R 脚本的语法错误会输出到 stderr，需要确保 `redirectErrorStream(true)` 开启，否则日志里看不到报错信息。