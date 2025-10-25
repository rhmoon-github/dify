#!/bin/bash

# Dify服务状态检查脚本

echo "=========================================="
echo "Dify服务状态检查"
echo "=========================================="

# 检查Docker服务状态
echo "1. 检查Docker服务状态..."
if systemctl is-active --quiet docker; then
    echo "✓ Docker服务正在运行"
else
    echo "✗ Docker服务未运行"
    echo "  启动命令: sudo systemctl start docker"
fi

# 检查Docker Compose文件
echo ""
echo "2. 检查Docker Compose配置..."
if [ -f "docker-compose.yaml" ]; then
    echo "✓ docker-compose.yaml 存在"
else
    echo "✗ docker-compose.yaml 不存在"
fi

if [ -f ".env" ]; then
    echo "✓ .env 配置文件存在"
else
    echo "✗ .env 配置文件不存在"
fi

# 检查镜像
echo ""
echo "3. 检查Docker镜像..."
REQUIRED_IMAGES=(
    "langgenius/dify-api:1.9.2"
    "langgenius/dify-web:1.9.2"
    "langgenius/dify-sandbox:0.2.12"
    "langgenius/dify-plugin-daemon:0.3.3-local"
    "postgres:15-alpine"
    "redis:6-alpine"
    "nginx:latest"
    "ubuntu/squid:latest"
    "semitechnologies/weaviate:1.27.0"
)

MISSING_IMAGES=()
for image in "${REQUIRED_IMAGES[@]}"; do
    if docker images --format "table {{.Repository}}:{{.Tag}}" | grep -q "^$image$"; then
        echo "✓ $image"
    else
        echo "✗ $image (缺失)"
        MISSING_IMAGES+=("$image")
    fi
done

# 检查容器状态
echo ""
echo "4. 检查容器状态..."
if command -v docker-compose &> /dev/null; then
    if [ -f "docker-compose.yaml" ]; then
        echo "当前运行的容器:"
        docker-compose ps
    else
        echo "✗ docker-compose.yaml 不存在，无法检查容器状态"
    fi
else
    echo "✗ docker-compose 命令不可用"
fi

# 检查端口占用
echo ""
echo "5. 检查端口占用..."
PORTS=(80 443 5001 5432 6379 8080 6333)
for port in "${PORTS[@]}"; do
    if netstat -tlnp 2>/dev/null | grep -q ":$port "; then
        echo "✓ 端口 $port 已被占用"
    else
        echo "○ 端口 $port 空闲"
    fi
done

# 检查网络连接
echo ""
echo "6. 检查网络连接..."
if ping -c 1 registry-1.docker.io > /dev/null 2>&1; then
    echo "✓ Docker Hub连接正常"
else
    echo "✗ Docker Hub连接失败"
fi

# 检查系统服务
echo ""
echo "7. 检查系统服务..."
if systemctl is-enabled --quiet dify.service; then
    echo "✓ Dify服务已设置为开机自启动"
else
    echo "○ Dify服务未设置为开机自启动"
fi

# 总结
echo ""
echo "=========================================="
echo "检查总结"
echo "=========================================="

if [ ${#MISSING_IMAGES[@]} -eq 0 ]; then
    echo "✓ 所有必要的Docker镜像都已准备就绪"
    echo ""
    echo "可以启动Dify服务："
    echo "  ./start-dify.sh"
    echo "  或"
    echo "  docker-compose up -d"
else
    echo "✗ 缺少以下Docker镜像："
    for image in "${MISSING_IMAGES[@]}"; do
        echo "  - $image"
    done
    echo ""
    echo "请参考以下文档解决："
    echo "  - README-INSTALL.md"
    echo "  - OFFLINE-INSTALL.md"
fi

echo ""
echo "访问地址："
echo "  主界面: http://localhost"
echo "  API接口: http://localhost:5001"
echo ""
echo "管理命令："
echo "  查看状态: docker-compose ps"
echo "  查看日志: docker-compose logs -f"
echo "  停止服务: docker-compose down"