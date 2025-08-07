# New API 本地开发环境搭建指南

## 📋 概述

本文档指导您搭建 New API 项目的本地开发环境，采用以下架构：
- **前端**：React + Vite 直接运行
- **后端**：Go + Gin 直接运行
- **数据库**：MySQL 8.2 通过 Docker 运行
- **缓存**：Redis 通过 Docker 运行

## 🛠️ 环境要求

### 必需软件
- **Go**: 1.23.4 或更高版本
- **Node.js**: 18.0 或更高版本
- **npm/yarn**: 最新版本
- **Docker**: 20.0 或更高版本
- **Docker Compose**: 2.0 或更高版本
- **Git**: 最新版本

### 系统要求
- 操作系统：Windows 10+、macOS 10.15+、Linux
- 内存：至少 4GB RAM
- 磁盘空间：至少 2GB 可用空间

## 📦 项目克隆

```bash
# 克隆项目
git clone https://github.com/Calcium-Ion/new-api.git
cd new-api
```

## 🐳 启动数据库和缓存服务

### 1. 创建开发环境 Docker Compose 文件

创建 `docker-compose.dev.yml` 文件：

```yaml
version: '3.8'

services:
  mysql:
    image: mysql:8.2
    container_name: new-api-mysql-dev
    restart: always
    ports:
      - "3306:3306"
    environment:
      MYSQL_ROOT_PASSWORD: 123456
      MYSQL_DATABASE: new-api
      MYSQL_USER: newapi
      MYSQL_PASSWORD: newapi123
    volumes:
      - mysql_dev_data:/var/lib/mysql
      - ./scripts/init.sql:/docker-entrypoint-initdb.d/init.sql
    command: --default-authentication-plugin=mysql_native_password

  redis:
    image: redis:7-alpine
    container_name: new-api-redis-dev
    restart: always
    ports:
      - "6379:6379"
    volumes:
      - redis_dev_data:/data

volumes:
  mysql_dev_data:
  redis_dev_data:
```

### 2. 启动数据库和缓存

```bash
# 启动 MySQL 和 Redis
docker-compose -f docker-compose.dev.yml up -d

# 查看服务状态
docker-compose -f docker-compose.dev.yml ps

# 查看日志（可选）
docker-compose -f docker-compose.dev.yml logs -f
```

### 3. 验证服务启动

```bash
# 测试 MySQL 连接
docker exec -it new-api-mysql-dev mysql -u root -p123456 -e "SHOW DATABASES;"

# 测试 Redis 连接
docker exec -it new-api-redis-dev redis-cli ping
```

## ⚙️ 后端开发环境配置

### 1. 安装 Go 依赖

```bash
# 在项目根目录下
go mod download
go mod tidy
```

### 2. 创建环境配置文件

创建 `.env` 文件：

```bash
# 复制示例配置文件
cp .env.example .env
```

编辑 `.env` 文件，配置开发环境：

```env
# 端口配置
PORT=3000

# 数据库配置
SQL_DSN=root:123456@tcp(localhost:3306)/new-api?parseTime=true&charset=utf8mb4

# Redis 配置
REDIS_CONN_STRING=redis://localhost:6379/0

# 调试配置
DEBUG=true
GIN_MODE=debug

# 会话密钥（开发环境）
SESSION_SECRET=dev_session_secret_change_in_production

# 其他开发配置
STREAMING_TIMEOUT=120
GENERATE_DEFAULT_TOKEN=true
ERROR_LOG_ENABLED=true
MEMORY_CACHE_ENABLED=true
SYNC_FREQUENCY=60

# 时区
TZ=Asia/Shanghai
```

### 3. 启动后端服务

```bash
# 方式1：直接运行
go run main.go

# 方式2：编译后运行
go build -o new-api
./new-api

# 方式3：使用 air 热重载（推荐开发时使用）
# 安装 air
go install github.com/cosmtrek/air@latest

# 创建 .air.toml 配置文件
air init

# 启动热重载
air
```

### 4. 验证后端启动

访问 http://localhost:3000/api/status 应该返回状态信息。

## 🎨 前端开发环境配置

### 1. 安装前端依赖

```bash
# 进入前端目录
cd web

# 安装依赖
npm install
# 或使用 yarn
yarn install
```

### 2. 启动前端开发服务器

```bash
# 启动开发服务器
npm run dev
# 或使用 yarn
yarn dev
```

前端开发服务器默认运行在 http://localhost:5173

### 3. 验证前端启动

访问 http://localhost:5173 应该能看到 New API 的前端界面。

## 🔧 开发工具配置

### VS Code 推荐插件

创建 `.vscode/extensions.json`：

```json
{
  "recommendations": [
    "golang.go",
    "bradlc.vscode-tailwindcss",
    "esbenp.prettier-vscode",
    "ms-vscode.vscode-json",
    "formulahendry.auto-rename-tag",
    "christian-kohler.path-intellisense"
  ]
}
```

### VS Code 工作区配置

创建 `.vscode/settings.json`：

```json
{
  "go.toolsManagement.checkForUpdates": "local",
  "go.useLanguageServer": true,
  "go.gopath": "",
  "go.goroot": "",
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.organizeImports": true
  },
  "[go]": {
    "editor.defaultFormatter": "golang.go"
  },
  "[javascript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[typescript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  }
}
```

## 🚀 开发流程

### 启动完整开发环境

```bash
# 1. 启动数据库和缓存
docker-compose -f docker-compose.dev.yml up -d

# 2. 启动后端（在项目根目录）
air  # 或 go run main.go

# 3. 启动前端（在 web 目录）
cd web && npm run dev
```

### 访问地址

- **前端开发服务器**: http://localhost:5173
- **后端 API 服务器**: http://localhost:3000
- **API 文档**: http://localhost:3000/swagger/index.html（如果启用）

### 开发端口说明

| 服务 | 端口 | 说明 |
|------|------|------|
| 前端开发服务器 | 5173 | Vite 默认端口 |
| 后端 API 服务器 | 3000 | Go 应用端口 |
| MySQL | 3306 | 数据库端口 |
| Redis | 6379 | 缓存端口 |

## 🔍 常见问题排查

### 数据库连接问题

```bash
# 检查 MySQL 是否启动
docker ps | grep mysql

# 检查 MySQL 日志
docker logs new-api-mysql-dev

# 手动连接测试
mysql -h localhost -P 3306 -u root -p123456
```

### Redis 连接问题

```bash
# 检查 Redis 是否启动
docker ps | grep redis

# 检查 Redis 日志
docker logs new-api-redis-dev

# 手动连接测试
redis-cli -h localhost -p 6379 ping
```

### Go 模块问题

```bash
# 清理模块缓存
go clean -modcache

# 重新下载依赖
go mod download

# 更新依赖
go mod tidy
```

### 前端依赖问题

```bash
cd web

# 清理缓存
npm cache clean --force

# 删除 node_modules
rm -rf node_modules package-lock.json

# 重新安装（如果遇到版本冲突）
npm install --legacy-peer-deps

# 或使用 yarn
rm -rf node_modules yarn.lock
yarn install
```

### 磁盘空间不足问题

如果遇到 `ENOSPC: no space left on device` 错误：

```bash
# 检查磁盘使用情况
df -h

# 清理系统缓存
sudo rm -rf /tmp/* /var/tmp/*
sudo apt-get clean
sudo apt-get autoremove

# 清理 Docker（如果使用）
docker system prune -f

# 清理 npm 缓存
npm cache clean --force

# 清理 Go 模块缓存
go clean -modcache

# 使用修复脚本
./scripts/fix-frontend-deps.sh
```

**替代方案（磁盘空间有限时）：**
1. 使用 `yarn` 替代 `npm`（通常占用更少空间）
2. 使用 `pnpm`（更节省磁盘空间）
3. 在云端开发环境中进行开发

## 🧪 测试环境

### 运行后端测试

```bash
# 运行所有测试
go test ./...

# 运行特定包的测试
go test ./model

# 运行测试并显示覆盖率
go test -cover ./...
```

### 运行前端测试

```bash
cd web

# 运行测试
npm test

# 运行测试并生成覆盖率报告
npm run test:coverage
```

## 📝 开发注意事项

1. **环境变量**: 开发环境的敏感信息不要提交到版本控制
2. **数据库迁移**: 数据库结构变更时注意备份数据
3. **API 兼容性**: 前后端 API 接口变更时注意版本兼容
4. **热重载**: 使用 air 进行后端热重载，提高开发效率
5. **代码格式化**: 提交前确保代码格式化正确

## 🛑 停止开发环境

```bash
# 停止前端开发服务器
# Ctrl+C 在前端终端

# 停止后端服务器
# Ctrl+C 在后端终端

# 停止数据库和缓存
docker-compose -f docker-compose.dev.yml down

# 停止并删除数据卷（谨慎使用）
docker-compose -f docker-compose.dev.yml down -v
```

---

## 📚 相关文档

- [项目 README](../README.md)
- [API 文档](https://docs.newapi.pro/api)
- [部署指南](https://docs.newapi.pro/installation)
- [环境变量配置](https://docs.newapi.pro/installation/environment-variables)
