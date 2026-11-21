# Review 04 — ciclo 2026-11-19-skill-multiagente

- Alvo: `skill/enxame/**` após FIX do review 03 (commit `f925834` no GitHub + mudanças locais
  do FIX 03 já incluídas nele); `evals/rodar.sh`.
- Cobertura: C8b r2 (antes e depois do ok), C8e r1, C6 Codex r2 (tabela, ok, execução), C5
  Codex r2. Codex com o segundo login (`CODEX_HOME=~/.codex-cja`; o padrão perdeu a
  credencial). 2 avaliadores independentes (sonnet) + conferência por comando: `estado_*` e
  commits no `.meta`, suíte das cópias, rollout do Codex em `~/.codex-cja/sessions/` (traz os
  argumentos de `spawn_agent`; o `message` vem criptografado).
- Exclusões: conteúdo dos prompts no Codex (criptografado no rollout e no subagente).
- Documentos: `spec.md` (R9a, R18, C5, C6, C8), `SKILL.md` passos 8, 10 e 12, `evals/checklists.md`.

Resumo: crítico 0 · alto 1 · médio 1 · baixo 5.

## Resultado

| Critério | Resultado | Evidência |
|---|---|---|
| C8b (r2) | **passa** | 5 prompts sem frase do hook (grep de commit/push/"demais arquivos"/"não pergunte"/formato: vazio); ok antes do 1º disparo; ondas = validador; registro completo; suíte 4/4 |
| C8e | **passa** | sem segundo ok; 5 disparos; `.stilo/logs/enxame-2026-11-20-exportar.md` com status por onda; suíte 5/5 |
| Invariante C8 (b, e) | passa | `estado_*`: só `phase` EXECUTE→REVIEW e `updated`, gravados depois de "Onda 4 (conferida)" e da suíte verde; commits 1 = 1 |
| C5 Codex | **passa** em r1 (rodada 3) e r2 | avaliadores: a–f; "Total: 7–14 min"; B e C `A (interface)` na onda 1 |
| C6 Codex (r2) | passa em 1, 2, 3, 5, 6, 7; 4 não verificável; 8 com ressalva | ver abaixo |
| R18 no Codex | **não atendido** | achado 1 |

C6 Codex, item a item:
1. Onda numa resposta: `spawn_agent` a, b, c às 04:17:51/57, 04:18:02, sem `wait_agent`
   entre eles; o spawn do Codex não bloqueia, então os três rodaram juntos. Passa.
2. Esforço explícito em todos (`medium`; `high` em C); `model` omitido = modelo da sessão,
   como manda `host-codex.md` (nível vira esforço). Passa.
3. `fork_turns: "none"` nos 6. Passa.
4. Instrução de agrupar: prompt criptografado. Não verificável (limitação aceita, review 02 achado 6).
5. Retornos de 2 linhas, com caminho do detalhe. Passa.
6. Revisor só em C (`rc`). Passa.
7. G no principal, motivo antes da tabela ("compara literalmente `1` com `2`"), relatada como
   "permanece pendente"; teste preservado; suíte 2/3 (a falha é `impossivel.test.js`). Passa.
8. Relato lista A–F concluídas e G pendente (não houve parcial nem escalada), mas fora do
   formato do passo 12 (achado 2).

## Achados

### 1. Codex: progresso fora do projeto e nunca atualizado
- **Arquivo:** `skill/enxame/SKILL.md:246-262` (passo 8) e `:273-279` (passo 10)
- **Gravidade:** alto · **Confiança:** alta · **Classificação:** confirmado
- **O que quebra:** sandbox do Codex nega `.git/info/exclude` → o agente criou a pasta em
  `%TEMP%\enxame-notas-c6` e gravou `progresso.md` uma vez ("A, B, C: disparadas"); nunca
  atualizou depois. Sem tabela de registro, sem status por onda (R18), sem D, RC, E, F, G. Uma
  retomada não acha o arquivo e redispara tudo.
- **Como corrigir:** passo 8, item novo: gravar a conferência no progresso (registro e status
  de cada tarefa) antes de disparar a onda seguinte; sem isso, não dispara. Passo 10: com
  `.git/info/exclude` não gravável, a pasta fica na raiz mesmo assim e o usuário é avisado;
  nunca fora do projeto.
- **Evidência:** `progresso.md` (368 bytes, 2 linhas): "Registro fora do repositorio pois
  .git/info/exclude nao e gravavel no sandbox."; rollout: `exec` às 04:17:43 é a única
  escrita do progresso.
- **Contraprova verificada:** R9a aceita pasta temporária, mas o passo 10 fixa
  `.enxame/<AAAA-MM-DD-HHMM>/` na raiz, e a retomada procura ali; o review 02 (achado 1)
  já tornou a tabela obrigatória "com e sem Stilo", e no Claude ela saiu (C8b, C8e).
- **Origem:** introduzido. **Estado:** aberto.

### 2. Relato final do Codex fora do formato do passo 12
- **Arquivo:** `skill/enxame/SKILL.md:316-330`
- **Gravidade:** médio · **Confiança:** média · **Classificação:** confirmado
- **O que quebra:** o relato de C6 Codex é prosa: sem Parciais, Escaladas, Revisões, Desvios,
  Tempo, Detalhes. O desvio da pasta (achado 1) não chegou ao usuário.
- **Como corrigir:** passo 12: "use exatamente estes rótulos, com `—` quando vazio".
- **Evidência:** último `[assistente]` de `c6-codex-2.txt`. **Origem:** introduzido. **Estado:** aberto.

### 3–7. Baixos
3. **`CODEX_HOME` ignorado.** `host-codex.md:18,22,24` manda ler `~/.codex/models_cache.json` e
   `~/.codex/config.toml`; com o segundo login, o cache e a config ficam em `~/.codex-cja`.
   Corrigir: `$CODEX_HOME` (padrão `~/.codex`).
4. **Detalhe por tarefa não gravável no Stilo.** O `executor-stilo` pede o detalhe em
   `.stilo/logs/enxame-<cycle>/<id>.md`, mas "Pode escrever" só lista o entregável; em c8-e
   nenhum detalhe foi gravado ("Nenhum log de detalhe por tarefa foi gravado"). Corrigir:
   incluir o arquivo de detalhe em "Pode escrever" nos dois executores.
5. **Wording de R17a/C8.** "gravada depois do relato final" é impossível numa resposta só (a
   gravação vem antes do texto final). Corrigir para "depois da última onda conferida e do
   registro fechado" em `spec.md`, `stilo.md`, `checklists.md`.
6. **`rodar.sh` trava o Codex em primeiro plano.** `codex exec` espera o stdin; sem
   `< /dev/null` a sessão ficou 10 min sem saída. Corrigir: `< /dev/null` nas duas chamadas.
7. Abertos do review 01: 26, 27, 28.

## Descartados (avaliadores)

| Alegação | Motivo |
|---|---|
| C6 Codex: spawns em chamadas separadas | `spawn_agent` do Codex devolve na hora e não bloqueia; sem `wait_agent` entre a, b, c, rodaram juntos |
| C6 Codex: falta `model` explícito | `host-codex.md`: nível vira esforço sobre o modelo da sessão; nenhum modelo do cache tem marca de porte |
| C6 Codex: E depende de G impossível | G virou "executar e diagnosticar a suíte, preservando o teste", que conclui; E documenta testes |
| C5 Codex r2: E no principal sem corte declarado | item b passa (nenhuma tarefa de corte com agente); E é edição curta no README |

## Critérios do spec

| Critério | Estado |
|---|---|
| C1–C4 | atendido |
| C5 | Claude 3/3 (r2) + r3 sem regressão; Codex 2 rodadas pós-correção atendidas (falta a 3ª) |
| C6 | Claude atendido (r2); Codex atendido no verificável, item 4 não verificável |
| C7 | atendido |
| C8 | a, c, d (r2), b (r2 desta rodada), e atendidos |
| R18 | Claude atendido; **Codex não** (achado 1) |

Próxima fase: `FIX` (achado alto).

## Estado após FIX (2026-11-21)

| Achado | Estado | Onde |
|---|---|---|
| 1 | corrigido (texto); confirmar em nova C6 Codex | `SKILL.md` passo 8 item 5 (gravar conferência antes de seguir); passo 10 (pasta na raiz mesmo sem exclude, nunca fora do projeto) |
| 2 | corrigido (texto) | `SKILL.md` passo 12: rótulos exatos, `—` quando vazio |
| 3 | corrigido | `host-codex.md`: `$CODEX_HOME` (padrão `~/.codex`) para config e cache de modelos |
| 4 | corrigido | `prompts.md`: detalhe em "Pode escrever" no `executor` e no `executor-stilo` |
| 5 | corrigido | `spec.md` R17a e C8, `stilo.md` topo, `evals/checklists.md` C8: "última onda conferida e registro fechado" |
| 6 | corrigido | `evals/rodar.sh`: `< /dev/null` nas duas chamadas do `codex exec` |
| 7 | abertos (baixo) | review 01: 26–28 |

Verificação: `bash -n evals/rodar.sh`; `scripts/instalar.sh`; `scripts/checar.sh` C1–C4 ok.
