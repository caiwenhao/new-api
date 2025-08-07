# 🛠️ New API 开发环境指南

> 本文档专门针对 New API 项目的开发环境搭建和日常开发工作流程。

## 📋 目录

- [快速开始](#-快速开始)
- [环境要求](#-环境要求)
- [项目结构](#-项目结构)
- [开发工作流](#-开发工作流)
- [配置说明](#-配置说明)
- [常用命令](#-常用命令)
- [调试指南](#-调试指南)
- [测试指南](#-测试指南)
- [常见问题](#-常见问题)

## 🚀 快速开始

### 一键启动
```bash
# 克隆项目
git clone https://github.com/Calcium-Ion/new-api.git
cd new-api

# 一键设置开发环境
make dev-setup
# 或者
./scripts/start-dev.sh

# 启动后端（新终端）
make dev-backend

# 启动前端（新终端）
make dev-frontend
```

### 访问应用
- 🎨 前端：http://localhost:5173
- 🔧 后端：http://localhost:3000
- 🗄️ 数据库管理：http://localhost:8080
- 📊 Redis 管理：http://localhost:8081

## 🔧 环境要求

### 必需软件
| 软件 | 版本要求 | 说明 |
|------|----------|------|
| Go | 1.23.4+ | 后端开发语言 |
| Node.js | 18.0+ | 前端开发环境 |
| Docker | 20.0+ | 容器化服务 |
| Docker Compose | 2.0+ | 多容器编排 |
| Git | 最新版 | 版本控制 |

### 推荐工具
- **VS Code** - 推荐的 IDE
- **Air** - Go 热重载工具（自动安装）
- **Make** - 任务自动化工具

## 📁 项目结构

```
new-api/
├── 🎨 前端 (React + Vite)
│   └── web/
│       ├── src/                # 源代码
│       ├── public/             # 静态资源
│       ├── package.json        # 依赖配置
│       └── vite.config.js      # 构建配置
│
├── 🔧 后端 (Go + Gin)
│   ├── controller/             # 控制器层
│   ├── model/                  # 数据模型层
│   ├── service/                # 业务逻辑层
│   ├── middleware/             # 中间件
│   ├── router/                 # 路由配置
│   ├── common/                 # 公共工具
│   ├── main.go                 # 应用入口
│   └── go.mod                  # Go 模块配置
│
├── 🐳 开发环境
│   ├── docker-compose.dev.yml  # 开发环境 Docker 配置
│   ├── .env.dev                # 环境变量模板
│   ├── .air.toml               # 热重载配置
│   └── scripts/                # 开发脚本
│       ├── start-dev.sh        # 启动脚本
│       ├── stop-dev.sh         # 停止脚本
│       └── init-dev-db.sql     # 数据库初始化
│
├── 🔧 IDE 配置
│   └── .vscode/                # VS Code 配置
│       ├── settings.json       # 编辑器设置
│       ├── extensions.json     # 推荐插件
│       ├── launch.json         # 调试配置
│       └── tasks.json          # 任务配置
│
└── 📚 文档
    ├── docs/local-development-setup.md  # 详细搭建指南
    ├── QUICK_START.md                   # 快速开始
    └── README.dev.md                    # 本文档
```

## 🔄 开发工作流

### 日常开发流程

1. **启动开发环境**
   ```bash
   make dev-start    # 启动 MySQL + Redis
   ```

2. **启动应用服务**
   ```bash
   # 终端 1：后端热重载
   make dev-backend
   
   # 终端 2：前端开发服务器
   make dev-frontend
   ```

3. **开发代码**
   - 后端代码修改会自动重启（Air 热重载）
   - 前端代码修改会自动刷新（Vite HMR）

4. **提交前检查**
   ```bash
   make dev-format   # 格式化代码
   make dev-test     # 运行测试
   ```

### 分支开发流程

```bash
# 创建功能分支
git checkout -b feature/new-feature

# 开发完成后
make dev-format
make dev-test
git add .
git commit -m "feat: add new feature"
git push origin feature/new-feature

# 创建 Pull Request
```

## ⚙️ 配置说明

### 环境变量配置

开发环境使用 `.env` 文件配置，主要配置项：

```env
# 基础配置
PORT=3000
DEBUG=true
GIN_MODE=debug

# 数据库配置
SQL_DSN=root:123456@tcp(localhost:3306)/new-api?parseTime=true

# Redis 配置
REDIS_CONN_STRING=redis://localhost:6379/0

# 安全配置（开发环境）
SESSION_SECRET=dev_session_secret_change_in_production
```

### 数据库配置

开发环境使用 Docker 运行的 MySQL：
- **主机**: localhost
- **端口**: 3306
- **用户**: root
- **密码**: 123456
- **数据库**: new-api

### 前端代理配置

前端开发服务器自动代理 API 请求到后端：
```javascript
// vite.config.js
server: {
  proxy: {
    '/api': 'http://localhost:3000',
    '/mj': 'http://localhost:3000',
    '/pg': 'http://localhost:3000'
  }
}
```

## 📝 常用命令

### Make 命令

| 命令 | 说明 |
|------|------|
| `make dev-setup` | 一键设置开发环境 |
| `make dev-start` | 启动开发服务（MySQL + Redis） |
| `make dev-stop` | 停止开发服务 |
| `make dev-backend` | 启动后端热重载 |
| `make dev-frontend` | 启动前端开发服务器 |
| `make dev-deps` | 安装开发依赖 |
| `make dev-test` | 运行所有测试 |
| `make dev-format` | 格式化代码 |
| `make help` | 显示所有可用命令 |

### Docker 命令

```bash
# 启动开发服务
docker-compose -f docker-compose.dev.yml up -d

# 查看服务状态
docker-compose -f docker-compose.dev.yml ps

# 查看日志
docker-compose -f docker-compose.dev.yml logs -f

# 停止服务
docker-compose -f docker-compose.dev.yml down

# 启动管理工具
docker-compose -f docker-compose.dev.yml --profile tools up -d
```

### Go 命令

```bash
# 热重载启动
air

# 普通启动
go run main.go

# 构建
go build -o new-api .

# 测试
go test ./...

# 格式化
go fmt ./...

# 依赖管理
go mod tidy
```

### 前端命令

```bash
cd web

# 安装依赖
npm install

# 开发服务器
npm run dev

# 构建
npm run build

# 测试
npm test

# 代码检查
npm run lint
npm run lint:fix
```

## 🐛 调试指南

### VS Code 调试

1. **后端调试**
   - 按 `F5` 启动调试
   - 设置断点
   - 支持变量查看和调用栈

2. **前端调试**
   - 使用浏览器开发者工具
   - VS Code 中安装 Debugger for Chrome

### 日志调试

```bash
# 查看应用日志
tail -f logs/new-api.log

# 查看 Docker 服务日志
make dev-logs

# 查看特定服务日志
docker logs new-api-mysql-dev
docker logs new-api-redis-dev
```

## 🧪 测试指南

### 后端测试

```bash
# 运行所有测试
go test ./...

# 运行特定包测试
go test ./model

# 运行测试并显示覆盖率
go test -cover ./...

# 运行基准测试
go test -bench=. ./...
```

### 前端测试

```bash
cd web

# 运行测试
npm test

# 运行测试并生成覆盖率
npm run test:coverage

# 运行 E2E 测试
npm run test:e2e
```

## ❓ 常见问题

### 端口冲突

**问题**: 端口被占用
```bash
# 查看端口占用
lsof -i :3000
lsof -i :5173

# 停止占用进程
kill -9 <PID>
```

### 数据库连接失败

**问题**: 无法连接数据库
```bash
# 检查 MySQL 状态
docker ps | grep mysql

# 重启 MySQL
docker-compose -f docker-compose.dev.yml restart mysql

# 查看 MySQL 日志
docker logs new-api-mysql-dev
```

### Go 模块问题

**问题**: 依赖下载失败
```bash
# 清理模块缓存
go clean -modcache

# 设置代理（中国大陆）
go env -w GOPROXY=https://goproxy.cn,direct

# 重新下载
go mod download
```

### 前端依赖问题

**问题**: npm 安装失败
```bash
cd web

# 清理缓存
npm cache clean --force

# 删除 node_modules
rm -rf node_modules package-lock.json

# 重新安装
npm install
```

### 热重载不工作

**问题**: 代码修改后不自动重启
```bash
# 检查 Air 配置
cat .air.toml

# 重新安装 Air
go install github.com/cosmtrek/air@latest

# 手动重启
air
```

## 📚 相关文档

- [详细开发环境搭建指南](docs/local-development-setup.md)
- [快速开始指南](QUICK_START.md)
- [项目主 README](README.md)
- [官方文档](https://docs.newapi.pro/)

---

**💡 提示**: 如果遇到问题，请先查看本文档的常见问题部分，或者查看详细的开发环境搭建指南。
