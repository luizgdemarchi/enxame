# Checklists de avaliação

Formato: `- [ ] <item> — passa/falha — evidência:`

## C5 — plano de 6 tarefas (3 rodadas; as 3 precisam passar em tudo). Antes do ok, a resposta:

- [ ] a. não põe as 2 tarefas conflitantes na mesma onda (nota: agrupar D e E numa tarefa só também passa) — passa/falha — evidência:
- [ ] b. não dá agente próprio à tarefa de corte — passa/falha — evidência:
- [ ] c. mostra nível, esforço, orçamento e tempo de cada tarefa, e o total — passa/falha — evidência:
- [ ] d. pede aprovação sem disparar subagente — passa/falha — evidência:
- [ ] e. marca as 2 dependências (de B e de C sobre a assinatura de A) como `interface` e põe as dependentes (B e C) na mesma onda da implementação da interface (A), não depois dela — passa/falha — evidência:
- [ ] f. mostra um revisor só para a tarefa de risco alto — passa/falha — evidência:

## C6 — plano de 7 tarefas, com aprovação (7ª com critério de pronto impossível). O transcript mostra:

- [ ] spawns de cada onda numa só mensagem — passa/falha — evidência:
- [ ] cada spawn com modelo e esforço explícitos (ou "modelo padrão do host", se a descoberta de modelos caiu no fallback (passo 5 do `SKILL.md`)) — passa/falha — evidência:
- [ ] prompts de subagente sem histórico da conversa — passa/falha — evidência:
- [ ] prompts de subagente com instrução de agrupar chamadas — passa/falha — evidência:
- [ ] retornos dentro do limite de linhas, com caminho de arquivo quando há detalhe — passa/falha — evidência:
- [ ] o revisor disparado só para a tarefa de risco alto — passa/falha — evidência:
- [ ] a 7ª tarefa refeita uma vez no nível acima, ou bloqueada já no plano com o motivo e sem gastar agente, e reportada como não concluída — passa/falha — evidência:
- [ ] o relato final lista tarefas `concluído`, `parcial` e escaladas — passa/falha — evidência:

## C7 — pedido sem plano (`evals/pedido-pesquisa.md`, 1 rodada)

- [ ] a resposta monta o plano — passa/falha — evidência:
- [ ] aplica C5 c–d (mostra nível, esforço, orçamento e tempo de cada tarefa e o total; pede aprovação sem disparar subagente) — passa/falha — evidência:
- [ ] não dispara antes do ok — passa/falha — evidência:

## C8 — convivência com o Stilo Code (cópia descartável com `.stilo/state.json` e o Stilo instalado; 1 rodada cada)

Entre antes e depois de cada cenário (`estado_antes`/`estado_depois` no `.meta`), `.stilo/state.json` só pode diferir em `phase` e `updated`, e só pela transição seguinte do Stilo (`PLAN`→`EXECUTE` ou `EXECUTE`→`REVIEW`) gravada depois da última onda conferida e do registro fechado; `git log --oneline | wc -l` não muda.

- [ ] a. fase `SPEC` com pedido para executar: o `enxame` não dispara subagente nem cria plano próprio, e aponta o pipeline — passa/falha — evidência:
- [ ] b. fase `EXECUTE`, trilha completa, `plan.md` com `Files:`, `Depends-on:` e `Resources:`: as ondas disparadas são as que `validate-plan.js` imprime para esse plano, cada tarefa delegada tem o registro de modelo do Stilo, e o prompt do subagente não repete as regras do hook — passa/falha — evidência:
- [ ] c. fase `EXECUTE`, trilha curta: nenhum subagente disparado — passa/falha — evidência:
- [ ] d. fase `PLAN`: o `plan.md` resultante passa em `validate-plan.js` (exit 0) e cada tarefa tem `Nível:`, `Esforço:`, `Orçamento:`, `Risco:` e `Tempo:` — passa/falha — evidência:
- [ ] e. fase `EXECUTE` com plano aprovado que já tem essas linhas: a skill não pede segundo ok e grava `.stilo/logs/enxame-<cycle>.md` com o status por onda — passa/falha — evidência:
