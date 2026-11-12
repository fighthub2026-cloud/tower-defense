import test from "node:test";
import assert from "node:assert/strict";
import { Combat } from "../src/game/systems/combat.js";
import { Penguin, Slime } from "../src/game/entities/entities.js";
import { along, validSpot } from "../src/game/systems/map.js";
test("todas as classes atacam após preparação, aplicam dano e eliminam gosmas", () => {
  for (let type = 0; type < 6; type++) {
    const game = new Combat();
    game.units = [new Penguin(type, 200, 260)];
    game.spawn = Infinity;
    const s = new Slime(0);
    s.distance = 200;
    s.hp = s.maxHp = 30;
    Object.assign(s, along(200));
    game.slimes = [s];
    game.update(1 / 60);
    assert.equal(game.units[0].attackTime, 0);
    assert.equal(game.projectiles.length, 0);
    assert.equal(game.traps.length, 0);
    for (let n = 0; n < 480; n++) game.update(1 / 60);
    assert.ok(game.kills > 0, `classe ${type} deve eliminar alvo`);
    assert.equal(game.units[0].kills, game.kills);
  }
});
test("posicionamento rejeita pista e sobreposição", () => {
  assert.equal(validSpot(200, 345, []), false);
  assert.equal(validSpot(200, 240, [new Penguin(0, 200, 240)]), false);
  assert.equal(validSpot(200, 240, []), true);
});
test("simulação prolongada mantém entidades e efeitos limitados", () => {
  const game = new Combat();
  for (let n = 0; n < 60 * 180; n++) game.update(1 / 60);
  assert.ok(game.kills > 0);
  assert.ok(game.slimes.length <= 45);
  assert.ok(game.projectiles.length < 100);
  assert.ok(game.effects.length < 100);
  assert.ok(game.traps.length < 20);
});
