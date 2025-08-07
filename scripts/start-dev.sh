#!/bin/bash

# New API 开发环境启动脚本
# 用于快速启动完整的开发环境

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查命令是否存在
check_command() {
    if ! command -v $1 &> /dev/null; then
        log_error "$1 未安装或不在 PATH 中"
        return 1
    fi
    return 0
}

# 检查端口是否被占用
check_port() {
    local port=$1
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        log_warning "端口 $port 已被占用"
        return 1
    fi
    return 0
}

# 等待服务启动
wait_for_service() {
    local host=$1
    local port=$2
    local service_name=$3
    local max_attempts=30
    local attempt=1

    log_info "等待 $service_name 启动..."

    while [ $attempt -le $max_attempts ]; do
        if nc -z $host $port 2>/dev/null; then
            log_success "$service_name 已启动"
            return 0
        fi

        echo -n "."
        sleep 2
        attempt=$((attempt + 1))
    done

    log_error "$service_name 启动超时"
    return 1
}

# 主函数
main() {
    log_info "开始启动 New API 开发环境..."

    # 检查必需的命令
    log_info "检查必需的工具..."
    check_command "docker" || exit 1
    check_command "docker compose" || exit 1
    check_command "go" || exit 1
    check_command "node" || exit 1
    check_command "npm" || exit 1

    # 检查 Go 版本
    go_version=$(go version | grep -oE 'go[0-9]+\.[0-9]+' | sed 's/go//')
    required_version="1.23"
    if [ "$(printf '%s\n' "$required_version" "$go_version" | sort -V | head -n1)" != "$required_version" ]; then
        log_error "Go 版本需要 >= $required_version，当前版本: $go_version"
        exit 1
    fi
    log_success "Go 版本检查通过: $go_version"

    # 检查 Node.js 版本
    node_version=$(node --version | sed 's/v//')
    required_node_version="18.0.0"
    if [ "$(printf '%s\n' "$required_node_version" "$node_version" | sort -V | head -n1)" != "$required_node_version" ]; then
        log_error "Node.js 版本需要 >= $required_node_version，当前版本: $node_version"
        exit 1
    fi
    log_success "Node.js 版本检查通过: $node_version"

    # 检查端口占用
    log_info "检查端口占用情况..."
    check_port 3000 || log_warning "后端端口 3000 被占用，请手动处理"
    check_port 5173 || log_warning "前端端口 5173 被占用，请手动处理"
    check_port 3306 || log_warning "MySQL 端口 3306 被占用，请手动处理"
    check_port 6379 || log_warning "Redis 端口 6379 被占用，请手动处理"

    # 创建必要的目录
    log_info "创建必要的目录..."
    mkdir -p data logs

    # 复制环境配置文件
    if [ ! -f ".env" ]; then
        log_info "创建环境配置文件..."
        cp .env.dev .env
        log_success "已创建 .env 文件，请根据需要修改配置"
    else
        log_info ".env 文件已存在，跳过创建"
    fi

    # 启动数据库和缓存服务
    log_info "启动数据库和缓存服务..."
    docker compose -f docker-compose.dev.yml up -d mysql redis

    # 等待服务启动
    wait_for_service "localhost" "3306" "MySQL" || exit 1
    wait_for_service "localhost" "6379" "Redis" || exit 1

    # 安装 Go 依赖
    log_info "安装 Go 依赖..."
    go mod download
    go mod tidy
    log_success "Go 依赖安装完成"

    # 安装前端依赖
    log_info "安装前端依赖..."
    cd web

    # 尝试正常安装，如果失败则使用 legacy-peer-deps
    if ! npm install; then
        log_warning "正常安装失败，尝试使用 --legacy-peer-deps..."
        npm install --legacy-peer-deps
    fi

    cd ..
    log_success "前端依赖安装完成"

    # 检查是否安装了 air（热重载工具）
    if ! command -v air &> /dev/null; then
        log_info "安装 air 热重载工具..."
        go install github.com/cosmtrek/air@latest
        log_success "air 安装完成"
    fi

    log_success "开发环境准备完成！"
    echo
    log_info "启动说明："
    echo "  1. 后端服务 (在项目根目录):"
    echo "     air                    # 热重载模式"
    echo "     go run main.go         # 普通模式"
    echo
    echo "  2. 前端服务 (在 web 目录):"
    echo "     cd web && npm run dev"
    echo
    echo "  3. 访问地址："
    echo "     前端: http://localhost:5173"
    echo "     后端: http://localhost:3000"
    echo "     phpMyAdmin: http://localhost:8080 (可选)"
    echo "     Redis Commander: http://localhost:8081 (可选)"
    echo
    echo "  4. 启动管理工具 (可选):"
    echo "     docker compose -f docker-compose.dev.yml --profile tools up -d"
    echo
    echo "  5. 停止服务:"
    echo "     docker compose -f docker-compose.dev.yml down"
    echo
    log_info "开发愉快！"
}

# 脚本入口
main "$@"
