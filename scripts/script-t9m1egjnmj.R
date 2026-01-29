# 变量描述
# input_file 输入文件
# yates_correction 是否开启Yates连续性校正，默认为 FALSE

# ========== 1. 数据加载 ==========
data <- read.csv(input_file)

# ========== 2. 卡方检验 ==========
tbl <- table(data$group, data$x)
result <- chisq.test(tbl, correct = yates_correction)

# ========== 3. 结果输出 ==========
cat("yates_correction =", yates_correction,
    "| χ² =", round(result$statistic, 3), 
    "| p =", format.pval(result$p.value, digits=3),
    "|", ifelse(result$p.value < 0.05, "✅显著", "❌不显著"), "\n")

# ========== 4. 多图输出（每条绘图命令生成独立图片）==========

# 图1: 分组条形图（基础R）
barplot(tbl, beside = TRUE,
        col = c("#5470C6", "#EE6666"),
        main = "频数分布（分组）",
        xlab = "组别", ylab = "频数",
        legend.text = colnames(tbl),
        args.legend = list(x = "topright", bty = "n"))

# 图2: 堆叠比例图（基础R）
barplot(prop.table(tbl, margin = 1) * 100,
        col = c("#5470C6", "#EE6666"),
        main = "组内构成比例",
        xlab = "组别", ylab = "百分比(%)",
        legend.text = colnames(tbl),
        args.legend = list(x = "topright", bty = "n"))

# 图3: 马赛克图（基础R）
mosaicplot(tbl, 
           main = "列联表马赛克图",
           xlab = "组别", ylab = "类别",
           color = TRUE,
           las = 2)

# 图4: ggplot2美化图（需自动安装包）==========
# 后端会自动检测并安装ggplot2，此处直接使用
library(ggplot2)

# 转换为数据框（ggplot2要求）
df <- as.data.frame(tbl)
colnames(df) <- c("组别", "类别", "频数")
num_categories <- length(unique(df$类别))
colors <- hcl.colors(num_categories, "Set2")  # R 3.6+ 内置

p <- ggplot(df, aes(x = 组别, y = 频数, fill = 类别)) +
  geom_col(position = "dodge", width = 0.7) +
  scale_fill_manual(values = colors) +  # ✅ 动态匹配类别数
  labs(title = "ggplot2美化条形图", x = "组别", y = "频数") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"))

print(p)