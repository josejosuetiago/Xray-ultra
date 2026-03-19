#!/bin/bash

clear
echo "========================================="
echo "   XRAY ULTRA SYSTEM (PAINEL + BOT)"
echo "========================================="

# ================= CONFIG =================
BASE_DIR="/root/xray-ultra"
BOT_FILE="$BASE_DIR/bot.js"
API_FILE="$BASE_DIR/api.js"
DB_FILE="$BASE_DIR/db.sqlite"

read -p "TOKEN BOT TELEGRAM: " BOT_TOKEN
read -p "SEU ID TELEGRAM (ADMIN): " ADMIN_ID
read -p "PORTA PAINEL WEB (ex: 3000): " WEB_PORT

# ================= DEPENDENCIAS =================
apt update -y
apt install -y curl wget nodejs npm sqlite3

# ================= XRAY =================
if ! command -v xray &>/dev/null; then
    bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install
fi

# ================= PASTA =================
mkdir -p $BASE_DIR
cd $BASE_DIR

# ================= BANCO =================
sqlite3 $DB_FILE <<EOF
CREATE TABLE IF NOT EXISTS revendas (
 id INTEGER PRIMARY KEY AUTOINCREMENT,
 nome TEXT,
 telegram_id TEXT,
 creditos INTEGER,
 usados INTEGER DEFAULT 0,
 expira INTEGER
);

CREATE TABLE IF NOT EXISTS pagamentos (
 id INTEGER PRIMARY KEY AUTOINCREMENT,
 user TEXT,
 valor INTEGER,
 status TEXT
);
EOF

# ================= API + PAINEL =================
cat > $API_FILE <<EOF
const express = require('express');
const sqlite3 = require('sqlite3').verbose();
const { exec } = require('child_process');

const app = express();
const db = new sqlite3.Database('./db.sqlite');

app.use(express.urlencoded({ extended: true }));

// LOGIN SIMPLES
app.get('/', (req, res) => {
    res.send('<h2>Painel Revenda</h2><form method="POST" action="/login"><input name="user"><button>Entrar</button></form>');
});

app.post('/login', (req, res) => {
    res.redirect('/dashboard?user=' + req.body.user);
});

app.get('/dashboard', (req, res) => {
    const user = req.query.user;

    db.get("SELECT * FROM revendas WHERE nome=?", [user], (err, rev) => {
        if (!rev) return res.send("Revenda não existe");

        res.send(\`
        <h2>Painel \${rev.nome}</h2>
        Créditos: \${rev.creditos - rev.usados}<br><br>

        <form action="/criar" method="GET">
        <input name="user" placeholder="usuario">
        <input name="dias" placeholder="dias">
        <input type="hidden" name="rev" value="\${rev.nome}">
        <button>Criar</button>
        </form>
        \`);
    });
});

app.get('/criar', (req, res) => {
    const { user, dias, rev } = req.query;

    db.get("SELECT * FROM revendas WHERE nome=?", [rev], (err, r) => {

        if (r.usados >= r.creditos)
            return res.send("Sem créditos");

        exec(\`bash /usr/local/bin/xray-nebula criar_user \${user} \${dias}\`, (err, out) => {

            db.run("UPDATE revendas SET usados = usados + 1 WHERE nome=?", [rev]);

            res.send("<pre>" + out + "</pre>");
        });
    });
});

app.listen(${WEB_PORT}, () => console.log("WEB ON"));
EOF

# ================= BOT =================
cat > $BOT_FILE <<EOF
const TelegramBot = require('node-telegram-bot-api');
const sqlite3 = require('sqlite3').verbose();
const { exec } = require('child_process');
const QRCode = require('qrcode');

const bot = new TelegramBot("${BOT_TOKEN}", { polling: true });
const db = new sqlite3.Database('./db.sqlite');

const ADMIN_ID = "${ADMIN_ID}";

function getIP(cb){
 exec("curl -s icanhazip.com",(e,o)=>cb(o.trim()));
}

bot.onText(/\\/addrevenda (.+) (\\d+) (\\d+)/, (msg, m)=>{
 if(msg.from.id != ADMIN_ID) return;

 const nome=m[1];
 const creditos=parseInt(m[2]);
 const dias=parseInt(m[3]);

 const exp=Date.now()+dias*86400000;

 db.run("INSERT INTO revendas (nome,creditos,expira) VALUES (?,?,?)",[nome,creditos,exp]);

 bot.sendMessage(msg.chat.id,"Revenda criada");
});

bot.onText(/\\/start/, (msg)=>{
 db.get("SELECT * FROM revendas WHERE telegram_id IS NULL LIMIT 1",(e,r)=>{
  if(r){
   db.run("UPDATE revendas SET telegram_id=? WHERE id=?",[msg.from.id,r.id]);
   bot.sendMessage(msg.chat.id,"Vinculado: "+r.nome);
  }
 });
});

bot.onText(/\\/criar (.+) (\\d+)/,(msg,m)=>{

 const user=m[1];
 const dias=parseInt(m[2]);

 db.get("SELECT * FROM revendas WHERE telegram_id=?",[msg.from.id],(e,r)=>{

  if(!r) return;

  if(r.usados>=r.creditos)
   return bot.sendMessage(msg.chat.id,"Sem créditos");

  exec(\`bash /usr/local/bin/xray-nebula criar_user \${user} \${dias}\`, async (err,out)=>{

   const uuid=out.match(/UUID: (.+)/)[1];

   getIP(async (ip)=>{

    const link=\`vless://\${uuid}@\${ip}:443?type=ws&security=none&path=/ws#\${user}\`;

    const qr=await QRCode.toBuffer(link);

    db.run("UPDATE revendas SET usados=usados+1 WHERE id=?",[r.id]);

    bot.sendMessage(msg.chat.id,
\`USER: \${user}
LINK:
\${link}\`);

    bot.sendPhoto(msg.chat.id,qr);

   });

  });

 });

});
EOF

# ================= NODE =================
npm init -y &>/dev/null
npm install express sqlite3 node-telegram-bot-api qrcode &>/dev/null

# ================= SERVICE BOT =================
cat > /etc/systemd/system/xray-bot.service <<EOF
[Unit]
Description=Bot Xray Ultra
After=network.target

[Service]
ExecStart=/usr/bin/node $BOT_FILE
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# ================= SERVICE WEB =================
cat > /etc/systemd/system/xray-web.service <<EOF
[Unit]
Description=Web Xray Ultra
After=network.target

[Service]
ExecStart=/usr/bin/node $API_FILE
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable xray-bot
systemctl enable xray-web
systemctl start xray-bot
systemctl start xray-web

# ================= FINAL =================
echo ""
echo "========================================="
echo "   SISTEMA ULTRA INSTALADO"
echo "========================================="
echo ""
echo "BOT: funcionando"
echo "PAINEL: http://IP:${WEB_PORT}"
echo ""
echo "COMANDOS:"
echo "/addrevenda nome creditos dias"
echo "/criar user dias"
echo ""
