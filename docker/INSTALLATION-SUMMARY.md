# Dify Docker 安装总结

## 安装状态

✅ **已完成的任务：**

1. **环境配置** - 创建了.env配置文件，设置了基本的Dify参数
2. **Docker配置** - 配置了Docker镜像源和系统服务
3. **开机自启动** - 设置了Dify服务开机自动运行
4. **脚本工具** - 创建了完整的安装、启动、停止和状态检查脚本

## 当前状态

❌ **网络连接问题：**
- 无法连接到Docker Hub拉取镜像
- 所有必要的Docker镜像都缺失
- 服务无法启动

## 解决方案

由于网络连接问题，您需要选择以下方案之一来解决：

### 方案1: 配置代理（推荐）

```bash
# 配置Docker代理
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo tee /etc/systemd/system/docker.service.d/http-proxy.conf > /dev/null <<EOF
[Service]
Environment="HTTP_PROXY=http://your-proxy:port"
Environment="HTTPS_PROXY=http://your-proxy:port"
Environment="NO_PROXY=localhost,127.0.0.1"
EOF

sudo systemctl daemon-reload
sudo systemctl restart docker
```

### 方案2: 使用离线镜像包

1. 在有网络的环境中下载镜像：
```bash
docker pull langgenius/dify-api:1.9.2
docker pull langgenius/dify-web:1.9.2
docker pull langgenius/dify-sandbox:0.2.12
docker pull langgenius/dify-plugin-daemon:0.3.3-local
docker pull postgres:15-alpine
docker pull redis:6-alpine
docker pull nginx:latest
docker pull ubuntu/squid:latest
docker pull semitechnologies/weaviate:1.27.0

docker save -o dify-images.tar langgenius/dify-api:1.9.2 langgenius/dify-web:1.9.2 langgenius/dify-sandbox:0.2.12 langgenius/dify-plugin-daemon:0.3.3-local postgres:15-alpine redis:6-alpine nginx:latest ubuntu/squid:latest semitechnologies/weaviate:1.27.0
```

2. 在目标服务器导入镜像：
```bash
docker load -i dify-images.tar
```

### 方案3: 使用国内镜像源

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

sudo systemctl restart docker
```

## 启动服务

解决网络问题后，使用以下命令启动Dify：

```bash
cd /mnt/data/dify-project/docker

# 检查状态
./status-check.sh

# 启动服务
./start-dify.sh

# 或者直接使用docker-compose
docker-compose up -d
```

## 开机自启动

Dify服务已配置为开机自启动：

```bash
# 检查服务状态
sudo systemctl status dify.service

# 启用/禁用自启动
sudo systemctl enable dify.service   # 启用
sudo systemctl disable dify.service  # 禁用
```

## 管理命令

```bash
# 查看服务状态
./status-check.sh

# 启动服务
./start-dify.sh

# 停止服务
./stop-dify.sh

# 查看容器状态
docker-compose ps

# 查看日志
docker-compose logs -f

# 重启服务
docker-compose restart
```

## 访问地址

服务启动后，可以通过以下地址访问：

- **主界面**: http://localhost
- **API接口**: http://localhost:5001
- **管理界面**: http://localhost

## 文件结构

```
/mnt/data/dify-project/docker/
├── docker-compose.yaml          # 主配置文件
├── .env                         # 环境变量配置
├── start-dify.sh               # 启动脚本
├── stop-dify.sh                # 停止脚本
├── status-check.sh             # 状态检查脚本
├── check-network.sh            # 网络检查脚本
├── install-dify.sh             # 完整安装脚本
├── README-INSTALL.md           # 安装指南
├── OFFLINE-INSTALL.md          # 离线安装指南
├── INSTALLATION-SUMMARY.md     # 安装总结（本文件）
└── volumes/                    # 数据目录
    ├── db/data/               # 数据库数据
    ├── redis/data/            # Redis数据
    ├── app/storage/           # 应用存储
    ├── sandbox/               # 沙箱数据
    └── plugin_daemon/         # 插件数据
```

## 故障排除

1. **网络问题**: 参考 `OFFLINE-INSTALL.md`
2. **服务启动失败**: 运行 `./status-check.sh` 检查状态
3. **端口冲突**: 修改 `.env` 文件中的端口配置
4. **权限问题**: 确保Docker用户有权限访问项目目录

## 下一步

1. 解决网络连接问题
2. 拉取必要的Docker镜像
3. 启动Dify服务
4. 访问Web界面开始使用

## 支持文档

- `README-INSTALL.md` - 详细安装指南
- `OFFLINE-INSTALL.md` - 离线安装解决方案
- `status-check.sh` - 状态检查工具

---

**注意**: 由于网络连接问题，当前无法直接启动Dify服务。请先解决网络问题，然后使用提供的脚本启动服务。