# 🔧 New API 开发环境问题排查指南

## 🚨 常见问题快速解决

### 1. 磁盘空间不足 (ENOSPC)

**症状**: `ENOSPC: no space left on device`

**快速解决**:
```bash
# 一键清理
make dev-cleanup-space

# 或手动清理
docker system prune -f
npm cache clean --force
go clean -modcache
sudo rm -rf /tmp/* /var/tmp/*
```

**检查空间**:
```bash
df -h
du -sh ~/.npm ~/.cache /tmp /var/tmp
```

### 2. 前端依赖冲突

**症状**: `ERESOLVE unable to resolve dependency tree`

**快速解决**:
```bash
# 使用修复脚本
make dev-fix-deps

# 或手动修复
cd web
rm -rf node_modules package-lock.json
npm install --legacy-peer-deps
```

**版本冲突处理**:
```bash
# 修复 @lobehub/icons 版本
sed -i 's/"@lobehub\/icons": "\^2\.[0-9]*\.[0-9]*"/"@lobehub\/icons": "^1.34.1"/g' web/package.json
```

### 3. 端口被占用

**症状**: `Error: listen EADDRINUSE :::3000`

**解决方法**:
```bash
# 查找占用进程
lsof -i :3000
lsof -i :5173

# 停止进程
kill -9 <PID>

# 或修改端口
export PORT=3001
```

### 4. 数据库连接失败

**症状**: `Error connecting to database`

**解决步骤**:
```bash
# 1. 检查 Docker 服务
docker ps | grep mysql

# 2. 重启 MySQL
docker restart new-api-mysql-dev

# 3. 查看日志
docker logs new-api-mysql-dev

# 4. 手动测试连接
mysql -h localhost -P 3306 -u root -p123456
```

### 5. Redis 连接失败

**症状**: `Redis connection failed`

**解决步骤**:
```bash
# 1. 检查 Redis 服务
docker ps | grep redis

# 2. 重启 Redis
docker restart new-api-redis-dev

# 3. 测试连接
redis-cli -h localhost -p 6379 ping
```

### 6. Go 模块问题

**症状**: `go: module not found`

**解决方法**:
```bash
# 清理模块缓存
go clean -modcache

# 设置代理（中国大陆）
go env -w GOPROXY=https://goproxy.cn,direct

# 重新下载
go mod download
go mod tidy
```

### 7. 热重载不工作

**症状**: 代码修改后不自动重启

**解决方法**:
```bash
# 重新安装 Air
go install github.com/cosmtrek/air@latest

# 检查配置
cat .air.toml

# 手动重启
pkill air
air
```

## 🔍 诊断工具

### 系统状态检查
```bash
# 检查系统资源
df -h                    # 磁盘空间
free -h                  # 内存使用
top                      # CPU 使用

# 检查网络端口
netstat -tulpn | grep :3000
netstat -tulpn | grep :5173
```

### 服务状态检查
```bash
# Docker 服务
docker ps
docker-compose -f docker-compose.dev.yml ps

# 进程状态
ps aux | grep air
ps aux | grep node
ps aux | grep mysql
```

### 日志查看
```bash
# 应用日志
tail -f logs/new-api.log

# Docker 服务日志
docker logs new-api-mysql-dev
docker logs new-api-redis-dev

# 系统日志
journalctl -f
```

## 🛠️ 环境重置

### 完全重置开发环境
```bash
# 1. 停止所有服务
./scripts/stop-dev.sh --all

# 2. 清理数据（谨慎使用）
./scripts/stop-dev.sh --remove-data

# 3. 清理磁盘空间
make dev-cleanup-space

# 4. 重新设置
./scripts/start-dev.sh
```

### 重置前端环境
```bash
cd web
rm -rf node_modules package-lock.json .next dist
npm cache clean --force
npm install --legacy-peer-deps
```

### 重置后端环境
```bash
go clean -cache
go clean -modcache
rm -f new-api
go mod download
go mod tidy
```

## 📋 环境验证清单

### 基础环境
- [ ] Go 版本 >= 1.23.4
- [ ] Node.js 版本 >= 18.0
- [ ] Docker 正常运行
- [ ] Docker Compose 可用
- [ ] 磁盘空间 > 2GB

### 服务状态
- [ ] MySQL 容器运行中 (端口 3306)
- [ ] Redis 容器运行中 (端口 6379)
- [ ] 后端服务启动 (端口 3000)
- [ ] 前端服务启动 (端口 5173)

### 功能测试
- [ ] 数据库连接正常
- [ ] Redis 连接正常
- [ ] 前端页面可访问
- [ ] API 接口响应正常
- [ ] 热重载工作正常

## 🆘 获取帮助

### 自助排查步骤
1. 查看错误日志
2. 检查系统资源
3. 验证环境配置
4. 尝试重启服务
5. 查阅本文档

### 社区支持
- 📋 [项目 Issues](https://github.com/Calcium-Ion/new-api/issues)
- 📚 [官方文档](https://docs.newapi.pro/)
- 💬 [社区讨论](https://docs.newapi.pro/support/community-interaction)

### 提交问题时请包含
- 操作系统和版本
- 软件版本信息
- 完整错误日志
- 重现步骤
- 已尝试的解决方法

## 🔧 高级故障排除

### 网络问题
```bash
# 检查 DNS 解析
nslookup github.com

# 检查网络连接
ping 8.8.8.8

# 检查代理设置
echo $HTTP_PROXY
echo $HTTPS_PROXY
```

### 权限问题
```bash
# 检查文件权限
ls -la scripts/
ls -la .env

# 修复权限
chmod +x scripts/*.sh
chmod 644 .env
```

### 内存不足
```bash
# 检查内存使用
free -h
ps aux --sort=-%mem | head

# 清理内存
sudo sync
sudo sysctl vm.drop_caches=3
```

---

**💡 提示**: 大多数问题都可以通过重启服务或清理缓存解决。如果问题持续存在，请参考手动搭建指南或寻求社区帮助。
