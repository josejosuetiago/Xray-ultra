#!/bin/bash

set -e

clear
echo "======================================"
echo "   XRAY ULTRA SYSTEM (PRO INSTALL)"
echo "======================================"

BASE_DIR="/root/xray-ultra"
REPO="https://github.com/josejosuetiago/Xray-ultra.git"

echo "[1/7] Atualizando sistema..."
apt update -y && apt upgrade -y

echo "[2/7] Instalando dependências..."
apt install -y curl wget git unzip sqlite3

echo "[3/7] Instalando Node.js (LTS)..."
curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
apt install -y nodejs

echo "[4/7] Instalando PM2..."
npm install -g pm2

echo "[5/7] Instalando XRAY..."
bash <(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh) install

echo "[6/7] Clonando projeto..."
rm -rf $BASE_DIR
git clone $REPO $BASE_DIR

cd $BASE_DIR

echo "[7/7] Instalando dependências Node..."
npm install

echo "[+] Criando banco..."
sqlite3 database/db.sqlite <<EOF
CREATE TABLE IF NOT EXISTS revendas (
 id INTEGER PRIMARY KEY AUTOINCREMENT,
 nome TEXT,
 telegram_id TEXT,
 creditos INTEGER,
 usados INTEGER DEFAULT 0,
 expira INTEGER
);

CREATE TABLE IF NOT EXISTS users (
 id INTEGER PRIMARY KEY AUTOINCREMENT,
 username TEXT,
 uuid TEXT,
 expira INTEGER
);
EOF

echo "[+] Subindo serviços..."

pm2 start bot/bot.js --name xray-bot
pm2 start api/server.js --name xray-api

pm2 save
pm2 startup | bash

IP=$(curl -s ifconfig.me)

echo ""
echo "======================================"
echo "   INSTALAÇÃO FINALIZADA 🚀"
echo "======================================"
echo ""
echo "BOT: ON"
echo "API: http://$IP:3000"
echo ""
echo "Agora configure seu bot no arquivo:"
echo "$BASE_DIR/bot/bot.js"
echo ""
