# ===================================================
# 线性回归分析脚本 (linear_regression.R)
# 由后端 RScriptExecutor 调用
# ===================================================

# === 由后端约定的变量 ===
# input_file - CSV 文件路径 (如果有文件上传)
# output_image - 输出图片路径 (由 wrapper 设置)
# sample_size - 样本数量 (用户可配置)
# noise_level - 噪声水平 (用户可配置)

# 业务逻辑
data <- NULL

# 判断文件是否存在并读取
if (exists("input_file") && file.exists(input_file)) {
  print(paste("Loading data from", input_file))
  data <- read.csv(input_file)
} else {
  print("Generating random data...")
  
  # 使用传入的变量 sample_size，如果不存在则使用默认值
  if (!exists("sample_size")) sample_size <- 100 
  if (!exists("noise_level")) noise_level <- 0.5
  
  # 生成模拟数据
  x <- 1:sample_size
  y <- 2 * x + rnorm(sample_size, sd = noise_level * sample_size)
  data <- data.frame(x = x, y = y)
}

# 打印数据概要 (会被捕获为 Text Output)
print("=== Data Summary ===")
print(summary(data))

# 执行线性回归
model <- lm(y ~ x, data = data)
print("=== Regression Summary ===")
print(summary(model))

# 绘图 (会被捕获为 Image Output)
# 注意：不需要写 png()，因为 wrapper.R 已经打开了 device
plot(data$x, data$y, 
     main = "Linear Regression Analysis",
     xlab = "X", 
     ylab = "Y",
     pch = 19,
     col = "blue")
abline(model, col = "red", lwd = 2)

# 添加图例
legend("topleft", 
       legend = c("Data Points", "Regression Line"),
       col = c("blue", "red"),
       pch = c(19, NA),
       lty = c(NA, 1),
       lwd = c(NA, 2))

print("Analysis Complete.")
