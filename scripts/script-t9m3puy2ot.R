# ========== 1. 数据加载（使用后端注入的 input_file 变量）==========
data <- read.csv(input_file)

# ========== 2. 缺失值处理与数据检查 ==========
# 自动移除任一列含NA的行（教学场景推荐做法）
original_n <- nrow(data)
data_clean <- na.omit(data[, c("Male", "Female")])
cleaned_n <- nrow(data_clean)

cat("【数据质量报告】\n")
cat("原始样本量:", original_n, "\n")
cat("有效样本量:", cleaned_n, "\n")
if (original_n > cleaned_n) {
  cat("已自动移除", original_n - cleaned_n, "行含缺失值的记录\n")
}
cat("\n")

# ========== 3. 独立样本 t 检验（Welch's t-test，不假设方差齐性）==========
result <- t.test(data_clean$Male, data_clean$Female, var.equal = FALSE)

# ========== 4. 结果输出（教学友好格式）==========
cat("【t 检验结果】\n")
cat("──────────────────────────────────────\n")
cat("检验类型: 两独立样本 t 检验 (Welch 校正)\n")
cat("组1 (Male)  样本量 =", length(data_clean$Male), 
    "| 均值 =", round(mean(data_clean$Male), 2), 
    "| 标准差 =", round(sd(data_clean$Male), 2), "\n")
cat("组2 (Female)样本量 =", length(data_clean$Female), 
    "| 均值 =", round(mean(data_clean$Female), 2), 
    "| 标准差 =", round(sd(data_clean$Female), 2), "\n")
cat("──────────────────────────────────────\n")
cat("t 值 =", round(result$statistic, 3), "\n")
cat("自由度 =", round(result$parameter, 2), "\n")
cat("p 值 =", format.pval(result$p.value, digits = 3), "\n")
cat("95% 置信区间: [", 
    round(result$conf.int[1], 2), ",", 
    round(result$conf.int[2], 2), "]\n")
cat("均值差 (Male - Female) =", round(result$estimate[1] - result$estimate[2], 2), "\n")
cat("──────────────────────────────────────\n")

# 显著性判断
if (result$p.value < 0.05) {
  cat("结论: 两组均值存在显著差异 (p <", 
      ifelse(result$p.value < 0.001, "0.001", round(result$p.value, 3)), ")\n")
} else {
  cat("结论: 两组均值无显著差异 (p =", round(result$p.value, 3), ")\n")
}
cat("\n")

# ========== 5. 可视化（多图输出）==========

# 图1: 箱线图（展示分布与离群值）
boxplot(data_clean$Male, data_clean$Female,
        names = c("Male", "Female"),
        col = c("#5470C6", "#EE6666"),
        main = "两组数据分布对比",
        ylab = "测量值",
        notch = TRUE)  # 凹槽表示95%置信区间

# 图2: 均值与置信区间图（教学重点）
means <- c(mean(data_clean$Male), mean(data_clean$Female))
ses <- c(sd(data_clean$Male)/sqrt(length(data_clean$Male)),
         sd(data_clean$Female)/sqrt(length(data_clean$Female)))
groups <- c("Male", "Female")

plot(1:2, means, type = "n", 
     ylim = c(min(means - 2*ses), max(means + 2*ses)),
     xaxt = "n", xlab = "组别", ylab = "均值 ± 标准误",
     main = "均值差异与置信区间")
axis(1, at = 1:2, labels = groups)
segments(1:2, means - ses, 1:2, means + ses, lwd = 2)  # 标准误
segments(1:2 - 0.1, means - ses, 1:2 + 0.1, means - ses, lwd = 2)
segments(1:2 - 0.1, means + ses, 1:2 + 0.1, means + ses, lwd = 2)
points(1:2, means, pch = 19, cex = 1.5, col = c("#5470C6", "#EE6666"))
abline(h = means[1], lty = 2, col = "gray50")
abline(h = means[2], lty = 2, col = "gray50")
legend("topright", legend = groups, 
       fill = c("#5470C6", "#EE6666"), bty = "n")