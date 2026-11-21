# Resumo da avaliação — 2026-11-19 (rodada 1)

| Critério | Resultado | Evidência |
|---|---|---|
| C1 frontmatter | passa | `estatico.md` |
| C2 ≤ 500 linhas | passa (282) | `estatico.md` |
| C3 sem nomes de modelo | passa | `estatico.md` |
| C4 instalações idênticas | passa | `estatico.md`; Codex lista `enxame` |
| C5 (Claude, 3 rodadas) | **falha** (c, e, f) | `c5-c7.md` |
| C5 (Codex, 1 rodada) | **falha** (Stilo assume) | `c5-c7.md` |
| C6 (Claude) | **falha** (effort, agrupamento, revisor extra, limite de linhas, G) | `c6.md` |
| C6 (Codex) | **falha** (Stilo assume) | `c6.md` |
| C7 | passa | `c5-c7.md` |
| C8 a, c | passa | `c8.md` |
| C8 b, d, e | não conclusivo / falha parcial (ambiente) | `c8.md` |
| C8 invariantes (state e commits) | passa nos 5 | `c8.md` |

Limitações: leitura de `~/.claude/skills/enxame/referencias/` negada no `claude -p`
(contamina C6 e C8 b, d, e); sandbox do Codex com `orchestrator_helper_incomplete`;
Stilo instalado no Codex trata pasta sem `.stilo/` como projeto novo.

Achados consolidados vão para `.stilo/review-01.md`.
