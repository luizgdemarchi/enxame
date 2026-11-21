Leia só quando existir `.stilo/state.json` subindo a partir do diretório atual.

# Enxame dentro do Stilo Code

Este arquivo só vale com `.stilo/state.json` existente. O enxame nunca cria `.stilo/`, e um
pedido para executar com o enxame não é pedido de projeto novo do Stilo. O Stilo decide o quê e quando; você só decide como paralelizar gastando pouco. Se o Stilo
listar o `enxame` entre os companions, siga o que ele indicar; sem isso, vale o que está aqui.

**Enquanto o enxame roda** (da leitura do plano à última onda conferida), **nunca:** gravar
`.stilo/state.json`, mudar de fase, fazer commit ou push, escrever em `.stilo/` fora de
`.stilo/logs/`, montar plano próprio fora do `plan.md` do Stilo, ou dar um segundo revisor a
tarefa de risco alto: ela tem um revisor só.

**Depois da última onda conferida e do registro fechado**, o enxame acabou e vale a
regra do Stilo: grave você mesmo a fase seguinte em `.stilo/state.json`, sem perguntar ao
usuário, se a fase terminou pelo critério do Stilo (no `EXECUTE`, todas as tarefas
`concluído` e conferidas). Com tarefa `parcial` ou `bloqueado`,
não avance a fase: relate.

## 1. Fase

Leia `phase` e `cycle` em `.stilo/state.json` (ou no bloco de estado do Stilo).

- `PLAN`: reforce o `plan.md` (seção Plano); não dispare subagente. Trilha curta (existe
  `docs/ciclos/<cycle>/ciclo.md`): não reforce nada, não crie nem edite `plan.md`.
- `EXECUTE`: siga as seções Validador a Progresso. Trilha curta (mesmo `ciclo.md`): sem
  ondas nem subagentes; não dispare nada.
- Revisão que o Stilo manda fazer em subagente: dispare só esse revisor (modelo
  `revisor-stilo` de `prompts.md`, não o `revisor`). Ela segue a aprovação do próprio Stilo:
  sem tabela e sem pedir ok.
- `BRAINSTORM`, `SPEC` e qualquer outra fase: não faça nada.

## 2. Plano

Fase `PLAN`, no `docs/ciclos/<cycle>/plan.md`. Não mude `ID:`, `Especialista:`, `Files:`,
`Depends-on:` nem `Resources:`, exceto o que os itens 1 a 3 exigem:

1. Definição de interface vira tarefa própria; quem só precisa dela depende só dela.
2. Junte cadeias de tarefas pequenas.
3. O validador do Stilo 0.2.0 não separa sozinho duas tarefas com o mesmo recurso: acusa
   "recurso compartilhado" e o plano fica inválido. Ponha `Depends-on` entre tarefas que
   dividem recurso.
4. Classifique pelas três classes de `orquestracao.md` do Stilo; risco alto usa os mesmos
   gatilhos. Onde as regras divergem, vale a mais restritiva (caminho incerto: em série).
5. Abaixo do contrato de cada tarefa, acrescente exatamente estas 5 linhas:

```text
Nível: barato|médio|forte
Esforço: baixo|médio|alto
Orçamento: <n> chamadas, <n> linhas
Risco: normal|alto
Tempo: <a>–<b> min
```

## 3. Validador

Fase `EXECUTE`.
1. No bloco de estado do Stilo, pegue a pasta da linha `Módulos sob demanda:`.
2. Rode `node "<pasta>/../scripts/validate-plan.js" "<plan.md>"` e leia as linhas
   `Onda N: T01, T02`. NÃO procure o validador com Glob nem find.
3. Use essas ondas sem recalcular. Só divida onda maior que o limite de simultâneos do host.
4. `Plano inválido`: pare, mostre os erros ao usuário e volte ao `PLAN`.
5. Sem a linha `Módulos sob demanda:` no bloco, ou validador ausente: calcule as ondas pela
   regra da skill e avise que não foram validadas.

## 4. Aprovação

Se o `plan.md` aprovado já tem as 5 linhas da seção Plano, a aprovação do Stilo vale: mostre
a tabela de ondas e tempo como informação e siga. Só peça ok de novo se algo mudou desde a
aprovação (modelo caiu no fallback, onda dividida, tarefa nova ou cortada).

## 5. Disparo

Use o modelo `executor-stilo` de `prompts.md`, com detalhe em `.stilo/logs/enxame-<cycle>/`.
Copie só esse modelo e preencha os campos; não acrescente frase de outro modelo nem regra
geral. O hook do Stilo já injeta, e o prompt **não** repete: "não faça commit nem push",
"edite só os arquivos atribuídos" (nem "não toque: demais arquivos"), "não pergunte ao
usuário", o formato do relato e "saída longa vai para `.stilo/logs/`". Esse texto repetido
conta no orçamento de contexto. Tarefa `Risco: alto` ganha, depois de concluída, um
revisor (modelo `revisor-stilo`). O registro de modelo que o Stilo pede é a tabela de
registro do passo 10 do `SKILL.md` (`id | classificação | modelo solicitado | esforço
solicitado | aplicação confirmada | status`), uma linha por tarefa delegada, em
`.stilo/logs/enxame-<cycle>.md`; classificação pelas classes de `orquestracao.md`.

## 6. Progresso

Ao fim de cada onda, atualize `.stilo/logs/enxame-<cycle>.md` (tabela de registro mais, por
tarefa, onda, id, status e caminho do detalhe (`.stilo/logs/enxame-<cycle>/<id>.md`)). Na retomada,
leia esse arquivo, confira os entregáveis marcados `concluído` e não redispare tarefa
concluída e conferida. Não mexa em `.git/info/exclude` nem no `.gitignore`: `.stilo/logs/` é
do Stilo.
