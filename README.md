# enxame

Skill para Claude Code e Codex que transforma um plano (ou um pedido grande) em ondas de
subagentes paralelos: o maior paralelismo útil, o menor gasto e o menor tempo. Funciona para
código, pesquisa e documentos.

## O que faz

- Lê o plano ou monta um a partir do pedido; separa tarefas, dependências (`interface` ou
  `pronta`) e travas de arquivo e de recurso; agrupa em ondas.
- Classifica cada tarefa em nível `barato`, `médio` ou `forte` e escolhe, **na hora**, o
  menor modelo disponível no host para aquele nível, com o esforço correspondente. Nenhum
  modelo fica fixo na skill.
- Dá a cada agente um orçamento de chamadas e de linhas de retorno, e um prompt enxuto só com
  o contexto das dependências diretas.
- Mostra uma tabela de aprovação (tarefa, dependência, onda, executor, nível→modelo, esforço,
  orçamento, risco/revisor, tempo estimado) e **só dispara depois do seu ok**.
- Corta tarefas pequenas demais para merecer agente, escala uma vez quando a falha é de
  capacidade, põe revisor só em tarefa de risco alto, registra progresso e retoma de onde
  parou.

## Instalar

```bash
bash scripts/instalar.sh
```

Copia `skill/enxame/` para `~/.claude/skills/enxame` (Claude Code) e
`~/.agents/skills/enxame` (Codex). `bash scripts/checar.sh` confere frontmatter, tamanho,
ausência de nome de modelo fixo e instalação idêntica nos dois destinos.

## Usar

```text
Use o enxame para executar este plano: ...
Divide isso em agentes e adianta o trabalho: ...
```

A skill responde com a tabela de ondas e espera o ok antes de disparar qualquer subagente.

## Com o Stilo Code

Convive com o [Stilo Code](https://github.com/luizgdemarchi/stilo-code). Em projeto com
`.stilo/state.json`, o Stilo decide o quê e quando; o enxame só decide como paralelizar:
age no `PLAN` (reforça o `plan.md` com nível, esforço, orçamento, risco e tempo) e no
`EXECUTE` (ondas do `validate-plan.js` do Stilo), não grava o estado enquanto roda, não faz
commit e registra o modelo de cada tarefa em `.stilo/logs/`. Regras em
`skill/enxame/referencias/stilo.md`.

## Estrutura

| Caminho | Conteúdo |
|---|---|
| `skill/enxame/SKILL.md` | a skill |
| `skill/enxame/referencias/` | detalhes por host (`host-claude.md`, `host-codex.md`), Stilo e modelos de prompt |
| `scripts/` | instalação e checagens estáticas |
| `evals/` | cenários, fixtures, checklists e `rodar.sh` (avaliação em cópia descartável) |
| `evals/resultados/` | resumos e metadados das rodadas (transcrições não versionadas) |
| `docs/ciclos/` e `.stilo/` | spec, plano e reviews do ciclo de desenvolvimento |

## Estado

Em avaliação (review 03 do ciclo `2026-11-19-skill-multiagente`). Comprovados no Claude
Code: tabela e ondas (C5, 3 de 3), execução com tarefa impossível (C6), pedido sem plano (C7)
e convivência com o Stilo nas fases `SPEC`, `PLAN` e trilha curta. No Codex: tabela e
aprovação (C5, 1 rodada). Pendentes: nova rodada do C8b, C8e, C6 no Codex depois do ok e a
segunda rodada do C5 no Codex. Detalhes em `.stilo/review-03.md`.
