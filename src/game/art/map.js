import { route } from "../systems/map.js";
export function createMapArt() {
  const bg = document.createElement("canvas");
  bg.width = 1240;
  bg.height = 820;
  const b = bg.getContext("2d");
  b.fillStyle = "#edf8fc";
  b.fillRect(0, 0, 1240, 820);
  let seed = 91;
  function rand() {
    seed = (seed * 1664525 + 1013904223) >>> 0;
    return seed / 4294967296;
  }
  for (let i = 0; i < 380; i++) {
    b.fillStyle = i % 2 ? "#d9edf355" : "#ffffffaa";
    b.beginPath();
    b.ellipse(rand() * 1240, rand() * 820, 2 + rand() * 5, 1, 0, 0, 7);
    b.fill();
  }
  function road(color, width) {
    b.beginPath();
    route.forEach((p, i) => (i ? b.lineTo(...p) : b.moveTo(...p)));
    b.lineWidth = width;
    b.strokeStyle = color;
    b.lineJoin = "round";
    b.lineCap = "round";
    b.stroke();
  }
  road("#b7dce9", 72);
  road("#fff", 66);
  road("#8bd8ec", 58);
  road("#a5e4f1", 44);
  for (const [x, y] of [
    [40, 90],
    [85, 70],
    [1190, 160],
    [1150, 110],
    [70, 740],
    [115, 780],
    [1160, 745],
  ]) {
    b.fillStyle = "#387888";
    b.beginPath();
    b.ellipse(x, y + 28, 24, 8, 0, 0, 7);
    b.fill();
    for (let j = 0; j < 3; j++) {
      b.beginPath();
      b.moveTo(x, y - 40 + j * 18);
      b.lineTo(x - 23 + j * 4, y + 5 + j * 13);
      b.quadraticCurveTo(x, y + 15 + j * 13, x + 23 - j * 4, y + 5 + j * 13);
      b.closePath();
      b.fillStyle = j % 2 ? "#cdeef5" : "#fff";
      b.fill();
      b.strokeStyle = "#9bcedc";
      b.lineWidth = 1;
      b.stroke();
    }
  }
  return bg;
}
