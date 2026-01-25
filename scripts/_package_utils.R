# ============================================
# R 包管理工具函数
# 在其他脚本开头引入: source("_package_utils.R")
# ============================================

#' 使用多个镜像重试安装包
#' @param packages 需要的包名向量
#' @param mirrors CRAN 镜像地址列表 (优先级递减)
ensure_packages <- function(packages, mirrors = c(
    "https://mirrors.tuna.tsinghua.edu.cn/CRAN/",
    "https://cloud.r-project.org/",
    "https://cran.r-project.org/"
)) {
  
  install_with_retry <- function(pkg, mirrors) {
    for (mirror in mirrors) {
      message(sprintf("[包管理] 正在从 %s 安装 %s ...", mirror, pkg))
      
      tryCatch({
        install.packages(pkg, repos = mirror, dependencies = TRUE, quiet = TRUE)
        
        # 验证包是否成功加载
        if (require(pkg, quietly = TRUE, character.only = TRUE)) {
          message(sprintf("[包管理] ✓ %s 安装成功", pkg))
          return(TRUE)
        } else {
          message(sprintf("[包管理] ✗ %s 加载失败", pkg))
        }
      }, error = function(e) {
        message(sprintf("[包管理] ✗ %s 安装失败: %s", pkg, e$message))
      }, warning = function(w) {
        # 某些警告可以忽略
        message(sprintf("[包管理] ⚠ 警告: %s", w$message))
      })
    }
    
    return(FALSE)
  }
  
  # 检查每个包
  failed_packages <- character()
  
  for (pkg in packages) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      if (!install_with_retry(pkg, mirrors)) {
        failed_packages <- c(failed_packages, pkg)
      }
    } else {
      message(sprintf("[包管理] %s 已安装", pkg))
    }
  }
  
  # 如果有失败的包，报错
  if (length(failed_packages) > 0) {
    stop(sprintf("[包管理] 无法安装必需的包: %s", paste(failed_packages, collapse = ", ")))
  }
  
  message("[包管理] 所有必需的包已就绪")
  return(invisible(TRUE))
}
