# Review 03 — ciclo 2026-11-19-skill-multiagente

- Alvo: `skill/enxame/**` após FIX do review 02 (sem git; instalado = fonte, `diff -r` vazio).
- Cobertura: rodada 3 parcial. Concluídas: C5 Claude r1 (regressão), C8b Claude (antes e depois
  do ok), C5 Codex r1 e C6 Codex primeiro turno (tabela). Interrompidas por falta de memória
  (processo morto pelo sistema): C6 Codex depois do ok, C5 Codex r2, C8e. 2 avaliadores
  independentes (sonnet) + conferência por comando (validador, `message.id`, hash, commits,
  suíte da cópia).
- Exclusões: fixtures de `evals/` só entram quando o defeito afeta o resultado da avaliação.
- Documentos: `spec.md`, `plan.md`, `evals/checklists.md`, `modules/subagente.md` do Stilo 0.2.0.
- Transcrições: `evals/resultados/{c8-b-claude-1,c5-codex-1,c6-codex-1}.jsonl`.

Resumo: crítico 1 · alto 0 · médio 1 · baixo 3.

## Resultado da rodada 3

| Critério | Resultado | Evidência |
|---|---|---|
| C1–C4 | passa | `checar.sh`: C1–C4 ok |
| C5 Claude r1 | passa (sem regressão) | avaliador r3 |
| C5 Codex r1 | **passa a–f** | avaliador: tabela com nível/esforço/orçamento/tempo e total "10–19 min"; B e C `A (interface)` na onda 1; só C com revisor; "ainda não alterei o projeto" |
| C5 Codex r2 | pendente | sessão não rodou (exit 127, memória) |
| C6 Codex (antes do ok) | passa no verificável | para e pede ok; revisor só em C; G bloqueada no plano com motivo ("contém `assert.equal(1, 2)`… não pode ser concluída de forma legítima"), no principal, sem agente |
| C6 Codex (disparos, registro) | pendente | retomada com ok não rodou |
| C8b | **falha** (prompt repete hook) | ondas = validador (T01 / T02,T05 / T03 / T04); registro completo nas 5; hash e commits iguais; ok antes do 1º disparo |
| C8e | pendente | sessão não rodou |
| Invariantes Stilo | passa | `c8-b-claude-1.meta`: hash `bab4e131…21c6` igual; commits 1 = 1 |

Achados do review 02: 1, 2, 3, 5 confirmados corrigidos na rodada 3; 4 reaberto (achado 1
abaixo); 6, 7 aceitos; 8 = 26–28 do review 01, abertos.

## Achados

### 1. Prompt do subagente no Stilo repete regras do hook
- **Arquivo:** `skill/enxame/referencias/stilo.md:67`; `skill/enxame/referencias/prompts.md:42`
- **Gravidade:** crítico (C8b sem atender) · **Confiança:** alta · **Classificação:** confirmado
- **O que quebra:** C8b exige prompt sem as regras do hook. Os 5 prompts de c8-b terminam com
  "Não faça commit." (hook: "Não faça commit nem push"); T01 tem "Não toque: demais arquivos."
  (hook: "Edite só os arquivos atribuídos").
- **Como corrigir:** `stilo.md` (Disparo): copie só o `executor-stilo`, sem acrescentar regra
  geral de outro modelo; lista literal do que o hook já injeta e não entra no prompt (commit
  ou push, editar só os atribuídos, não perguntar ao usuário, formato do relato, saída longa
  em `.stilo/logs/`). `executor-stilo`: linha `Não toque` só com arquivos concretos de outra
  tarefa da onda; sem eles, omita a linha.
- **Evidência:** `c8-b.txt:244` (prompt de T01, fim: "Não faça commit."); avaliador C8 r3;
  `executor-stilo` não tem commit; o `executor` genérico tem (`prompts.md:42`) e o principal
  leu o arquivo inteiro (`c8-b.txt:149`).
- **Contraprova verificada:** review 02, achado 4, atribuiu a repetição ao agente e só enxugou
  o modelo; a repetição voltou com o modelo enxuto, então falta proibição explícita.
- **Origem:** introduzido. **Estado:** aberto.

### 2. Fim do EXECUTE no Stilo: a fase seguinte vira pergunta ao usuário
- **Arquivo:** `skill/enxame/referencias/stilo.md:9`; `spec.md` R17a e C8
- **Gravidade:** médio · **Confiança:** alta · **Classificação:** confirmado
- **O que quebra:** o hook do Stilo manda gravar a fase seguinte ao concluir; o enxame proíbe
  gravar `state.json`. c8-b terminou com "Não gravei `.stilo/state.json`: a regra da skill do
  enxame proíbe isso… Quer que eu grave `phase: "REVIEW"`?". O pipeline fica em `EXECUTE` até
  o usuário responder.
- **Como corrigir (decisão do usuário):** (a) `stilo.md`: a proibição vale durante o enxame;
  depois do relato final, o coordenador segue a regra do Stilo para a fase, e C8 mede o hash
  até o relato final; ou (b) manter a pergunta (comportamento atual, seguro, uma pergunta a
  mais por ciclo).
- **Evidência:** `c8-b.txt`, último `[final]`.
- **Contraprova verificada:** C8 exige hash igual "antes e depois de cada cenário"; gravar a
  fase na mesma sessão quebraria C8 como está escrito. **Origem:** introduzido. **Estado:** aberto.

### 3–5. Baixos
3. **`.git/info/exclude` em projeto Stilo.** `SKILL.md:277` manda a exclusão só para `.enxame/`
   fora do Stilo; em c8-b o principal tentou `echo '.stilo/logs/' >> .git/info/exclude`
   (negado, pedido de permissão em arquivo sensível). Corrigir: `stilo.md`, "não mexa em
   `.git/info/exclude`; `.stilo/logs/` é do Stilo". Origem: introduzido.
4. **Fixture C8 com suíte intermitente.** `test/previa-{csv,json}.test.js` usam a porta fixa
   4173 e `node --test` roda arquivos em paralelo: `--test-concurrency=1` → 4/4; padrão → 3/4,
   `EADDRINUSE`. O enxame serializou a execução (Resources); o conflito é do plano da fixture.
   Corrigir: `package.json` das fixtures `execute-{completa,aprovada}` com
   `"test": "node --test --test-concurrency=1"`. Origem: introduzido (fixture).
5. Abertos do review 01: 26, 27, 28.

## Descartados (avaliadores)

| Alegação | Motivo |
|---|---|
| Onda 2 de c8-b serializada (T02 e T05 em mensagens separadas) | T02 e T05 têm o mesmo `message.id` `msg_011ChF67uWFiYvYRmcvUSEcB`; a intercalação vem do subagente em segundo plano |
| C6 Codex: G não marcada "bloqueada" na tabela | motivo dado antes da tabela e G no principal, sem agente: atende "bloqueada já no plano com o motivo e sem gastar agente" (decisão 1) |
| C6 Codex: E depende de G (pronta), inalcançável | G virou "verificar e registrar o impedimento", que conclui; E já é onda 3 por D (mesmo `README.md`), sem custo |
| CLI com contrato diferente em C5 e C6 Codex | o plano de entrada não define a origem das notas; a interface proposta aparece na tabela antes do ok |
| "modelo padrão do host" × "modelo da sessão" | é o que `SKILL.md:167` manda (agentes × principal) |
| Registro não separa verificação do principal | coluna status: "concluído (agente parcial por Bash negado; verificado pelo principal)" |

## Critérios do spec

| Critério | Estado |
|---|---|
| C1–C4 | atendido |
| C5 | Claude atendido (r2 3/3, r3 sem regressão); Codex 1 de 3 rodadas atendida, r2 pendente |
| C6 | Claude atendido (r2); Codex: parte antes do ok atendida, disparos e registro pendentes |
| C7 | atendido (r2) |
| C8 | a, c, d atendidos (r2); **b não atendido** (achado 1); e pendente |

Pendente de evidência: C5 Codex r2, C6 Codex depois do ok, C8e.

Próxima fase: `FIX` (achado crítico).

## Estado após FIX (2026-11-21)

| Achado | Estado | Onde |
|---|---|---|
| 1 | corrigido (texto); confirmar em nova C8b | `stilo.md` seção Disparo (lista literal do que não entra); `prompts.md` nota após `executor-stilo` (linha `Não toque` condicional) |
| 2 | corrigido (decisão do usuário: a) | `stilo.md` topo (proibição só enquanto o enxame roda; depois do relato, regra do Stilo); `spec.md` R17a e C8; `plan.md` conferência; `evals/checklists.md` C8; `evals/rodar.sh` grava `estado_antes`/`estado_depois` |
| 3 | corrigido | `stilo.md` seção Progresso |
| 4 | corrigido | `evals/stilo/execute-{completa,aprovada}/package.json` com `--test-concurrency=1`; suíte de c8-b em série: pass 4, fail 0 |
| 5 | abertos (baixo) | review 01: 26–28 |

Verificação: `scripts/instalar.sh`; `scripts/checar.sh` C1–C4 ok.
