# 🚀 New API 快速开始指南

## 📋 一键启动开发环境

### 前提条件检查
确保已安装以下软件：
- **Go** 1.23.4+
- **Node.js** 18.0+
- **Docker** & **Docker Compose**

### 🎯 快速启动（推荐）

```bash
# 1. 克隆项目
git clone https://github.com/Calcium-Ion/new-api.git
cd new-api

# 2. 一键启动开发环境
./scripts/start-dev.sh
```

启动脚本会自动：
- ✅ 检查环境依赖
- ✅ 创建配置文件
- ✅ 启动 MySQL 和 Redis
- ✅ 安装 Go 和前端依赖
- ✅ 安装热重载工具

### 🔧 手动启动服务

启动脚本完成后，需要手动启动前后端服务：

```bash
# 终端1：启动后端（热重载）
air

# 终端2：启动前端
cd web && npm run dev
```

### 🌐 访问地址

| 服务 | 地址 | 说明 |
|------|------|------|
| 🎨 前端界面 | http://localhost:5173 | React 开发服务器 |
| 🔧 后端 API | http://localhost:3000 | Go API 服务器 |
| 🗄️ phpMyAdmin | http://localhost:8080 | 数据库管理（可选） |
| 📊 Redis Commander | http://localhost:8081 | Redis 管理（可选） |

### 🛠️ 管理工具（可选）

启动数据库管理工具：
```bash
docker-compose -f docker-compose.dev.yml --profile tools up -d
```

## 📁 项目结构

```
new-api/
├── 📂 web/                 # 前端代码 (React + Vite)
├── 📂 controller/          # 控制器
├── 📂 model/              # 数据模型
├── 📂 service/            # 业务逻辑
├── 📂 middleware/         # 中间件
├── 📂 router/             # 路由
├── 📂 common/             # 公共工具
├── 📂 scripts/            # 开发脚本
├── 📂 docs/               # 文档
├── 📄 main.go             # 入口文件
├── 📄 .env                # 环境配置
├── 📄 .air.toml           # 热重载配置
└── 📄 docker-compose.dev.yml  # 开发环境 Docker 配置
```

## 🔧 开发工作流

### 日常开发
```bash
# 启动完整开发环境
./scripts/start-dev.sh

# 在不同终端启动服务
air                    # 后端热重载
cd web && npm run dev  # 前端开发服务器
```

### 代码提交前
```bash
# 格式化代码
go fmt ./...
cd web && npm run lint:fix

# 运行测试
go test ./...
cd web && npm test
```

### 停止开发环境
```bash
# 停止所有服务
./scripts/stop-dev.sh

# 停止并删除数据（谨慎使用）
./scripts/stop-dev.sh --remove-data
```

## 🐛 常见问题

### 端口被占用
```bash
# 查看端口占用
lsof -i :3000  # 后端端口
lsof -i :5173  # 前端端口
lsof -i :3306  # MySQL 端口
lsof -i :6379  # Redis 端口

# 停止占用进程
kill -9 <PID>
```

### 数据库连接失败
```bash
# 检查 MySQL 状态
docker ps | grep mysql
docker logs new-api-mysql-dev

# 重启 MySQL
docker-compose -f docker-compose.dev.yml restart mysql
```

### Go 模块问题
```bash
# 清理并重新下载依赖
go clean -modcache
go mod download
go mod tidy
```

### 前端依赖问题
```bash
# 使用修复脚本（推荐）
./scripts/fix-frontend-deps.sh

# 或手动修复
cd web
rm -rf node_modules package-lock.json
npm install --legacy-peer-deps
```

### 磁盘空间不足
```bash
# 清理空间
docker system prune -f
npm cache clean --force
sudo apt-get clean

# 检查空间
df -h
```

## 🎯 VS Code 开发

项目已配置 VS Code 开发环境：

### 推荐插件
- Go 语言支持
- Prettier 代码格式化
- ESLint 代码检查
- Docker 支持
- GitLens Git 增强

### 调试配置
- `F5` 启动 Go 应用调试
- 断点调试支持
- 测试调试支持

### 任务快捷键
- `Ctrl+Shift+P` → `Tasks: Run Task`
  - `Start Full Dev Environment` - 启动完整开发环境
  - `go: build` - 构建 Go 应用
  - `npm: start frontend` - 启动前端
  - `docker: start dev services` - 启动 Docker 服务

## 📚 更多文档

- 📖 [详细开发环境搭建指南](docs/local-development-setup.md)
- 🔧 [环境变量配置说明](.env.dev)
- 🐳 [Docker 开发配置](docker-compose.dev.yml)
- 🔥 [热重载配置](.air.toml)

## 🆘 获取帮助

- 📋 [项目 README](README.md)
- 🌐 [官方文档](https://docs.newapi.pro/)
- 🐛 [问题反馈](https://github.com/Calcium-Ion/new-api/issues)
- 💬 [社区讨论](https://docs.newapi.pro/support/community-interaction)

---

**🎉 开发愉快！如有问题，请查看详细文档或提交 Issue。**
