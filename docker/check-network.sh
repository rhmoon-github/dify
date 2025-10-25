#!/bin/bash

# 网络连接检查脚本

echo "检查网络连接..."

# 检查Docker Hub连接
if ping -c 3 registry-1.docker.io > /dev/null 2>&1; then
    echo "✓ Docker Hub连接正常"
    NETWORK_OK=true
else
    echo "✗ Docker Hub连接失败"
    NETWORK_OK=false
fi

# 检查DNS解析
if nslookup registry-1.docker.io > /dev/null 2>&1; then
    echo "✓ DNS解析正常"
else
    echo "✗ DNS解析失败"
    NETWORK_OK=false
fi

# 检查HTTPS连接
if curl -s --connect-timeout 10 https://registry-1.docker.io/v2/ > /dev/null 2>&1; then
    echo "✓ HTTPS连接正常"
    NETWORK_OK=true
else
    echo "✗ HTTPS连接失败"
    NETWORK_OK=false
fi

if [ "$NETWORK_OK" = true ]; then
    echo ""
    echo "网络连接正常，可以启动Dify服务"
    echo "运行: ./start-dify.sh"
    exit 0
else
    echo ""
    echo "网络连接有问题，请参考README-INSTALL.md中的解决方案"
    echo "1. 配置代理"
    echo "2. 使用离线镜像包"
    echo "3. 使用国内镜像源"
    exit 1
fi