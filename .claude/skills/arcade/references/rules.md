# Arcade challenge rules — Platanus Hack 26

Source: the Platanus Hack 26 Arcade Challenge sheet the user pasted on 2026-11-14 (event
Santiago, 20–22 November 2026). It overrides edition 25: the codes, the key table and the
metadata changed. If the official repo's `AGENTS.md` or `docs/` say otherwise, they win.

## Dates

- **Submission deadline:** Wednesday 18 November 2026, 23:59 Santiago (UTC−3).
- **Community vote closes:** 20 November 2026, 23:59 Santiago.
- Prizes: Best Game (Platanus team) and Most Popular (community), each $150 USDC, a hackathon
  slot and the game on the cabinet.

## Submission

| File | Rule |
|---|---|
| `game.js` | The game. **≤ 50 KB after minification** (the official checker minifies it) |
| `metadata.json` | Game name, description, and `player_mode`: `single_player` or `two_player` |
| `cover.png` | **Exactly 800x600**, **≤ 500 KB** |

Submit with the **Submit** button in the official dev UI (`npm install`, `npm run dev`,
`http://localhost:3001`, live size and restriction status).

## Code

- Vanilla JavaScript only: no `import`, no `require`.
- No external URLs: no `http://`, `https://` or `//` (only `data:` URIs).
- No network: no `fetch`, `XMLHttpRequest` or similar. It runs in a sandboxed iframe with no
  internet and **no `allow-same-origin`**.
- Phaser **3.87.0**, loaded by the cabinet from a CDN, not counted in the size.
- Allowed: `data:` URI images, Graphics-API textures, Web Audio tones, canvas effects.
- **The user's own rule is stricter: no assets at all, "todo con código".** No `data:` images;
  every texture from Graphics, every sound from Web Audio.

## Controls

`CABINET_KEYS` matches the physical wiring. **Never change or replace its keys**; adding extra
local-testing keys to an array is allowed (append only). Game logic reads cabinet codes, never
raw keys.

| | Joystick | Top row | Bottom row | Start |
|---|---|---|---|---|
| P1 | `P1_U` `P1_D` `P1_L` `P1_R` (W S A D) | `P1_1` `P1_2` `P1_3` (U I O) | `P1_4` `P1_5` `P1_6` (J K L) | `START1` (Enter) |
| P2 | `P2_U` `P2_D` `P2_L` `P2_R` (arrows) | `P2_1` `P2_2` `P2_3` (R T Y) | `P2_4` `P2_5` `P2_6` (F G H) | `START2` (2) |

Advice from the sheet: joystick plus 1–2 action buttons.

## Canvas

The official starter: 800x600, `parent: 'game-root'`,
`scale: { mode: Phaser.Scale.FIT, autoCenter: Phaser.Scale.CENTER_BOTH }`.

## Storage

`localStorage` is not reliable in the sandbox. Persist through the parent bridge:

```js
await window.platanusArcadeStorage.get(key)    // { found, value }
await window.platanusArcadeStorage.set(key, value)
await window.platanusArcadeStorage.remove(key)
```

Fall back to a guarded `localStorage` only when the bridge is absent (local testing), as the
official starter does.

## Not sourced

- The judging criteria beyond "best game" and "most popular".
- The exact minifier and the KB definition (1000 or 1024 bytes): keep headroom below 50 000 B.
