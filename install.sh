#!/bin/bash

set -e

clear
echo "====================================="
echo "   XRAY ULTRA - INSTALLER PRO"
echo "====================================="

BASE_DIR="/root/xray-ultra"
REPO="https://github.com/josejosuetiago/Xray-ultra.git"

echo "[1/7] Atualizando sistema..."
apt update -y && apt upgrade -y

echo "[2/7] Instalando dependências básicas..."
apt install -y curl wget git unzip sqlite3 build-essential

echo "[3/7] Instalando Node.js..."
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs

echo "[4/7] Instalando PM2..."
npm install -g pm2

echo "[5/7] Instalando Xray..."
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)"

echo "[6/7] Instalando projeto..."

rm -rf $BASE_DIR
git clone $REPO $BASE_DIR

cd $BASE_DIR

echo "[+] Instalando dependências do projeto..."
npm install

echo "[7/7] Configurando serviços..."

cat > /etc/systemd/system/xray-ultra.service <<EOF
[Unit]
Description=Xray Ultra System
After=network.target

[Service]
Type=simple
WorkingDirectory=$BASE_DIR
ExecStart=/usr/bin/node bot/bot.js
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable xray-ultra
systemctl start xray-ultra

echo ""
echo "====================================="
echo " INSTALAÇÃO COMPLETA FINALIZADA"
echo "====================================="
echo ""
echo "Diretório: $BASE_DIR"
echo "Serviço rodando: xray-ultra"
echo ""
echo "COMANDOS ÚTEIS:"
echo "systemctl status xray-ultra"
echo "pm2 list"
echo ""
echo "ACESSO: configure seu bot e API dentro do projeto"
echo ""
