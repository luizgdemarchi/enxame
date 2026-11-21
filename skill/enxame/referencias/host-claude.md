Leia só no Claude Code.

# Host: Claude Code

Fonte: https://code.claude.com/docs/en/sub-agents (conferida em 2026-11-19).

## Disparar subagente
- Use a ferramenta `Agent`. Por chamada, passe:
  - `model`: só alias (nunca ID completo nem `inherit`). Precedência: parâmetro da chamada > campo `model` do agente > `CLAUDE_CODE_SUBAGENT_MODEL` > modelo da sessão.
  - `effort`: `low` | `medium` | `high` | `xhigh` | `max`. Os níveis aceitos dependem do modelo. Exige Claude Code v2.1.292 ou mais novo; vale para subagente que não seja fork.
- Onda paralela: emita todas as chamadas `Agent` da onda na MESMA mensagem; em mensagens separadas elas rodam em sequência. (A página de docs não descreve essa mecânica; é o comportamento da ferramenta.)

## Descobrir os aliases (não fixe modelos)
- Leia o enum do parâmetro `model` no esquema da ferramenta de subagente da sessão. Só use alias que esteja ali.
- Ordem de porte, do menor ao maior (exemplo datado): haiku < sonnet < opus (exemplo datado).
- Alias cujo porte você não conhece não é usado. Ex.: `fable` (exemplo datado) aparece nos docs, mas sem ordem de porte conhecida fica de fora.
- Mapeie nível da tarefa para alias pela ordem de porte e use `effort` para ajuste fino.

## Limites
- Simultâneos: padrão 20 por sessão (`CLAUDE_CODE_MAX_CONCURRENT_SUBAGENTS`, inteiro positivo, v2.1.217+). Acima disso a chamada falha com `Concurrent subagent limit reached` e o erro manda não repetir. Divida a onda em lotes de no máximo o limite; retomar subagente já terminado também ocupa vaga.
- Profundidade: padrão 3 camadas abaixo da conversa principal (`CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH`; `1` desliga o aninhamento). Subagente da onda não deve disparar outros.

## Orçamento por tarefa
- `maxTurns` só existe em agente definido em arquivo (`.claude/agents/*.md`) ou em `--agents` JSON; NÃO é parâmetro da ferramenta `Agent`. A skill não instala agente definido, então `maxTurns` não se aplica: o orçamento (chamadas de ferramenta e linhas do retorno) vai no prompt de cada tarefa.

## Aplicação forçada
- Se `CLAUDE_CODE_SUBAGENT_MODEL_FORCE=1` estiver ligado (v2.1.257+), o modelo pedido é ignorado e o agente não consegue passar `model`. Todos os subagentes usam o modelo forçado.
- Nesse caso registre no relatório: "aplicação confirmada: não".
- Sem a variável, registre o alias pedido e "aplicação confirmada: sim" apenas se o retorno ou o log mostrar o modelo usado.

## Checklist da onda
1. Ler o enum de `model` e listar aliases de porte conhecido.
2. Verificar `CLAUDE_CODE_MAX_CONCURRENT_SUBAGENTS` e `CLAUDE_CODE_SUBAGENT_MODEL_FORCE` no ambiente.
3. Cortar a onda no limite; disparar o lote numa só mensagem.
4. Cada prompt leva o orçamento; registrar modelo, `effort` e aplicação confirmada por tarefa.
