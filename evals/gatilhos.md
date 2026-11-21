# Testes de gatilho — skill `enxame`

Conferência: ler só a `description` do `skill/enxame/SKILL.md` e decidir, para cada pedido,
se a skill seria carregada. A decisão tirada só da `description` tem que bater com a
esperada.

## Devem disparar

| # | Pedido | Decisão esperada | Motivo |
|---|---|---|---|
| 1 | "Executa o plano em docs/plan.md com vários agentes." | dispara | "executar o plano" e "vários agentes" estão nos gatilhos. |
| 2 | "Divide em agentes e faz em paralelo a migração dos 12 módulos para ESM." | dispara | "dividir em agentes" e "em paralelo"; trabalho grande, não tarefa única. |
| 3 | "Usa o enxame: compare 3 bibliotecas de CSV e entregue docs/comparacao-csv.md." | dispara | "enxame" citado; a description cobre pesquisa e documentos. |
| 4 | "Quero adiantar trabalho: põe uns subagentes escrevendo os testes que faltam enquanto reviso a API." | dispara | "adiantar trabalho" e "subagentes"; várias tarefas independentes. |
| 5 | Projeto Stilo Code na fase EXECUTE: "segue com o EXECUTE usando agentes em paralelo." | dispara | Fase EXECUTE está entre as permitidas em projeto Stilo; "em paralelo". |

## Não devem disparar

| # | Pedido | Decisão esperada | Motivo |
|---|---|---|---|
| 6 | "Troca LIMITE de 100 para 200 em src/constantes.js." | não dispara | Tarefa única e pequena, excluída na description. |
| 7 | "O que é um subagente e quando vale a pena usar um?" | não dispara | Pergunta simples / explicação sobre agentes, excluída na description. |
| 8 | Projeto Stilo Code na fase BRAINSTORM: "vamos levantar ideias para o recurso de exportação." | não dispara | Em projeto Stilo a skill vale só em PLAN, EXECUTE e revisões em subagente. |

## Resultado da conferência (2026-11-19)

Lendo só a `description`: 1–5 disparam, 6–8 não disparam. Os dois grupos se separam.
