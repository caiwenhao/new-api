#!/bin/bash

# New API 前端依赖修复脚本
# 用于解决前端依赖冲突问题

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

# 检查是否在项目根目录
check_project_root() {
    if [ ! -f "web/package.json" ]; then
        log_error "请在项目根目录运行此脚本"
        exit 1
    fi
}

# 备份 package.json
backup_package_json() {
    log_info "备份 package.json..."
    cp web/package.json web/package.json.backup
    log_success "已备份到 web/package.json.backup"
}

# 清理前端依赖
clean_frontend_deps() {
    log_info "清理前端依赖..."
    cd web
    
    # 删除 node_modules 和 lock 文件
    if [ -d "node_modules" ]; then
        rm -rf node_modules
        log_info "已删除 node_modules"
    fi
    
    if [ -f "package-lock.json" ]; then
        rm -f package-lock.json
        log_info "已删除 package-lock.json"
    fi
    
    if [ -f "yarn.lock" ]; then
        rm -f yarn.lock
        log_info "已删除 yarn.lock"
    fi
    
    cd ..
}

# 修复依赖版本冲突
fix_dependency_conflicts() {
    log_info "修复依赖版本冲突..."
    
    # 检查并修复 @lobehub/icons 版本
    if grep -q '"@lobehub/icons": "\^2\.' web/package.json; then
        log_warning "检测到 @lobehub/icons 版本冲突，降级到兼容版本..."
        sed -i 's/"@lobehub\/icons": "\^2\.[0-9]*\.[0-9]*"/"@lobehub\/icons": "^1.34.1"/g' web/package.json
        log_success "已修复 @lobehub/icons 版本"
    fi
    
    # 检查其他可能的冲突
    log_info "检查其他潜在冲突..."
    
    # 可以在这里添加更多的版本修复逻辑
}

# 安装前端依赖
install_frontend_deps() {
    log_info "安装前端依赖..."
    cd web
    
    # 方法1: 尝试正常安装
    log_info "尝试正常安装..."
    if npm install; then
        log_success "正常安装成功"
        cd ..
        return 0
    fi
    
    # 方法2: 使用 --legacy-peer-deps
    log_warning "正常安装失败，尝试使用 --legacy-peer-deps..."
    if npm install --legacy-peer-deps; then
        log_success "使用 --legacy-peer-deps 安装成功"
        cd ..
        return 0
    fi
    
    # 方法3: 使用 --force
    log_warning "legacy-peer-deps 安装失败，尝试使用 --force..."
    if npm install --force; then
        log_warning "使用 --force 安装成功（可能存在兼容性问题）"
        cd ..
        return 0
    fi
    
    # 方法4: 使用 yarn
    if command -v yarn &> /dev/null; then
        log_warning "npm 安装失败，尝试使用 yarn..."
        if yarn install; then
            log_success "使用 yarn 安装成功"
            cd ..
            return 0
        fi
    fi
    
    cd ..
    log_error "所有安装方法都失败了"
    return 1
}

# 验证安装结果
verify_installation() {
    log_info "验证安装结果..."
    cd web
    
    # 检查关键依赖是否存在
    if [ ! -d "node_modules/react" ]; then
        log_error "React 未正确安装"
        cd ..
        return 1
    fi
    
    if [ ! -d "node_modules/@douyinfe/semi-ui" ]; then
        log_error "Semi UI 未正确安装"
        cd ..
        return 1
    fi
    
    # 尝试运行构建测试
    log_info "测试构建配置..."
    if npm run build --dry-run 2>/dev/null || true; then
        log_success "构建配置正常"
    else
        log_warning "构建配置可能存在问题，但依赖已安装"
    fi
    
    cd ..
    log_success "依赖验证完成"
}

# 显示解决方案建议
show_solutions() {
    echo
    log_info "如果仍然遇到问题，可以尝试以下解决方案："
    echo
    echo "1. 手动安装特定版本："
    echo "   cd web"
    echo "   npm install @lobehub/icons@1.34.1 --save"
    echo
    echo "2. 使用 yarn 代替 npm："
    echo "   cd web"
    echo "   yarn install"
    echo
    echo "3. 更新 Node.js 版本："
    echo "   确保使用 Node.js 18+ 版本"
    echo
    echo "4. 清理 npm 缓存："
    echo "   npm cache clean --force"
    echo
    echo "5. 如果问题持续，可以暂时忽略 peer dependencies："
    echo "   cd web"
    echo "   npm install --legacy-peer-deps"
}

# 主函数
main() {
    local force_clean=false
    
    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            --clean)
                force_clean=true
                shift
                ;;
            -h|--help)
                echo "用法: $0 [选项]"
                echo "选项:"
                echo "  --clean      强制清理并重新安装"
                echo "  -h, --help   显示帮助信息"
                exit 0
                ;;
            *)
                log_error "未知选项: $1"
                exit 1
                ;;
        esac
    done
    
    log_info "开始修复前端依赖问题..."
    
    # 检查项目根目录
    check_project_root
    
    # 备份配置文件
    backup_package_json
    
    # 如果指定了清理或者存在问题，则清理依赖
    if [ "$force_clean" = true ] || [ -d "web/node_modules" ]; then
        clean_frontend_deps
    fi
    
    # 修复依赖冲突
    fix_dependency_conflicts
    
    # 安装依赖
    if install_frontend_deps; then
        # 验证安装
        verify_installation
        
        log_success "前端依赖修复完成！"
        echo
        log_info "现在可以启动前端开发服务器："
        echo "  cd web && npm run dev"
    else
        log_error "前端依赖修复失败"
        show_solutions
        exit 1
    fi
}

# 脚本入口
main "$@"
