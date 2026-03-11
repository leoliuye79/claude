#!/bin/bash
# Tailscale 常用配置脚本
# 用于配置 Tailscale 各种功能

set -e

show_help() {
    echo "用法: sudo bash tailscale-config.sh [选项]"
    echo ""
    echo "选项:"
    echo "  --up              连接到 Tailscale 网络（基本模式）"
    echo "  --exit-node       配置为出口节点"
    echo "  --subnet CIDR     广播子网路由 (例: 192.168.1.0/24)"
    echo "  --ssh             启用 Tailscale SSH"
    echo "  --status          显示当前状态"
    echo "  --down            断开 Tailscale 连接"
    echo "  --help            显示此帮助"
    echo ""
    echo "示例:"
    echo "  sudo bash tailscale-config.sh --up"
    echo "  sudo bash tailscale-config.sh --exit-node"
    echo "  sudo bash tailscale-config.sh --subnet 192.168.1.0/24"
}

check_tailscale() {
    if ! command -v tailscale &>/dev/null; then
        echo "错误: Tailscale 未安装，请先运行 install-tailscale.sh"
        exit 1
    fi
}

case "${1:-}" in
    --up)
        check_tailscale
        echo "正在连接到 Tailscale 网络..."
        tailscale up
        ;;
    --exit-node)
        check_tailscale
        echo "正在配置为出口节点..."
        # 启用 IP 转发
        echo 'net.ipv4.ip_forward = 1' | tee -a /etc/sysctl.d/99-tailscale.conf
        echo 'net.ipv6.conf.all.forwarding = 1' | tee -a /etc/sysctl.d/99-tailscale.conf
        sysctl -p /etc/sysctl.d/99-tailscale.conf
        tailscale up --advertise-exit-node
        echo "此节点已配置为出口节点，请在 Tailscale 管理控制台批准。"
        ;;
    --subnet)
        check_tailscale
        if [ -z "${2:-}" ]; then
            echo "错误: 请提供子网 CIDR，例: --subnet 192.168.1.0/24"
            exit 1
        fi
        SUBNET="$2"
        echo "正在广播子网路由: $SUBNET"
        # 启用 IP 转发
        echo 'net.ipv4.ip_forward = 1' | tee -a /etc/sysctl.d/99-tailscale.conf
        sysctl -p /etc/sysctl.d/99-tailscale.conf
        tailscale up --advertise-routes="$SUBNET"
        echo "子网路由已广播，请在 Tailscale 管理控制台批准。"
        ;;
    --ssh)
        check_tailscale
        echo "正在启用 Tailscale SSH..."
        tailscale up --ssh
        echo "Tailscale SSH 已启用。"
        ;;
    --status)
        check_tailscale
        echo "=== Tailscale 状态 ==="
        tailscale status
        echo ""
        echo "=== 当前 IP ==="
        tailscale ip -4 2>/dev/null && tailscale ip -6 2>/dev/null || echo "未连接"
        ;;
    --down)
        check_tailscale
        echo "正在断开 Tailscale 连接..."
        tailscale down
        echo "已断开连接。"
        ;;
    --help|"")
        show_help
        ;;
    *)
        echo "未知选项: $1"
        show_help
        exit 1
        ;;
esac
