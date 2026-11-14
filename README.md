# Arcade Challenge Studio

A trimmed fork of [Claude Code Game Studios](https://github.com/Donchitos/Claude-Code-Game-Studios),
cut down to one job: build the coolest arcade game for the **Platanus Hack 26 Arcade
Challenge** (deadline **18 November 2026, 23:59 Santiago**), with **Phaser 3**, in **one
`game.js` under 50 KB**, and **no external assets**: every sprite drawn and every sound
synthesized in code.

## Quick path: as a submodule of your challenge repo

This repo is a tool; the game lives in your copy of the challenge repo (it has `game.js`,
`metadata.json` and `AGENTS.md` at its root). In that repo:

```bash
git submodule add https://github.com/Jrgil20/Claude-Code-Game-Studios tools/studio
mkdir -p .claude/skills
ln -s ../../tools/studio/.claude/skills/arcade .claude/skills/arcade
npm install
```

1. Start Claude Code at the challenge repo's root.
2. Run `/arcade <your game in one sentence>`. It edits the root `game.js`,
   `metadata.json` and `cover.png` only, obeys the repo's `AGENTS.md`, runs
   `npm run check-restrictions` plus its own check, and screenshots the cover.
3. Play it with `npm run dev` (localhost:3001), then hit **Submit** in the dev UI.

**Why the symlink:** Claude Code loads skills from `.claude/skills/` where the session starts
and in parent folders, but a nested one (`tools/studio/.claude/skills/`) only after Claude
first touches a file there. `/add-dir tools/studio` also works, per session. The studio's
hooks, agents and `settings.json` do not load from the parent; `/arcade` does not need them.

**Not sourced:** whether the official checker or the Submit step objects to the extra
`tools/` and `.claude/` folders. The repo's `AGENTS.md` only says which files to edit.

## Standalone

Open Claude Code in this folder and run `/arcade`: with no challenge repo around, it builds in
`prototypes/<name>/` and you play it by opening that folder's `index.html`.

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
| Check scripts | `.claude/skills/arcade/scripts/`: `arcade-check.sh <game folder>` (raw and minified size, forbidden-pattern hits, `CABINET_KEYS` intact, `player_mode`, cover size) and `cover-shot.sh <game folder> <out.png>` (the 800x600 cover). They report; `/arcade` decides |
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
