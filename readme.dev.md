```bash
# 构建基础镜像，命名为 r-book-base:latest
docker build -f Dockerfile.base -t r-book-base:latest .
```

```bash
# 1. 本地构建 JAR
./mvnw clean package -DskipTests

# 2. 使用开发配置构建和启动
docker compose -f docker-compose.dev.yml up -d --build
```

```bash
# 查看日志
docker logs -f r-book-app
```

```bash
# 停止容器（保留数据）
docker compose -f docker-compose.dev.yml stop

# 停止并删除容器（保留数据卷）
docker compose -f docker-compose.dev.yml down

# 停止并删除容器 + 数据卷（清空所有数据）
docker compose -f docker-compose.dev.yml down -v
```