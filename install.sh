#!/bin/bash

set -e

clear
echo "====================================="
echo "   XRAY ULTRA - INSTALLER (FIXED)"
echo "====================================="

BASE_DIR="/root/xray-ultra"

echo "[+] Atualizando sistema..."
apt update -y && apt upgrade -y

echo "[+] Instalando dependências..."
apt install -y curl wget git sqlite3 unzip

echo "[+] Instalando Node.js..."
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs

echo "[+] Criando diretório..."
mkdir -p $BASE_DIR

cd $BASE_DIR

echo "[+] Instalando Xray (CORRETO)..."
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)"

echo "[+] Instalando dependências Node..."
npm init -y
npm install express sqlite3 node-telegram-bot-api qrcode

echo ""
echo "====================================="
echo " INSTALAÇÃO FINALIZADA COM SUCESSO"
echo "====================================="
echo ""
echo "Diretório:"
echo "$BASE_DIR"
echo ""
echo "Agora envie seu projeto para esse diretório."
echo ""
