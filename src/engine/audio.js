export class Audio {
  enabled = false;
  toggle() {
    this.enabled = !this.enabled;
    if (this.enabled) {
      this.context ??= new AudioContext();
      this.context.resume();
    }
    return this.enabled;
  }
  play(type = 0) {
    if (!this.enabled || !this.context) return;
    const a = this.context,
      o = a.createOscillator(),
      g = a.createGain();
    o.type = type === 2 ? "sawtooth" : "sine";
    o.frequency.setValueAtTime(
      [650, 800, 130, 1100, 240, 490][type],
      a.currentTime,
    );
    o.frequency.exponentialRampToValueAtTime(70, a.currentTime + 0.12);
    g.gain.setValueAtTime(0.035, a.currentTime);
    g.gain.exponentialRampToValueAtTime(0.001, a.currentTime + 0.15);
    o.connect(g).connect(a.destination);
    o.start();
    o.stop(a.currentTime + 0.16);
  }
}
