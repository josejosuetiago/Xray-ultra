const express = require('express');
const sqlite3 = require('sqlite3').verbose();

const app = express();
const PORT = 3000;

const db = new sqlite3.Database('./database/db.sqlite');

app.use(express.urlencoded({ extended: true }));

app.get('/', (req, res) => {
    res.send("Painel Xray Ultra funcionando 🚀");
});

app.listen(PORT, () => {
    console.log("Servidor rodando na porta", PORT);
});
