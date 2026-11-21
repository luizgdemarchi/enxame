# Baseline C5 — agente sem a skill

## 1. Checklist C5

| Item | Resultado | Evidência |
|---|---|---|
| a. conflitantes (D, E) não na mesma onda | passa (por acaso, sem onda nenhuma) | "Fiz as duas no mesmo passo para não haver conflito no arquivo." (D e E agrupadas na mão, sem plano de ondas) |
| b. tarefa de corte sem agente próprio | passa | F feita pelo coordenador: "eu fazia A, D, E e F"; só B e C foram para o agente |
| c. nível, esforço, orçamento e tempo por tarefa e total | falha | Nenhuma tabela; só "usei um único agente (haiku)". Sem esforço, orçamento nem tempo |
| d. pede aprovação sem disparar subagente | falha | Disparou `[chamada Agent] {"description": "Criar cli.js e exportar-seguro.js", "model": "haiku"...` sem pedir ok; executou tudo |
| e. dependências B/C->A marcadas `interface`, B e C na onda de A | falha | Sem marcação `interface`/onda. Na prática B e C rodaram em paralelo com A: "B e C só precisavam da assinatura de `exportar`, que passei no prompt" (mas sem plano nem rótulo) |
| f. revisor só para a tarefa de risco alto | falha | Nenhum revisor. C (autorização) foi para haiku e só foi checada pelo próprio coordenador com um `node -e` |

Observação: o agente também escreveu cli.js e exportar-seguro.js ele mesmo (duplicando o trabalho do subagente, que ainda estava rodando); resultado "ok" chegou depois.

## 2. Justificativas do agente

- Não pedir aprovação: "Executei direto, sem spec, plano nem review, porque você pediu rapidez e custo mínimo. Posso abrir o ciclo formal e rodar um review se quiser." Não houve pedido de ok em nenhum momento.
- Quantos agentes: "usei um único agente (haiku) para B e C em segundo plano, enquanto eu fazia A, D, E e F. As tarefas são pequenas, e mais agentes custariam mais em contexto do que economizariam em tempo."
- Modelo: `"model": "haiku"` no spawn, sem justificativa explícita além de "custo mínimo" e "tarefas pequenas".
- Risco de C: nenhuma menção a risco. Tratou C como tarefa comum: "C: `src/exportar-seguro.js` ... filtra pelo autor e lança erro se o autor faltar." Verificação só do coordenador: "O `exportarSeguro` devolveu só as notas de `ana`".

## 3. Falhas a cobrir na skill

- Mostrar plano com nível, esforço, orçamento e tempo por tarefa e total antes de qualquer spawn.
- Pedir aprovação e não disparar subagente antes do ok.
- Marcar dependências de assinatura como `interface` e organizar ondas (B e C com A).
- Identificar tarefa de risco alto (C, autorização) e dar a ela um revisor, só a ela.
- Não duplicar trabalho: o coordenador reescreveu B e C enquanto o subagente os fazia.
- Não declarar "feitas e verificadas" sem relato do subagente e revisão da tarefa de risco.
- Justificar modelo/esforço por tarefa, não só "haiku" para tudo.
