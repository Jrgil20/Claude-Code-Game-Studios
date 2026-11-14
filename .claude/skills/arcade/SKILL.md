---
name: arcade
description: "Builds or changes a Platanus Hack 26 arcade game: Phaser 3, one game.js under 50 KB minified, no assets, cabinet controls, storage bridge, cover.png. Use for the arcade challenge or when its check fails."
argument-hint: "[game idea | change to make] [--name <folder>]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, AskUserQuestion, Bash(bash ${CLAUDE_SKILL_DIR}/scripts/arcade-check.sh *), Bash(bash ${CLAUDE_SKILL_DIR}/scripts/cover-shot.sh *), Bash(npm run check-restrictions), Bash(mkdir -p prototypes/*), Bash(cp ${CLAUDE_SKILL_DIR}/assets/* prototypes/*)
---

# Arcade

Build for the challenge in `${CLAUDE_SKILL_DIR}/references/rules.md`. Read it first, every
run: it is the contract (deadline 18 November 2026, 23:59 Santiago), and it says what is
not sourced. Scripts and assets live in `${CLAUDE_SKILL_DIR}`: this skill also runs from a
git submodule, so never use a `.claude/...` path relative to the session.

## 0. Where the game is

| The session's root (`${CLAUDE_PROJECT_DIR}`) has | Game folder `<G>` | Mode |
|---|---|---|
| `game.js`, `metadata.json` and `AGENTS.md` | the root itself | **Challenge repo** |
| anything else | `prototypes/<name>/` | **Standalone** |

**Challenge repo:** read its `AGENTS.md` and obey it; where it is stricter than this skill,
it wins. Write only `game.js`, `metadata.json` and `cover.png`; never touch `index.html`,
`package.json`, `vite.config.ts` or `docs/`; never run `npm run dev` (the user does). Its
`docs/phaser-quick-start.md` and `docs/phaser-api.md` are the Phaser reference: search them
by section, never read `phaser-api.md` whole.

## 1. The game

- A new game: ask one question, the game in one sentence and whether it is one or two
  players (unless the argument already gives both), then stop and wait.
  - Challenge repo: the existing `game.js` is the official starter. The new game replaces
    it, keeping its `CABINET_KEYS` block byte for byte; take the structure from
    `${CLAUDE_SKILL_DIR}/assets/game.js`.
  - Standalone: `mkdir -p prototypes/<name>`, then copy `${CLAUDE_SKILL_DIR}/assets/*` into it.
- A change: read `<G>/game.js` whole before changing it.

## 2. Build

Before writing, say in two or three lines what changes, then ask "May I write
`<G>/game.js` and `<G>/metadata.json`?" and wait. Keep the starter's shape:

- `CABINET_KEYS` exactly as it is: never change or remove a key (appending a test key
  is allowed). Read input by cabinet code (`held.P1_L`, `take('P1_1')`), never by raw key.
  Design for the joystick plus `P1_1`, at most `P1_2`; `START1` starts. Two players: the
  same with `P2_*` and `START2`.
- Persist only through `getStorage()` (the `platanusArcadeStorage` bridge); never call
  `localStorage` directly. Validate what you read back: its shape may be from an older build.
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

Run `bash ${CLAUDE_SKILL_DIR}/scripts/arcade-check.sh <G>`. In the challenge repo, also run
`npm run check-restrictions`: it is the official checker and its size wins over ours. If it
fails because `node_modules` is missing, say so and ask the user to run `npm install`.

- Any `hits:` row other than `none`, `cabinet_keys` other than `intact`, or
  `player_mode` other than a valid value: fix it before anything else.
- `min_bytes` above `budget_bytes`: cut. `min_bytes: NOT ASSESSED` and no official
  check: report `raw_bytes` as an upper bound and say the minified size was not measured.

## 4. Look

`bash ${CLAUDE_SKILL_DIR}/scripts/cover-shot.sh <G> <G>/cover.png`. Read the PNG. An
`uncaught` line above 0 is a bug: fix it and shoot again. The `cover:` line must read
800 x 600 and at most 500 KB. The shot is the title screen; if it is not the cover the
user wants, say so.

## 5. Report

Say: the mode and `<G>`, the game in one line, the controls, the official size (or
`min_bytes`, or `raw_bytes` and NOT ASSESSED), every row that is not clean, the cover, and
what was not run (play past the title is not driven by any script: the user plays it with
`npm run dev`, or the standalone `index.html`). Do not commit.
