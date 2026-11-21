# Revisão editorial 01 — ciclo 2026-11-19-skill-multiagente

- Modo: integral (primeiro ciclo do projeto: só `docs/ciclos/2026-11-19-skill-multiagente/`,
  sem `spec.md` na raiz).
- Commit-base: `ba56f98`; revisado: `f925834` + mudanças locais dos FIX 03 e 04 (snapshot de
  2026-11-21).
- Objetivo e público: README para quem instala e usa; `SKILL.md` e referências para o agente
  que executa a skill (instrução imperativa e tabelas decidíveis são intencionais).
- Cobertura (`git ls-files --cached --others --exclude-standard`, prosa): `README.md`,
  `skill/enxame/SKILL.md`, `skill/enxame/referencias/{host-claude,host-codex,stilo,prompts}.md`
  (em `prompts.md`, dentro dos modelos só ambiguidade e contradição), `evals/checklists.md`.
- Exclusões: `docs/ciclos/**` (documentos do ciclo, viram histórico no `DONE`), `.stilo/**`
  (histórico), fixtures e resultados de `evals/` (dados e evidência), `scripts/` (código).
- Revisor independente (sonnet), sem editar; linhas conferidas pelo coordenador.

Resumo: crítico 0 · alto 0 · médio 6 · baixo 3.

## Achados

### 1. Regra duplicada que diverge: quem grava o registro de modelo
- **Arquivo:** `skill/enxame/referencias/prompts.md:123-135`
- **Trecho:** "Grave no detalhe de cada tarefa delegada, dentro ou fora do Stilo:"
- **Contexto e efeito:** `SKILL.md` passo 10 manda o principal gravar na tabela de registro;
  aqui, sem sujeito, o registro vai para o detalhe da tarefa. Em c8-b o principal pediu ao
  subagente esses campos, que o subagente não tem como saber.
- **Gravidade:** médio · **Confiança:** alta
- **Correção mínima:** a seção aponta para a tabela do passo 10, gravada pelo principal, e
  lista os valores aceitos.
- **Estado:** aberto

### 2. Valor "não" de "aplicação confirmada" ausente no `SKILL.md`
- **Arquivo:** `skill/enxame/SKILL.md:287-288`; `skill/enxame/referencias/host-claude.md:28`
- **Trecho:** "'Aplicação confirmada' é `sim` só se o host confirmou o modelo; senão, 'não
  informada pela ferramenta'."
- **Contexto e efeito:** `host-claude.md` manda registrar "não" com o modelo forçado, e diz
  "relatório" para o que é a tabela de registro.
- **Gravidade:** médio · **Confiança:** alta
- **Correção mínima:** três valores no `SKILL.md`; "tabela de registro" no `host-claude.md`.
- **Estado:** aberto

### 3. Modelos de revisor sem "Não dispare subagentes."
- **Arquivo:** `skill/enxame/referencias/prompts.md:82-121`; `SKILL.md:215-218`
- **Trecho:** passo 7.3: "Campos obrigatórios de todo disparo … 'Não dispare subagentes.'"
- **Contexto e efeito:** o revisor é disparo; os dois modelos omitem a frase.
- **Gravidade:** médio · **Confiança:** média
- **Correção mínima:** acrescentar a frase aos dois modelos de revisor.
- **Estado:** aberto

### 4. Leitura negada só trata `stilo.md` e `prompts.md`
- **Arquivo:** `skill/enxame/SKILL.md:28-30`
- **Trecho:** "fora dele, siga com o passo 7 deste arquivo e avise."
- **Contexto e efeito:** sem regra para `host-*.md` negado; "siga com o passo 7" pode ser
  lido como pular a tabela do passo 6.
- **Gravidade:** médio · **Confiança:** média
- **Correção mínima:** separar `prompts.md` (prompt mínimo) e referência de host ("modelo
  padrão do host", lotes de até 4), com tabela e ok mantidos.
- **Estado:** aberto

### 5. Exceção que contradiz os itens seguintes
- **Arquivo:** `skill/enxame/referencias/stilo.md:34-35`
- **Trecho:** "Não mude `ID:`, … nem `Resources:`, exceto o item 3:"
- **Contexto e efeito:** os itens 1 e 2 criam e juntam tarefas (mudam `ID:`, `Files:`,
  `Depends-on:`); a frase os proíbe.
- **Gravidade:** médio · **Confiança:** alta
- **Correção mínima:** "exceto o que os itens 1 a 3 exigem".
- **Estado:** aberto

### 6. Codex sem subagentes: "rode em série" ignora tabela e ok
- **Arquivo:** `skill/enxame/referencias/host-codex.md:16`
- **Trecho:** "Se `false`, não há onda: rode em série e avise."
- **Contexto e efeito:** o fallback do `SKILL.md` (passo 11) mantém tabela e ok.
- **Gravidade:** médio · **Confiança:** média
- **Correção mínima:** "siga o passo 11 do `SKILL.md` (fallback)".
- **Estado:** aberto

### 7. Referente solto em "grave-a"
- **Arquivo:** `skill/enxame/referencias/stilo.md:15-16`
- **Trecho:** "vale a regra do Stilo para a fase seguinte: grave-a você mesmo"
- **Contexto e efeito:** "-a" pode ser a regra ou a fase; o arquivo gravado não aparece.
- **Gravidade:** baixo · **Confiança:** alta
- **Correção mínima:** "grave você mesmo a fase seguinte em `.stilo/state.json`".
- **Estado:** aberto

### 8. Estado do README defasado
- **Arquivo:** `README.md:61-67`
- **Trecho:** "Em avaliação (review 03 …) … Detalhes em `.stilo/review-03.md`."
- **Contexto e efeito:** já existem os reviews 04 e 05, com C5–C8 atendidos nos dois hosts.
- **Gravidade:** baixo · **Confiança:** alta (conferido pelo coordenador)
- **Correção mínima:** estado atual e link para `review-05.md`.
- **Estado:** aberto

### 9. "R7" sem definição no checklist
- **Arquivo:** `evals/checklists.md:17`
- **Trecho:** "se R7 caiu no fallback"
- **Contexto e efeito:** código da spec, sem sentido fora dela.
- **Gravidade:** baixo · **Confiança:** alta
- **Correção mínima:** "se a descoberta de modelos caiu no fallback (passo 5 do `SKILL.md`)".
- **Estado:** aberto

## Estado após EDITORIAL_FIX (2026-11-21)

| Achado | Estado | Onde |
|---|---|---|
| 1 | corrigido | `skill/enxame/referencias/prompts.md`, seção "Registro por tarefa delegada" (principal grava na tabela do passo 10; valores aceitos) |
| 2 | corrigido | `skill/enxame/SKILL.md:289-290`; `skill/enxame/referencias/host-claude.md:28` |
| 3 | corrigido | `prompts.md`: modelos `revisor` e `revisor-stilo` com "Não dispare subagentes." |
| 4 | corrigido | `SKILL.md:28-32` |
| 5 | corrigido | `skill/enxame/referencias/stilo.md:34-35` |
| 6 | corrigido | `skill/enxame/referencias/host-codex.md:16` |
| 7 | corrigido | `stilo.md:14-16` |
| 8 | corrigido | `README.md` seção Estado |
| 9 | corrigido | `evals/checklists.md:17` |

Verificação: `scripts/instalar.sh`; `scripts/checar.sh` C1–C4 ok.
