# 📋 New API 开发环境文件清单

本文档列出了为 New API 项目创建的所有开发环境相关文件及其用途。

## 📁 创建的文件列表

### 📚 文档文件

| 文件路径 | 用途 | 说明 |
|----------|------|------|
| `docs/local-development-setup.md` | 详细开发环境搭建指南 | 完整的本地开发环境搭建步骤和配置说明 |
| `QUICK_START.md` | 快速开始指南 | 一页式快速启动开发环境的指南 |
| `README.dev.md` | 开发环境专用 README | 开发工作流程和日常开发指南 |
| `docs/development-files-summary.md` | 本文档 | 开发环境文件清单和说明 |

### 🐳 Docker 配置

| 文件路径 | 用途 | 说明 |
|----------|------|------|
| `docker-compose.dev.yml` | 开发环境 Docker 配置 | MySQL、Redis 和管理工具的容器配置 |

### ⚙️ 环境配置

| 文件路径 | 用途 | 说明 |
|----------|------|------|
| `.env.dev` | 开发环境变量模板 | 包含所有开发环境需要的环境变量配置 |
| `.air.toml` | Go 热重载配置 | Air 工具的配置文件，支持代码热重载 |

### 🔧 脚本文件

| 文件路径 | 用途 | 说明 |
|----------|------|------|
| `scripts/start-dev.sh` | 开发环境启动脚本 | 一键启动完整开发环境的自动化脚本 |
| `scripts/stop-dev.sh` | 开发环境停止脚本 | 停止开发环境服务的脚本 |
| `scripts/init-dev-db.sql` | 数据库初始化脚本 | MySQL 容器启动时的初始化 SQL |

### 🎯 VS Code 配置

| 文件路径 | 用途 | 说明 |
|----------|------|------|
| `.vscode/settings.json` | VS Code 工作区设置 | 编辑器配置、格式化、语言特定设置 |
| `.vscode/extensions.json` | 推荐插件列表 | 开发所需的 VS Code 插件推荐 |
| `.vscode/launch.json` | 调试配置 | Go 应用的调试启动配置 |
| `.vscode/tasks.json` | 任务配置 | 常用开发任务的自动化配置 |

### 🛠️ 构建配置

| 文件路径 | 用途 | 说明 |
|----------|------|------|
| `makefile` | 任务自动化 | 更新了原有 Makefile，增加开发环境相关命令 |

## 🎯 文件功能详解

### 核心配置文件

#### `docker-compose.dev.yml`
- **MySQL 8.2**: 开发数据库，端口 3306
- **Redis 7**: 缓存服务，端口 6379  
- **phpMyAdmin**: 数据库管理界面，端口 8080
- **Redis Commander**: Redis 管理界面，端口 8081
- 健康检查和数据持久化配置

#### `.env.dev`
- 完整的开发环境变量模板
- 包含数据库连接、Redis 配置、调试选项
- 安全配置（开发环境专用密钥）
- 功能开关和性能调优参数

#### `.air.toml`
- Go 应用热重载配置
- 文件监控和自动重启
- 构建优化和日志配置

### 自动化脚本

#### `scripts/start-dev.sh`
- 环境依赖检查（Go、Node.js、Docker 版本）
- 端口占用检查
- 自动创建配置文件
- 启动 Docker 服务
- 安装项目依赖
- 安装开发工具（Air）

#### `scripts/stop-dev.sh`
- 停止前后端进程
- 停止 Docker 服务
- 可选数据清理
- 端口占用检查
- 临时文件清理

### VS Code 集成

#### 开发体验优化
- **语言支持**: Go、JavaScript/TypeScript、JSON、YAML
- **代码格式化**: 保存时自动格式化
- **调试支持**: 一键启动调试，断点调试
- **任务集成**: 快捷键执行常用任务
- **插件推荐**: 自动推荐必需插件

#### 调试配置
- Go 应用调试（支持环境变量）
- 测试调试
- 远程调试支持
- 进程附加调试

## 🚀 使用流程

### 首次设置
```bash
# 1. 克隆项目
git clone https://github.com/Calcium-Ion/new-api.git
cd new-api

# 2. 一键设置开发环境
./scripts/start-dev.sh
# 或使用 Make
make dev-setup
```

### 日常开发
```bash
# 启动基础服务
make dev-start

# 启动后端（终端1）
make dev-backend

# 启动前端（终端2）  
make dev-frontend
```

### 停止环境
```bash
# 停止所有服务
./scripts/stop-dev.sh
# 或使用 Make
make dev-stop
```

## 🔧 技术栈支持

### 后端 (Go)
- **框架**: Gin Web Framework
- **数据库**: MySQL 8.2 (开发), SQLite (可选)
- **缓存**: Redis 7
- **ORM**: GORM
- **热重载**: Air
- **测试**: Go 内置测试框架

### 前端 (React)
- **框架**: React 18
- **构建工具**: Vite
- **UI 库**: Semi UI
- **状态管理**: React Hooks
- **路由**: React Router
- **开发服务器**: Vite Dev Server (HMR)

### 开发工具
- **容器化**: Docker + Docker Compose
- **代码编辑**: VS Code (完整配置)
- **版本控制**: Git
- **任务自动化**: Make + Shell Scripts
- **包管理**: Go Modules + npm

## 📊 端口分配

| 服务 | 端口 | 用途 |
|------|------|------|
| 前端开发服务器 | 5173 | React + Vite |
| 后端 API 服务器 | 3000 | Go + Gin |
| MySQL 数据库 | 3306 | 开发数据库 |
| Redis 缓存 | 6379 | 缓存服务 |
| phpMyAdmin | 8080 | 数据库管理 |
| Redis Commander | 8081 | Redis 管理 |

## 🎯 特性亮点

### 🔥 热重载支持
- **后端**: Air 工具实现 Go 代码热重载
- **前端**: Vite HMR 实现 React 组件热更新

### 🐳 容器化开发
- 数据库和缓存服务容器化
- 应用代码本地运行，便于调试
- 一键启动/停止环境

### 🎨 IDE 集成
- VS Code 完整配置
- 调试支持
- 任务自动化
- 插件推荐

### 📋 自动化脚本
- 环境检查和设置
- 依赖安装
- 服务管理
- 清理工具

### 📚 完整文档
- 快速开始指南
- 详细搭建文档
- 开发工作流程
- 问题排查指南

## 🔄 维护说明

### 定期更新
- 依赖版本更新
- 配置优化
- 文档同步

### 扩展支持
- 新的开发工具集成
- 额外的数据库支持
- 更多 IDE 配置

---

**📝 注意**: 这些文件专为开发环境设计，生产环境请参考项目主 README 和官方部署文档。
