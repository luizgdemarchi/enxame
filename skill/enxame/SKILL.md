---
name: enxame
description: Use quando o usuário pedir para executar um plano ou um pedido grande com vários agentes, em paralelo, com subagentes, para adiantar trabalho, "executar o plano", "dividir em agentes" ou "usar o enxame", em código, pesquisa ou documentos; monta ondas de subagentes com nível, esforço, orçamento e tempo e só dispara depois do ok. Em projeto Stilo Code (com .stilo/state.json) vale só nas fases PLAN e EXECUTE e nas revisões em subagente. Não use para tarefa única e pequena, pergunta simples ou explicação sobre agentes.
---

# Enxame

Nunca dispare um subagente antes de mostrar a tabela de aprovação e receber o ok. "Use o
enxame para executar…" é o pedido, não o ok; o ok vem depois da tabela. (Em Stilo com plano
já aprovado com as linhas do enxame, vale a exceção de `referencias/stilo.md`.)

Transforma um plano ou um pedido em ondas de subagentes paralelos: o maior paralelismo
útil, o menor gasto e o menor tempo. Nada roda sem o ok do usuário. Responda no idioma do
usuário. Siga os passos na ordem.

## 0. Ambiente

1. **Stilo Code.** Procure `.stilo/state.json` no diretório atual e subindo até a raiz. Se
   existir, leia `referencias/stilo.md` agora. Ela tem precedência sobre este arquivo onde
   os dois divergem; se ela mandar parar (fase errada, trilha curta), pare. Sem
   `.stilo/state.json`, o pedido para executar com o enxame **não** é projeto novo do Stilo:
   não crie `.stilo/` nem abra BRAINSTORM/SPEC; siga esta skill.
2. **Host.** Veja a ferramenta de criar subagente desta sessão:
   - `Agent` → Claude Code → leia `referencias/host-claude.md`.
   - `spawn_agent` → Codex → leia `referencias/host-codex.md`.
   - nenhuma → não há subagentes: siga o passo 11 (fallback) e diga isso ao usuário.
   Leia só a referência do seu host.
3. **Leitura negada.** Se a leitura de uma referência for negada, diga ao usuário que libere
   a pasta da skill (ex.: "permita leitura de ~/.claude/skills/enxame"). Em projeto Stilo,
   não siga sem `referencias/stilo.md`; fora dele, siga com o passo 7 deste arquivo e avise.

## 1. Entrada

- Plano pronto (texto ou arquivo): use-o como base.
- Pedido sem plano: monte o plano você mesmo, com os passos 2 a 5, antes de seguir. Em
  projeto Stilo, não monte plano fora do `plan.md` do Stilo.
- Vale para código, pesquisa e documentos. Em pesquisa e documento, o entregável é um
  arquivo, e o critério de pronto é cobertura do pedido com fontes citadas.

## 2. Decomposição em fichas

Cada tarefa vira uma ficha. Todo campo é obrigatório; campo vazio significa que a tarefa
ainda não está pronta para o plano.

```text
T3 — criar o endpoint GET /busca
Entregável: src/rotas/busca.js
Pronto quando: `npm test -- busca` passa
Depende de: T1 (interface) | T2 (pronta) | nenhuma
Interface: buscar(termo, filtros) → Promise<Produto[]>   (só se depende de interface)
Escreve: src/rotas/busca.js (criar)
Lê: src/busca.js, src/rotas/index.js
Recursos: porta 3000 | banco | dir de saída | perfil de navegador | nenhum
Tamanho: P | M | G
Classe/Nível: lógica comum com teste / médio, esforço médio
Orçamento: 20 chamadas, retorno de 15 linhas
Risco: normal | alto (risco: <gatilho>)
Corte: não | sim (corte: <regra>) → principal ou agrupada com <id>
```

`Escreve` inclui os arquivos que a tarefa vai criar. Ler não entra em `Escreve`; entra em
`Lê`, que lista os arquivos que o agente pode ler.

**Dependências com tipo.** Cada dependência é `interface` (basta uma assinatura,
formato ou esboço definido) ou `pronta` (precisa do trabalho concluído). Para cada
`pronta`, pergunte: a tarefa poderia começar contra uma interface escrita agora? Se sim,
vira `interface`. Quando duas ou mais tarefas dependem da interface de outra, a definição
da interface vira tarefa própria e pequena na primeira onda:
- se a interface cabe em até 10 linhas (assinatura, formato, campos), o principal a escreve
  no próprio plano, dentro das fichas, e ela vai inline no prompt de cada dependente, no
  campo `Interface:`; ela está definida no momento da aprovação, e a implementação e as
  dependentes vão juntas para a onda 1;
- se não cabe, é uma tarefa P na onda 1, e implementação e dependentes vão juntas na
  onda seguinte.
Dependente de interface nunca espera a implementação.

**Tamanho.** P: até 1 arquivo e até 30 linhas alteradas, ou leitura de até 5 arquivos.
M: até 3 arquivos e até 150 linhas. G: o resto; tarefa G é dividida antes de ir para o
plano, salvo se for indivisível (dizer por quê).

**Corte.** A tarefa não ganha agente próprio se cumpre qualquer regra: *comando único* (um
comando só, sem análise do resultado); *edição curta já lida* (até 10 linhas num arquivo
que o principal já leu nesta sessão); *pergunta factual* (responde lendo até 2 arquivos
conhecidos); *agrupar na cadeia* (é P, tem dependência `pronta` de outra tarefa e escreve
os mesmos arquivos: agrupa com ela). Na ficha e na tabela: "corte: <regra>". Tarefa
cortada fica com o principal (executor `principal`) ou agrupada com a outra.

**Juntar cadeias.** Sequência de tarefas P com dependência `pronta` sobre os mesmos
arquivos vira uma tarefa só. Fora do corte e dessas cadeias, não junte tarefas
independentes num agente só para "economizar contexto": elas passam a rodar em fila, e o
agente carrega o contexto das duas. O número de agentes é o máximo que respeita as travas
(passo 3) e o corte.

**Risco alto.** Só estes gatilhos: risco: autorização (autenticação, autorização ou
permissões); risco: dados persistidos (dados persistidos ou migração); risco: destrutiva
(apagar, sobrescrever, forçar); risco: contrato existente (contrato público **existente**
alterado ou removido: API exportada, formato de arquivo, flags de CLI). Criar contrato
novo não é risco alto. Incerteza alta sobe o nível (passo 5), mas não cria revisor. Risco
alto ganha revisor (passo 9) e entra na tabela com ele.

## 3. Travas

- Duas tarefas que escrevem o mesmo arquivo nunca ficam na mesma onda. Leitura não trava.
- Trava declarada como diretório ou glob trava todos os arquivos que cobre.
- Caminho incerto (não dá para saber quais arquivos a tarefa vai tocar): trave o
  diretório inteiro.
- Tarefa que edita arquivo escrito por tarefa de onda anterior declara dependência dela.
- Recursos exclusivos também travam: porta, banco de dados, diretório de saída, perfil de
  navegador. Duas tarefas com o mesmo recurso não dividem onda.

## 4. Ondas

1. Uma tarefa está liberada quando as dependências `interface` têm a interface definida e
   as dependências `pronta` estão concluídas e conferidas.
2. Tarefas liberadas e sem conflito de trava formam a onda. Em conflito, a de menor id
   fica e a outra vai para a onda seguinte.
3. A onda seguinte só começa depois que a anterior foi conferida (passo 8).
4. Onda com mais agentes que o limite de simultâneos do host (ver referência do host) é
   dividida em lotes de até o limite: onda 2a, 2b. Cada lote sai numa só mensagem; os lotes
   saem em sequência, e a conferência é feita ao fim de cada lote.
5. Em projeto Stilo, as ondas vêm do validador (ver `referencias/stilo.md`).

## 5. Nível, esforço, orçamento e tempo

**Nível e esforço.** Três classes, iguais às do Stilo:

| Classe | Nível | Esforço |
|---|---|---|
| edição mecânica verificável, busca, leitura, coleta | barato | baixo |
| lógica comum com teste, redação, síntese de pesquisa | médio | médio |
| arquitetura, segurança, permissões, dados persistidos, incerteza alta | forte | alto |

Na dúvida entre duas classes, a mais barata, porque a escalada (passo 8) sobe se falhar.
Nunca o mesmo nível para tudo: cada tarefa tem a classe dela, escrita na ficha. Tarefa do
principal também recebe nível, esforço e orçamento da sua classe.

**Orçamento padrão.** barato: 8 chamadas, relatório de 10 linhas. médio: 20 chamadas,
15 linhas. forte: 40 chamadas, 25 linhas. revisor: 15 chamadas, 15 linhas. O plano pode
subir um valor com motivo escrito.

**Tempo, em minutos, faixa.**

| Nível | P | M | G |
|---|---|---|---|
| barato | 1–2 | 2–4 | 4–8 |
| médio | 2–4 | 4–8 | 8–15 |
| forte | 4–8 | 8–15 | 15–30 |

Tarefa feita pelo principal usa a mesma tabela. Onda = maior faixa da onda (incluindo as
tarefas do principal); onda dividida em lotes = soma das faixas dos lotes; total = soma
das ondas. No fallback (passo 11), total = soma das tarefas. Todo tempo é aproximado.

**Nível → modelo.** Não fixe nomes de modelo. Na sessão:
1. Liste os modelos e esforços que o host aceita (esquema da ferramenta de subagente,
   configuração ou documentação; a referência do host diz onde olhar).
2. Ordene por porte relativo dentro da família: menor/mais rápido < intermediário < maior.
   "Mais barato" é porte relativo, não preço. Modelo de porte desconhecido não é usado.
3. Cada nível vai para o menor modelo que o atende: barato → menor, médio →
   intermediário, forte → maior. Com menos de três portes, o nível vira principalmente
   esforço sobre o modelo disponível (é o caso comum no Codex; ver `referencias/host-codex.md`).
4. Sem conseguir identificar: use o modelo padrão do host, e a tabela diz
   "modelo padrão do host".

## 6. Tabela de aprovação — e PARE

Mostre exatamente este formato (troque os valores; `<alias ...>` vira o nome descoberto no
passo 5, ou "modelo padrão do host"; o principal roda no modelo da sessão):

```text
Plano do enxame — busca de produtos (host: Claude Code, até 20 simultâneos)

| id | tarefa | depende de | onda | executor | nível→modelo | esforço | orçamento (chamadas/linhas) | risco/revisor | tempo |
|---|---|---|---|---|---|---|---|---|---|
| T1 | assinatura `buscar(termo, filtros)` escrita nas fichas | — | 1 | principal | barato→modelo da sessão | baixo | 8/10 | normal | 1–2 min |
| T2 | implementar `buscar` em src/busca.js | T1 (interface) | 1 | agente | médio→<alias intermediário> | médio | 20/15 | normal | 4–8 min |
| T3 | endpoint GET /busca em src/rotas/busca.js | T1 (interface) | 1 | agente | médio→<alias intermediário> | médio | 20/15 | normal | 2–4 min |
| T4 | migração do índice de produtos | — | 1 | agente | forte→<alias maior> | alto | 40/25 | alto (risco: dados persistidos) / revisor RT4 | 8–15 min |
| T5 | seção "Busca" no README.md | — | 1 | agente | barato→<alias menor> | baixo | 8/10 | normal | 1–2 min |
| T6 | `TAMANHO_PAGINA` 20→50 em src/config.js (corte: edição curta já lida) | — | 1 | principal | barato→modelo da sessão | baixo | 8/10 | normal | 1–2 min |
| RT4 | revisar T4 | T4 (pronta) | 2 | agente | médio→<alias intermediário> | médio | 15/15 | revisor de T4 | 2–4 min |

Onda 1: 8–15 min (4 agentes + principal) · Onda 2: 2–4 min (1 agente)
Total: 10–19 min (aproximado)

Aprova? Responda "ok" ou diga o que mudar.
```

Toda linha tem todas as colunas, inclusive as do principal (executor `principal`). Revisor
tem linha própria. "depende de" usa `<id> (interface)`, `<id> (pronta)` ou `—`.

**Depois da tabela, PARE** (regra do topo). Termine a mensagem na pergunta; na mesma resposta
não edite arquivo do plano. Só um ok explícito, dado depois de ver a tabela, libera o passo 7.

As justificativas para pular este passo, e por que não valem:
- "É pequeno, vou direto." A tabela pequena custa uma mensagem; pequeno demais para
  tabela não é caso de enxame: faça sem a skill.
- "É urgente / custo mínimo." A tabela custa um turno; onda errada custa a onda inteira.
- "O usuário já disse 'execute'." Pedir execução não aprova um plano que ele ainda não viu.
- "Depois eu mostro o que fiz." Mostrar depois não é aprovação.

Única exceção: projeto Stilo com plano aprovado que já tem as linhas do enxame (ver
`referencias/stilo.md`): mostre a tabela como informação e siga.

Se o usuário cortar, mudar ou acrescentar tarefas: refaça fichas, ondas e estimativa,
mostre a tabela nova e peça ok de novo.

## 7. Disparo

1. **Antes do primeiro disparo:** crie a pasta de trabalho (passo 10), garanta a exclusão
   do git e grave no progresso a tabela aprovada e as fichas (base da retomada).
2. Leia `referencias/prompts.md` e monte um prompt por tarefa com o modelo indicado. O
   prompt leva só o objetivo geral (até 5 linhas), a ficha, a `Interface:` inline quando
   houver e o caminho do resultado das dependências diretas. Nunca histórico da conversa
   nem resultado de tarefa não relacionada.
3. **Campos obrigatórios de todo disparo**, com ou sem `referencias/prompts.md`: modelo e
   esforço explícitos na chamada (ou "modelo padrão do host", passo 5); orçamento de
   chamadas; limite de linhas do retorno; "Agrupe leituras e comandos independentes numa só
   chamada."; "Não dispare subagentes."; sem histórico da conversa.
4. Se `referencias/prompts.md` não puder ser lido, use este prompt mínimo:

```text
Retorno: até <L> linhas. Orçamento: até <N> chamadas.
Objetivo geral: <até 5 linhas>
Tarefa <id> — <título>. Entregável: <arquivo>. Pronto quando: <critério>.
Escreva só em: <Escreve>. Pode ler: <Lê>.
Interface: <texto, se houver> · Resultado das dependências: <caminho>
Agrupe leituras e comandos independentes numa só chamada. Não dispare subagentes.
Grave o detalhe em <pasta de trabalho>/<id>.md.
Termine com: status (concluído | parcial | bloqueado), arquivos alterados,
verificação com a saída decisiva, pendências. Retorno: até <L> linhas.
```

5. Dispare a onda inteira (ou o lote, se dividida) **numa só mensagem**: todas as chamadas
   de subagente juntas. Em mensagens separadas elas rodam em fila.
6. Grave no progresso (passo 10) uma linha por tarefa delegada, com status `disparada`.
7. Não encerre a resposta com agentes da onda pendentes: espere todos voltarem, confira
   (passo 8) e siga para a onda seguinte.

**Enquanto a onda roda, o principal nunca edita arquivo travado por subagente em execução,
nem refaz o trabalho de um subagente "para adiantar".** Duplicar dobra o custo, cria
conflito no arquivo e deixa dois resultados para conferir. Se você sabe fazer a tarefa
rápido, ela devia ter sido cortada no passo 2; mudar isso agora exige refazer a tabela e
pedir ok. Enquanto espera, faça só as tarefas de executor `principal` daquela onda cujos
arquivos nenhum subagente em execução escreve. Sem tarefa sua, espere os retornos.

## 8. Conferência e escalada

Depois de cada onda (ou lote), antes da seguinte:

1. Para cada entregável, confira contra o critério de pronto: rode o comando ou teste
   quando existir; senão, aplique o checklist do critério (pesquisa e documento: cobertura
   do pedido e fontes citadas). "Concluído" no retorno não é conferência; tarefa sem
   retorno do subagente não está feita. Retorno acima do limite de linhas é desvio:
   registre-o no progresso.
2. Falhou (`parcial`, `bloqueado` ou critério não atendido)? Separe a causa:
   - **ambiente** (comando ausente, permissão, sandbox, rede, dependência, teste
     instável): corrija ou registre. Não troque de modelo.
   - **capacidade** (resultado errado com o ambiente íntegro): refaça a tarefa **uma vez**
     no nível acima, com a evidência da falha no prompt.
3. **Escalada.** barato → médio → forte; o esforço vai para o padrão do novo nível.
4. Já estava no forte, ou falhou de novo depois de escalar: pare essa linha de trabalho
   (a tarefa e as que dependem dela) e reporte ao usuário. As outras linhas seguem.

## 9. Revisor (só risco alto)

Tarefa de risco alto (passo 2), depois de concluída e conferida, ganha um revisor separado,
sem o contexto do executor: recebe só a ficha, o critério de pronto e o resultado (modelo
`revisor` de `referencias/prompts.md`) e devolve achados no formato de retorno curto. O
revisor é sempre nível médio, esforço médio, tamanho P, com o orçamento de revisor. Tarefa
de risco normal não tem revisor. Achado que bloqueia volta ao executor uma vez; depois
segue o passo 8. Em projeto Stilo, é um revisor só, não um do Stilo e outro do enxame.

## 10. Progresso e retomada

**Pasta de trabalho.** Fora do Stilo: `.enxame/<AAAA-MM-DD-HHMM>/` na raiz do projeto, com
`progresso.md` e um `<id>.md` por tarefa com detalhe. Em repo git, garanta a linha
`.enxame/` em `.git/info/exclude` (local, não versionado); nunca mexa no `.gitignore`. Em
projeto Stilo: `.stilo/logs/enxame-<cycle>.md` e `.stilo/logs/enxame-<cycle>/<id>.md`.
Tarefas dependentes recebem o caminho do detalhe, não o conteúdo.

**Tabela de registro (obrigatória, com e sem Stilo).** Uma linha por tarefa delegada, gravada
no disparo e atualizada na conferência. "Aplicação confirmada" é `sim` só se o host confirmou
o modelo; senão, "não informada pela ferramenta". 
```text
| id | classificação | modelo solicitado | esforço solicitado | aplicação confirmada | status |
|---|---|---|---|---|---|
| T2 | lógica comum | <alias intermediário> | médio | não informada pela ferramenta | concluído |
```

Ao fim de cada onda, atualize o progresso (que começa com a tabela aprovada e as fichas):

```text
# enxame — busca de produtos
Plano aprovado: 2026-11-19 14:02 · host: Claude Code · (tabela aprovada e fichas)
## Registro (tabela acima)
## Onda 1 (conferida 14:15)
- T2 concluído · conferido: `npm test -- busca` 6 ok · .enxame/2026-11-19-1402/T2.md
- T4 parcial → escalado médio→forte · .enxame/2026-11-19-1402/T4.md
- T6 concluído (principal)
- desvio: T3 devolveu 19 linhas (limite 15)
## Onda 2 (em andamento)
```

**Retomada.** Depois de interrupção, leia o progresso (tabela aprovada e fichas), confira
de novo cada entregável marcado `concluído` antes de confiar nele e não redispare tarefa
concluída e conferida. Siga da primeira onda não conferida.

## 11. Fallback sem subagentes

Se o host não cria subagentes: diga isso ao usuário, mostre a tabela com executor
`principal` em todas as linhas e total = soma das tarefas, peça ok e execute as tarefas
em sequência, na ordem das ondas. Conferência, escalada de esforço e progresso continuam
valendo. Sem revisor separado, o principal revisa cada tarefa de risco alto com o
checklist do modelo `revisor` de `referencias/prompts.md` e diz isso no relato.

## 12. Relato final

```text
Concluídas: T1, T2, T3, T5, T6
Parciais: —
Escaladas: T4 (médio→forte, concluída)
Paradas: — (ou id, motivo e evidência)
Revisões: RT4 — nenhum achado que bloqueia
Desvios: T3 retorno acima do limite de linhas
Tempo: estimado 10–19 min; real ~16 min (se souber)
Detalhes: .enxame/2026-11-19-1402/progresso.md
```

Não declare tudo "feito e verificado" sem o retorno de cada subagente, a conferência do
passo 8 e a revisão das tarefas de risco alto.
