export class Input {
  constructor(canvas, width, height, onClick, onCancel) {
    this.pointer = null;
    const position = (e) => {
      const r = canvas.getBoundingClientRect();
      return {
        x: ((e.clientX - r.left) * width) / r.width,
        y: ((e.clientY - r.top) * height) / r.height,
      };
    };
    canvas.addEventListener("pointermove", (e) => (this.pointer = position(e)));
    canvas.addEventListener("pointerleave", () => (this.pointer = null));
    canvas.addEventListener("pointerdown", (e) => onClick(position(e)));
    window.addEventListener("keydown", (e) => {
      if (e.key === "Escape") onCancel();
    });
  }
}
