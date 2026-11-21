#!/usr/bin/env bash
# Instala skill/enxame em ~/.claude/skills/enxame e ~/.agents/skills/enxame.
set -euo pipefail

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ORIGEM="$RAIZ/skill/enxame"

# Recusa qualquer destino que não termine em /skills/enxame ou com HOME vazio.
checar_destino() {
  local d="$1"
  if [ -z "${HOME:-}" ]; then
    echo "instalar: HOME vazio; recusado." >&2; return 1
  fi
  case "$d" in
    */skills/enxame) ;;
    *) echo "instalar: destino recusado (não termina em /skills/enxame): $d" >&2; return 1 ;;
  esac
  if [ "$d" = "/skills/enxame" ]; then
    echo "instalar: destino recusado (raiz): $d" >&2; return 1
  fi
}

# Só executa quando rodado diretamente (permite 'source' para testar a função).
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  if [ ! -f "$ORIGEM/SKILL.md" ]; then
    echo "instalar: $ORIGEM/SKILL.md não existe; nada foi apagado." >&2
    exit 1
  fi
  DESTINOS=("${HOME:-}/.claude/skills/enxame" "${HOME:-}/.agents/skills/enxame")
  # Valida todos antes de apagar qualquer coisa.
  for d in "${DESTINOS[@]}"; do checar_destino "$d" || exit 1; done
  for d in "${DESTINOS[@]}"; do
    rm -rf "$d"
    mkdir -p "$(dirname "$d")"
    cp -r "$ORIGEM" "$d"
  done
  printf 'instalado em:\n'
  printf '  %s\n' "${DESTINOS[@]}"
fi
