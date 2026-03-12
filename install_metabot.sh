#!/bin/bash
set -e

echo "========================================="
echo "  MetaBot 一键安装脚本 (非交互式)"
echo "========================================="

# 1. 检查 Node.js
if ! command -v node &>/dev/null; then
    echo "[1/6] 安装 Node.js 20..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
else
    echo "[1/6] Node.js 已安装: $(node -v)"
fi

# 2. 检查 Git
if ! command -v git &>/dev/null; then
    echo "[2/6] 安装 Git..."
    sudo apt-get update && sudo apt-get install -y git
else
    echo "[2/6] Git 已安装"
fi

# 3. 克隆 MetaBot
echo "[3/6] 克隆 MetaBot..."
cd ~
if [ -d "metabot" ]; then
    echo "  metabot 目录已存在，更新代码..."
    cd metabot && git pull
else
    git clone https://github.com/xvirobotics/metabot.git
    cd metabot
fi

# 4. 安装依赖
echo "[4/6] 安装 npm 依赖..."
npm install

# 5. 安装 PM2
echo "[5/6] 安装 PM2..."
sudo npm install -g pm2 2>/dev/null || npm install -g pm2

# 6. 生成配置文件
echo "[6/6] 生成配置文件..."
if [ -f bots.example.json ] && [ ! -f bots.json ]; then
    cp bots.example.json bots.json
    echo "  已创建 bots.json (需要手动配置)"
fi
if [ -f .env.example ] && [ ! -f .env ]; then
    cp .env.example .env
    echo "  已创建 .env (需要手动配置)"
fi

echo ""
echo "========================================="
echo "  MetaBot 安装完成！"
echo "========================================="
echo ""
echo "下一步："
echo "  1. 编辑配置: nano ~/metabot/bots.json"
echo "  2. 编辑环境变量: nano ~/metabot/.env"
echo "  3. 启动: cd ~/metabot && npm run dev"
echo "  4. 生产模式: cd ~/metabot && pm2 start npm --name metabot -- run start"
echo ""
