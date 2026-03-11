# Tailscale 安装与配置

本仓库包含用于安装和配置 Tailscale 的脚本，适用于 Ubuntu/Debian 系统。

## 快速开始

### 1. 安装 Tailscale

```bash
sudo bash install-tailscale.sh
```

安装完成后，运行以下命令连接到你的 Tailscale 网络：

```bash
sudo tailscale up
```

按照提示打开认证链接，在浏览器中完成登录。

### 2. 配置 Tailscale

使用配置脚本进行常见设置：

```bash
# 查看帮助
bash tailscale-config.sh --help

# 连接到 Tailscale 网络
sudo bash tailscale-config.sh --up

# 查看状态
sudo bash tailscale-config.sh --status
```

## 常用功能

### 作为出口节点（Exit Node）

```bash
sudo bash tailscale-config.sh --exit-node
```

然后在 [Tailscale 管理控制台](https://login.tailscale.com/admin/machines) 批准该节点作为出口节点。

### 广播子网路由

```bash
sudo bash tailscale-config.sh --subnet 192.168.1.0/24
```

然后在管理控制台批准子网路由。

### 启用 Tailscale SSH

```bash
sudo bash tailscale-config.sh --ssh
```

启用后可以通过 `ssh user@hostname.tailnet-name.ts.net` 连接。

## 常用命令

| 命令 | 说明 |
|------|------|
| `tailscale status` | 查看网络状态和设备列表 |
| `tailscale ip` | 查看本机 Tailscale IP |
| `tailscale ping <主机名>` | 测试与其他节点的连通性 |
| `tailscale up` | 连接到网络 |
| `tailscale down` | 断开连接 |
| `tailscale logout` | 退出账号 |

## 管理控制台

访问 [https://login.tailscale.com/admin](https://login.tailscale.com/admin) 管理你的 Tailscale 网络。

## 故障排查

### 连接问题

```bash
# 检查服务状态
systemctl status tailscaled

# 查看日志
journalctl -u tailscaled -f

# 重启服务
sudo systemctl restart tailscaled
```

### 重新认证

```bash
sudo tailscale up --force-reauth
```

更多帮助请访问 [Tailscale 知识库](https://tailscale.com/kb/)。
