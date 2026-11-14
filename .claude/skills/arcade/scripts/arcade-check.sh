#!/usr/bin/env bash
# arcade-check.sh — measure an arcade-challenge game folder against the challenge's
# restrictions (../references/rules.md) and report what it sees.
#
# It reports; whether a row blocks the submission is /arcade's call. A row that could not
# be measured says NOT ASSESSED and why, never a silent pass.
#
# Usage: bash <skill>/scripts/arcade-check.sh <folder> [--budget BYTES]
#   <folder>        the game's folder, holding game.js, metadata.json and cover.png
#   --budget BYTES  the minified size limit, default 50000 (50 KB read as 1000-byte KB, the
#                   stricter reading: the sheet does not say which KB it means)
#
# Rows (one per line, "key: value"):
#   raw_bytes, min_bytes (esbuild --minify, an estimate: the official checker minifies
#   with SWC), budget_bytes, headroom_bytes, hits:<pattern> with line numbers in the
#   minified code, cabinet_keys (every official key still mapped to its code), metadata
#   (player_mode), cover (pixels and bytes, limit 800x600 and 500 KB).
# Exit: 0 when it ran (whatever it found), 2 on bad usage or no game.js.

set -u
DIR="${1:-}"; BUDGET=50000
[ -n "$DIR" ] || { echo "usage: arcade-check.sh <folder> [--budget BYTES]" >&2; exit 2; }
shift
while [ $# -gt 0 ]; do case "$1" in
  --budget) BUDGET="$2"; shift 2 ;;
  *) echo "arcade-check: unknown option $1" >&2; exit 2 ;;
esac; done
GAME="$DIR/game.js"
[ -f "$GAME" ] || { echo "arcade-check: no game.js in $DIR" >&2; exit 2; }

echo "raw_bytes: $(wc -c < "$GAME" | tr -d ' ')"
echo "budget_bytes: $BUDGET"

TMP=$(mktemp -d); trap 'rm -r "$TMP"' EXIT
MIN="$TMP/game.min.js"
# Only a minifier already installed (on PATH or in the folder's node_modules); this script
# never downloads one. Install it yourself, e.g. `npm i -g esbuild`, to get min_bytes.
ESB=$(command -v esbuild || ls "$DIR/node_modules/.bin/esbuild" 2>/dev/null || true)
if [ -n "$ESB" ] && "$ESB" "$GAME" --minify --log-level=error > "$MIN" 2> "$TMP/err"; then
  M=$(wc -c < "$MIN" | tr -d ' ')
  echo "min_bytes: $M (esbuild estimate)"
  echo "headroom_bytes: $((BUDGET - M))"
  SRC="$MIN"; SRC_NOTE="minified"
else
  echo "min_bytes: NOT ASSESSED (no esbuild installed${ESB:+: $(head -1 "$TMP/err")})"
  echo "headroom_bytes: NOT ASSESSED"
  SRC="$GAME"; SRC_NOTE="raw, comments included"
fi

# Forbidden by the challenge: modules, network, external URLs, and loaded files.
# "//" outside a string is a comment in raw code, so the URL row is only exact on
# minified code; on raw code it is labelled as such.
echo "patterns_scanned_on: $SRC_NOTE"
scan() { # name regex
  local hits; hits=$(grep -nE "$2" "$SRC" | cut -d: -f1 | head -20 | tr '\n' ' ')
  echo "hits:$1: ${hits:-none}"
}
scan import        '(^|[^A-Za-z0-9_$.])import[ ({*]|import\('
scan require       '(^|[^A-Za-z0-9_$.])require\('
scan url           'https?:|["'"'"'`]//'
scan fetch         '(^|[^A-Za-z0-9_$])fetch\('
scan xhr           'XMLHttpRequest|WebSocket|EventSource|sendBeacon'
scan loader        '\.load\.(image|audio|spritesheet|atlas|json|bitmapFont|svg|script|tilemap|text)'
scan data_uri      'data:[a-z]+/'

# CABINET_KEYS must keep every official key on its code (appending keys is allowed).
if command -v node >/dev/null 2>&1; then
  echo "cabinet_keys: $(node -e '
const src = require("fs").readFileSync(process.argv[1], "utf8");
const m = src.match(/const\s+CABINET_KEYS\s*=\s*(\{[\s\S]*?\});/);
if (!m) { console.log("missing"); process.exit(0); }
let k; try { k = Function("return " + m[1])(); } catch (e) { console.log("NOT ASSESSED (not a plain object literal)"); process.exit(0); }
const want = {P1_U:"w",P1_D:"s",P1_L:"a",P1_R:"d",P1_1:"u",P1_2:"i",P1_3:"o",P1_4:"j",P1_5:"k",P1_6:"l",
  P2_U:"ArrowUp",P2_D:"ArrowDown",P2_L:"ArrowLeft",P2_R:"ArrowRight",P2_1:"r",P2_2:"t",P2_3:"y",P2_4:"f",P2_5:"g",P2_6:"h",START1:"Enter",START2:"2"};
const bad = Object.entries(want).filter(([c, key]) => !(Array.isArray(k[c]) && k[c].includes(key))).map(([c]) => c);
console.log(bad.length ? "changed: " + bad.join(" ") : "intact");
' "$GAME")"
else echo "cabinet_keys: NOT ASSESSED (no node)"; fi

if [ -f "$DIR/metadata.json" ]; then
  if grep -q 'FILL THIS' "$DIR/metadata.json"; then echo "metadata: placeholder text left"
  else echo "metadata: $(tr -d '\n' < "$DIR/metadata.json" | head -c 200)"; fi
  PM=$(grep -oE '"player_mode"[[:space:]]*:[[:space:]]*"[^"]*"' "$DIR/metadata.json" | sed -E 's/.*"([^"]*)"$/\1/')
  case "$PM" in single_player|two_player) echo "player_mode: $PM" ;; "") echo "player_mode: missing" ;; *) echo "player_mode: invalid ($PM)" ;; esac
else echo "metadata: missing"; echo "player_mode: missing"; fi

if [ -f "$DIR/cover.png" ]; then
  echo "cover: $(file -b "$DIR/cover.png" | grep -oE '[0-9]+ x [0-9]+' || echo 'size NOT ASSESSED'), $(wc -c < "$DIR/cover.png" | tr -d ' ') bytes (limit 800 x 600, 500 KB)"
else echo "cover: missing"; fi
exit 0
