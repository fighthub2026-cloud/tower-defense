export class Penguin {
  constructor(type, x, y) {
    Object.assign(this, {
      type,
      x,
      y,
      cooldown: 0,
      attackTime: -1,
      released: false,
      target: null,
      flip: false,
      kills: 0,
    });
  }
}
export class Slime {
  constructor(id) {
    Object.assign(this, {
      id,
      distance: -id * 65,
      hp: 55,
      maxHp: 55,
      slow: 0,
      flash: 0,
      alive: true,
      x: -100,
      y: 345,
      type: id % 3,
    });
  }
}
export class Projectile {
  constructor(unit, target) {
    Object.assign(this, {
      type: unit.type,
      x: unit.x,
      y: unit.y + 10,
      target,
      life: 2,
      hit: new Set(),
    });
    this.damage = 0;
  }
}
