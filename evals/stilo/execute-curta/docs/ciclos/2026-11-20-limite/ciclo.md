# Ciclo 2026-11-20-limite

- Trilha: curta
- Commit-base: a1b2c3d

## Spec
Trocar o limite de notas de 100 para 200 em `src/constantes.js`.
Critério: `grep 'LIMITE = 200' src/constantes.js` encontra a linha.

## Plano
1. Alterar `LIMITE` para 200 em `src/constantes.js`.
2. Rodar `npm test` e o `grep` do critério.
