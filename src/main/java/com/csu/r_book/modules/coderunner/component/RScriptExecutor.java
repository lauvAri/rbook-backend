package com.csu.r_book.modules.coderunner.component;

import com.csu.r_book.modules.coderunner.config.CodeRunnerProperties;
import com.csu.r_book.modules.coderunner.model.dto.ExecutionResultDTO;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.nio.file.attribute.BasicFileAttributes;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.TimeUnit;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * R 脚本执行器
 * 核心组件：负责调用 ProcessBuilder 执行 R 脚本
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class RScriptExecutor {

    private final CodeRunnerProperties properties;

    /**
     * 已安装包的缓存 (避免重复检测)
     */
    private final Set<String> installedPackagesCache = ConcurrentHashMap.newKeySet();

    /**
     * CRAN 镜像地址列表 (主镜像 + 备用镜像)
     */
    private static final String[] CRAN_MIRRORS = {
        "https://mirrors.tuna.tsinghua.edu.cn/CRAN/",  // 清华镜像
        "https://cloud.r-project.org/",                 // 官方镜像
        "https://cran.r-project.org/"                   // 官方备用镜像
    };

    /**
     * 提取 library() 或 require() 调用的正则
     */
    private static final Pattern PACKAGE_PATTERN = Pattern.compile(
            "(?:library|require)\\s*\\(\\s*[\"']?([a-zA-Z][a-zA-Z0-9.]*)([\"'])?\\s*(?:,|\\))",
            Pattern.MULTILINE
    );

    @PostConstruct
    public void init() {
        // 启动时刷新已安装包缓存
        refreshInstalledPackagesCache();
    }

    /**
     * 刷新已安装包缓存
     */
    public void refreshInstalledPackagesCache() {
        try {
            Set<String> packages = getInstalledPackages();
            installedPackagesCache.clear();
            installedPackagesCache.addAll(packages);
            log.info("Refreshed R packages cache, found {} packages", packages.size());
        } catch (Exception e) {
            log.warn("Failed to refresh R packages cache: {}", e.getMessage());
        }
    }

    /**
     * 获取当前已安装的 R 包列表
     */
    private Set<String> getInstalledPackages() throws IOException, InterruptedException {
        ProcessBuilder pb = new ProcessBuilder(
                properties.getRExecutable(),
                "-e",
                "cat(installed.packages()[,'Package'], sep='\\n')"
        );
        pb.redirectErrorStream(true);

        Process process = pb.start();
        boolean finished = process.waitFor(30, TimeUnit.SECONDS);

        if (!finished) {
            process.destroyForcibly();
            throw new IOException("Timeout while getting installed packages");
        }

        String output = new String(process.getInputStream().readAllBytes(), StandardCharsets.UTF_8);
        Set<String> packages = new HashSet<>();
        for (String line : output.split("\\n")) {
            String pkg = line.trim();
            if (!pkg.isEmpty() && !pkg.startsWith("Error") && !pkg.startsWith("Warning")) {
                packages.add(pkg);
            }
        }
        return packages;
    }

    /**
     * 从 R 脚本中提取依赖的包
     */
    private Set<String> extractRequiredPackages(String scriptContent) {
        Set<String> packages = new LinkedHashSet<>();
        Matcher matcher = PACKAGE_PATTERN.matcher(scriptContent);
        while (matcher.find()) {
            packages.add(matcher.group(1));
        }
        return packages;
    }

    /**
     * 检测并安装缺失的包
     *
     * @param packages 需要的包列表
     * @return 安装结果消息 (空表示全部已安装)
     */
    private String ensurePackagesInstalled(Set<String> packages) {
        if (packages.isEmpty()) {
            return "";
        }

        List<String> missingPackages = new ArrayList<>();
        for (String pkg : packages) {
            if (!installedPackagesCache.contains(pkg)) {
                missingPackages.add(pkg);
            }
        }

        if (missingPackages.isEmpty()) {
            return "";
        }

        log.info("Missing R packages detected: {}", missingPackages);
        StringBuilder installLog = new StringBuilder();
        installLog.append("[包管理] 检测到缺失的 R 包，正在安装...\n");

        for (String pkg : missingPackages) {
            try {
                installLog.append(String.format("[包管理] 安装 %s ...\n", pkg));
                boolean success = installPackage(pkg);
                if (success) {
                    installedPackagesCache.add(pkg);
                    installLog.append(String.format("[包管理] %s 安装成功\n", pkg));
                    log.info("Successfully installed R package: {}", pkg);
                } else {
                    installLog.append(String.format("[包管理] %s 安装失败\n", pkg));
                    log.warn("Failed to install R package: {}", pkg);
                }
            } catch (Exception e) {
                installLog.append(String.format("[包管理] %s 安装异常: %s\n", pkg, e.getMessage()));
                log.error("Error installing R package {}: {}", pkg, e.getMessage());
            }
        }

        return installLog.toString();
    }

    /**
     * 安装单个 R 包 (支持镜像重试和更详细的错误信息)
     */
    private boolean installPackage(String packageName) throws IOException, InterruptedException {
        // 尝试多个镜像
        for (int mirrorIdx = 0; mirrorIdx < CRAN_MIRRORS.length; mirrorIdx++) {
            String mirror = CRAN_MIRRORS[mirrorIdx];
            log.debug("Attempting to install package {} from mirror: {}", packageName, mirror);

            // 建立详细的安装命令，包括依赖检查和详细的错误报告
            String installCmd = String.format(
                    "options(repos=c(CRAN='%s')); " +
                    "options(warn=-1); " +  // 抑制警告
                    "result <- tryCatch({install.packages('%s', dependencies=TRUE, quiet=FALSE)}, " +
                    "  error=function(e){cat('ERROR:', e$message, '\\n'); FALSE}, " +
                    "  warning=function(w){cat('WARNING:', w$message, '\\n'); TRUE}); " +
                    "if(require('%s', quietly=TRUE)) cat('SUCCESS\\n') else cat('LOAD_FAILED\\n')",
                    mirror, packageName, packageName
            );

            ProcessBuilder pb = new ProcessBuilder(properties.getRExecutable(), "-e", installCmd);
            pb.redirectErrorStream(true);

            Process process = pb.start();
            // 包安装可能较慢，给 5 分钟超时
            boolean finished = process.waitFor(300, TimeUnit.SECONDS);

            if (!finished) {
                process.destroyForcibly();
                log.warn("Package installation timed out for {}, trying next mirror", packageName);
                continue;  // 尝试下一个镜像
            }

            int exitCode = process.exitValue();
            String output = new String(process.getInputStream().readAllBytes(), StandardCharsets.UTF_8);
            
            log.debug("Package {} installation attempt output:\n{}", packageName, output);

            // 检查是否安装成功（通过检查最后的输出）
            if (output.contains("SUCCESS")) {
                log.info("Successfully installed R package {} using mirror: {}", packageName, mirror);
                return true;
            }

            if (output.contains("ERROR") || output.contains("LOAD_FAILED")) {
                log.warn("Package {} installation failed with output: {}", packageName, output);
                if (mirrorIdx < CRAN_MIRRORS.length - 1) {
                    log.info("Trying alternative mirror for package {}", packageName);
                    continue;  // 尝试下一个镜像
                }
            } else if (exitCode != 0) {
                log.warn("Package {} installation exited with code {}, output: {}", packageName, exitCode, output);
                if (mirrorIdx < CRAN_MIRRORS.length - 1) {
                    continue;  // 尝试下一个镜像
                }
            }
        }

        log.error("Failed to install R package {} after trying all mirrors", packageName);
        return false;
    }

    /**
     * 执行 R 脚本
     *
     * @param scriptFilename R 脚本文件名
     * @param variables      变量参数
     * @param csvData        CSV 数据内容
     * @return 执行结果
     */
    public ExecutionResultDTO run(String scriptFilename, Map<String, Object> variables, String csvData) {
        long startTime = System.currentTimeMillis();
        Path workDir = null;
        StringBuilder packageInstallLog = new StringBuilder();

        try {
            // 0. 检查脚本文件是否存在，并提前检测包依赖
            Path targetScriptPath = Paths.get(properties.getScriptStoragePath(), scriptFilename);
            if (!Files.exists(targetScriptPath)) {
                log.error("Script file not found: {}", targetScriptPath);
                return ExecutionResultDTO.builder()
                        .success(false)
                        .error("Script file not found: " + scriptFilename)
                        .executionTime(System.currentTimeMillis() - startTime)
                        .build();
            }

            // 0.1 读取脚本内容并提取依赖的包
            String scriptContent = Files.readString(targetScriptPath, StandardCharsets.UTF_8);
            Set<String> requiredPackages = extractRequiredPackages(scriptContent);
            if (!requiredPackages.isEmpty()) {
                log.info("Script {} requires packages: {}", scriptFilename, requiredPackages);
                String installResult = ensurePackagesInstalled(requiredPackages);
                if (!installResult.isEmpty()) {
                    packageInstallLog.append(installResult).append("\n");
                }
            }

            // 1. 创建临时工作目录 (隔离每次执行)
            workDir = Files.createTempDirectory("r_exec_");
            log.info("Created temp directory: {}", workDir);

            // 2. 处理 CSV 输入
            if (StringUtils.hasText(csvData)) {
                Files.writeString(workDir.resolve("data.csv"), csvData);
                log.info("Written CSV data to data.csv");
            }

            // 3. 构建 Wrapper 脚本内容
            StringBuilder wrapperCode = new StringBuilder();

            // 3.1 注入变量
            if (variables != null && !variables.isEmpty()) {
                variables.forEach((key, value) -> {
                    // 安全检查：变量名只允许字母数字和下划线
                    if (!isValidVariableName(key)) {
                        log.warn("Invalid variable name: {}", key);
                        return;
                    }

                    String rValue = convertToRValue(value);
                    wrapperCode.append(String.format("%s <- %s\n", key, rValue));
                });
            }

            // 3.2 注入固定环境变量
            wrapperCode.append("input_file <- \"data.csv\"\n");
            wrapperCode.append("output_image <- \"plot.png\"\n");

            // 3.3 设置图片捕获 (R语言绘图重定向)
            wrapperCode.append("png(output_image, width=800, height=600)\n");

            // 3.4 调用实际脚本 (使用 source 运行目标代码，tryCatch 确保即使脚本出错也能关闭 device)
            String scriptPath = targetScriptPath.toAbsolutePath().toString().replace("\\", "/");
            wrapperCode.append(String.format(
                    "tryCatch({ source(\"%s\") }, finally = { dev.off() })",
                    scriptPath
            ));

            // 写入 wrapper.R
            Path wrapperPath = workDir.resolve("wrapper.R");
            Files.writeString(wrapperPath, wrapperCode.toString());
            log.info("Written wrapper script: {}", wrapperCode);

            // 4. 调用系统进程执行
            ProcessBuilder pb = new ProcessBuilder(properties.getRExecutable(), "wrapper.R");
            pb.directory(workDir.toFile());
            pb.redirectErrorStream(true); // 合并 stdout 和 stderr

            Process process = pb.start();

            // 设置超时
            boolean finished = process.waitFor(properties.getTimeoutSeconds(), TimeUnit.SECONDS);
            if (!finished) {
                process.destroyForcibly();
                log.warn("R script execution timed out");
                return ExecutionResultDTO.builder()
                        .success(false)
                        .error("Execution timed out after " + properties.getTimeoutSeconds() + " seconds")
                        .executionTime(System.currentTimeMillis() - startTime)
                        .build();
            }

            // 5. 收集结果
            // 5.1 读取控制台输出
            String logs = new String(process.getInputStream().readAllBytes(), StandardCharsets.UTF_8);

            // 5.2 构建输出列表
            List<ExecutionResultDTO.OutputItem> outputs = new ArrayList<>();

            // 添加包安装日志 (如果有)
            if (packageInstallLog.length() > 0) {
                outputs.add(ExecutionResultDTO.OutputItem.builder()
                        .type("text")
                        .content(packageInstallLog.toString())
                        .build());
            }

            // 添加脚本执行输出
            if (StringUtils.hasText(logs)) {
                outputs.add(ExecutionResultDTO.OutputItem.builder()
                        .type("text")
                        .content(logs)
                        .build());
            }

            // 5.3 读取图片 (如果生成了的话)
            Path imagePath = workDir.resolve("plot.png");
            if (Files.exists(imagePath) && Files.size(imagePath) > 0) {
                byte[] imgBytes = Files.readAllBytes(imagePath);
                String base64 = Base64.getEncoder().encodeToString(imgBytes);
                outputs.add(ExecutionResultDTO.OutputItem.builder()
                        .type("image")
                        .data(base64)
                        .format("png")
                        .caption("Result Plot")
                        .build());
                log.info("Generated image output");
            }

            // 6. 判断 R 脚本是否报错 (通过 exit code)
            int exitCode = process.exitValue();
            if (exitCode != 0) {
                log.warn("R process exited with code: {}", exitCode);
                return ExecutionResultDTO.builder()
                        .success(false)
                        .outputs(outputs)
                        .error("R process exited with code " + exitCode)
                        .executionTime(System.currentTimeMillis() - startTime)
                        .build();
            }

            log.info("R script executed successfully");
            return ExecutionResultDTO.builder()
                    .success(true)
                    .outputs(outputs)
                    .executionTime(System.currentTimeMillis() - startTime)
                    .build();

        } catch (Exception e) {
            log.error("R execution failed", e);
            return ExecutionResultDTO.builder()
                    .success(false)
                    .error(e.getMessage())
                    .executionTime(System.currentTimeMillis() - startTime)
                    .build();
        } finally {
            // 7. 清理临时目录 (非常重要！)
            if (workDir != null) {
                deleteDirectory(workDir);
            }
        }
    }

    /**
     * 验证变量名是否合法 (只允许字母数字和下划线)
     */
    private boolean isValidVariableName(String name) {
        return name != null && name.matches("^[a-zA-Z_][a-zA-Z0-9_]*$");
    }

    /**
     * 将 Java 对象转换为 R 语言的值表示
     * 自动识别数值、布尔值和字符串
     */
    private String convertToRValue(Object value) {
        if (value == null) {
            return "NULL";
        }

        // 已经是数值类型
        if (value instanceof Number) {
            return value.toString();
        }

        // 已经是布尔类型
        if (value instanceof Boolean) {
            return ((Boolean) value) ? "TRUE" : "FALSE";
        }

        String strValue = value.toString().trim();

        // 尝试解析为数值 (整数或浮点数)
        if (isNumeric(strValue)) {
            return strValue;
        }

        // 检查布尔字符串
        if ("true".equalsIgnoreCase(strValue)) {
            return "TRUE";
        }
        if ("false".equalsIgnoreCase(strValue)) {
            return "FALSE";
        }

        // 默认当作字符串处理，需要加引号
        String safeValue = sanitizeStringValue(strValue);
        return String.format("\"%s\"", safeValue);
    }

    /**
     * 检查字符串是否为数值（整数或浮点数）
     */
    private boolean isNumeric(String str) {
        if (str == null || str.isEmpty()) {
            return false;
        }
        try {
            Double.parseDouble(str);
            return true;
        } catch (NumberFormatException e) {
            return false;
        }
    }

    /**
     * 对字符串值进行安全处理，防止注入攻击
     */
    private String sanitizeStringValue(String value) {
        if (value == null) {
            return "";
        }
        // 转义双引号和反斜杠
        return value.replace("\\", "\\\\").replace("\"", "\\\"");
    }

    /**
     * 递归删除目录
     */
    private void deleteDirectory(Path path) {
        if (path == null || !Files.exists(path)) {
            return;
        }
        try {
            Files.walkFileTree(path, new SimpleFileVisitor<>() {
                @Override
                public FileVisitResult visitFile(Path file, BasicFileAttributes attrs) throws IOException {
                    Files.delete(file);
                    return FileVisitResult.CONTINUE;
                }

                @Override
                public FileVisitResult postVisitDirectory(Path dir, IOException exc) throws IOException {
                    Files.delete(dir);
                    return FileVisitResult.CONTINUE;
                }
            });
            log.debug("Deleted temp directory: {}", path);
        } catch (IOException e) {
            log.warn("Failed to delete temp directory: {}", path, e);
        }
    }
}
