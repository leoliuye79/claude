#!/bin/bash
# Tailscale 安装与配置脚本
# 支持 Ubuntu/Debian 系统

set -e

echo "=== Tailscale 安装脚本 ==="

# 检查是否以 root 或 sudo 运行
if [ "$EUID" -ne 0 ]; then
    echo "请使用 sudo 运行此脚本: sudo bash install-tailscale.sh"
    exit 1
fi

# 检查是否已安装
if command -v tailscale &>/dev/null; then
    echo "Tailscale 已安装，版本: $(tailscale version)"
    echo "正在检查运行状态..."
else
    echo "正在安装 Tailscale..."

    # 检测发行版
    if [ -f /etc/debian_version ]; then
        # Debian/Ubuntu
        curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/noble.noarmor.gpg \
            | tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
        curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/noble.tailscale-keyring.list \
            | tee /etc/apt/sources.list.d/tailscale.list
        apt-get update -q
        apt-get install -y tailscale
    elif [ -f /etc/redhat-release ]; then
        # RHEL/CentOS/Fedora
        dnf config-manager --add-repo https://pkgs.tailscale.com/stable/fedora/tailscale.repo
        dnf install -y tailscale
    else
        echo "不支持的发行版，请手动安装 Tailscale: https://tailscale.com/download"
        exit 1
    fi

    echo "Tailscale 安装完成！"
fi

# 启动 tailscaled 服务
echo "正在启动 tailscaled 服务..."
systemctl enable --now tailscaled

# 显示状态
echo ""
echo "=== Tailscale 服务状态 ==="
systemctl status tailscaled --no-pager || true

echo ""
echo "=== 下一步操作 ==="
echo "运行以下命令将此设备加入你的 Tailscale 网络:"
echo ""
echo "  sudo tailscale up"
echo ""
echo "常用选项:"
echo "  sudo tailscale up --advertise-exit-node    # 作为出口节点"
echo "  sudo tailscale up --accept-routes          # 接受路由广播"
echo "  sudo tailscale up --ssh                    # 启用 Tailscale SSH"
echo ""
echo "查看网络状态:"
echo "  tailscale status"
echo ""
echo "更多帮助: https://tailscale.com/kb/"
