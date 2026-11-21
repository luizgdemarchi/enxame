# Review 05 — ciclo 2026-11-19-skill-multiagente

- Alvo: `skill/enxame/**` após FIX do review 04; `evals/rodar.sh`.
- Cobertura: C6 Codex r3 (tabela, ok, execução) e C5 Codex r3, com `CODEX_HOME=~/.codex-cja`;
  avaliador independente (sonnet); conferência por comando: rollout em
  `~/.codex-cja/sessions/` (argumentos de `spawn_agent`), `progresso.md` e `.meta`.
- Exclusões: conteúdo dos prompts no Codex (criptografado).
- Documentos: `spec.md` (R18, C5, C6), `SKILL.md` passos 2, 8, 10, 12, `evals/checklists.md`.

Resumo: crítico 0 · alto 0 · médio 1 · baixo 4.

## Resultado

| Critério | Resultado | Evidência |
|---|---|---|
| C5 Codex | **passa 3/3** pós-correção (r1 da rodada 3, r2, r3) | r3: a–f; "Total: 12–23 min"; B e C `A (interface)` na onda de A; só RC |
| C6 Codex (r3) | **passa** nos verificáveis (1, 2, 6, 7, 8); 3 por `fork_turns: "none"`; 4 e 5 não verificáveis (criptografia) | a, b, c às 04:29:04/10/16 sem `wait_agent`; esforço `medium`/`high` (C); "Paradas: G"; "Parciais: —", "Escaladas: —" |
| R18 no Codex | **passa** (achado 1 do review 04 corrigido) | `.enxame/2026-11-21-0128/progresso.md` com "## Onda 1 conferida", "## Onda 2 conferida", "## Onda 3 conferida", cada uma gravada antes da onda seguinte |
| Relato final (passo 12) | passa (achado 2 do review 04 corrigido) | rótulos na ordem: Concluídas … Detalhes |
| Commits | iguais | `c6-codex-3.meta`, `c5-codex-3.meta`: 1 = 1 |

Achados do review 04: 1–6 corrigidos e confirmados (1, 2 nesta rodada; 3–6 por leitura e
comando); 7 = 26–28 do review 01, abertos.

## Achados

### 1. Codex não atualiza a tabela de registro
- **Arquivo:** `skill/enxame/SKILL.md` passo 8 item 5 e passo 10
- **Gravidade:** médio · **Confiança:** alta · **Classificação:** confirmado
- **O que quebra:** em c6-codex-3, A, B e C ficam `disparada` até o fim e D e RC nunca entram
  na tabela; o status certo está só nas seções de onda. Sem a linha, D e RC ficam sem
  registro de esforço solicitado.
- **Como corrigir:** passo 8 item 5, literal: "troque `disparada` pelo status conferido em cada
  linha"; passo 7 item 6 já manda gravar a linha no disparo de cada onda (repetir "de cada
  onda, não só da primeira").
- **Evidência:** `progresso.md` de c6-codex-3, seção Registro (3 linhas `disparada`).
- **Contraprova verificada:** no Claude (C8b, C8e) a tabela sai completa; R18 passa pelas
  seções de onda. **Origem:** introduzido. **Estado:** aberto.

### 2–5. Baixos
2. Cadeia D→E (ambas P, mesmo `README.md`) não agrupada em C5 Codex r3: E com agente próprio,
   sem "corte:". O checklist aceita separado; custa um agente a mais. Origem: introduzido.
3. Relato final do C6 Codex omite em "Desvios" a falha da 1ª verificação integrada, que está no
   progresso; e a linha "Concluídas" traz prosa depois dos ids. Origem: introduzido.
4. `progresso.md` do Codex resume a tabela aprovada (nível e esforço juntos, sem coluna de
   revisor; "Plano aprovado" sem hora). Retomada continua possível. Origem: introduzido.
5. Abertos do review 01: 26, 27, 28.

## Critérios do spec

| Critério | Estado |
|---|---|
| C1–C4 | atendido (`checar.sh`) |
| C5 | atendido: Claude 3/3 (rodada 2) + regressão ok; Codex 3/3 |
| C6 | atendido: Claude (rodada 2); Codex nos itens verificáveis (4 e 5 limitados pela criptografia do Codex, limitação aceita) |
| C7 | atendido |
| C8 | atendido: a, c, d (rodada 2); b, e (review 04) |
| Invariantes Stilo | atendido |

Sem achado crítico nem alto. Próxima fase: `EDITORIAL_REVIEW`.
