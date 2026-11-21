#!/usr/bin/env bash
# Roda uma avaliação da skill instalada numa cópia descartável fora do projeto.
set -euo pipefail

uso() {
  cat >&2 <<'U'
Uso: evals/rodar.sh <cenario> <host: claude|codex> <rodada> (--pedido <arquivo> | --texto "<pedido>")
                    [--fixture <dir>] [--extra <arquivo>:<destino-relativo>]
                    [--max-turns N] [--resume "<texto>"]
  --max-turns vale só para claude (padrão 30); o codex exec não tem limite de turnos e o ignora.
  --resume continua a sessão gravada no .meta, sem recriar a cópia.
  Cópia em ${TEMP:-/tmp}/enxame-evals/<cenario>-<host>-<rodada> (fora do projeto, por causa do .stilo/).
U
  exit 2
}

[ $# -ge 3 ] || uso
CENARIO="$1"; HOST="$2"; RODADA="$3"; shift 3
case "$HOST" in claude|codex) ;; *) echo "host inválido: $HOST" >&2; uso ;; esac
case "$CENARIO$RODADA" in */*|*\*|*..*) echo "cenário/rodada inválidos" >&2; exit 2 ;; esac

PEDIDO=""; FIXTURE=""; MAXT=30; RESUME=""; EXTRAS=()
while [ $# -gt 0 ]; do
  case "$1" in
    --pedido)    [ $# -ge 2 ] || uso; [ -f "$2" ] || { echo "pedido não existe: $2" >&2; exit 2; }; PEDIDO="$(cat "$2")"; shift 2 ;;
    --texto)     [ $# -ge 2 ] || uso; PEDIDO="$2"; shift 2 ;;
    --fixture)   [ $# -ge 2 ] || uso; FIXTURE="$2"; shift 2 ;;
    --extra)     [ $# -ge 2 ] || uso; EXTRAS+=("$2"); shift 2 ;;
    --max-turns) [ $# -ge 2 ] || uso; MAXT="$2"; shift 2 ;;
    --resume)    [ $# -ge 2 ] || uso; RESUME="$2"; shift 2 ;;
    *) echo "argumento desconhecido: $1" >&2; uso ;;
  esac
done
[ -n "$PEDIDO" ] || [ -n "$RESUME" ] || { echo "falta --pedido ou --texto" >&2; uso; }

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
BASE="${TEMP:-/tmp}"
command -v cygpath >/dev/null 2>&1 && BASE="$(cygpath -u "$BASE")"
mkdir -p "$BASE/enxame-evals"
BASE="$(cd "$BASE/enxame-evals" && pwd -P)"
DIR="$BASE/$CENARIO-$HOST-$RODADA"
case "$DIR/" in
  "$RAIZ"/*) echo "recusado: $DIR está dentro do projeto $RAIZ" >&2; exit 1 ;;
esac

mkdir -p "$RAIZ/evals/resultados"
META="$RAIZ/evals/resultados/$CENARIO-$HOST-$RODADA.meta"
JSONL="$RAIZ/evals/resultados/$CENARIO-$HOST-$RODADA.jsonl"

set_meta() { # chave valor: substitui ou acrescenta
  touch "$META"
  grep -v "^$1=" "$META" > "$META.tmp" || true
  echo "$1=$2" >> "$META.tmp"
  mv "$META.tmp" "$META"
}
hash_estado() {
  if [ -f "$DIR/.stilo/state.json" ]; then sha256sum "$DIR/.stilo/state.json" | cut -d' ' -f1; else echo "sem-stilo"; fi
}
estado() {
  if [ -f "$DIR/.stilo/state.json" ]; then tr -d '\r\n' < "$DIR/.stilo/state.json"; else echo "sem-stilo"; fi
}
n_commits() { (cd "$DIR" && git log --oneline 2>/dev/null | wc -l | tr -d ' '); }

if [ -z "$RESUME" ]; then
  rm -rf "$DIR"
  mkdir -p "$DIR"
  cp -r "$RAIZ/evals/projeto-exemplo/." "$DIR/"
  if [ -n "$FIXTURE" ]; then
    [ -d "$FIXTURE" ] || { echo "fixture não existe: $FIXTURE" >&2; exit 1; }
    cp -r "$FIXTURE/." "$DIR/"
  fi
  for e in ${EXTRAS[@]+"${EXTRAS[@]}"}; do
    src="${e%%:*}"; dst="${e#*:}"
    [ -f "$src" ] || { echo "extra não existe: $src" >&2; exit 1; }
    mkdir -p "$(dirname "$DIR/$dst")"
    cp "$src" "$DIR/$dst"
  done
  (cd "$DIR" && git init -q && git add -A && git -c user.name=eval -c user.email=eval@local commit -qm base)
  : > "$META"
  : > "$JSONL"
  set_meta hash_antes "$(hash_estado)"
  set_meta estado_antes "$(estado)"
  set_meta commits_antes "$(n_commits)"
else
  [ -d "$DIR" ] || { echo "cópia não existe para --resume: $DIR" >&2; exit 1; }
fi

SID=""
[ -f "$META" ] && SID="$(grep '^session_id=' "$META" | tail -1 | cut -d= -f2- || true)"
if [ -n "$RESUME" ]; then
  [ -n "$SID" ] || { echo "sem session_id no $META" >&2; exit 1; }
  TEXTO="$RESUME"
else
  TEXTO="$PEDIDO"
fi

cd "$DIR"
set +e
if [ "$HOST" = claude ]; then
  ARGS=(-p "$TEXTO")
  [ -n "$RESUME" ] && ARGS+=(--resume "$SID")
  claude "${ARGS[@]}" --model sonnet --output-format stream-json --verbose --max-turns "$MAXT" \
    --permission-mode acceptEdits --add-dir "$HOME/.claude/skills/enxame" \
    --allowedTools "Bash(node:*)" "Bash(npm:*)" "Bash(git:*)" "Bash(ls:*)" "Bash(cat:*)" >> "$JSONL"
  RC=$?
  if [ -z "$RESUME" ]; then
    SID="$(grep -o '"session_id": *"[^"]*"' "$JSONL" | head -1 | sed 's/.*: *"\(.*\)"/\1/')"
    set_meta session_id "$SID"
  fi
else
  if [ -n "$RESUME" ]; then
    codex exec resume --json --skip-git-repo-check -c 'sandbox_mode="workspace-write"' "$SID" "$TEXTO" >> "$JSONL" < /dev/null
  else
    codex exec --json --skip-git-repo-check --sandbox workspace-write "$TEXTO" >> "$JSONL" < /dev/null
  fi
  RC=$?
  if [ -z "$RESUME" ]; then
    SID="$(grep -o '"thread_id": *"[^"]*"' "$JSONL" | head -1 | sed 's/.*: *"\(.*\)"/\1/')"
    set_meta session_id "$SID"
  fi
fi
set -e

set_meta hash_depois "$(hash_estado)"
set_meta estado_depois "$(estado)"
set_meta commits_depois "$(n_commits)"
set_meta exit_host "$RC"
exit 0
