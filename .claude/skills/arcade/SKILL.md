---
name: arcade
description: "Builds or changes a Platanus Hack 26 arcade game: Phaser 3, one game.js under 50 KB minified, no assets, cabinet controls, storage bridge, cover.png. Use for the arcade challenge or when its check fails."
argument-hint: "[game idea | change to make] [--name <folder>]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, AskUserQuestion, Bash(bash .claude/scripts/arcade-check.sh *), Bash(bash .claude/scripts/page-shot.sh *), Bash(mkdir -p prototypes/*), Bash(cp .claude/skills/arcade/assets/* prototypes/*)
---

# Arcade

Build for the challenge in `references/rules.md`. Read it first, every run: it is the
contract (deadline 18 November 2026, 23:59 Santiago), and it says what is not sourced.

## 1. The game

- No `prototypes/<name>/game.js` yet: ask one question, the game in one sentence and
  whether it is one or two players (unless the argument already gives both), then stop
  and wait. Copy `assets/*` into `prototypes/<name>/` (`mkdir -p`, then `cp`).
- One exists: read it whole before changing it.

## 2. Build

Before writing, say in two or three lines what changes, then ask "May I write
`prototypes/<name>/game.js` and `metadata.json`?" and wait. Write only those two;
`index.html` is the local runner and is not submitted. Keep the starter's shape:

- `CABINET_KEYS` exactly as it is: never change or remove a key (appending a test key
  is allowed). Read input by cabinet code (`held.P1_L`, `take('P1_1')`), never by raw key.
  Design for the joystick plus `P1_1`, at most `P1_2`; `START1` starts. Two players: the
  same with `P2_*` and `START2`.
- Persist only through `getStorage()` (the `platanusArcadeStorage` bridge); never call
  `localStorage` directly.
- Every gameplay number in `TUNE`.
- Textures from `make.graphics()` + `generateTexture`; sound from `tone()`; text in
  `monospace`. No `this.load.*`, no files, no `data:` URIs, no URLs, no `fetch`, no
  `import`/`require`.
- An arcade loop: title with best score → play that gets harder → game over → title.
  Make it a challenge: a score to beat, rising difficulty, a death that reads at once.
- Juice is cheap code: shake, particles, flashes, tweens. Spend bytes there, not menus.
- `metadata.json`: `game_name`, `description`, `player_mode` (`single_player` or
  `two_player`).

## 3. Check

Run `bash .claude/scripts/arcade-check.sh prototypes/<name>`.

- Any `hits:` row other than `none`, `cabinet_keys` other than `intact`, or
  `player_mode` other than a valid value: fix it before anything else.
- `min_bytes` above `budget_bytes`: cut. `min_bytes: NOT ASSESSED`: report `raw_bytes` as
  an upper bound and say the minified size was not measured; raw under 50000 passes, raw
  over it needs a minifier (`npm i -g esbuild`) or the official `npm run dev` checker.

## 4. Look

`bash .claude/scripts/page-shot.sh prototypes/<name>/index.html prototypes/<name>/cover.png --size 800x600 --wait 2500`.
Read the PNG. An `uncaught` line above 0 is a bug: fix it and shoot again. Run the check
again for the `cover` row: 800 x 600 and at most 500 KB. The shot is the title screen; if
it is not the cover the user wants, say so.

## 5. Report

Say: the game in one line, the controls, `min_bytes` (or `raw_bytes` and NOT ASSESSED),
every row that is not clean, the cover path, and what was not run (play past the title
is not driven by any script: the user plays it with `index.html`). Do not commit.
