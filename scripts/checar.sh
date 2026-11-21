#!/usr/bin/env bash
# Checagens da skill enxame. Rodar da raiz do projeto.
cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 1
S=skill/enxame
SKILL=$S/SKILL.md
falhou=0
ok()   { echo "$1 ok"; }
erro() { echo "$1 FALHOU: $2"; falhou=1; }

# C1: frontmatter com name e description
if [ -f "$SKILL" ]; then
  n=$(awk 'NR==1&&/^---$/{f=1;next} f&&/^---$/{exit} f' "$SKILL" | grep -cE '^(name: enxame|description: .+)$')
  [ "$n" = "2" ] && ok C1 || erro C1 "frontmatter com name: enxame e description esperava 2 linhas, achou $n"
else
  erro C1 "$SKILL não existe"
fi

# C2: tamanho
if [ -f "$SKILL" ]; then
  l=$(wc -l < "$SKILL")
  [ "$l" -le 500 ] && ok C2 || erro C2 "SKILL.md tem $l linhas (máx 500)"
else
  erro C2 "$SKILL não existe"
fi

# C3: sem nomes de modelo fora das referências por host
if [ -d "$S" ]; then
  achados=$(grep -rniE 'claude-|gpt-|\b(opus|sonnet|haiku|fable|codex-mini)\b' "$S/" 2>/dev/null \
    | grep -v '(exemplo datado)' \
    | grep -vE '^skill/enxame/referencias/host-(claude|codex)\.md:' || true)
  if [ -z "$achados" ]; then ok C3; else erro C3 "nome de modelo fixo:"; echo "$achados"; fi
else
  erro C3 "$S não existe"
fi

# C4: instalação idêntica nos dois destinos
A="${HOME:-}/.claude/skills/enxame"; B="${HOME:-}/.agents/skills/enxame"
if [ -d "$A" ] && [ -d "$B" ]; then
  d=$(diff -r "$A" "$B" 2>&1 || true)
  if [ -n "$d" ]; then erro C4 "destinos diferem:"; echo "$d"
  elif [ ! -f "$A/SKILL.md" ] || [ ! -f "$B/SKILL.md" ]; then erro C4 "SKILL.md ausente em um destino"
  else ok C4; fi
else
  erro C4 "não instalado"
fi

exit $falhou
