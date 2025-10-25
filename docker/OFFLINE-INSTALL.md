# Dify 离线安装指南

由于网络连接问题，无法直接从Docker Hub拉取镜像。以下是完整的离线安装解决方案：

## 方案1: 使用代理服务器

### 1.1 配置Docker代理

```bash
# 创建代理配置目录
sudo mkdir -p /etc/systemd/system/docker.service.d

# 创建代理配置文件（替换为您的代理地址）
sudo tee /etc/systemd/system/docker.service.d/http-proxy.conf > /dev/null <<EOF
[Service]
Environment="HTTP_PROXY=http://your-proxy-server:port"
Environment="HTTPS_PROXY=http://your-proxy-server:port"
Environment="NO_PROXY=localhost,127.0.0.1"
EOF

# 重启Docker服务
sudo systemctl daemon-reload
sudo systemctl restart docker
```

### 1.2 验证代理配置

```bash
# 检查Docker代理配置
sudo systemctl show --property=Environment docker

# 测试连接
docker pull hello-world
```

## 方案2: 使用离线镜像包

### 2.1 在有网络的环境中准备镜像

在可以访问Docker Hub的环境中运行：

```bash
# 拉取所有必要的镜像
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
docker save -o dify-images.tar \
  langgenius/dify-api:1.9.2 \
  langgenius/dify-web:1.9.2 \
  langgenius/dify-sandbox:0.2.12 \
  langgenius/dify-plugin-daemon:0.3.3-local \
  postgres:15-alpine \
  redis:6-alpine \
  nginx:latest \
  ubuntu/squid:latest \
  semitechnologies/weaviate:1.27.0
```

### 2.2 在目标服务器上导入镜像

```bash
# 将镜像包传输到目标服务器后
docker load -i dify-images.tar

# 验证镜像导入
docker images | grep -E "(dify|postgres|redis|nginx|ubuntu|semitechnologies)"
```

## 方案3: 使用国内镜像源

### 3.1 配置Docker使用国内镜像源

```bash
# 备份原配置
sudo cp /etc/docker/daemon.json /etc/docker/daemon.json.bak

# 配置国内镜像源
sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn",
    "https://hub-mirror.c.163.com",
    "https://mirror.baidubce.com",
    "https://ccr.ccs.tencentyun.com"
  ],
  "dns": ["8.8.8.8", "8.8.4.4", "114.114.114.114"]
}
EOF

# 重启Docker服务
sudo systemctl restart docker
```

### 3.2 使用阿里云镜像加速器

```bash
# 登录阿里云容器镜像服务
# 获取您的专属加速器地址
# 配置Docker使用阿里云加速器
sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
  "registry-mirrors": [
    "https://your-accelerator-id.mirror.aliyuncs.com"
  ]
}
EOF

sudo systemctl restart docker
```

## 方案4: 使用VPN或网络代理

### 4.1 配置系统代理

```bash
# 设置环境变量
export http_proxy=http://your-proxy:port
export https_proxy=http://your-proxy:port
export no_proxy=localhost,127.0.0.1

# 配置Docker使用系统代理
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo tee /etc/systemd/system/docker.service.d/http-proxy.conf > /dev/null <<EOF
[Service]
Environment="HTTP_PROXY=$http_proxy"
Environment="HTTPS_PROXY=$https_proxy"
Environment="NO_PROXY=$no_proxy"
EOF

sudo systemctl daemon-reload
sudo systemctl restart docker
```

## 启动Dify服务

解决网络问题后，使用以下命令启动Dify：

```bash
cd /mnt/data/dify-project/docker

# 检查网络连接
./check-network.sh

# 启动服务
./start-dify.sh

# 或者直接使用docker-compose
docker-compose up -d
```

## 设置开机自启动

```bash
# 启用服务
sudo systemctl enable dify.service

# 启动服务
sudo systemctl start dify.service

# 检查状态
sudo systemctl status dify.service
```

## 验证安装

```bash
# 检查容器状态
docker-compose ps

# 检查服务日志
docker-compose logs -f

# 访问Web界面
curl http://localhost
```

## 故障排除

### 1. 镜像拉取失败

```bash
# 检查Docker配置
docker info

# 检查网络连接
ping registry-1.docker.io

# 检查DNS解析
nslookup registry-1.docker.io
```

### 2. 服务启动失败

```bash
# 查看详细日志
docker-compose logs

# 检查端口占用
netstat -tlnp | grep -E "(80|5001|5432|6379)"

# 检查磁盘空间
df -h
```

### 3. 数据库连接失败

```bash
# 检查PostgreSQL容器
docker logs dify-db

# 检查数据库连接
docker exec -it dify-db psql -U postgres -d dify
```

## 常用命令

```bash
# 启动服务
docker-compose up -d

# 停止服务
docker-compose down

# 重启服务
docker-compose restart

# 查看状态
docker-compose ps

# 查看日志
docker-compose logs -f

# 更新服务
docker-compose pull
docker-compose up -d

# 清理资源
docker-compose down -v
docker system prune -a
```

## 注意事项

1. 确保服务器有足够的内存（建议至少4GB）
2. 确保有足够的磁盘空间（建议至少20GB）
3. 确保防火墙允许相关端口（80, 443, 5001等）
4. 定期备份数据目录
5. 监控服务状态和日志