# Ubuntu Mysql8 配置文档

```bash
sudo mysql
```

```bash
-- 将 root 用户的密码修改为 'root'，并启用密码验证
ALTER USER 'root'@'localhost' IDENTIFIED WITH caching_sha2_password BY 'root';

-- 刷新权限使其生效
FLUSH PRIVILEGES;

-- 退出
EXIT;
```