const TelegramBot = require('node-telegram-bot-api');
const sqlite3 = require('sqlite3').verbose();

const BOT_TOKEN = "COLOQUE_SEU_TOKEN_AQUI";
const ADMIN_ID = "COLOQUE_SEU_ID_AQUI";

const bot = new TelegramBot(BOT_TOKEN, { polling: true });
const db = new sqlite3.Database('./database/db.sqlite');

bot.onText(/\/start/, (msg) => {
    bot.sendMessage(msg.chat.id, "Bot ativo 🚀");
});

bot.onText(/\/addrevenda (.+) (\\d+) (\\d+)/, (msg, match) => {
    if (msg.from.id != ADMIN_ID) return;

    const nome = match[1];
    const creditos = parseInt(match[2]);
    const dias = parseInt(match[3]);

    const expira = Date.now() + (dias * 86400000);

    db.run(
        "INSERT INTO revendas (nome,creditos,expira) VALUES (?,?,?)",
        [nome, creditos, expira]
    );

    bot.sendMessage(msg.chat.id, "Revenda criada ✅");
});
