#!/bin/bash

set -e

clear
echo "====================================="
echo "   XRAY ULTRA - INSTALLER"
echo "====================================="

BASE_DIR="/root/xray-ultra"

echo "[+] Atualizando sistema..."
apt update -y

echo "[+] Instalando dependências..."
apt install -y curl wget git sqlite3

echo "[+] Instalando Node.js..."
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs

echo "[+] Criando diretório..."
mkdir -p $BASE_DIR

echo "[+] Instalando Xray..."
bash <(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh) @ install

echo "[+] Instalando dependências Node..."
cd $BASE_DIR
npm init -y
npm install express sqlite3 node-telegram-bot-api qrcode

echo ""
echo "====================================="
echo " INSTALAÇÃO BASE FINALIZADA"
echo "====================================="
echo ""
echo "Agora envie os arquivos do projeto para:"
echo "$BASE_DIR"
