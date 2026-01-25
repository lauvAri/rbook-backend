#!/usr/bin/env Rscript
# ============================================
# R 环境初始化脚本
# 用于设置镜像源并安装常用统计分析包
# 运行方式: sudo Rscript init_r_environment.R
# ============================================

cat("==============================================\n")
cat("       R 环境初始化\n")
cat("==============================================\n\n")

# 设置 CRAN 镜像源 (使用清华大学镜像)
options(repos = c(CRAN = "https://mirrors.tuna.tsinghua.edu.cn/CRAN/"))
cat("✓ 已设置 CRAN 镜像源: 清华大学\n\n")

# 定义需要安装的常用包
required_packages <- c(
  # 数据处理
  "jsonlite",      # JSON 处理
  "dplyr",         # 数据操作
  "tidyr",         # 数据整理
  "readr",         # 快速读取数据
  
  # 可视化
  "ggplot2",       # 绑图
  "scales",        # 图形刻度
  "RColorBrewer",  # 配色方案
  
  # 统计分析
  "stats",         # 基础统计 (通常已内置)
  "car",           # 回归分析辅助
  "psych",         # 心理学统计
  "survival",      # 生存分析
  
  # 报告生成
  "knitr",         # 动态报告
  "rmarkdown"      # Markdown 报告
)

cat("【安装常用包】\n")
cat("----------------------------------------------\n")

# 获取已安装的包
installed <- installed.packages()[, "Package"]

# 逐个检查并安装
for (pkg in required_packages) {
  if (pkg %in% installed) {
    cat(sprintf("  ✓ %s (已安装)\n", pkg))
  } else {
    cat(sprintf("  → 正在安装 %s ...\n", pkg))
    tryCatch({
      install.packages(pkg, quiet = TRUE)
      cat(sprintf("  ✓ %s (安装成功)\n", pkg))
    }, error = function(e) {
      cat(sprintf("  ✗ %s (安装失败: %s)\n", pkg, e$message))
    })
  }
}

cat("\n==============================================\n")
cat("       初始化完成\n")
cat("==============================================\n")

# 验证关键包
cat("\n【验证关键包】\n")
key_packages <- c("ggplot2", "jsonlite", "dplyr")
for (pkg in key_packages) {
  tryCatch({
    library(pkg, character.only = TRUE)
    cat(sprintf("  ✓ %s 可正常加载\n", pkg))
  }, error = function(e) {
    cat(sprintf("  ✗ %s 加载失败\n", pkg))
  })
}
