// Platanus Hack 26 arcade starter: one file, Phaser 3.87 (loaded by the cabinet), no assets.
// Everything you see is drawn with Graphics; everything you hear is a Web Audio tone.

const W = 800, H = 600;

// Arcade cabinet button -> keyboard key mapping. It matches the physical cabinet wiring.
// DO NOT modify or replace these keys; append extra local-testing keys only.
const CABINET_KEYS = {
  P1_U: ['w'], P1_D: ['s'], P1_L: ['a'], P1_R: ['d'],
  P1_1: ['u'], P1_2: ['i'], P1_3: ['o'],
  P1_4: ['j'], P1_5: ['k'], P1_6: ['l'],
  P2_U: ['ArrowUp'], P2_D: ['ArrowDown'], P2_L: ['ArrowLeft'], P2_R: ['ArrowRight'],
  P2_1: ['r'], P2_2: ['t'], P2_3: ['y'],
  P2_4: ['f'], P2_5: ['g'], P2_6: ['h'],
  START1: ['Enter'], START2: ['2'],
};

const KEY_TO_ARCADE = {};
for (const [code, keys] of Object.entries(CABINET_KEYS)) {
  for (const key of keys) KEY_TO_ARCADE[key.length === 1 ? key.toLowerCase() : key] = code;
}

// ---- Input: held state plus one-shot presses, keyed by cabinet code ----
const held = Object.create(null), pressed = Object.create(null);
const codeOf = (e) => KEY_TO_ARCADE[e.key.length === 1 ? e.key.toLowerCase() : e.key];
window.addEventListener('keydown', (e) => {
  const c = codeOf(e); if (!c) return;
  if (!held[c]) pressed[c] = true;
  held[c] = true;
});
window.addEventListener('keyup', (e) => { const c = codeOf(e); if (c) held[c] = false; });
const take = (c) => { const p = pressed[c]; pressed[c] = false; return p; };
// Drop presses buffered in another state, so a button mashed in play cannot skip GAME OVER.
const flush = () => { for (const c in pressed) pressed[c] = false; };

// ---- Storage: the arcade's parent bridge, or guarded localStorage when testing locally ----
function getStorage() {
  if (window.platanusArcadeStorage) return window.platanusArcadeStorage;
  return {
    async get(key) {
      try {
        const raw = window.localStorage.getItem(key);
        return raw === null ? { found: false, value: null } : { found: true, value: JSON.parse(raw) };
      } catch { return { found: false, value: null }; }
    },
    async set(key, value) { try { window.localStorage.setItem(key, JSON.stringify(value)); } catch {} },
  };
}

// ---- Tuning: every gameplay number lives here ----
const TUNE = {
  playerSpeed: 320,
  spawnEveryMs: 900, spawnFloorMs: 250, spawnRampMs: 15,
  enemySpeedMin: 120, enemySpeedMax: 260,
  pointsPerSecond: 10,
};

// ---- Sound: short synth tones, no files ----
function tone(scene, freq, ms, type = 'square', vol = 0.08) {
  const ctx = scene.sound.context; if (!ctx) return;
  const o = ctx.createOscillator(), g = ctx.createGain();
  o.type = type; o.frequency.value = freq;
  g.gain.setValueAtTime(vol, ctx.currentTime);
  g.gain.exponentialRampToValueAtTime(0.0001, ctx.currentTime + ms / 1000);
  o.connect(g).connect(ctx.destination); o.start(); o.stop(ctx.currentTime + ms / 1000);
}

// ---- Textures: drawn once, then used like images ----
function makeTextures(scene) {
  if (scene.textures.exists('player')) return;
  const g = scene.make.graphics({ x: 0, y: 0, add: false });
  g.fillStyle(0xe1ff00).fillTriangle(16, 0, 32, 32, 0, 32).generateTexture('player', 32, 32).clear();
  g.fillStyle(0xff6ec7).fillCircle(12, 12, 12).generateTexture('enemy', 24, 24).clear();
  g.fillStyle(0xffffff).fillRect(0, 0, 2, 2).generateTexture('dot', 2, 2).destroy();
}

const BEST_KEY = 'dodge-best';
let best = 0;

class Title extends Phaser.Scene {
  constructor() { super('title'); }
  create() {
    flush(); makeTextures(this);
    this.add.text(W / 2, H / 3, 'DODGE', { fontFamily: 'monospace', fontSize: '72px', color: '#e1ff00' }).setOrigin(0.5);
    const bestText = this.add.text(W / 2, H / 2 + 40, 'BEST ' + best, { fontFamily: 'monospace', fontSize: '24px', color: '#fff' }).setOrigin(0.5);
    getStorage().get(BEST_KEY).then((r) => { if (r.found) { best = r.value; bestText.setText('BEST ' + best); } });
    const p = this.add.text(W / 2, H * 0.75, 'PRESS START', { fontFamily: 'monospace', fontSize: '28px', color: '#ff6ec7' }).setOrigin(0.5);
    this.tweens.add({ targets: p, alpha: 0, duration: 500, yoyo: true, repeat: -1 });
  }
  update() { if (take('START1') || take('P1_1')) { tone(this, 660, 120); this.scene.start('play'); } }
}

class Play extends Phaser.Scene {
  constructor() { super('play'); }
  create() {
    flush(); this.score = 0; this.alive = true; this.spawnMs = TUNE.spawnEveryMs; this.nextSpawn = 0;
    this.player = this.physics.add.image(W / 2, H - 60, 'player').setCollideWorldBounds(true);
    this.enemies = this.physics.add.group();
    this.physics.add.overlap(this.player, this.enemies, () => this.die());
    this.hud = this.add.text(16, 12, '', { fontFamily: 'monospace', fontSize: '22px', color: '#fff' });
    this.burst = this.add.particles(0, 0, 'dot', { speed: 200, lifespan: 600, quantity: 30, emitting: false });
  }
  update(time, dt) {
    if (!this.alive) { if (take('START1') || take('P1_1')) this.scene.start('title'); return; }
    const s = TUNE.playerSpeed;
    this.player.setVelocity((held.P1_R ? s : 0) - (held.P1_L ? s : 0), (held.P1_D ? s : 0) - (held.P1_U ? s : 0));
    if (time > this.nextSpawn) {
      this.nextSpawn = time + this.spawnMs;
      this.spawnMs = Math.max(TUNE.spawnFloorMs, this.spawnMs - TUNE.spawnRampMs);
      const e = this.enemies.create(Phaser.Math.Between(12, W - 12), -12, 'enemy');
      e.setVelocityY(Phaser.Math.Between(TUNE.enemySpeedMin, TUNE.enemySpeedMax));
    }
    this.enemies.children.each((e) => { if (e.y > H + 20) e.destroy(); });
    this.score += (TUNE.pointsPerSecond * dt) / 1000;
    this.hud.setText('SCORE ' + Math.floor(this.score) + '   BEST ' + best);
  }
  die() {
    if (!this.alive) return;
    this.alive = false; this.physics.pause(); flush();
    this.burst.explode(30, this.player.x, this.player.y); this.player.setVisible(false);
    this.cameras.main.shake(250, 0.01); tone(this, 110, 400, 'sawtooth', 0.12);
    const s = Math.floor(this.score);
    if (s > best) { best = s; getStorage().set(BEST_KEY, best); }
    this.add.text(W / 2, H / 2, 'GAME OVER\n\nSCORE ' + s, { fontFamily: 'monospace', fontSize: '40px', color: '#fff', align: 'center' }).setOrigin(0.5);
  }
}

new Phaser.Game({
  type: Phaser.AUTO, width: W, height: H, parent: 'game-root', backgroundColor: '#111111',
  scale: { mode: Phaser.Scale.FIT, autoCenter: Phaser.Scale.CENTER_BOTH },
  physics: { default: 'arcade' },
  scene: [Title, Play],
});
