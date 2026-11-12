export class Renderer {
  constructor(canvas, width = 1440, height = 820) {
    this.canvas = canvas;
    this.width = width;
    this.height = height;
    this.context = canvas.getContext("2d");
    this.resize = () => {
      const dpr = Math.min(devicePixelRatio || 1, 2);
      canvas.width = width * dpr;
      canvas.height = height * dpr;
      this.context.setTransform(dpr, 0, 0, dpr, 0, 0);
    };
    this.resize();
    window.addEventListener("resize", this.resize);
  }
  clear() {
    this.context.clearRect(0, 0, this.width, this.height);
  }
}
