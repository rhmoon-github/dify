#!/bin/bash

# Dify完整安装脚本

set -e

echo "=========================================="
echo "Dify AI Platform 安装脚本"
echo "=========================================="

# 检查Docker是否安装
if ! command -v docker &> /dev/null; then
    echo "错误: Docker未安装，请先安装Docker"
    exit 1
fi

# 检查Docker Compose是否安装
if ! command -v docker-compose &> /dev/null; then
    echo "错误: Docker Compose未安装，请先安装Docker Compose"
    exit 1
fi

# 检查Docker服务是否运行
if ! docker info > /dev/null 2>&1; then
    echo "启动Docker服务..."
    sudo systemctl start docker
fi

echo "✓ Docker环境检查通过"

# 创建必要的目录
echo "创建数据目录..."
mkdir -p volumes/db/data
mkdir -p volumes/redis/data
mkdir -p volumes/app/storage
mkdir -p volumes/sandbox/dependencies
mkdir -p volumes/sandbox/conf
mkdir -p volumes/plugin_daemon

# 设置目录权限
sudo chown -R 999:999 volumes/db/data
sudo chown -R 999:999 volumes/redis/data

echo "✓ 数据目录创建完成"

# 检查网络连接
echo "检查网络连接..."
if ./check-network.sh; then
    echo "✓ 网络连接正常，开始拉取镜像..."
    
    # 拉取必要的镜像
    echo "拉取Dify镜像..."
    docker pull langgenius/dify-api:1.9.2 || echo "警告: 无法拉取dify-api镜像"
    docker pull langgenius/dify-web:1.9.2 || echo "警告: 无法拉取dify-web镜像"
    docker pull langgenius/dify-sandbox:0.2.12 || echo "警告: 无法拉取dify-sandbox镜像"
    docker pull langgenius/dify-plugin-daemon:0.3.3-local || echo "警告: 无法拉取dify-plugin-daemon镜像"
    
    echo "拉取基础服务镜像..."
    docker pull postgres:15-alpine
    docker pull redis:6-alpine
    docker pull nginx:latest
    docker pull ubuntu/squid:latest
    docker pull semitechnologies/weaviate:1.27.0
    
    echo "✓ 镜像拉取完成"
    
    # 启动完整服务
    echo "启动Dify服务..."
    docker-compose up -d
    
    if [ $? -eq 0 ]; then
        echo "✓ Dify服务启动成功！"
        echo ""
        echo "访问地址:"
        echo "  主界面: http://localhost"
        echo "  API接口: http://localhost:5001"
        echo ""
        echo "管理命令:"
        echo "  查看状态: docker-compose ps"
        echo "  查看日志: docker-compose logs -f"
        echo "  停止服务: docker-compose down"
        echo "  重启服务: docker-compose restart"
    else
        echo "✗ Dify服务启动失败"
        exit 1
    fi
    
else
    echo "✗ 网络连接有问题，启动基础服务..."
    
    # 启动基础服务
    echo "启动基础服务（数据库和缓存）..."
    docker-compose -f docker-compose.simple.yaml up -d
    
    if [ $? -eq 0 ]; then
        echo "✓ 基础服务启动成功！"
        echo ""
        echo "基础服务已启动，包括："
        echo "  - PostgreSQL数据库 (端口: 5432)"
        echo "  - Redis缓存 (端口: 6379)"
        echo "  - Nginx代理 (端口: 80)"
        echo ""
        echo "请解决网络问题后，运行以下命令启动完整服务："
        echo "  ./start-dify.sh"
    else
        echo "✗ 基础服务启动失败"
        exit 1
    fi
fi

# 设置开机自启动
echo "设置开机自启动..."
sudo systemctl enable dify.service

echo ""
echo "=========================================="
echo "安装完成！"
echo "=========================================="
echo ""
echo "下一步："
echo "1. 如果服务已启动，访问 http://localhost 开始使用"
echo "2. 如果网络有问题，请参考 README-INSTALL.md 解决"
echo "3. 查看服务状态: docker-compose ps"
echo "4. 查看日志: docker-compose logs -f"
echo ""