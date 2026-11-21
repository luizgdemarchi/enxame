# Revisão editorial 02 — ciclo 2026-11-19-skill-multiagente

- Modo: incremental, depois do `EDITORIAL_FIX` 01: os trechos corrigidos e o entorno.
- Base: snapshot da revisão 01; revisado: snapshot de 2026-11-21 com as 9 correções.
- Cobertura: `SKILL.md:28-32` e `:289-290`; `prompts.md` (cabeçalhos dos revisores e seção
  "Registro por tarefa delegada"); `host-claude.md:28`; `host-codex.md:16`; `stilo.md:14-16` e
  `:34-35`; `README.md` (Estado); `evals/checklists.md:17`.
- Exclusões: as mesmas da revisão 01. Revisão pelo coordenador.

Resumo: crítico 0 · alto 0 · médio 0 · baixo 1.

## Achados

### 1. Rótulo de classe diverge da tabela do passo 5
- **Arquivo:** `skill/enxame/referencias/prompts.md` (seção "Registro por tarefa delegada")
- **Trecho:** "`arquitetura, segurança, permissões, dados ou incerteza alta`"
- **Contexto e efeito:** o passo 5 diz "dados persistidos"; e em projeto Stilo a classificação
  segue `orquestracao.md` (`stilo.md`), o que a seção não menciona.
- **Gravidade:** baixo · **Confiança:** alta
- **Correção mínima:** "dados persistidos" e "(no Stilo, as classes de `orquestracao.md`)".
- **Estado:** corrigido (`prompts.md`, seção "Registro por tarefa delegada")

Sem achado crítico nem alto.
