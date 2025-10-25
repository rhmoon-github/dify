# Dify Docker 安装指南

## 问题说明

由于网络连接问题，无法直接从Docker Hub拉取镜像。以下是几种解决方案：

## 解决方案

### 方案1: 配置代理（推荐）

如果您有可用的代理服务器，可以配置Docker使用代理：

1. 创建Docker代理配置目录：
```bash
sudo mkdir -p /etc/systemd/system/docker.service.d
```

2. 创建代理配置文件：
```bash
sudo tee /etc/systemd/system/docker.service.d/http-proxy.conf > /dev/null <<EOF
[Service]
Environment="HTTP_PROXY=http://your-proxy:port"
Environment="HTTPS_PROXY=http://your-proxy:port"
Environment="NO_PROXY=localhost,127.0.0.1"
EOF
```

3. 重启Docker服务：
```bash
sudo systemctl daemon-reload
sudo systemctl restart docker
```

### 方案2: 使用离线镜像包

1. 从其他网络环境下载Dify镜像：
```bash
# 在可访问Docker Hub的环境中运行
docker pull langgenius/dify-api:1.9.2
docker pull langgenius/dify-web:1.9.2
docker pull langgenius/dify-sandbox:0.2.12
docker pull langgenius/dify-plugin-daemon:0.3.3-local
docker pull postgres:15-alpine
docker pull redis:6-alpine
docker pull nginx:latest
docker pull ubuntu/squid:latest
docker pull semitechnologies/weaviate:1.27.0

# 导出镜像
docker save -o dify-images.tar langgenius/dify-api:1.9.2 langgenius/dify-web:1.9.2 langgenius/dify-sandbox:0.2.12 langgenius/dify-plugin-daemon:0.3.3-local postgres:15-alpine redis:6-alpine nginx:latest ubuntu/squid:latest semitechnologies/weaviate:1.27.0
```

2. 将镜像包传输到目标服务器并导入：
```bash
docker load -i dify-images.tar
```

### 方案3: 使用国内镜像源

1. 修改Docker配置使用国内镜像源：
```bash
sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn",
    "https://hub-mirror.c.163.com",
    "https://mirror.baidubce.com"
  ]
}
EOF
```

2. 重启Docker服务：
```bash
sudo systemctl restart docker
```

## 启动Dify服务

配置好网络后，使用以下命令启动Dify：

```bash
# 启动服务
./start-dify.sh

# 或者直接使用docker-compose
cd /mnt/data/dify-project/docker
docker-compose up -d
```

## 设置开机自启动

1. 启用Dify服务：
```bash
sudo systemctl enable dify.service
```

2. 启动Dify服务：
```bash
sudo systemctl start dify.service
```

3. 检查服务状态：
```bash
sudo systemctl status dify.service
```

## 访问Dify

服务启动后，可以通过以下地址访问：

- 主界面: http://localhost
- API接口: http://localhost:5001

## 常用命令

```bash
# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f

# 停止服务
./stop-dify.sh

# 重启服务
docker-compose restart

# 更新服务
docker-compose pull
docker-compose up -d
```

## 故障排除

1. 如果服务启动失败，检查日志：
```bash
docker-compose logs
```

2. 如果端口被占用，修改.env文件中的端口配置

3. 如果数据库连接失败，检查PostgreSQL容器是否正常运行

4. 如果内存不足，可以调整Docker的内存限制或关闭不必要的服务