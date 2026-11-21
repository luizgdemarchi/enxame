# Review 01 — ciclo 2026-11-19-skill-multiagente

- Alvo: `skill/enxame/**`, `scripts/*.sh`, `evals/rodar.sh` (sem git: snapshot dos arquivos
  em 2026-11-20).
- Cobertura: avaliação comportamental (C1–C8, `evals/resultados/`), revisor independente de
  texto × spec (sonnet, esforço alto), revisor de risco alto de T03 (onda 1).
- Exclusões: fixtures de `evals/` (dados de teste), `docs/`.
- Documentos: `spec.md`, `plan.md`, `evals/resultados/{RESUMO,c5-c7,c6,c8,baseline}.md`.
- Decisões do usuário nesta rodada (2026-11-20): (1) C6 aceita tarefa impossível bloqueada no
  plano com motivo, sem gastar agente, ou tentada e escalada uma vez; (2) Stilo × Codex:
  regra no `enxame` e ajuste no Stilo; (3) risco alto por contrato público só quando contrato
  existente é alterado ou removido.

Resumo: crítico 6 · alto 5 · médio 11 · baixo 6. Todos introduzidos neste ciclo, salvo nota.

## Achados

Formato compacto: cada achado traz Arquivo · Gravidade · Confiança · Classificação; O que
quebra; Como corrigir; Evidência; Contraprova. Origem: introduzido. Estado: aberto.

### 1. C3 literal falha
- `skill/enxame/SKILL.md:18` · crítico · alta · confirmado
- Quebra: grep de C3 do spec imprime a linha que cita `referencias/claude-code.md`.
- Corrigir: renomear `referencias/claude-code.md` → `referencias/claude.md` (e citações);
  `scripts/checar.sh` volta ao grep literal do spec (remover o `sed` de `claude-code`).
- Evidência: revisor rodou o grep: `SKILL.md:18: ... leia \`referencias/claude-code.md\``.
- Contraprova: o `checar.sh` passava só por causa do desvio introduzido no FIX de T03.

### 2. Tabela sem tipo de dependência (C5e)
- `SKILL.md` (passo 6, tabela) · crítico · alta · confirmado
- Quebra: B e C vão na onda certa, mas a tabela não mostra `interface`; C5e falhou em 2 de 3.
- Corrigir: coluna "depende de" com formato `A (interface)` / `A (pronta)` / `—`.
- Evidência: `c5-c7.md` C5e R1, R2.

### 3. Tarefas do principal sem nível, esforço e orçamento (C5c)
- `SKILL.md` (passo 6) · crítico · média · confirmado
- Quebra: linhas do principal com "—"; C5c falhou em R1.
- Corrigir: o principal também recebe nível/esforço da tabela de classes e orçamento do
  nível; coluna executor = `principal`.
- Evidência: `c5-c7.md` C5c R1.

### 4. Risco alto amplo demais (C5f, C6)
- `SKILL.md` (tabela de risco); `plan.md` D9; `spec.md` R2 · crítico · alta · confirmado
- Quebra: CLI nova com flags vira risco alto → revisor extra (C5f R2, R3; C6).
- Corrigir (decisão 3): "contrato público existente alterado ou removido".
- Evidência: "alto (D9: flags de CLI) / revisor RB".

### 5. `effort` e agrupamento só nas referências (C6)
- `SKILL.md` passo 7; `referencias/prompts.md` · crítico · alta · confirmado
- Quebra: com referência ilegível, os 6 disparos saíram sem `effort` e sem instrução de
  agrupar.
- Corrigir: passo 7 do `SKILL.md` lista campos obrigatórios de todo disparo (modelo,
  esforço, "agrupe chamadas independentes", orçamento, limite de linhas, "não dispare
  subagentes") e um prompt mínimo inline; `prompts.md` fica como versão completa.
- Evidência: `c6.md` itens 2 e 4.

### 6. Stilo no Codex assume pasta sem `.stilo/` (C5/C6 Codex)
- `SKILL.md` passo 0; `referencias/stilo.md` · crítico · alta · confirmado
- Quebra: Codex criou `.stilo/state.json` e abriu BRAINSTORM/SPEC em vez da tabela.
- Corrigir (decisão 2): passo 0 do `SKILL.md`: "sem `.stilo/state.json`, o pedido para
  executar com o enxame não é projeto novo do Stilo; não crie `.stilo/` nem abra o pipeline";
  e item novo no prompt do Stilo (§ 3 do `state.json`/hook: projeto novo só quando o usuário
  pede para começar um projeto).
- Evidência: `c5-c7.md` Codex; `c6.md` Codex (hash depois `d667f022`).

### 7. Leitura das referências negada
- `SKILL.md` passo 0; `evals/rodar.sh` · alto · alta · confirmado
- Quebra: `claude -p` nega Read em `~/.claude/skills/enxame/referencias/`; C8 b, d pararam,
  C6 e C8 e degradaram. No uso interativo vira pedido de permissão.
- Corrigir: `SKILL.md`: se a leitura for negada, dizer ao usuário como liberar a pasta da
  skill e, em projeto Stilo, não seguir sem `stilo.md`; `rodar.sh`: `--add-dir` da pasta da
  skill no Claude.
- Evidência: `c8.md` b, d, e.

### 8. Retorno acima do limite de linhas (C6)
- `referencias/prompts.md`; `SKILL.md` passo 8 · alto · média · confirmado
- Quebra: revisor de C devolveu ~19 linhas com limite 15.
- Corrigir: limite na primeira e na última linha do prompt; passo 8 trata excesso como
  desvio registrado.

### 9. Ficha sem campos de leitura, classe e orçamento
- `SKILL.md:36-46` · alto · alta · confirmado (leitura)
- Quebra: o prompt pede `{arquivos_leitura}` e orçamento, mas a ficha não os tem.
- Corrigir: campos `Lê:`, `Classe/Nível:`, `Orçamento:` na ficha.

### 10. Códigos internos do plano na saída
- `SKILL.md` (várias) · alto · alta · confirmado
- Quebra: usuário vê "D8 b", "D9"; não significam nada fora deste projeto.
- Corrigir: nomes descritivos ("corte: comando único", "risco: autorização").

### 11. Sessão não interativa encerra com onda pendente
- `SKILL.md` passo 7–8 · alto · baixa · hipótese
- Quebra: c8-e terminou com "Agora aguardo o retorno" após a onda 1.
- Corrigir: "não encerre a resposta com agentes da onda pendentes; espere todos voltarem".
- Contraprova: C6 Claude completou 2 ondas; pode ser efeito de agente em segundo plano.

### 12–22. Médios
12. Nível do revisor não decidível (`SKILL.md:106-119`) → "revisor: médio/médio, P".
13. Interface escrita no plano não chega ao dependente (`SKILL.md:55-57`, `prompts.md`) →
    campo `Interface:` inline no prompt.
14. Modelo `revisor` repete o hook do Stilo e conflita com o formato de achado do Stilo →
    `revisor-stilo` enxuto.
15. Limite de simultâneos do Codex indefinido (`codex.md:18`) → padrão 4, dividir ao primeiro
    erro de limite.
16. Retomada sem o plano (`SKILL.md:246-261`) → gravar tabela aprovada e fichas no
    `progresso.md` na aprovação.
17. `{pasta_detalhe}` não criada antes do disparo (`SKILL.md:192-203`) → criar pasta e
    exclusão do git no passo 7, antes do disparo.
18. Executor não proíbe subagentes (`prompts.md`) → "Não dispare subagentes." nos modelos.
19. Trilha curta no PLAN manda editar `plan.md` inexistente (`stilo.md:16,25`) → no PLAN
    curto, não reforçar.
20. Tabelas com lacunas (`SKILL.md:62-113`): "ou" no tamanho M; "dados" × "coleta";
    "pequenas" sem tamanho; tempo e conferência de onda dividida em lotes.
21. Revisão mandada pelo Stilo sem regra de aprovação (`stilo.md:19`) → dizer que segue a
    aprovação do Stilo (sem tabela).
22. `maxTurns` mencionado mas nunca aplicável (`claude.md:24`, `prompts.md:10`) → dizer que
    só vale com agente definido em arquivo e que a skill não instala nenhum.

### 23–28. Baixos
23. Fallback sem revisor separado, relato exige revisão (`SKILL.md:264-281`).
24. "passo 2/3–6" do `stilo.md` colide com passos do `SKILL.md` → "seção".
25. Exemplo T5 "(agrupadas, D8 d)" contradiz a regra de corte (`SKILL.md:158`).
26. Tabela sem total de orçamento (só tempo; spec não exige) — sugestão.
27. `rodar.sh`: `--extra` com caminho Windows quebra; `exit 0` mesmo com host falhando
    (revisor de T03) — preexistente da onda 1.
28. `checar.sh` C1 falha com SKILL.md em CRLF (revisor de T03) — sugestão.

## Critérios do spec

| Critério | Estado |
|---|---|
| C1, C2, C4 | atendido |
| C3 | **não atendido** (achado 1) |
| C5 | **não atendido** (2, 3, 4; Codex: 6) |
| C6 | **não atendido** (4, 5, 8; Codex: 6); G atendido pela decisão 1 |
| C7 | atendido |
| C8 | a, c atendidos; b, d, e não conclusivos (7) |
| Conferência por leitura | parcial (9, 12, 20) |

Próxima fase: `FIX` (há achados críticos e altos).

## Estado após FIX (2026-11-20)

| Achado | Estado | Onde |
|---|---|---|
| 1 | corrigido | referências renomeadas `host-claude.md`/`host-codex.md` (nome `claude.md` vira `CLAUDE.md` no Windows); `SKILL.md:20-21`; `scripts/checar.sh` C3 literal |
| 2 | corrigido | `SKILL.md:168,188` coluna "depende de" |
| 3 | corrigido | `SKILL.md:137,170,175` |
| 4 | corrigido | `SKILL.md:90-95`; `spec.md:37`; `plan.md` D9 |
| 5 | corrigido | `SKILL.md:215-230`; `prompts.md` |
| 6 | corrigido no enxame (`SKILL.md:16-18`, `stilo.md`); ajuste no Stilo vai no prompt da outra sessão |
| 7 | corrigido | `SKILL.md:24-26`; `evals/rodar.sh` `--add-dir` |
| 8 | corrigido | `SKILL.md:253-254`; `prompts.md` limite no início e no fim |
| 9 | corrigido | `SKILL.md:47-52` |
| 10 | corrigido | `SKILL.md` sem códigos (grep vazio) |
| 11 | corrigido (instrução) | `SKILL.md:236`; confirmação na reavaliação |
| 12 | corrigido | `SKILL.md:269` |
| 13 | corrigido | `SKILL.md:65-67,212`; `prompts.md` campo `Interface:` |
| 14 | corrigido | `prompts.md` `revisor-stilo`; `stilo.md` |
| 15 | corrigido | `host-codex.md:18` lotes de 4 |
| 16, 17 | corrigido | `SKILL.md:209-210,294` |
| 18 | corrigido | `prompts.md` "Não dispare subagentes." ×2 |
| 19, 21, 24 | corrigido | `stilo.md` |
| 20 | corrigido | `SKILL.md:75,84,115-116,127,146,250` |
| 22 | corrigido | `host-claude.md:24`; `prompts.md` |
| 23 | corrigido | `SKILL.md:303-304` |
| 25 | corrigido | `SKILL.md` exemplo T5 |
| 26 | aberto (baixo, sugestão) | total de orçamento não exigido pelo spec |
| 27 | aberto (baixo) | `rodar.sh` `--extra` com caminho Windows; `exit 0` |
| 28 | aberto (baixo) | `checar.sh` C1 com CRLF |
| C6/G | spec ajustado (decisão 1) | `spec.md:220`; `evals/checklists.md:22` |
