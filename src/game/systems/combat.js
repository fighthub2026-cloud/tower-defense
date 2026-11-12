import { CLASSES } from "../data.js";
import { Penguin, Slime, Projectile } from "../entities/entities.js";
import { along, total } from "./map.js";
export class Combat {
  constructor(audio) {
    this.audio = audio;
    this.reset();
  }
  reset() {
    this.time = 0;
    this.money = 1250;
    this.kills = 0;
    this.escaped = 0;
    this.spawn = 0;
    this.nextId = 0;
    this.slimes = [];
    this.projectiles = [];
    this.effects = [];
    this.traps = [];
    this.units = [
      [5, 380, 240],
      [2, 805, 345],
      [3, 465, 565],
      [1, 880, 570],
      [0, 605, 335],
      [4, 230, 540],
    ].map((a) => new Penguin(...a));
  }
  damage(slime, amount, unit) {
    if (!slime.alive) return;
    slime.hp -= amount;
    slime.flash = 0.12;
    if (slime.hp <= 0) {
      slime.alive = false;
      this.kills++;
      this.money += 8;
      unit.kills++;
      this.effects.push({
        x: slime.x,
        y: slime.y,
        type: unit.type,
        life: 0.4,
        max: 0.4,
      });
    }
  }
  update(dt) {
    this.time += dt;
    this.spawn -= dt;
    if (this.spawn <= 0 && this.slimes.length < 45) {
      this.spawn = 0.85;
      const s = new Slime(this.nextId++);
      s.distance = 0;
      this.slimes.push(s);
    }
    for (const s of this.slimes) {
      if (!s.alive) continue;
      s.slow = Math.max(0, s.slow - dt);
      s.flash = Math.max(0, s.flash - dt);
      s.distance += dt * (s.type === 1 ? 62 : 46) * (s.slow > 0 ? 0.4 : 1);
      Object.assign(s, along(s.distance));
      if (s.distance > total) {
        s.alive = false;
        this.escaped++;
      }
    }
    for (const u of this.units) {
      const spec = CLASSES[u.type];
      u.cooldown = Math.max(0, u.cooldown - dt);
      if (u.attackTime >= 0) {
        u.attackTime += dt;
        if (!u.released && u.attackTime >= 0.8 * 0.35) {
          u.released = true;
          this.audio?.play(u.type);
          if (u.type === 4) {
            const p = along(u.target.distance + 18);
            this.traps.push({ ...p, life: 8, unit: u });
          } else {
            const p = new Projectile(u, u.target);
            p.unit = u;
            p.damage = spec.damage;
            this.projectiles.push(p);
          }
        }
        if (u.attackTime >= 0.8) u.attackTime = -1;
      }
      if (u.attackTime < 0 && u.cooldown <= 0) {
        const target = this.slimes
          .filter(
            (s) => s.alive && Math.hypot(s.x - u.x, s.y - u.y) <= spec.range,
          )
          .sort((a, b) => b.distance - a.distance)[0];
        if (target) {
          u.target = target;
          u.flip = target.x < u.x;
          u.attackTime = 0;
          u.released = false;
          u.cooldown = spec.cooldown;
        }
      }
    }
    for (const p of this.projectiles) {
      p.life -= dt;
      if (!p.target.alive) {
        p.life = 0;
        continue;
      }
      const dx = p.target.x - p.x,
        dy = p.target.y - p.y,
        d = Math.hypot(dx, dy),
        speed = p.type === 2 ? 310 : 430;
      if (d < speed * dt + 12) {
        p.life = 0;
        this.damage(p.target, p.damage, p.unit);
        if (p.type === 3) p.target.slow = 2.5;
        if (p.type === 2 || p.type === 3) {
          const radius = p.type === 2 ? 65 : 50;
          for (const s of this.slimes)
            if (
              s !== p.target &&
              s.alive &&
              Math.hypot(s.x - p.x, s.y - p.y) < radius
            ) {
              this.damage(s, p.damage * 0.6, p.unit);
              if (p.type === 3) s.slow = 2.5;
            }
        }
        this.effects.push({
          x: p.x,
          y: p.y,
          type: p.type,
          life: 0.3,
          max: 0.3,
        });
      } else {
        p.x += (dx / d) * speed * dt;
        p.y += (dy / d) * speed * dt;
      }
    }
    for (const trap of this.traps) {
      trap.life -= dt;
      const s = this.slimes.find(
        (s) => s.alive && Math.hypot(s.x - trap.x, s.y - trap.y) < 25,
      );
      if (s) {
        this.damage(s, CLASSES[4].damage, trap.unit);
        s.slow = 1;
        trap.life = 0;
      }
    }
    for (const e of this.effects) e.life -= dt;
    this.slimes = this.slimes.filter((s) => s.alive);
    this.projectiles = this.projectiles.filter((p) => p.life > 0);
    this.effects = this.effects.filter((e) => e.life > 0);
    this.traps = this.traps.filter((t) => t.life > 0);
  }
}
