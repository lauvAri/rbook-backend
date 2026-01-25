# =============================================
# R-Book 应用 Docker 镜像
# 基于 Ubuntu + Java 17 + R 语言环境
# 支持中文显示和中文字体
# =============================================

# 第一阶段：构建 Java 应用
FROM maven:3.9-eclipse-temurin-17 AS builder

WORKDIR /build

# 复制 pom.xml 并下载依赖（利用缓存）
COPY pom.xml .
RUN mvn dependency:go-offline -B

# 复制源码并构建
COPY src ./src
RUN mvn clean package -DskipTests -B

# =============================================
# 第二阶段：运行时镜像
# =============================================
FROM ubuntu:22.04

LABEL maintainer="R-Book Team"
LABEL description="R-Book Backend Service with R Language Support"

# 设置环境变量，避免交互式安装
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=zh_CN.UTF-8
ENV LANGUAGE=zh_CN:zh
ENV LC_ALL=zh_CN.UTF-8
ENV TZ=Asia/Shanghai

# 设置 CRAN 镜像
ENV CRAN_MIRROR=https://mirrors.tuna.tsinghua.edu.cn/CRAN/

WORKDIR /app

# =============================================
# 安装系统依赖
# =============================================
RUN apt-get update && apt-get install -y --no-install-recommends \
    # 基础工具
    ca-certificates \
    curl \
    wget \
    gnupg \
    locales \
    tzdata \
    # Java 17
    openjdk-17-jre-headless \
    # R 语言依赖
    software-properties-common \
    dirmngr \
    # 中文字体
    fonts-wqy-zenhei \
    fonts-wqy-microhei \
    fonts-noto-cjk \
    fontconfig \
    # R 图形依赖
    libcairo2-dev \
    libxt-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    # 其他 R 包编译依赖
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    && rm -rf /var/lib/apt/lists/*

# =============================================
# 配置中文环境
# =============================================
RUN locale-gen zh_CN.UTF-8 && \
    update-locale LANG=zh_CN.UTF-8 && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone

# =============================================
# 安装 R 语言
# =============================================
RUN wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | \
    gpg --dearmor -o /usr/share/keyrings/r-project.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/r-project.gpg] https://cloud.r-project.org/bin/linux/ubuntu jammy-cran40/" | \
    tee /etc/apt/sources.list.d/r-project.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends r-base r-base-dev && \
    rm -rf /var/lib/apt/lists/*

# =============================================
# 配置 R 语言中文支持
# =============================================
# 创建 R 配置文件
RUN mkdir -p /etc/R && \
    echo 'options(repos = c(CRAN = "https://mirrors.tuna.tsinghua.edu.cn/CRAN/"))' >> /etc/R/Rprofile.site && \
    echo 'invisible(Sys.setlocale("LC_ALL", "zh_CN.UTF-8"))' >> /etc/R/Rprofile.site && \
    echo 'options(encoding = "UTF-8")' >> /etc/R/Rprofile.site

# 刷新字体缓存
RUN fc-cache -fv

# =============================================
# 安装常用 R 包 (带重试和详细错误日志)
# =============================================
RUN R --vanilla --slave -e "\
packages <- c('jsonlite', 'ggplot2', 'dplyr', 'tidyr', 'scales', 'RColorBrewer', 'showtext'); \
mirrors <- c('https://mirrors.tuna.tsinghua.edu.cn/CRAN/', 'https://cloud.r-project.org/', 'https://cran.r-project.org/'); \
for (pkg in packages) { \
  installed <- FALSE; \
  for (mirror in mirrors) { \
    cat(sprintf('Installing %s from %s...\\n', pkg, mirror)); \
    tryCatch({ \
      install.packages(pkg, repos = mirror, dependencies = TRUE, quiet = TRUE); \
      if (require(pkg, character.only = TRUE, quietly = TRUE)) { \
        cat(sprintf('OK: %s installed\\n', pkg)); \
        installed <- TRUE; \
        break; \
      } \
    }, error = function(e) { cat(sprintf('FAIL: %s\\n', e\$message)); }); \
  }; \
  if (!installed) cat(sprintf('WARNING: Failed to install %s\\n', pkg)); \
}; \
critical <- c('jsonlite', 'ggplot2'); \
missing <- critical[!sapply(critical, function(x) require(x, character.only=TRUE, quietly=TRUE))]; \
if (length(missing) > 0) { cat(sprintf('ERROR: Missing: %s\\n', paste(missing, collapse=', '))); q(status=1); }; \
cat('All critical packages installed\\n'); \
"

# 配置 showtext 以支持中文字体显示
RUN R --vanilla --slave -e "\
tryCatch({ \
  library(showtext); \
  font_add('wqy-zenhei', '/usr/share/fonts/truetype/wqy/wqy-zenhei.ttc'); \
  showtext_auto(); \
  cat('Showtext configured\\n'); \
}, error = function(e) { cat(sprintf('WARNING: showtext config failed: %s\\n', e\$message)); }); \
"

# =============================================
# 部署应用
# =============================================
# 从构建阶段复制 JAR 包
COPY --from=builder /build/target/*.jar app.jar

# 创建脚本存储目录
RUN mkdir -p /app/scripts

# 复制 R 脚本
COPY scripts/*.R /app/scripts/

# 设置脚本目录权限
RUN chmod -R 755 /app/scripts

# =============================================
# 运行配置
# =============================================
# 暴露端口
EXPOSE 8080

# JVM 参数
ENV JAVA_OPTS="-Xms256m -Xmx512m -Djava.security.egd=file:/dev/./urandom"

# 应用配置
ENV APP_CODERUNNER_SCRIPT_STORAGE_PATH=/app/scripts
ENV APP_CODERUNNER_R_EXECUTABLE=Rscript
ENV APP_CODERUNNER_TIMEOUT_SECONDS=60

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/actuator/health || exit 1

# 启动命令
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
