export class Loop {
  constructor(update, render) {
    this.update = update;
    this.render = render;
    this.step = 1 / 60;
    this.speed = 1;
    this.paused = false;
    this.accumulator = 0;
    this.last = null;
    this.frame = this.frame.bind(this);
  }
  start() {
    requestAnimationFrame(this.frame);
  }
  frame(now) {
    const dt = this.last === null ? 0 : Math.min((now - this.last) / 1000, 0.1);
    this.last = now;
    if (!this.paused) {
      this.accumulator += dt * this.speed;
      while (this.accumulator >= this.step) {
        this.update(this.step);
        this.accumulator -= this.step;
      }
    }
    this.render(this.accumulator / this.step);
    requestAnimationFrame(this.frame);
  }
}
