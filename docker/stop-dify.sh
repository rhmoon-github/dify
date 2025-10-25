#!/bin/bash

# Dify停止脚本

echo "正在停止Dify服务..."

cd /mnt/data/dify-project/docker
docker-compose down

if [ $? -eq 0 ]; then
    echo "Dify服务已停止"
else
    echo "停止Dify服务时出现错误"
    exit 1
fi