Leia só no Codex.

# Host: Codex

Fonte: https://learn.chatgpt.com/docs/agent-configuration/subagents.md (conferida em 2026-11-19).

## Ferramenta e parâmetros
- Ferramenta `collaboration.spawn_agent` (probe com codex-cli 0.169.0 autenticado, 2026-11-19): `task_name` (obrigatório; minúsculas, dígitos, `_`), `message` (obrigatório; o prompt da tarefa), `fork_turns` (`"all"` padrão | `"none"`), `model` (opcional; lista própria da sessão), `reasoning_effort` (opcional).
- **Sempre `fork_turns: "none"`**: sem ele o subagente herda o histórico da conversa (gasta contexto e viola o prompt enxuto), e `model`/`reasoning_effort` só valem com `"none"`.
- Omitir `model` ou `reasoning_effort` herda do pai. A lista de `model` aceita na sessão pode ser menor que o cache: use só valores que o esquema da ferramenta lista.
- Não use esforço `ultra`: ele delega tarefas sozinho, o que foge do orçamento.
- Disparar a onda: todas as chamadas de `spawn_agent` da onda na mesma resposta.
- Se o esquema da sessão divergir disto, vale o esquema.

## Configuração relevante
- Subagentes ligados por padrão (`agents.enabled = true`). Se `false`, não há subagentes: siga o passo 11 do `SKILL.md` (fallback) e avise.
- Padrões: `agents.default_subagent_model`, `agents.default_subagent_reasoning_effort`. Override por spawn vence.
- Limite: `agents.max_concurrent_threads_per_session` (alias legado `agents.max_threads`), exclui a thread principal. Leia em `$CODEX_HOME/config.toml` (padrão `~/.codex`) e `.codex/config.toml`; se não definido, use lotes de até 4 (a doc não diz o padrão). Se um disparo falhar por limite de threads, reduza o lote ao número que estava rodando e siga em lotes.
- Profundidade e turnos: a doc não fixa nenhum. Sem limite nativo de turnos: ponha o orçamento no prompt de cada tarefa.

## Descobrir modelos e esforços
- Leia `$CODEX_HOME/models_cache.json` (padrão `~/.codex`), campo `"models"`. Use só entradas com `visibility` = `"list"`.
- Esforços aceitos por modelo: `supported_reasoning_levels[].effort`. A doc cita `low`, `medium`, `high`, `xhigh`, `max`, `ultra`; valide contra o cache.
- Modelo da sessão: campo `model` de `config.toml` (ex.: `gpt-6.1-terra` (exemplo datado)).

## Mapear nível da tarefa
- O nome do modelo não diz o porte. O nível vira principalmente ESFORÇO sobre o modelo da sessão: barato = `low`, médio = `medium`, forte = `high`, dentro do que o modelo aceita. Escalada sobe um degrau (`low` → `medium` → `high`).
- Troque para modelo menor só se nome ou descrição o marcar como menor ou mais rápido (mini, nano, lite, flash, fast). Sem marca, não presuma porte.

## Registro por tarefa
- Anote modelo, esforço pedido e "aplicação confirmada" (sim só se o retorno ou o log mostrar o que rodou).
