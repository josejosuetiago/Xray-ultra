const { exec } = require('child_process');

function criarUsuario(nome, dias) {
    return new Promise((resolve, reject) => {

        const cmd = `echo "Criar usuário ${nome} por ${dias} dias"`;

        exec(cmd, (err, stdout, stderr) => {
            if (err) return reject(err);
            resolve(stdout);
        });

    });
}

module.exports = {
    criarUsuario
};
