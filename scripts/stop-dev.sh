#!/bin/bash

# New API 开发环境停止脚本
# 用于停止开发环境的所有服务

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

# 检查进程是否存在
check_process() {
    local process_name=$1
    if pgrep -f "$process_name" > /dev/null; then
        return 0
    fi
    return 1
}

# 停止进程
stop_process() {
    local process_name=$1
    local service_name=$2
    
    if check_process "$process_name"; then
        log_info "停止 $service_name..."
        pkill -f "$process_name" || true
        sleep 2
        
        # 强制停止（如果还在运行）
        if check_process "$process_name"; then
            log_warning "强制停止 $service_name..."
            pkill -9 -f "$process_name" || true
        fi
        
        log_success "$service_name 已停止"
    else
        log_info "$service_name 未运行"
    fi
}

# 主函数
main() {
    local remove_data=false
    local stop_all=false
    
    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            --remove-data)
                remove_data=true
                shift
                ;;
            --all)
                stop_all=true
                shift
                ;;
            -h|--help)
                echo "用法: $0 [选项]"
                echo "选项:"
                echo "  --remove-data    同时删除数据卷"
                echo "  --all           停止所有服务（包括管理工具）"
                echo "  -h, --help      显示帮助信息"
                exit 0
                ;;
            *)
                log_error "未知选项: $1"
                exit 1
                ;;
        esac
    done
    
    log_info "开始停止 New API 开发环境..."
    
    # 停止前端开发服务器
    stop_process "vite" "前端开发服务器"
    stop_process "npm.*dev" "前端开发服务器"
    
    # 停止后端服务器
    stop_process "air" "后端服务器 (air)"
    stop_process "go run main.go" "后端服务器 (go run)"
    stop_process "./new-api" "后端服务器 (编译版本)"
    
    # 停止 Docker 服务
    log_info "停止 Docker 服务..."
    
    if [ "$stop_all" = true ]; then
        # 停止所有服务（包括管理工具）
        if [ "$remove_data" = true ]; then
            docker-compose -f docker-compose.dev.yml --profile tools down -v
            log_warning "已删除数据卷，所有数据将丢失"
        else
            docker-compose -f docker-compose.dev.yml --profile tools down
        fi
    else
        # 只停止基础服务
        if [ "$remove_data" = true ]; then
            docker-compose -f docker-compose.dev.yml down -v
            log_warning "已删除数据卷，所有数据将丢失"
        else
            docker-compose -f docker-compose.dev.yml down
        fi
    fi
    
    # 检查是否还有相关容器在运行
    log_info "检查剩余容器..."
    running_containers=$(docker ps --filter "name=new-api" --format "table {{.Names}}\t{{.Status}}" | tail -n +2)
    
    if [ -n "$running_containers" ]; then
        log_warning "以下容器仍在运行:"
        echo "$running_containers"
        echo
        log_info "如需强制停止，请运行:"
        echo "  docker stop \$(docker ps -q --filter \"name=new-api\")"
    else
        log_success "所有相关容器已停止"
    fi
    
    # 显示端口占用情况
    log_info "检查端口占用情况..."
    
    ports=(3000 5173 3306 6379 8080 8081)
    occupied_ports=()
    
    for port in "${ports[@]}"; do
        if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
            occupied_ports+=($port)
        fi
    done
    
    if [ ${#occupied_ports[@]} -gt 0 ]; then
        log_warning "以下端口仍被占用: ${occupied_ports[*]}"
        echo
        log_info "查看端口占用详情:"
        for port in "${occupied_ports[@]}"; do
            echo "  端口 $port:"
            lsof -Pi :$port -sTCP:LISTEN | head -2 | tail -1 || true
        done
    else
        log_success "所有相关端口已释放"
    fi
    
    # 清理临时文件（可选）
    log_info "清理临时文件..."
    
    # 清理 Go 构建缓存（可选）
    if [ -f "new-api" ]; then
        rm -f new-api
        log_info "已删除编译文件"
    fi
    
    # 清理日志文件（可选）
    if [ -d "logs" ] && [ "$(ls -A logs)" ]; then
        read -p "是否清理日志文件? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf logs/*
            log_info "已清理日志文件"
        fi
    fi
    
    log_success "开发环境已停止"
    echo
    log_info "重新启动开发环境:"
    echo "  ./scripts/start-dev.sh"
    echo
    log_info "查看 Docker 服务状态:"
    echo "  docker-compose -f docker-compose.dev.yml ps"
    echo
    log_info "查看 Docker 日志:"
    echo "  docker-compose -f docker-compose.dev.yml logs -f"
}

# 脚本入口
main "$@"
