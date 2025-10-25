#!/bin/bash

# Dify启动脚本
# 此脚本用于启动Dify服务并设置开机自启动

echo "正在启动Dify服务..."

# 检查Docker是否运行
if ! docker info > /dev/null 2>&1; then
    echo "错误: Docker服务未运行，请先启动Docker服务"
    echo "运行: sudo systemctl start docker"
    exit 1
fi

# 检查网络连接
echo "检查网络连接..."
if ! ping -c 1 registry-1.docker.io > /dev/null 2>&1; then
    echo "警告: 无法连接到Docker Hub，可能需要配置代理或使用离线镜像"
    echo "请确保网络连接正常或使用离线安装包"
fi

# 启动Dify服务
echo "启动Dify服务..."
cd /mnt/data/dify-project/docker
docker-compose up -d

if [ $? -eq 0 ]; then
    echo "Dify服务启动成功！"
    echo "访问地址: http://localhost"
    echo "管理界面: http://localhost"
    echo ""
    echo "查看服务状态: docker-compose ps"
    echo "查看日志: docker-compose logs -f"
    echo "停止服务: docker-compose down"
else
    echo "Dify服务启动失败，请检查错误信息"
    exit 1
fi