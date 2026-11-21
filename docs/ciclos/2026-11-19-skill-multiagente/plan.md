# Plano — skill `enxame`

- Ciclo: `2026-11-19-skill-multiagente`
- Spec: `docs/ciclos/2026-11-19-skill-multiagente/spec.md` (aprovado em 2026-11-19)
- Commit-base: sem git
- Tecnologia: Markdown (skill), Bash (scripts, Git Bash no Windows), Node 24 (projeto de
  exemplo e validador do Stilo), `claude` 2.1.326 e `codex` 0.169.0 em modo não interativo
  para as avaliações.

Todos os caminhos são relativos à raiz do projeto
(`C:\Users\luizg\Documents\claude code\skill agents\enxame`), exceto os marcados.

## Decisões fechadas

D1. **Layout.** Fonte da skill em `skill/enxame/`: `SKILL.md` e `referencias/`
(`host-claude.md`, `host-codex.md`, `stilo.md`, `prompts.md`). Tabelas de corte, risco, nível,
orçamento e tempo ficam no `SKILL.md`, porque toda execução usa todas. `referencias/stilo.md`
só é lida quando existe `.stilo/state.json`; a referência do host só no host
correspondente; `prompts.md` só na hora de disparar.

D2. **Idioma.** Texto da skill em português; a skill responde no idioma do usuário.

D3. **Pasta de trabalho (R9a, R18).** Fora do Stilo: `.enxame/<AAAA-MM-DD-HHMM>/` na raiz
do projeto do usuário, com `progresso.md` e um `<id>.md` por tarefa com detalhe; em repo
git, a skill garante a linha `.enxame/` em `.git/info/exclude` (local, não versionado) e
nunca mexe no `.gitignore`. Em projeto Stilo: `.stilo/logs/enxame-<cycle>.md` (progresso) e
`.stilo/logs/enxame-<cycle>/<id>.md` (detalhe).

D4. **Tamanho da tarefa.** P: até 1 arquivo e até 30 linhas alteradas, ou leitura de até 5
arquivos. M: até 3 arquivos ou até 150 linhas. G: o resto; tarefa G é dividida antes de ir
para o plano, salvo se for indivisível (dizer por quê).

D5. **Nível e esforço (R6, R17e).** Três classes, iguais às do Stilo:
| Classe | Nível | Esforço |
|---|---|---|
| edição mecânica verificável, busca, leitura, coleta | barato | baixo |
| lógica comum com teste, redação, síntese de pesquisa | médio | médio |
| arquitetura, segurança, permissões, dados, incerteza alta | forte | alto |
Na dúvida entre duas classes, a mais barata, porque R12 escala se falhar.

D6. **Orçamento padrão (R8).** barato: 8 chamadas, relatório de 10 linhas. médio: 20
chamadas, 15 linhas. forte: 40 chamadas, 25 linhas. revisor: 15 chamadas, 15 linhas. O
plano pode subir um valor com motivo escrito.

D7. **Tempo (R10), em minutos, faixa.**
| Nível | P | M | G |
|---|---|---|---|
| barato | 1–2 | 2–4 | 4–8 |
| médio | 2–4 | 4–8 | 8–15 |
| forte | 4–8 | 8–15 | 15–30 |
Tarefa feita pelo principal usa a mesma tabela. Onda = maior faixa da onda; total = soma.

D8. **Corte (R4).** A tarefa não ganha agente próprio se cumpre qualquer um: (a) é um
comando só, sem análise do resultado; (b) altera até 10 linhas num arquivo que o principal
já leu nesta sessão; (c) responde pergunta factual lendo até 2 arquivos conhecidos; (d) é P,
tem dependência `pronta` de outra tarefa e escreve os mesmos arquivos (agrupa com ela).

D9. **Risco alto (R2, R16).** Toca autenticação, autorização ou permissões; dados
persistidos ou migração; operação destrutiva (apagar, sobrescrever, forçar); contrato
público existente alterado ou removido (API exportada, formato de arquivo, flags de CLI
já usados por outros); criar algo novo não conta (decisão do usuário, 2026-11-20). Só isso. Incerteza alta sobe o
nível (D5), mas não cria revisor.

D10. **Escalada (R12).** barato → médio → forte; o esforço vai para o padrão do novo nível.

D11. **Modelos (R7).** Claude Code: os aliases do parâmetro `model` da ferramenta de
subagente, em ordem de porte pela documentação do host; alias de porte desconhecido não é
usado. Codex: modelos com `visibility: "list"` em `~/.codex/models_cache.json` e os
esforços de `supported_reasoning_levels`; como o nome não diz o porte, o nível vira
principalmente esforço sobre o modelo da sessão, e um modelo menor só entra quando o nome
ou a descrição o marcam como menor ou mais rápido (`mini`, `nano`, `lite`, `flash`, `fast`).
Nomes concretos só nas referências de host, com `(exemplo datado)`.

D12. **Instalação (R14).** `scripts/instalar.sh` apaga e recopia só
`~/.claude/skills/enxame` e `~/.agents/skills/enxame`. Se o Codex não listar a skill
instalada em `~/.agents/skills`, a execução para e volta ao `PLAN` (não instalar em outro
lugar por conta própria).

D13. **Avaliações.** Rodam a skill instalada, em cópias em `$TEMP/enxame-evals/<cenário>/`
(fora de qualquer projeto Stilo, para o `.stilo/` deste projeto não vazar), por
`evals/rodar.sh`. Claude: `claude -p --model sonnet --output-format stream-json --verbose
--max-turns <N> --permission-mode acceptEdits --allowedTools "Bash(node:*)" "Bash(npm:*)"
"Bash(git:*)" "Bash(ls:*)" "Bash(cat:*)"`. Codex: `codex exec --json --sandbox
workspace-write` (flags conferidas com `codex exec --help` em T03). Aprovação = retomar a
mesma sessão com `ok` (`claude -p --resume <id>`; `codex exec resume --last`). O avaliador é
um subagente sem o contexto da conversa, que lê só a saída gravada e o checklist de
`evals/checklists.md`. Nenhum avaliador vê o `SKILL.md`.

D14. **Formato do plano do `enxame` dentro do Stilo:** linhas extras abaixo do contrato,
exatamente `Nível:`, `Esforço:`, `Orçamento: <n> chamadas, <n> linhas`, `Risco: normal|alto`,
`Tempo: <a>–<b> min`. Este plano usa o mesmo formato.

## Tarefas

### Tarefa T01 — projeto de exemplo e pedidos das avaliações
ID: T01
Especialista: avaliação
Files:
- Create: evals/projeto-exemplo/package.json
- Create: evals/projeto-exemplo/src/notas.js
- Create: evals/projeto-exemplo/src/constantes.js
- Create: evals/projeto-exemplo/src/acesso.js
- Create: evals/projeto-exemplo/test/notas.test.js
- Create: evals/projeto-exemplo/README.md
- Create: evals/c6/impossivel.test.js
- Create: evals/plano-6-tarefas.md
- Create: evals/plano-7-tarefas.md
- Create: evals/pedido-pesquisa.md
- Create: evals/checklists.md
Depends-on: nenhum
Resources: nenhum
Nível: médio
Esforço: médio
Orçamento: 25 chamadas, 15 linhas
Risco: normal
Tempo: 4–8 min

Passos:
1. Projeto Node mínimo "notas": `package.json` com `"type": "module"` e
   `"scripts": {"test": "node --test"}`; `src/notas.js` com `criarNota(autor, texto)` e
   `listar()` em memória; `src/constantes.js` com `export const LIMITE = 100;`;
   `src/acesso.js` com `podeApagar(usuario, nota)` que hoje retorna sempre `true`;
   `test/notas.test.js` com 2 testes que passam; `README.md` com título e uma seção "Uso".
   Verificação: `cd evals/projeto-exemplo && npm test` → 2 testes passam.
2. `evals/plano-6-tarefas.md`: o pedido em texto livre ("execute este plano com o enxame")
   e 6 tarefas, sem formato Stilo:
   - A: implementar `exportar(notas, formato)` em `src/exportar.js`, JSON e CSV;
   - B: criar `src/cli.js` que chama `exportar` (precisa só da assinatura de A);
   - C: criar `src/exportar-seguro.js`, que só exporta notas do próprio autor, usando a
     assinatura de A (precisa só da assinatura; risco alto, autorização);
   - D: acrescentar seção "Exportação" ao `README.md`;
   - E: acrescentar seção "Testes" ao `README.md` (conflita com D);
   - F: trocar `LIMITE` de 100 para 200 em `src/constantes.js` (corte, D8 b ou a).
   Não marcar no arquivo quais tarefas conflitam, são triviais ou têm risco: a skill tem
   que perceber.
3. `evals/plano-7-tarefas.md`: o mesmo, mais G: "fazer `npm test` passar incluindo
   `test/impossivel.test.js`, sem editar esse teste". `evals/c6/impossivel.test.js` afirma
   `assert.equal(1, 2)`.
4. `evals/pedido-pesquisa.md`: "Use o enxame. Compare 3 bibliotecas JS de leitura de CSV
   (papaparse, csv-parse, fast-csv) em licença, última versão, tamanho e suporte a
   streaming, e entregue `docs/comparacao-csv.md`."
5. `evals/checklists.md`: um bloco por critério, copiando literalmente C5 a–f, C6, C7 e
   C8 a–e do spec, cada item com "passa / falha / evidência (trecho da saída)". Para C5a,
   anotar: agrupar D e E numa tarefa só também passa.
   Verificação: `grep -c '^- \[ \]' evals/checklists.md` ≥ 16.

### Tarefa T02 — referências de host
ID: T02
Especialista: pesquisa
Files:
- Create: skill/enxame/referencias/host-claude.md
- Create: skill/enxame/referencias/host-codex.md
Depends-on: nenhum
Resources: nenhum
Nível: médio
Esforço: médio
Orçamento: 25 chamadas, 20 linhas
Risco: normal
Tempo: 4–8 min

Passos:
1. `host-claude.md` (até 60 linhas, primeira linha: "Leia só no Claude Code."): como
   disparar subagente com `model` (só alias) e `effort`, no mesmo turno para paralelo;
   limite de simultâneos (padrão 20, `CLAUDE_CODE_MAX_CONCURRENT_SUBAGENTS`); profundidade
   (padrão 3); `maxTurns` só em agente definido em arquivo; como descobrir os aliases (o
   esquema da ferramenta de subagente na sessão) e a ordem de porte (exemplo datado:
   `haiku < sonnet < opus`); fonte: https://code.claude.com/docs/en/sub-agents.
2. `host-codex.md` (até 60 linhas, primeira linha: "Leia só no Codex."): subagentes ligados por
   padrão; override por spawn de modelo e esforço; limite
   `agents.max_concurrent_threads_per_session` (alias `agents.max_threads`); descoberta por
   `~/.codex/models_cache.json` (D11); fonte:
   https://learn.chatgpt.com/docs/agent-configuration/subagents.md.
   Confirmar o nome exato dos parâmetros de modelo e esforço da ferramenta de spawn: na
   documentação e, se ela não disser, com `codex exec --json "Liste o nome exato dos
   parâmetros da sua ferramenta de criar subagente. Não crie nenhum."` em `$TEMP`. Registrar
   a fonte da confirmação no arquivo.
   Verificação: `grep -c 'exemplo datado' skill/enxame/referencias/*.md` ≥ 1 por arquivo, e
   `wc -l` ≤ 60 em cada.

### Tarefa T03 — scripts de instalação, checagem e avaliação
ID: T03
Especialista: ferramentas
Files:
- Create: scripts/instalar.sh
- Create: scripts/checar.sh
- Create: evals/rodar.sh
Depends-on: nenhum
Resources: nenhum
Nível: médio
Esforço: médio
Orçamento: 25 chamadas, 15 linhas
Risco: alto
Tempo: 4–8 min

Risco alto porque `instalar.sh` apaga diretórios (D9: operação destrutiva).

Passos:
1. `scripts/instalar.sh`: `set -euo pipefail`; para cada destino em
   `$HOME/.claude/skills/enxame` e `$HOME/.agents/skills/enxame`: recusa se o caminho não
   termina em `/skills/enxame`, `rm -rf` só desse caminho, `mkdir -p` do pai, `cp -r
   skill/enxame` para ele. Imprime os dois destinos.
2. `scripts/checar.sh`: roda C1, C2, C3 e C4 do spec, cada um imprimindo `C1 ok` ou
   `C1 FALHOU: <motivo>`; sai com 1 se algum falhar. C3 exclui `referencias/host-claude.md`
   e `referencias/host-codex.md` do grep, como o spec permite.
3. `evals/rodar.sh <cenario> <host> <rodada> [fixture]`: cria
   `$TEMP/enxame-evals/<cenario>-<host>-<rodada>/` limpo, copia `evals/projeto-exemplo`
   (e a fixture Stilo, se dada) para lá, faz `git init` + commit inicial dentro da cópia,
   grava `sha256sum .stilo/state.json` (se existir) e `git log --oneline | wc -l`, roda o
   host com o pedido do cenário (D13), grava a saída em
   `evals/resultados/<cenario>-<host>-<rodada>.jsonl`, e grava hash e contagem depois em
   `evals/resultados/<cenario>-<host>-<rodada>.meta`. Aceita `--resume "<texto>"` para
   retomar a última sessão daquela cópia. Conferir as flags de `codex exec --help` e
   `claude --help` antes de escrevê-las.
   Verificação: `bash -n` nos três; `scripts/instalar.sh` recusa um destino adulterado
   (testar trocando a variável num subshell); `evals/rodar.sh` sem argumentos imprime uso
   e sai com 2.

### Tarefa T04 — fixtures do Stilo para C8
ID: T04
Especialista: avaliação
Files:
- Create: evals/stilo/spec-fase/.stilo/state.json
- Create: evals/stilo/spec-fase/docs/ciclos/2026-11-20-exportar/spec.md
- Create: evals/stilo/execute-completa/.stilo/state.json
- Create: evals/stilo/execute-completa/docs/ciclos/2026-11-20-exportar/spec.md
- Create: evals/stilo/execute-completa/docs/ciclos/2026-11-20-exportar/plan.md
- Create: evals/stilo/execute-curta/.stilo/state.json
- Create: evals/stilo/execute-curta/docs/ciclos/2026-11-20-limite/ciclo.md
- Create: evals/stilo/plan-fase/.stilo/state.json
- Create: evals/stilo/plan-fase/docs/ciclos/2026-11-20-exportar/spec.md
- Create: evals/stilo/execute-aprovada/.stilo/state.json
- Create: evals/stilo/execute-aprovada/docs/ciclos/2026-11-20-exportar/spec.md
- Create: evals/stilo/execute-aprovada/docs/ciclos/2026-11-20-exportar/plan.md
- Create: evals/stilo/pedidos.md
Depends-on: nenhum
Resources: nenhum
Nível: médio
Esforço: médio
Orçamento: 25 chamadas, 15 linhas
Risco: normal
Tempo: 4–8 min

Passos:
1. Estados no formato do Stilo 0.2.0 (`version`, `project`, `phase`, `cycle`,
   `reviewRound`, `editorialReviewRound`, `updated`), um por cenário: SPEC, EXECUTE, EXECUTE
   (trilha curta: só `ciclo.md`, sem `plan.md`), PLAN, EXECUTE.
2. Specs curtos (até 25 linhas) do recurso "exportar notas" do projeto de exemplo.
3. `execute-completa/.../plan.md`: 4 tarefas no contrato do Stilo (`ID:`, `Especialista:`,
   `Files:`, `Depends-on:`, `Resources:`), uma delas com `Resources: port:127.0.0.1:4173` e
   outra com o mesmo recurso, sem as linhas do `enxame`. `execute-aprovada/.../plan.md`: o
   mesmo, com as linhas de D14 em cada tarefa e a nota "Aprovado pelo usuário em
   2026-11-20".
4. `pedidos.md`: o pedido de cada cenário (a: "use o enxame e execute agora"; b, e: "siga
   com o EXECUTE usando o enxame"; c: idem; d: "escreva o plan.md usando o enxame").
   Verificação: `node <plugin stilo>/scripts/validate-plan.js` nos dois `plan.md` → exit 0,
   e o de `execute-completa` imprime as duas tarefas com a mesma porta em ondas diferentes.
   `<plugin stilo>` = pasta irmã de `modules/` indicada no bloco de estado do Stilo.

### Tarefa T05 — linha de base sem a skill
ID: T05
Especialista: avaliação
Files:
- Create: evals/resultados/baseline-claude-1.jsonl
- Create: evals/resultados/baseline.md
Depends-on: T01, T03
Resources: dir:$TEMP/enxame-evals/baseline-claude-1
Nível: médio
Esforço: baixo
Orçamento: 12 chamadas, 15 linhas
Risco: normal
Tempo: 4–8 min

Passos:
1. Antes de instalar a skill, rodar `evals/rodar.sh baseline claude 1` com o pedido de
   `plano-6-tarefas.md` trocando "com o enxame" por "com vários agentes em paralelo,
   gastando o mínimo", `--max-turns 30`. Conferir antes que `~/.claude/skills/enxame` não
   existe.
2. Um avaliador (subagente, nível médio) aplica o checklist C5 a–f à saída e grava em
   `evals/resultados/baseline.md`: cada item passa/falha com o trecho, e as justificativas
   do agente nas palavras dele.
   Verificação: `baseline.md` tem as 6 linhas C5a–C5f.

### Tarefa T06 — referência do Stilo e modelos de prompt
ID: T06
Especialista: instruções
Files:
- Create: skill/enxame/referencias/stilo.md
- Create: skill/enxame/referencias/prompts.md
Depends-on: nenhum
Resources: nenhum
Nível: forte
Esforço: alto
Orçamento: 30 chamadas, 20 linhas
Risco: normal
Tempo: 8–15 min

Passos:
1. `stilo.md` (primeira linha: "Leia só quando existir `.stilo/state.json` subindo a partir
   do diretório atual."): R17 a–n em forma de instrução, na ordem em que o agente decide
   (fase → trilha → plano → validador → aprovação → disparo → registro → progresso).
   Inclui o formato de D14 e o caminho do validador (pasta irmã de `modules/` do bloco de
   estado; `--json` se aceito, senão linhas `Onda N: ...`). Até 80 linhas.
2. `prompts.md`: modelo de prompt do executor (até 40 linhas) com os campos de R9 e o
   retorno de R9a; instrução de agrupar chamadas (R8a); contagem das próprias chamadas e
   parada em `parcial`; variante curta para projeto Stilo que omite o que o hook do Stilo
   já injeta (R17g). Modelo do revisor (até 25 linhas) para R16. Modelo do registro de
   modelo do Stilo (R17h).
   Verificação: `awk` conta as linhas entre os marcadores de cada modelo: executor ≤ 40,
   revisor ≤ 25.

### Tarefa T07 — SKILL.md e testes de gatilho
ID: T07
Especialista: instruções
Files:
- Create: skill/enxame/SKILL.md
- Create: evals/gatilhos.md
Depends-on: T05, T02, T06
Resources: nenhum
Nível: forte
Esforço: alto
Orçamento: 40 chamadas, 25 linhas
Risco: normal
Tempo: 15–30 min

Passos:
1. Ler `evals/resultados/baseline.md`: o texto da skill responde às falhas observadas (forma
   segue a falha, conforme o módulo de autoria de skill do Stilo).
2. Frontmatter: `name: enxame`; `description` começando por "Use quando", com gatilhos
   reais ("vários agentes", "em paralelo", "adiantar trabalho", "executar o plano",
   "enxame"), o limite "em projeto Stilo, só em PLAN, EXECUTE e revisões em subagente"
   (R17m) e quando não usar (tarefa única e pequena).
3. Corpo, nesta ordem: detectar Stilo (se sim, ler `referencias/stilo.md`) e host (ler a
   referência do host); entrada (R1); decomposição (R2, R2a) com D4, D8, D9; travas (R3);
   ondas (R5) e divisão pelo limite de simultâneos; nível, esforço, orçamento e tempo (D5,
   D6, D7, R7 com D11); tabela de aprovação (R11, formato literal de exemplo); disparo
   (ler `referencias/prompts.md`; uma onda por mensagem); conferência e escalada (R12,
   D10); revisor (R16); progresso e retomada (R18, D3); fallback sem subagentes (R15);
   relato final.
4. `evals/gatilhos.md`: 5 pedidos que devem disparar e 3 que não devem, cada um com a
   decisão esperada; conferir lendo só a `description`.
   Verificação: `scripts/checar.sh` passa C1, C2 e C3 (C4 só após T08); `wc -l` do
   `SKILL.md` ≤ 300.

### Tarefa T08 — instalar e checar
ID: T08
Especialista: ferramentas
Files:
- Create: evals/resultados/estatico.md
Depends-on: T03, T07
Resources: dir:$HOME/.claude/skills/enxame, dir:$HOME/.agents/skills/enxame
Nível: barato
Esforço: baixo
Orçamento: 6 chamadas, 10 linhas
Risco: normal
Tempo: 1–2 min

Feita pelo principal (corte D8 a: dois comandos).

Passos:
1. `bash scripts/instalar.sh && bash scripts/checar.sh | tee evals/resultados/estatico.md`
   → C1–C4 `ok`.
2. `codex exec "Quais skills você tem disponíveis? Responda só os nomes, um por linha."`
   em `$TEMP` → lista contém `enxame`. Se não contém: parar e voltar ao `PLAN` (D12).
   Gravar a saída no fim de `estatico.md`.

### Tarefa T09 — avaliação C5 e C7
ID: T09
Especialista: avaliação
Files:
- Create: evals/resultados/c5-claude-1.jsonl
- Create: evals/resultados/c5-claude-2.jsonl
- Create: evals/resultados/c5-claude-3.jsonl
- Create: evals/resultados/c5-codex-1.jsonl
- Create: evals/resultados/c7-claude-1.jsonl
- Create: evals/resultados/c5-c7.md
Depends-on: T08, T01
Resources: dir:$TEMP/enxame-evals/c5
Nível: médio
Esforço: baixo
Orçamento: 20 chamadas, 15 linhas
Risco: normal
Tempo: 8–15 min

Passos:
1. `evals/rodar.sh c5 claude 1..3` e `evals/rodar.sh c5 codex 1` com
   `plano-6-tarefas.md`, `--max-turns 30`; `evals/rodar.sh c7 claude 1` com
   `pedido-pesquisa.md`.
2. Um avaliador por saída (subagentes nível médio, disparados juntos) aplica o checklist e
   devolve passa/falha por item com trecho. Consolidar em `c5-c7.md`.
   Verificação: C5 a–f passam nas 3 rodadas do Claude; C7 passa; a rodada do Codex é
   registrada (falha nela é achado, não bloqueio do critério C5, que o spec fixa em 3
   rodadas).

### Tarefa T10 — avaliação C6
ID: T10
Especialista: avaliação
Files:
- Create: evals/resultados/c6-claude-1.jsonl
- Create: evals/resultados/c6-codex-1.jsonl
- Create: evals/resultados/c6.md
Depends-on: T08, T01
Resources: dir:$TEMP/enxame-evals/c6
Nível: médio
Esforço: médio
Orçamento: 25 chamadas, 15 linhas
Risco: normal
Tempo: 15–30 min

Passos:
1. `evals/rodar.sh c6 claude 1` e `evals/rodar.sh c6 codex 1` com `plano-7-tarefas.md`,
   copiando `evals/c6/impossivel.test.js` para `test/` da cópia, `--max-turns 80`; depois
   `--resume "ok"` em cada um.
2. Avaliador aplica o checklist C6 lendo os eventos de chamada de subagente no `.jsonl`
   (modelo, esforço, agrupamento por mensagem, texto do prompt, retornos). Consolidar em
   `c6.md`.
   Verificação: todos os itens de C6 passam no Claude; Codex registrado como em T09.

### Tarefa T11 — avaliação C8 (Stilo)
ID: T11
Especialista: avaliação
Files:
- Create: evals/resultados/c8-a.jsonl
- Create: evals/resultados/c8-b.jsonl
- Create: evals/resultados/c8-c.jsonl
- Create: evals/resultados/c8-d.jsonl
- Create: evals/resultados/c8-e.jsonl
- Create: evals/resultados/c8.md
Depends-on: T08, T04
Resources: dir:$TEMP/enxame-evals/c8
Nível: médio
Esforço: médio
Orçamento: 25 chamadas, 15 linhas
Risco: normal
Tempo: 15–30 min

Passos:
1. `evals/rodar.sh c8-<x> claude 1 evals/stilo/<fixture>` para a=spec-fase,
   b=execute-completa, c=execute-curta, d=plan-fase, e=execute-aprovada, com os pedidos de
   `evals/stilo/pedidos.md`. Em b, depois do plano mostrado, `--resume "ok"`.
2. Conferir em cada `.meta`: `estado_antes`/`estado_depois` diferem no máximo em `phase` e
   `updated`, pela transição seguinte do Stilo depois do relato final (spec C8), e contagem de
   commits igual antes e depois. Em b, comparar as ondas disparadas com a saída de `validate-plan.js` sobre o
   `plan.md` da fixture. Em d, rodar `validate-plan.js` no `plan.md` gerado (exit 0) e
   `grep -c` das 5 linhas de D14 por tarefa. Em e, conferir que não houve pedido de ok e
   que `.stilo/logs/enxame-<cycle>.md` existe na cópia.
3. Avaliador aplica o checklist C8; consolidar em `c8.md`, registrando se o hook do Stilo
   rodou no modo não interativo (se não rodou, é limitação declarada de C8).

### Tarefa T12 — resumo da avaliação
ID: T12
Especialista: avaliação
Files:
- Create: evals/resultados/RESUMO.md
Depends-on: T09, T10, T11
Resources: nenhum
Nível: barato
Esforço: baixo
Orçamento: 6 chamadas, 10 linhas
Risco: normal
Tempo: 1–2 min

Feita pelo principal. Tabela critério → passa/falha → arquivo de evidência, para C1–C8,
com limitações. Falha em qualquer critério leva ao `REVIEW` como achado; não se corrige a
skill nem o checklist dentro desta tarefa.

## Ondas

Calculadas por `validate-plan.js` (ver saída abaixo da aprovação):

1. T01, T02, T03, T04, T06 — paralelas (arquivos disjuntos, sem recursos).
2. T05 — linha de base, antes de a skill existir.
3. T07 — `SKILL.md`.
4. T08 — instalação (principal).
5. T09, T10, T11 — avaliações em diretórios separados.
6. T12 — resumo (principal).

Tempo estimado: onda 1 8–15 · onda 2 4–8 · onda 3 15–30 · onda 4 1–2 · onda 5 15–30 ·
onda 6 1–2 → **total 44–87 min** (aproximado). Revisor de T03 (risco alto): nível médio,
15 chamadas, 15 linhas, 2–4 min, logo depois de T03, dentro da folga da onda 1.

## Foco da revisão

- T07: tabelas decidíveis (D4–D9) copiadas sem mudar números; ordem dos passos; a
  `description` separa os pedidos de `evals/gatilhos.md`.
- T06: R17 completo, em especial a, f, k; modelo de prompt sem histórico e com agrupamento.
- T03: `instalar.sh` nunca apaga fora de `*/skills/enxame`; `rodar.sh` roda fora de
  qualquer `.stilo/` (o deste projeto contaminaria C5–C7).
- T02: nome dos parâmetros de spawn do Codex confirmado por fonte citada.
- C3: falso positivo ou negativo do grep de nomes de modelo.
