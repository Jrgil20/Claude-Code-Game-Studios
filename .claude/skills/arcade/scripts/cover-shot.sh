#!/usr/bin/env bash
# cover-shot.sh — run a game.js in a throwaway page (the skill's assets/index.html, which loads
# Phaser 3.87.0) in headless Chrome and save an 800x600 screenshot as the cover.
#
# The challenge repo's own index.html is its dev dashboard, not the game, so the game is
# copied into a temp folder beside the skill's runner page; nothing is written into the game
# folder except the cover. It reports what page-shot.sh reports (uncaught errors, console
# lines) plus the cover's size; whether it is a good cover is the skill's call.
#
# Usage: bash <skill>/scripts/cover-shot.sh <game-folder> <out.png> [--wait MS]
#   <game-folder>  the folder holding game.js
#   <out.png>      where the cover goes
#   --wait MS      page time before the picture, default 2500
# Exit: page-shot.sh's exit code; 2 on bad usage or no game.js.

set -u
HERE="$(cd "$(dirname "$0")" && pwd -P)"
GAME_DIR="${1:-}"; OUT="${2:-}"; WAIT=2500
[ -n "$GAME_DIR" ] && [ -n "$OUT" ] || { echo "usage: cover-shot.sh <game-folder> <out.png> [--wait MS]" >&2; exit 2; }
shift 2
while [ $# -gt 0 ]; do case "$1" in
  --wait) WAIT="$2"; shift 2 ;;
  *) echo "cover-shot: unknown option $1" >&2; exit 2 ;;
esac; done
[ -f "$GAME_DIR/game.js" ] || { echo "cover-shot: no game.js in $GAME_DIR" >&2; exit 2; }

SHOT="$HERE/../../../scripts/page-shot.sh"
[ -f "$SHOT" ] || { echo "cover-shot: NOT ASSESSED — page-shot.sh not found at $SHOT" >&2; exit 2; }

TMP=$(mktemp -d); trap 'rm -r "$TMP"' EXIT
cp "$HERE/../assets/index.html" "$TMP/index.html"
cp "$GAME_DIR/game.js" "$TMP/game.js"
bash "$SHOT" "$TMP/index.html" "$TMP/cover.png" --size 800x600 --wait "$WAIT"
CODE=$?
if [ -f "$TMP/cover.png" ]; then
  cp "$TMP/cover.png" "$OUT"
  echo "cover: $OUT, $(file -b "$OUT" | grep -oE '[0-9]+ x [0-9]+'), $(wc -c < "$OUT" | tr -d ' ') bytes (limit 800 x 600, 500 KB)"
else
  echo "cover: NOT WRITTEN (page-shot produced no picture)"
fi
exit $CODE
