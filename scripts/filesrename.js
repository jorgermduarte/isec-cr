const fs = require('fs');
const path = require('path');

const pastaPrincipal = '../data/datasets/start';

function lerPasta(pasta) {
  const pastas = fs.readdirSync(pasta, { withFileTypes: true })
    .filter(dirent => dirent.isDirectory())
    .map(dirent => dirent.name);

  pastas.forEach(nomePasta => {
    const pastaCompleta = path.join(pasta, nomePasta);
    const arquivos = fs.readdirSync(pastaCompleta, { withFileTypes: true })
      .filter(dirent => dirent.isFile())
      .map(dirent => dirent.name);

    arquivos.forEach(nomeArquivo => {
      const novoNome = '_' + nomePasta + '_' + nomeArquivo;
      const caminhoAntigo = path.join(pastaCompleta, nomeArquivo);
      const caminhoNovo = path.join(pastaCompleta, novoNome);

      fs.renameSync(caminhoAntigo, caminhoNovo);
      console.log(`Arquivo ${nomeArquivo} renomeado para ${novoNome}`);
    });
  });
}

lerPasta(pastaPrincipal);
