# ===================================================
# 基础统计分析脚本 (basic_stats.R)
# 由后端 RScriptExecutor 调用
# ===================================================

# === 由后端约定的变量 ===
# input_file - CSV 文件路径

# 读取数据
if (exists("input_file") && file.exists(input_file)) {
  print(paste("Loading data from", input_file))
  data <- read.csv(input_file)
} else {
  print("No input file provided. Generating sample data...")
  data <- data.frame(
    value = c(23, 45, 67, 89, 12, 34, 56, 78, 90, 21,
              43, 65, 87, 9, 32, 54, 76, 98, 10, 33)
  )
}

# 打印数据预览
print("=== Data Preview (first 10 rows) ===")
print(head(data, 10))

# 计算基本统计量
print("=== Basic Statistics ===")
print(summary(data))

# 对数值列计算额外统计量
numeric_cols <- sapply(data, is.numeric)
if (any(numeric_cols)) {
  print("=== Detailed Statistics for Numeric Columns ===")
  for (col_name in names(data)[numeric_cols]) {
    col_data <- data[[col_name]]
    cat("\n--- Column:", col_name, "---\n")
    cat("Mean:", mean(col_data, na.rm = TRUE), "\n")
    cat("Median:", median(col_data, na.rm = TRUE), "\n")
    cat("Std Dev:", sd(col_data, na.rm = TRUE), "\n")
    cat("Variance:", var(col_data, na.rm = TRUE), "\n")
    cat("Min:", min(col_data, na.rm = TRUE), "\n")
    cat("Max:", max(col_data, na.rm = TRUE), "\n")
    cat("Range:", max(col_data, na.rm = TRUE) - min(col_data, na.rm = TRUE), "\n")
  }
  
  # 绘制直方图 (取第一个数值列)
  first_numeric_col <- names(data)[numeric_cols][1]
  hist(data[[first_numeric_col]], 
       main = paste("Histogram of", first_numeric_col),
       xlab = first_numeric_col,
       col = "steelblue",
       border = "white")
}

print("Basic Statistics Analysis Complete.")
