# Review 02 — ciclo 2026-11-19-skill-multiagente

- Alvo: `skill/enxame/**` após FIX do review 01; `evals/rodar.sh`, `scripts/checar.sh`.
- Cobertura: rodada 2 de avaliação (15 sessões: C5 ×3 + C7 + C6 + C8 a–e no Claude; C5 e C6
  no Codex), 7 avaliadores independentes, conferências por comando (hash, commits,
  validador, ids de mensagem). Transcrições: `evals/resultados/*.jsonl`; rodada 1 em
  `evals/resultados/rodada-1/`.
- Achados do review 01: todos `corrigido`, salvo 26–28 (baixo, abertos) — ver tabela lá.

Resumo: crítico 1 · alto 1 · médio 3 · baixo 3.

## Resultado da rodada 2

| Critério | Resultado | Evidência |
|---|---|---|
| C1–C4 | passa | `checar.sh` |
| C5 Claude (3 rodadas, a–f) | **passa** nas 3 | avaliadores r2; `interface` rotulado (em R1/R2 sobre T0, a tarefa de interface que o spec manda criar) |
| C5 Codex | falha (c, d, f) | "a skill pede aprovação após uma tabela, mas seu pedido já autoriza" |
| C6 Claude | **passa** 8/8 | avaliador marcou "spawns em mensagens separadas"; descartado: A, B e C têm o mesmo `message.id` `msg_011ChETwY1xSuFzcaJTtsqJ1` |
| C6 Codex | parcial | tabela e ok certos, G bloqueada com motivo, revisor só em C, sem Stilo; disparos não verificáveis (`codex exec --json` não registra `spawn_agent`), e `progresso.md` sem modelo/esforço |
| C7 | passa | — |
| C8 a, c, d | passa | d: `plan.md` passa no `validate-plan.js` (exit 0) com as 5 linhas nas 4 tarefas |
| C8 b | **falha** (registro de modelo) | ondas = validador, `model`/`effort` em cada disparo, ok antes de disparar; sem Classificação/Modelo solicitado/Esforço solicitado/Aplicação confirmada |
| C8 e | não conclusivo | parou corretamente por defeito da fixture (nenhuma tarefa cria `src/previa.js`) |
| Invariantes Stilo | passa | hash e commits iguais nos 5; Codex não criou `.stilo/` |

## Achados

### 1. Registro de modelo ausente no progresso (C8b; também Codex C6)
- **Arquivo:** `skill/enxame/SKILL.md` (modelo de `progresso.md`); `referencias/stilo.md`
- **Gravidade:** crítico · **Confiança:** alta · **Classificação:** confirmado
- **O que quebra:** C8b exige o registro de modelo do Stilo por tarefa delegada; o log de
  c8-b só tem "médio→sonnet, esforço médio"; o de c6-codex não tem modelo nem esforço.
- **Como corrigir:** modelo de `progresso.md` com uma linha por tarefa delegada:
  `id | classificação | modelo solicitado | esforço solicitado | aplicação confirmada | status`,
  obrigatório com e sem Stilo; gravado no disparo.
- **Evidência:** avaliador C8 r2 ("Registro de modelo ausente"); `progresso.md` de
  `c6-codex-1` (só texto corrido por onda).
- **Contraprova verificada:** `prompts.md` tem o bloco "Registro por tarefa delegada", mas
  o `SKILL.md` não o põe no modelo de progresso. **Origem:** introduzido. **Estado:** aberto.

### 2. Codex pula a aprovação ("o pedido já autoriza")
- **Arquivo:** `skill/enxame/SKILL.md` (topo e passo de aprovação)
- **Gravidade:** alto · **Confiança:** média · **Classificação:** confirmado (1 de 2 rodadas)
- **O que quebra:** pedido "Use o enxame para executar este plano" → Codex executou sem
  tabela nem ok (c5-codex r2). No c6-codex, com o mesmo início, pediu ok.
- **Como corrigir:** regra de parada na primeira linha do corpo do `SKILL.md`, com a frase
  rebatida literal: "'use o enxame para executar' é o pedido, não o ok; o ok vem depois da
  tabela".
- **Evidência:** avaliador Codex r2.
- **Contraprova verificada:** o `SKILL.md` já rebate "o usuário já disse execute"; não
  bastou no Codex. **Origem:** introduzido. **Estado:** aberto.

### 3. Validador do Stilo não roda: agente procura o arquivo
- **Arquivo:** `skill/enxame/referencias/stilo.md`
- **Gravidade:** médio · **Confiança:** alta · **Classificação:** confirmado
- **O que quebra:** em c8-b, d, e o agente usou Glob em `~/.claude` para achar
  `validate-plan.js`, a leitura foi negada, e as ondas foram calculadas à mão.
- **Como corrigir:** comando literal: pegar a pasta da linha `Módulos sob demanda:` do bloco
  de estado do Stilo e rodar `node "<pasta>/../scripts/validate-plan.js" "<plan.md>"`, sem
  procurar com Glob; se o bloco não tiver a linha, calcular e avisar.
- **Evidência:** `c8-b` e `c8-d`: `Glob {"pattern": "**/validate-plan.js", "path": "C:\\Users\\luizg\\.claude"}` → negado.
- **Origem:** introduzido. **Estado:** aberto.

### 4. `executor-stilo` ainda repete regras do hook
- **Arquivo:** `skill/enxame/referencias/prompts.md`
- **Gravidade:** médio · **Confiança:** média · **Classificação:** confirmado
- **O que quebra:** prompts de c8-b repetem "Não faça commit", "Escreva só em" e o formato
  do relato, que o hook do Stilo já injeta (custo de contexto, R17g).
- **Como corrigir:** tirar do `executor-stilo` commit/push e o formato do relato; manter só
  a lista de arquivos que pode escrever.
- **Evidência:** avaliador C8 r2, cenário b. **Origem:** introduzido. **Estado:** aberto.

### 5. Fixture de C8 sem a tarefa da prévia
- **Arquivo:** `evals/stilo/execute-{completa,aprovada}/docs/ciclos/2026-11-20-exportar/{plan,spec}.md`
- **Gravidade:** médio · **Confiança:** alta · **Classificação:** confirmado
- **O que quebra:** T03/T04 testam `src/previa.js`, que nenhuma tarefa cria; critério do spec
  usa `require` num projeto `"type": "module"`. C8e fica inconclusivo.
- **Como corrigir:** tarefa que cria `src/previa.js` (porta 4173) antes de T03/T04; critério
  com `import()`.
- **Evidência:** c8-e e c8-b pararam apontando isso. **Origem:** introduzido (T04).
  **Estado:** aberto.

### 6–8. Baixos
6. `codex exec --json` não registra os argumentos de `spawn_agent`; a verificação de C6 no
   Codex depende do registro em `progresso.md` (achado 1). Limitação declarada.
7. Sandbox do Codex deixa `.git` só leitura: a exclusão em `.git/info/exclude` falha; a skill
   registrou a limitação (comportamento aceitável). Sem mudança.
8. Abertos do review 01: 26 (total de orçamento, sugestão), 27 (`rodar.sh` `--extra` Windows
   / `exit 0`), 28 (`checar.sh` C1 com CRLF).

Próxima fase: `FIX` (achado crítico e alto).

## Estado após FIX (2026-11-20)

| Achado | Estado | Onde |
|---|---|---|
| 1 | corrigido | `SKILL.md` passo 7.6 e passo 10 (tabela de registro obrigatória); `stilo.md` seção Disparo |
| 2 | corrigido | `SKILL.md` primeira linha do corpo (regra de parada literal) |
| 3 | corrigido | `stilo.md` seção do validador (comando literal, sem Glob) |
| 4 | corrigido em parte | `prompts.md` `executor-stilo` sem retorno duplicado; o modelo não tinha commit/relato — a repetição em c8-b veio do agente; reavaliar |
| 5 | corrigido | fixtures `execute-{completa,aprovada}`: T05 `src/previa.js`; critério com `import()`; validador exit 0 (5 tarefas, 4 ondas) |
| 6, 7 | aceitos (limitação declarada) | — |
| 8 | abertos (baixo) | ver review 01 |
