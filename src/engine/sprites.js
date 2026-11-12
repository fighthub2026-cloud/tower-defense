export class SpriteAtlas {
  constructor(draw, types, { size = 128, frames = 24, duration = 0.8 } = {}) {
    Object.assign(this, { size, frames, duration });
    this.sheets = Array.from({ length: types }, (_, type) => {
      const canvas = document.createElement("canvas");
      canvas.width = size * frames;
      canvas.height = size * 2;
      const c = canvas.getContext("2d");
      for (let state = 0; state < 2; state++)
        for (let f = 0; f < frames; f++) {
          c.save();
          c.translate(f * size, state * size);
          draw(c, type, f / (frames - 1), state === 1);
          c.restore();
        }
      return canvas;
    });
  }
  draw(c, type, x, y, time, attack = false, scale = 1, flip = false) {
    const frame = attack
      ? Math.min(
          this.frames - 1,
          Math.floor((time / this.duration) * this.frames),
        )
      : Math.floor(time * 12) % this.frames;
    c.save();
    c.translate(x, y);
    c.scale(flip ? -scale : scale, scale);
    c.drawImage(
      this.sheets[type],
      frame * this.size,
      attack ? this.size : 0,
      this.size,
      this.size,
      -this.size / 2,
      -this.size / 2,
      this.size,
      this.size,
    );
    c.restore();
  }
}
