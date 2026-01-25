# ============================================
# 新型降压药疗效对比分析 - 独立样本 T 检验
# ============================================
# 输入变量:
#   input_file - CSV文件路径 (包含 group, reduction 列)
#   conf_level - 置信水平 (数字, 如 0.95)
#   equal_var  - 是否假设方差相等 (布尔, TRUE/FALSE)
# ============================================

library(ggplot2)

# 读取数据
data <- read.csv(input_file)

# 验证列名
if (!all(c("group", "reduction") %in% names(data))) {
  stop("CSV 文件必须包含 'group' 和 'reduction' 列")
}

# 转换分组为因子
data$group <- as.factor(data$group)

# 获取分组信息
groups <- levels(data$group)
if (length(groups) != 2) {
  stop(paste("数据必须恰好包含两个分组，当前发现", length(groups), "个分组:", paste(groups, collapse=", ")))
}

cat("==============================================\n")
cat("       独立样本 T 检验分析结果\n")
cat("==============================================\n\n")

# 描述性统计
cat("【描述性统计】\n")
cat("----------------------------------------------\n")
for (g in groups) {
  subset_data <- data$reduction[data$group == g]
  cat(sprintf("分组: %s\n", g))
  cat(sprintf("  样本量: %d\n", length(subset_data)))
  cat(sprintf("  均值: %.4f\n", mean(subset_data)))
  cat(sprintf("  标准差: %.4f\n", sd(subset_data)))
  cat(sprintf("  最小值: %.4f\n", min(subset_data)))
  cat(sprintf("  最大值: %.4f\n", max(subset_data)))
  cat("\n")
}

# 执行 T 检验
cat("【T 检验结果】\n")
cat("----------------------------------------------\n")
test_type <- if (equal_var) "Student t-test (假设方差相等)" else "Welch t-test (不假设方差相等)"
cat(sprintf("检验类型: %s\n", test_type))
cat(sprintf("置信水平: %.2f%%\n\n", conf_level * 100))

res <- t.test(reduction ~ group, data = data, 
              conf.level = conf_level, 
              var.equal = equal_var)

cat(sprintf("t 统计量: %.4f\n", res$statistic))
cat(sprintf("自由度: %.2f\n", res$parameter))
cat(sprintf("p 值: %.6f\n", res$p.value))
cat(sprintf("%.0f%% 置信区间: [%.4f, %.4f]\n", 
            conf_level * 100, res$conf.int[1], res$conf.int[2]))

# 显著性判断
alpha <- 1 - conf_level
cat("\n【统计推断】\n")
cat("----------------------------------------------\n")
if (res$p.value < alpha) {
  cat(sprintf("✓ p值 (%.6f) < 显著性水平 (%.2f)\n", res$p.value, alpha))
  cat("结论: 拒绝原假设，两组均值存在显著差异\n")
} else {
  cat(sprintf("✗ p值 (%.6f) >= 显著性水平 (%.2f)\n", res$p.value, alpha))
  cat("结论: 不能拒绝原假设，两组均值无显著差异\n")
}

cat("\n==============================================\n")

# 绘制箱线图 + 抖动点
p <- ggplot(data, aes(x = group, y = reduction, fill = group)) +
  geom_boxplot(alpha = 0.7, outlier.shape = NA) +
  geom_jitter(width = 0.2, size = 2.5, alpha = 0.8) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),
    legend.position = "none"
  ) +
  labs(
    title = "不同组别血压下降幅度对比",
    x = "分组",
    y = "血压下降值 (mmHg)"
  ) +
  scale_fill_brewer(palette = "Set2")

print(p)
