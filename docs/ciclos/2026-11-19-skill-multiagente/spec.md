# Spec — skill `enxame`

- Ciclo: `2026-11-19-skill-multiagente`
- Trilha: completa
- Commit-base: sem git (projeto não versionado; avaliações usam cópia da pasta no
  scratchpad, nunca a pasta do projeto)
- `reviewRound` de início: 0

## Problema

Executar um plano com um agente só é lento: tarefas independentes rodam em fila. Disparar
muitos agentes sem critério gasta muito, porque cada agente começa do zero (relê contexto,
instruções e arquivos), usa o modelo caro por padrão e pode pisar no trabalho de outro.

## Objetivo

Uma skill que, no Claude Code e no Codex, transforma um pedido ou um plano em ondas de
subagentes paralelos, com o maior paralelismo útil, o menor gasto e o menor tempo. Cada
agente recebe modelo, esforço, limite de chamadas e limite de contexto proporcionais à
tarefa. Nada roda sem o ok do usuário.

## Não-objetivos

- Estimar custo em dinheiro ou tokens.
- Isolar agentes com git worktree.
- Interface gráfica, agendamento ou execução em nuvem.
- Substituir o raciocínio do agente principal por script (abordagem A: só instruções).

## Requisitos

R1. **Entrada.** Aceita um plano pronto (texto ou arquivo) ou um pedido sem plano. Sem
plano, a skill monta um antes de seguir, exceto em projeto Stilo Code (R17).

R2. **Decomposição.** O plano vira uma lista de tarefas. Cada tarefa tem: id, objetivo,
entregável, critério de pronto, dependências, conjunto de arquivos que ela escreve
(incluindo os que vai criar) e risco (normal ou alto, por critério decidível na skill:
por exemplo segurança, dados persistidos, operação destrutiva, contrato público existente alterado ou removido — criar algo novo não conta).

R2a. **Dependências com tipo.** Cada dependência é `interface` (a tarefa só precisa de uma
interface, assinatura, formato ou esboço definido) ou `pronta` (precisa do trabalho
concluído). Para cada `pronta`, a skill pergunta se a tarefa poderia começar contra uma
interface definida; se sim, vira `interface`. Quando várias tarefas dependem da interface
de outra, a definição dessa interface vira tarefa própria e pequena na primeira onda, e
as dependentes rodam em paralelo com a implementação.

R3. **Travas.** Duas tarefas que escrevem o mesmo arquivo nunca ficam na mesma onda. Leitura
não trava. Trava declarada como diretório ou glob trava todos os arquivos que ela cobre.
Tarefa que edita arquivo escrito por tarefa de onda anterior declara dependência dela.
Recursos exclusivos também travam: porta, banco de dados, diretório de saída, perfil de
navegador. Duas tarefas com o mesmo recurso não dividem onda.

R4. **Corte de agente inútil.** A skill traz um critério decidível (lista de condições
objetivas, por exemplo: uma edição em um arquivo já conhecido, ou um comando só) para
tarefa que não ganha agente próprio. Essa tarefa é feita pelo agente principal ou agrupada
com outra do mesmo contexto. Sequência de tarefas pequenas com dependência `pronta` sobre
os mesmos arquivos vira uma tarefa só. O número de agentes é o máximo que respeita R3 e
R4.

R5. **Ondas.** Uma tarefa está liberada quando suas dependências `interface` têm a
interface definida e suas dependências `pronta` estão concluídas. Tarefas liberadas e sem
conflito de trava formam uma onda e são disparadas juntas, numa só mensagem. A onda
seguinte só começa quando a anterior foi conferida.

R6. **Seletor de nível.** Cada tarefa recebe um nível de capacidade (barato, médio, forte)
e um esforço (baixo, médio, alto) por uma tabela decidível na skill (tipo de tarefa,
ambiguidade, risco, tamanho). Regra: o nível mais barato que provavelmente resolve.

R7. **Descoberta de modelos.** As regras da skill não fixam nomes de modelo. Na execução, o
agente identifica os modelos e esforços que o host aceita naquela sessão (pelo esquema da
ferramenta de spawn, pela configuração ou pela documentação do host) e os ordena por porte
relativo dentro da família (menor/mais rápido < intermediário < maior). Cada nível vai
para o menor modelo que o atende. "Mais barato" é porte relativo, não preço. Sem conseguir
identificar, usa o modelo padrão do host e o plano diz "modelo padrão do host". Nome de
modelo citado como exemplo leva o marcador literal `(exemplo datado)` na mesma linha.

R8. **Orçamento por agente.** Cada tarefa recebe um limite de chamadas de ferramenta, uma
lista de arquivos que pode ler e um tamanho máximo de relatório em linhas. Onde o host
tem limite nativo aplicável (no Claude Code, `maxTurns` em agentes definidos), a skill o
usa; nos demais casos, o limite vai escrito no prompt do subagente, que conta as próprias
chamadas. Ao atingir o limite, o subagente para e devolve resultado marcado `parcial`.

R8a. **Chamadas agrupadas.** O prompt do subagente manda agrupar leituras e comandos
independentes numa só chamada (um comando composto ou um script curto) em vez de uma
chamada por item, sempre que o host permitir. Chamadas independentes de ferramentas
diferentes saem na mesma mensagem.

R9. **Prompt enxuto do subagente.** A skill traz um modelo de prompt com: objetivo,
arquivos permitidos, arquivos travados por outros na mesma onda, critério de pronto,
orçamento e formato de retorno. O contexto se limita ao objetivo geral em até 5 linhas, à
ficha da tarefa e ao resultado das tarefas de que ela depende diretamente. Nada de
histórico da conversa nem resultado de tarefas não relacionadas.

R9a. **Retorno curto mais arquivo.** O subagente devolve no chat só: status
`concluído`/`parcial`/`bloqueado` (o mesmo vocabulário do Stilo Code), arquivos alterados,
verificação rodada com as linhas decisivas e o que falta, em até o limite de linhas de R8,
e o caminho de um arquivo de detalhe, quando houver detalhe. A pasta desses arquivos fica
fora do que o git versiona (ignorada ou temporária) e nunca dentro de `.stilo/`, exceto
`.stilo/logs/` em projeto Stilo Code. Tarefas dependentes recebem o caminho, não o
conteúdo.

R10. **Estimativa de tempo.** A skill traz uma tabela de faixas de tempo por nível e
tamanho. O plano mostra o tempo por tarefa, por onda (a tarefa mais lenta da onda, incluindo
as feitas pelo principal) e o total (soma das ondas; no fallback de R15, soma das tarefas),
declarado como aproximado.

R11. **Aprovação.** Antes de disparar, a skill mostra: tarefas, ondas, nível/modelo,
esforço, orçamento e tempo estimado, e espera o ok do usuário (em projeto Stilo, ver
R17k). Se o usuário cortar ou mudar
tarefas, a skill refaz ondas e estimativa e pede ok de novo.

R12. **Conferência e escalada.** Após cada onda, o agente principal confere cada entregável
contra o critério de pronto: comando ou teste quando existir; senão, checklist do critério
(para pesquisa e documento: cobertura do pedido e fontes citadas). Antes de escalar, a
skill separa a causa: falha de ambiente (comando ausente, permissão, sandbox, rede,
dependência, teste instável) é corrigida ou registrada, sem trocar de modelo; só falha de
capacidade (resultado errado com o ambiente íntegro) faz a tarefa `parcial` ou `bloqueado`
ser refeita uma vez no nível acima, com a evidência da falha. Se já estava no nível forte,
ou se falhar de novo, a skill para essa linha de trabalho e reporta ao usuário. Ondas respeitam o limite
de agentes simultâneos do host; onda maior que o limite é dividida.

R13. **Escopo de trabalho.** Serve para código, pesquisa e documentos.

R14. **Hosts.** Um único diretório `enxame/` (com `SKILL.md` e referências) funciona nos
dois hosts. A instalação copia o diretório inteiro para `~/.claude/skills/enxame/` e
`~/.agents/skills/enxame/`. Detalhes de cada host ficam numa referência própria, que o
`SKILL.md` manda ler só no host correspondente.

R15. **Fallback sem subagentes.** Se o host não puder criar subagentes, a skill executa as
tarefas em sequência no agente principal, na ordem das ondas, e diz isso.

R16. **Revisor para risco alto.** Tarefa de risco alto (R2) ganha, depois de concluída, um
revisor separado, sem o contexto do executor, que recebe só a ficha, o critério de pronto
e o resultado, e devolve achados no formato de R9a. Tarefa de risco normal não tem
revisor. O revisor aparece no plano de R11, com nível, orçamento e tempo próprios; achado
que bloqueia volta ao executor uma vez, e depois segue R12.

R17. **Convivência com o Stilo Code.** Projeto Stilo Code é o que tem `.stilo/state.json`
achado subindo a partir do diretório atual. Nele, o Stilo decide o quê e quando; o
`enxame` só decide como paralelizar com pouco gasto. Regras:
  a. Enquanto roda (da leitura do plano ao relato final), o `enxame` nunca grava
     `.stilo/state.json`, nunca muda de fase, nunca faz commit nem push, e não escreve em
     `.stilo/` fora de `.stilo/logs/`. Depois do relato final, a fase seguinte segue a regra
     do Stilo: o coordenador a grava sem perguntar ao usuário, se a fase terminou pelo
     critério do Stilo (decisão do usuário, review 03).
  b. Só dispara subagentes na fase `EXECUTE` (implementadores) e nas revisões que o próprio
     Stilo manda fazer em subagente. Em `BRAINSTORM` e `SPEC` não faz nada. Não monta plano
     próprio fora do `plan.md` do Stilo.
  c. **No `PLAN` do Stilo, o `enxame` reforça o `plan.md`:** aplica R2a (a definição de
     interface vira tarefa própria, e quem só precisa dela passa a depender só dela), R4
     (junta cadeias de tarefas pequenas) e acrescenta a cada tarefa, abaixo do contrato do
     Stilo, as linhas `Nível:`, `Esforço:`, `Orçamento:`, `Risco:` e `Tempo:`. O validador do Stilo
     aceita essas linhas (conferido com `validate-plan.js` 0.2.0). O contrato do Stilo
     (`ID:`, `Especialista:`, `Files:`, `Depends-on:`, `Resources:`) não muda; onde as
     regras dos dois divergem, vale a mais restritiva (caminho incerto põe a tarefa em
     série).
  d. **No `EXECUTE` do Stilo, as ondas vêm do validador:** a skill acha
     `scripts/validate-plan.js` na pasta irmã da pasta de módulos que o bloco de estado do
     Stilo informa, roda-o e usa as ondas dele, em vez de calculá-las por raciocínio; usa
     `--json` quando o validador aceitar, senão lê as linhas `Onda N: ...`. Só divide uma
     onda maior que o limite de simultâneos do host. Plano inválido: para e volta ao
     `PLAN`, como o Stilo manda. Validador ausente: calcula as ondas por R5 e avisa.
  e. **Classificação única:** os níveis de R6 seguem as três classes de `orquestracao.md`
     do Stilo (edição mecânica verificável → barato/baixo; lógica comum com teste →
     médio/médio; arquitetura, segurança, permissões, dados ou incerteza alta →
     forte/alto), e o risco alto de R2 usa os mesmos gatilhos. Assim as duas skills nunca
     dão nível diferente para a mesma tarefa.
  f. Trilha curta do Stilo: `EXECUTE` sem ondas nem subagentes, e o `enxame` não dispara
     nada.
  g. O prompt do subagente não repete as regras que o hook do Stilo já injeta em todo
     subagente (papel, proibições, relato); o orçamento de contexto de R8 conta esse texto.
  h. Cada tarefa delegada gera o registro de modelo que o Stilo pede: classificação,
     modelo solicitado, esforço solicitado e aplicação confirmada.
  i. Tarefa de risco alto tem um revisor só, não um do Stilo e outro do `enxame`.
  j. Sem `.stilo/state.json`, nada disso se aplica, e o `enxame` funciona sozinho.
  k. **Aprovação única:** o Stilo já pede aprovação do `plan.md`. Se o plano aprovado tem
     as linhas de R17c, essa aprovação vale como a de R11: no `EXECUTE`, a skill mostra a
     tabela de ondas e tempo como informação e segue. Só pede ok de novo se algo mudou
     desde a aprovação (modelo caiu no fallback, onda dividida, tarefa nova ou cortada).
  l. O progresso de R18 vai para `.stilo/logs/enxame-<cycle>.md`, para a retomada
     verificável do Stilo saber o que cada onda entregou.
  m. A descrição da skill diz que, em projeto Stilo, ela vale só em `PLAN`, `EXECUTE` e
     nas revisões em subagente, para não ser carregada à toa nas outras fases.
  n. **Companion opcional:** se o Stilo listar o `enxame` entre os companions, ou o
     validador ganhar `--json`, a skill usa; sem isso, R17 funciona como está.

R18. **Progresso e retomada.** A skill registra num arquivo da pasta de trabalho (R9a) o
status de cada tarefa por onda, atualizado ao fim de cada onda. Depois de uma interrupção,
retoma a partir desse arquivo, confere os entregáveis já marcados como concluídos antes de
confiar neles e não redispara tarefa concluída e conferida.

## Critérios de aceite (executáveis)

C1. `awk 'NR==1&&/^---$/{f=1;next} f&&/^---$/{exit} f' SKILL.md | grep -cE '^(name: enxame|description: .+)$'`
imprime `2` (as duas linhas estão dentro do frontmatter).

C2. `wc -l < SKILL.md` ≤ 500.

C3. `grep -niE 'claude-|gpt-|\b(opus|sonnet|haiku|fable|codex-mini)\b' -r enxame/ | grep -v '(exemplo datado)'`
não imprime nada, exceto na referência do host, onde aliases aceitos pela ferramenta são
documentação, não regra (R7).

C4. Após a instalação, `diff -r ~/.claude/skills/enxame ~/.agents/skills/enxame` não
imprime nada, e os dois contêm `SKILL.md`.

C5. Avaliação comportamental. Arquivo `evals/plano-6-tarefas.md` com 6 tarefas: 2 escrevem
o mesmo arquivo, 1 atende ao critério de corte de R4, 2 dependem só da interface de uma
terceira, e 1 é de risco alto. Em cópia descartável, 3 rodadas, cada uma julgada por um
avaliador sem o contexto da conversa contra este checklist; as 3 precisam passar em tudo.
Antes do ok, a resposta:
  a. não põe as 2 tarefas conflitantes na mesma onda;
  b. não dá agente próprio à tarefa de corte;
  c. mostra nível, esforço, orçamento e tempo de cada tarefa, e o total;
  d. pede aprovação sem disparar subagente;
  e. marca as 2 dependências como `interface` e põe as dependentes na mesma onda da
     implementação da interface, não depois dela;
  f. mostra um revisor só para a tarefa de risco alto.

C6. Mesmo cenário, com aprovação e uma 7ª tarefa com critério de pronto impossível. O
transcript mostra: spawns de cada onda numa só mensagem, cada um com modelo e esforço
explícitos (ou "modelo padrão do host", se R7 caiu no fallback); prompts de subagente sem
histórico da conversa e com instrução de agrupar chamadas; retornos dentro do limite de
linhas, com caminho de arquivo quando há detalhe; o revisor disparado só para a tarefa de
risco alto; a 7ª tarefa refeita uma vez no nível acima, ou bloqueada já no plano com o motivo e sem gastar agente, e reportada como não concluída; o
relato final lista tarefas `concluído`, `parcial` e escaladas.

C7. Avaliação com pedido sem plano (`evals/pedido-pesquisa.md`, tarefa de pesquisa): a
resposta monta o plano, aplica C5 c–d e não dispara antes do ok. 1 rodada, mesmo
avaliador.

C8. Convivência com o Stilo Code, em cópia descartável com `.stilo/state.json` e o Stilo
instalado. Entre antes e depois de cada cenário, `.stilo/state.json` só pode diferir em
`phase` e `updated`, e só pela transição seguinte do Stilo (`PLAN`→`EXECUTE` ou
`EXECUTE`→`REVIEW`) gravada depois do relato final do `enxame`; `git log --oneline | wc -l`
não muda. Cenários, 1 rodada cada, mesmo avaliador:
  a. fase `SPEC` com pedido para executar: o `enxame` não dispara subagente nem cria plano
     próprio, e aponta o pipeline;
  b. fase `EXECUTE`, trilha completa, `plan.md` com `Files:`, `Depends-on:` e `Resources:`:
     as ondas disparadas são as que `validate-plan.js` imprime para esse plano, cada tarefa
     delegada tem o registro de modelo do Stilo, e o prompt do subagente não repete as
     regras do hook;
  c. fase `EXECUTE`, trilha curta: nenhum subagente disparado;
  d. fase `PLAN`: o `plan.md` resultante passa em `validate-plan.js` (exit 0) e cada tarefa
     tem `Nível:`, `Esforço:`, `Orçamento:`, `Risco:` e `Tempo:`;
  e. fase `EXECUTE` com plano aprovado que já tem essas linhas: a skill não pede segundo ok
     e grava `.stilo/logs/enxame-<cycle>.md` com o status por onda.

## Conferência por leitura (não executável)

- Os critérios de corte (R4), de risco (R2), a tabela de nível (R6) e a tabela de tempo
  (R10) são decidíveis: duas pessoas chegariam à mesma escolha.
- O modelo de prompt do subagente (R9) cabe em até 40 linhas.
- A referência de cada host cobre: como criar subagente com modelo e esforço, limite de
  simultâneos e limite nativo de turnos, se houver.

## Fora de escopo

Custo em dinheiro, worktrees, merge de conflitos, UI, agendamento, telemetria real de
tokens, independência do conferente (o principal confere a própria onda).

## Riscos

- **Limites só por instrução:** fora do `maxTurns` do Claude Code, nenhum host documenta
  limite rígido de chamadas ou tokens por subagente. O subagente pode estourar o
  orçamento ou contar errado. Mitigação: orçamento explícito e retorno `PARCIAL`.
- **Descoberta de modelos:** nenhum host documenta comando que liste modelos. O Claude Code
  aceita aliases no spawn; o Codex aceita `model` e `model_reasoning_effort` por spawn.
  R7 depende do que a sessão expõe e tem fallback.
- **Estimativa de tempo** é heurística e vai errar; fica declarada como aproximada.
- **Codex:** `agents.max_concurrent_threads_per_session` pode ser baixo; R12 divide ondas.
- **Avaliação não determinística:** C5–C7 usam rodadas repetidas, mas podem oscilar.
- **Ondas por raciocínio:** o `parallel-roadmap` calcula ondas por script porque o agente
  raciocinando deixa passar aresta ou sobreposição. Em projeto Stilo, o risco some: as
  ondas vêm de `validate-plan.js` (R17d). Fora dele, a defesa é a tabela aprovada pelo
  usuário (R11) e C5; se C5 falhar por isso, um validador próprio entra em ciclo novo.
- **Acoplamento à versão do Stilo:** R17 depende de `validate-plan.js`, do vocabulário de
  status e das três classes de `orquestracao.md` da 0.2.0. Se o Stilo mudar, R17 precisa
  de revisão; sem o validador, a skill cai no cálculo próprio e avisa.
- **Revisor (R16)** aumenta o custo das tarefas de risco alto; o critério de risco
  precisa ser estreito para não virar revisor em tudo.

## Referências

- Biblioteca `gerente-do-depois-biblioteca`: Code Mode (chamadas agrupadas, R8a), revisão
  dupla e especialistas (R16), aprovação humana (R11).
- `lxsmnsyc/agent-skills` → `parallel-roadmap`: dependências com tipo (R2a), contexto só
  das dependências diretas (R9), juntar cadeias de tarefas pequenas (R4).
- `ringlochid/oh-my-subagents`: retorno curto mais arquivo (R9a).
- `TheBlindM/codex-deepseek-router`: modelo barato para leitura, forte para raciocínio
  (R6).
- `luizgdemarchi/stilo-code` 0.2.0 (igual à versão instalada): `orquestracao.md`,
  `subagente.md`, `execucao.md` e contrato de hooks (R3 recursos, R9a status, R12
  ambiente × capacidade, R17).

## Teste com leitor

Executado 2026-11-19 (subagente sem contexto). Lacunas encontradas e corrigidas: marcador
de exemplo indefinido (R7, C3); instalação e referências por host fora do `diff` (R14, C4);
"mais barato" sem definição (R7); unidade do relatório (R8); tempo do principal e do
fallback (R10); escalada no nível máximo e conferência sem teste (R12); trava entre ondas e
de diretórios (R3); edição do plano pelo usuário (R11); plano de exemplo, rodadas e limiar
inexistentes (C5); escalada não exercitada (C6); R1/R13 sem critério (C7). Fica como risco
aceito: limite por instrução não é rígido.
