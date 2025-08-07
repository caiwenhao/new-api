# New API Makefile
# 支持生产构建和开发环境

FRONTEND_DIR = ./web
BACKEND_DIR = .
DOCKER_COMPOSE_DEV = docker-compose.dev.yml

# 默认目标
.PHONY: all build-frontend start-backend help

# 生产构建（原有功能）
all: build-frontend start-backend

build-frontend:
	@echo "Building frontend for production..."
	@cd $(FRONTEND_DIR) && bun install && DISABLE_ESLINT_PLUGIN='true' VITE_REACT_APP_VERSION=$(cat VERSION) bun run build

start-backend:
	@echo "Starting backend server..."
	@cd $(BACKEND_DIR) && go run main.go &

# 开发环境相关命令
.PHONY: dev-setup dev-start dev-stop dev-clean dev-logs dev-status
.PHONY: dev-backend dev-frontend dev-deps dev-test dev-build dev-format
.PHONY: dev-fix-deps dev-cleanup-space

# 开发环境设置
dev-setup:
	@echo "Setting up development environment..."
	@./scripts/start-dev.sh

# 启动开发环境
dev-start:
	@echo "Starting development services..."
	@docker-compose -f $(DOCKER_COMPOSE_DEV) up -d

# 停止开发环境
dev-stop:
	@echo "Stopping development services..."
	@docker-compose -f $(DOCKER_COMPOSE_DEV) down

# 清理开发环境（包括数据）
dev-clean:
	@echo "Cleaning development environment..."
	@./scripts/stop-dev.sh --remove-data

# 查看开发环境日志
dev-logs:
	@docker-compose -f $(DOCKER_COMPOSE_DEV) logs -f

# 查看开发环境状态
dev-status:
	@docker-compose -f $(DOCKER_COMPOSE_DEV) ps

# 启动后端开发服务器（热重载）
dev-backend:
	@echo "Starting backend development server with hot reload..."
	@air

# 启动前端开发服务器
dev-frontend:
	@echo "Starting frontend development server..."
	@cd $(FRONTEND_DIR) && npm run dev

# 安装开发依赖
dev-deps:
	@echo "Installing development dependencies..."
	@go mod download && go mod tidy
	@cd $(FRONTEND_DIR) && npm install

# 运行测试
dev-test:
	@echo "Running tests..."
	@go test ./...
	@cd $(FRONTEND_DIR) && npm test

# 开发构建
dev-build:
	@echo "Building for development..."
	@go build -o new-api .
	@cd $(FRONTEND_DIR) && npm run build

# 格式化代码
dev-format:
	@echo "Formatting code..."
	@go fmt ./...
	@cd $(FRONTEND_DIR) && npm run lint:fix

# 修复前端依赖
dev-fix-deps:
	@echo "Fixing frontend dependencies..."
	@./scripts/fix-frontend-deps.sh

# 清理磁盘空间
dev-cleanup-space:
	@echo "Cleaning up disk space..."
	@docker system prune -f
	@npm cache clean --force
	@go clean -modcache
	@sudo rm -rf /tmp/* /var/tmp/* 2>/dev/null || true
	@echo "Disk space cleanup completed"

# 帮助信息
help:
	@echo "New API Makefile Commands:"
	@echo ""
	@echo "Production Commands:"
	@echo "  all              - Build frontend and start backend (production)"
	@echo "  build-frontend   - Build frontend for production"
	@echo "  start-backend    - Start backend server"
	@echo ""
	@echo "Development Commands:"
	@echo "  dev-setup        - Setup complete development environment"
	@echo "  dev-start        - Start development services (MySQL, Redis)"
	@echo "  dev-stop         - Stop development services"
	@echo "  dev-clean        - Clean development environment (remove data)"
	@echo "  dev-logs         - View development services logs"
	@echo "  dev-status       - Show development services status"
	@echo "  dev-backend      - Start backend with hot reload"
	@echo "  dev-frontend     - Start frontend development server"
	@echo "  dev-deps         - Install development dependencies"
	@echo "  dev-test         - Run all tests"
	@echo "  dev-build        - Build for development"
	@echo "  dev-format       - Format all code"
	@echo "  dev-fix-deps     - Fix frontend dependency conflicts"
	@echo "  dev-cleanup-space - Clean up disk space"
	@echo "  help             - Show this help message"
	@echo ""
	@echo "Quick Development Workflow:"
	@echo "  1. make dev-setup    # First time setup"
	@echo "  2. make dev-backend  # In terminal 1"
	@echo "  3. make dev-frontend # In terminal 2"
