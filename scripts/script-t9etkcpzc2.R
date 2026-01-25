# ========================================================
# 脚本名称: BMI与胆固醇相关性分析
# ========================================================

library(ggplot2)

# --- 1. 接收变量 ---
if (!exists("bmi_threshold")) bmi_threshold <- 18.5
if (!exists("show_confidence")) show_confidence <- TRUE

# --- 2. 数据源处理 ---
data <- NULL

if (exists("input_file") && file.exists(input_file)) {
  # [模式 A]: 文件上传
  print(paste("正在读取上传的数据文件:", input_file))
  data <- read.csv(input_file)
  if (!all(c("bmi", "cholesterol") %in% names(data))) {
    stop("错误: CSV 文件必须包含 'bmi' 和 'cholesterol' 两列")
  }
} else {
  # [模式 B]: 模拟数据生成
  # 这里的逻辑与题目描述中的表格数据完全对应
  print("未检测到输入文件，正在基于模型 Y = 150 + 2.5X + e 生成模拟数据...")
  
  set.seed(42) # 固定随机种子，保证每次演示效果一致
  n <- 200
  
  # 生成 BMI (均值 25, 标准差 4)
  bmi <- rnorm(n, mean=25, sd=4)
  
  # 生成胆固醇 (严格遵循题目公式：150 + 2.5*bmi + 噪音)
  noise <- rnorm(n, mean=0, sd=15) # 噪音
  cholesterol <- 150 + 2.5 * bmi + noise
  
  data <- data.frame(bmi=bmi, cholesterol=cholesterol)
  
  # 打印前几行数据供用户在日志中核对
  print("=== 模拟数据预览 (前 5 行) ===")
  print(head(data, 5))
}

# --- 3. 数据过滤 ---
# 替换变量测试点：使用 bmi_threshold
data_filtered <- subset(data, bmi >= as.numeric(bmi_threshold))
print(paste("已过滤 BMI <", bmi_threshold, "的数据。剩余记录:", nrow(data_filtered)))

# --- 4. 统计分析 ---
model <- lm(cholesterol ~ bmi, data=data_filtered)
print("=== 线性回归结果 ===")
print(summary(model))

# --- 5. 绘图 ---
p <- ggplot(data_filtered, aes(x=bmi, y=cholesterol)) +
  geom_point(alpha=0.5, color="#0984e3") + 
  geom_smooth(method="lm", color="#d63031", se=as.logical(show_confidence)) +
  labs(
    title = "BMI 与 胆固醇水平回归分析",
    subtitle = paste("拟合公式: y =", round(coef(model)[1], 1), "+", round(coef(model)[2], 2), "x"),
    x = "BMI (身体质量指数)",
    y = "Total Cholesterol (mg/dL)"
  ) +
  theme_minimal() +
  # 在图上标注题目描述中的理论公式，方便对比
  annotate("text", x=min(data_filtered$bmi), y=max(data_filtered$cholesterol), 
           label="理论模型: Y = 150 + 2.5X", hjust=0, vjust=1, color="darkgreen", size=4)

print(p)