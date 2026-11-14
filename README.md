# Arcade Challenge Studio

A trimmed fork of [Claude Code Game Studios](https://github.com/Donchitos/Claude-Code-Game-Studios),
cut down to one job: build the coolest arcade game for the **Platanus Hack 26 Arcade
Challenge** (deadline **18 November 2026, 23:59 Santiago**), with **Phaser 3**, in **one
`game.js` under 50 KB**, and **no external assets**: every sprite drawn and every sound
synthesized in code.

## Quick path

1. Open Claude Code in this folder (hooks and permissions load only from here).
2. No idea yet? Run `/brainstorm`. Have one? Run `/arcade <your game in one sentence>`.
3. `/arcade` copies the starter into `prototypes/<name>/`, builds `game.js`, runs the
   restriction check, screenshots the title screen as `cover.png`, and reports.
4. Play it: open `prototypes/<name>/index.html` in a browser (it loads Phaser 3.87.0 from a
   CDN). Ask `/arcade` for changes until it is fun.
5. Copy `game.js`, `metadata.json` and `cover.png` into the challenge's own repo, run its
   checker (`npm install`, `npm run dev`, localhost:3001) and hit **Submit** in its dev UI.

## The challenge rules

Full, sourced list: [`.claude/skills/arcade/references/rules.md`](.claude/skills/arcade/references/rules.md).
They come from the Platanus Hack 26 challenge sheet; the official repo's `AGENTS.md` wins
where it differs.

| Rule | Value |
|---|---|
| Library | Phaser 3.87.0, loaded by the cabinet, not counted |
| Size | `game.js` ≤ 50 KB minified (before gzip) |
| Code | Vanilla JS: no `import`/`require`, no URLs, no `fetch` or other network |
| Assets | None (your rule, stricter than the sheet): Graphics-API textures and Web Audio tones only |
| Controls | Cabinet codes (`P1_U`, `P1_1`, `START1`, …); `CABINET_KEYS` is never modified |
| Storage | `window.platanusArcadeStorage` bridge, not `localStorage` |
| Submission | `game.js`, `metadata.json` (with `player_mode`), `cover.png` (800x600, ≤ 500 KB) |

## What is in here

| Kind | Items |
|---|---|
| Skills | `/arcade` (the challenge build), `/brainstorm` (find the idea), `/prototype` (any other browser sketch), `/cut` (decide what to drop and finish), `/project-settings` and `/settings` (config) |
| Agents | `creative-director`, `game-designer`, `prototyper`, `gameplay-programmer`, `technical-artist`, `art-director`, `sound-designer`, `ui-programmer`, `performance-analyst` |
| Check script | `bash .claude/scripts/arcade-check.sh prototypes/<name>`: raw and minified size, forbidden-pattern hits, `CABINET_KEYS` intact, `player_mode`, cover size. It reports; `/arcade` decides |
| Starter | `.claude/skills/arcade/assets/`: `game.js` (cabinet input, storage bridge, procedural textures, synth sound, title → play → game over), local `index.html`, `metadata.json` |

## Good to know

- **Minified size needs esbuild.** Without it, `arcade-check.sh` reports the raw size and
  says the minified size was NOT ASSESSED. Install it with `npm i -g esbuild`, or trust the
  official `npm run dev` checker.
- **Phaser 3, not 4.** The repo's web engine starters (`.claude/engines/web/`) pin Phaser 4;
  `/arcade` does not use them.
- **Not driven past the title.** The screenshot proves the game boots; play-testing is yours.
- **Collaborative by default.** Skills ask before writing files and never commit on their own.

## What was removed

The full studio pipeline: GDDs, ADRs, epics, stories, sprints, release, QA, localization,
live-ops, the `team-*` orchestrations, engine specialists for Godot, Unity and Unreal, and
the framework's own test suite. All of it is in git history if you need it back.

## Platform support

Hooks and scripts are POSIX bash with fallbacks for missing tools, tested upstream on
Windows (Git Bash), macOS and Linux. Screenshots need Chrome, Edge or Chromium.

## Credits and license

Based on Claude Code Game Studios by Donchitos. MIT License, see [LICENSE](LICENSE).
