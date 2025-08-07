# 🔧 New API 手动开发环境搭建

> 当自动化脚本因磁盘空间或其他问题失败时，使用此手动搭建指南

## 🚨 常见问题快速解决

### 磁盘空间不足
```bash
# 检查磁盘使用情况
df -h

# 清理系统缓存
sudo rm -rf /tmp/* /var/tmp/*
sudo apt-get clean
sudo apt-get autoremove

# 清理 Docker
docker system prune -f

# 清理 npm 缓存
npm cache clean --force
```

### 前端依赖冲突
```bash
cd web

# 修复 @lobehub/icons 版本冲突
sed -i 's/"@lobehub\/icons": "\^2\.[0-9]*\.[0-9]*"/"@lobehub\/icons": "^1.34.1"/g' package.json

# 清理并重新安装
rm -rf node_modules package-lock.json
npm install --legacy-peer-deps
```

## 📋 手动搭建步骤

### 1. 环境检查
```bash
# 检查必需软件版本
go version    # 需要 1.23.4+
node --version # 需要 18.0+
docker --version
docker-compose --version
```

### 2. 创建环境配置
```bash
# 复制环境变量模板
cp .env.dev .env

# 编辑配置（可选）
nano .env
```

### 3. 启动数据库服务
```bash
# 启动 MySQL 和 Redis
docker-compose -f docker-compose.dev.yml up -d mysql redis

# 等待服务启动（约30秒）
sleep 30

# 验证服务状态
docker-compose -f docker-compose.dev.yml ps
```

### 4. 安装后端依赖
```bash
# 安装 Go 依赖
go mod download
go mod tidy

# 安装热重载工具
go install github.com/cosmtrek/air@latest
```

### 5. 安装前端依赖
```bash
cd web

# 方法1：正常安装
npm install

# 如果失败，使用方法2：兼容模式
npm install --legacy-peer-deps

# 如果还失败，使用方法3：强制安装
npm install --force

# 返回项目根目录
cd ..
```

### 6. 启动开发服务

**终端1 - 启动后端：**
```bash
# 使用热重载（推荐）
air

# 或普通启动
go run main.go
```

**终端2 - 启动前端：**
```bash
cd web
npm run dev
```

## 🌐 验证安装

### 检查服务状态
```bash
# 检查端口占用
lsof -i :3000  # 后端
lsof -i :5173  # 前端
lsof -i :3306  # MySQL
lsof -i :6379  # Redis

# 检查 Docker 服务
docker ps
```

### 访问应用
- 前端：http://localhost:5173
- 后端：http://localhost:3000
- 数据库管理：http://localhost:8080 (可选)
- Redis 管理：http://localhost:8081 (可选)

## 🛠️ 可选管理工具

```bash
# 启动数据库和 Redis 管理界面
docker-compose -f docker-compose.dev.yml --profile tools up -d
```

## 🔧 常用命令

### 服务管理
```bash
# 启动所有 Docker 服务
docker-compose -f docker-compose.dev.yml up -d

# 停止所有 Docker 服务
docker-compose -f docker-compose.dev.yml down

# 查看服务日志
docker-compose -f docker-compose.dev.yml logs -f

# 重启特定服务
docker-compose -f docker-compose.dev.yml restart mysql
```

### 开发工具
```bash
# 格式化代码
go fmt ./...
cd web && npm run lint:fix

# 运行测试
go test ./...
cd web && npm test

# 构建项目
go build -o new-api .
cd web && npm run build
```

## 🐛 故障排除

### 后端无法启动
```bash
# 检查环境变量
cat .env

# 检查数据库连接
mysql -h localhost -P 3306 -u root -p123456

# 检查 Redis 连接
redis-cli -h localhost -p 6379 ping
```

### 前端无法启动
```bash
cd web

# 检查 Node.js 版本
node --version

# 清理并重新安装
rm -rf node_modules package-lock.json
npm cache clean --force
npm install --legacy-peer-deps
```

### 数据库连接失败
```bash
# 重启 MySQL 容器
docker restart new-api-mysql-dev

# 查看 MySQL 日志
docker logs new-api-mysql-dev

# 手动连接测试
docker exec -it new-api-mysql-dev mysql -u root -p123456
```

### 端口被占用
```bash
# 查找占用进程
lsof -i :3000

# 停止进程
kill -9 <PID>

# 或者修改端口
export PORT=3001
```

## 💡 优化建议

### 性能优化
- 使用 SSD 硬盘
- 增加内存到 8GB+
- 使用 yarn 或 pnpm 替代 npm

### 开发体验
- 安装 VS Code 并使用项目配置
- 使用 Git hooks 进行代码检查
- 配置代码自动格式化

### 资源管理
- 定期清理 Docker 镜像和容器
- 监控磁盘空间使用
- 使用 .gitignore 排除不必要文件

## 🆘 获取帮助

如果手动搭建仍然遇到问题：

1. 检查系统资源（磁盘空间、内存）
2. 更新软件版本到最新
3. 查看详细错误日志
4. 参考项目 Issues 或提交新问题

---

**💡 提示**: 手动搭建完成后，可以使用 `make` 命令简化日常开发工作流程。
