# Spec: exportar notas em JSON e CSV

- Ciclo: 2026-11-20-exportar
- Trilha: completa
- Commit-base: a1b2c3d
- reviewRound: 0

## Problema
O usuário não consegue tirar as notas do app para outras ferramentas.

## Objetivo
Exportar notas em JSON e CSV, por CLI e por uma prévia local.

## Requisitos
- `src/exportar.js` exporta `paraJSON(notas)` e `paraCSV(notas)`.
- `src/cli.js` aceita `exportar --formato json|csv` e imprime o resultado.
- `src/previa.js` sobe um servidor em 127.0.0.1:4173 com `/notas.json` e `/notas.csv`.
- CSV com cabeçalho `id,texto` e aspas escapadas.

## Critérios de aceite
1. `node -e "console.log(require('./src/exportar').paraJSON([{id:1,texto:'a'}]))"` imprime JSON válido com a nota.
2. `node src/cli.js exportar --formato csv` imprime a linha `id,texto` como primeira linha.
