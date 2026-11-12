export function drawPenguin(c, type, phase, attack) {
  const breath = Math.sin(phase * Math.PI * 2);
  const wind = attack
    ? Math.sin((Math.min(phase / 0.34, 1) * Math.PI) / 2) *
      (phase < 0.34 ? 1 : 0)
    : 0;
  const hit =
    attack && phase >= 0.34 ? Math.max(0, 1 - (phase - 0.34) / 0.18) : 0;
  const recover =
    attack && phase >= 0.52 ? Math.max(0, 1 - (phase - 0.52) / 0.48) : 0;
  const kick = hit;
  const swing = attack
    ? phase < 0.34
      ? -wind
      : phase < 0.52
        ? 1
        : recover
    : 0;
  c.save();
  c.translate(60, 66);
  c.lineWidth = 2.2;
  c.lineJoin = "round";
  c.lineCap = "round";
  function path(points, fill, stroke = "#233b50") {
    c.beginPath();
    points.forEach((p, i) => (i ? c.lineTo(...p) : c.moveTo(...p)));
    c.closePath();
    c.fillStyle = fill;
    c.fill();
    if (stroke) {
      c.strokeStyle = stroke;
      c.stroke();
    }
  }
  function oval(x, y, rx, ry, fill, stroke = "#233b50") {
    c.beginPath();
    c.ellipse(x, y, rx, ry, 0, 0, Math.PI * 2);
    c.fillStyle = fill;
    c.fill();
    if (stroke) {
      c.strokeStyle = stroke;
      c.stroke();
    }
  }
  function line(x, y, xx, yy, color, width = 3) {
    c.beginPath();
    c.moveTo(x, y);
    c.lineTo(xx, yy);
    c.strokeStyle = color;
    c.lineWidth = width;
    c.stroke();
    c.lineWidth = 2.2;
  }
  function star(x, y, r, color) {
    const p = [];
    for (let i = 0; i < 10; i++) {
      const a = (i * Math.PI) / 5 - Math.PI / 2,
        k = i % 2 ? r * 0.45 : r;
      p.push([x + Math.cos(a) * k, y + Math.sin(a) * k]);
    }
    path(p, color);
  }
  oval(0, 20, 28, 10, "#376b8523", null);
  c.translate(-wind * 3 + hit * 4, attack ? wind * 3 - hit * 3 : breath * 0.6);
  c.rotate(-wind * 0.16 + hit * 0.18);
  oval(-11, 19, 8, 5, "#f6af32");
  oval(11, 19, 8, 5, "#f6af32");
  // Asas nas laterais, articuladas pelo ombro; a asa direita executa o golpe.
  c.save();
  c.translate(-21, 3);
  c.rotate(0.25 + wind * 0.35 - hit * 0.4);
  oval(0, 8, 7, 14, "#22354b");
  c.restore();
  c.save();
  c.translate(20, 3);
  c.rotate(-0.25 - swing * 1.35);
  oval(0, 8, 7, 16, "#22354b");
  c.restore();
  const g = c.createLinearGradient(-20, -22, 22, 23);
  g.addColorStop(0, "#45576e");
  g.addColorStop(0.6, "#1c2c40");
  g.addColorStop(1, "#0f2034");
  oval(0, 0, 23, 27, g);
  oval(0, 6, 16, 19, "#f4faff");
  oval(-7, -5, 10, 10, "#f4faff", null);
  oval(7, -5, 10, 10, "#f4faff", null);
  if (phase > 0.84 && !attack) {
    line(-11, -5, -5, -5, "#243449", 2);
    line(5, -5, 11, -5, "#243449", 2);
  } else {
    oval(-8, -6, 2.7, 3.6, "#162e42", null);
    oval(8, -6, 2.7, 3.6, "#162e42", null);
    oval(-8.6, -7, 1, 1, "white", null);
    oval(7.4, -7, 1, 1, "white", null);
  }
  path(
    [
      [-6, 0],
      [0, -2],
      [7, 1],
      [0, 7],
    ],
    "#ffbf34",
  );
  if (type === 0) {
    path(
      [
        [-23, -15],
        [-19, -28],
        [-3, -34],
        [16, -29],
        [22, -15],
      ],
      "#368cd4",
    );
    oval(0, -15, 25, 5, "#5ebcf6");
    oval(-18, -28, 6, 6, "#f5fbff");
    if (!attack || phase < 0.35) {
      oval(25 - wind * 15, 18 - wind * 24, 8, 8, "#f6fdff");
      line(
        21 - wind * 15,
        21 - wind * 24,
        27 - wind * 15,
        23 - wind * 24,
        "#8dd8ef",
        2,
      );
    }
  }
  if (type === 1) {
    path(
      [
        [-23, -17],
        [23, -17],
        [23, -7],
        [-23, -7],
      ],
      "#ef4b43",
    );
    path(
      [
        [21, -13],
        [35, -24],
        [34, -11],
        [24, -8],
        [38, -2],
        [27, 2],
      ],
      "#e4433c",
    );
    if (!attack || phase < 0.35) {
      c.save();
      c.translate(28 - wind * 14, 17 - wind * 18);
      c.rotate(-wind * 1.8);
      star(0, 0, 11, "#bdced9");
      oval(0, 0, 2, 2, "#25364b", null);
      c.restore();
    }
  }
  if (type === 2) {
    path(
      [
        [-23, -16],
        [-19, -30],
        [-4, -36],
        [13, -31],
        [22, -17],
      ],
      "#eb544a",
    );
    oval(0, -17, 25, 4, "#ff7c59");
    line(-21, -9, 21, -9, "#1c3047", 5);
    oval(-11, -10, 8, 7, "#f6c16a");
    oval(9, -10, 8, 7, "#f6c16a");
    oval(-11, -10, 5, 4, "#6de0f7");
    oval(9, -10, 5, 4, "#6de0f7");
    c.save();
    c.translate(22 - hit * 13, 14 + wind * 2);
    path(
      [
        [-12, -8],
        [17, -10],
        [19, 9],
        [-12, 9],
      ],
      "#546c7e",
    );
    oval(18, 0, 7, 10, "#263e51");
    oval(18, 0, 4, 6, "#0c2230");
    if (hit > 0.25) {
      star(29, 0, 15 * hit, "#ffcf58");
      star(29, 0, 8 * hit, "#fff8c1");
    }
    c.restore();
  }
  if (type === 3) {
    path(
      [
        [-25, -8],
        [-23, -28],
        [-9, -38],
        [10, -36],
        [24, -23],
        [26, -7],
      ],
      "#3da9e8",
    );
    for (let i = 0; i < 9; i++)
      oval(
        -24 + i * 6,
        -12 + Math.sin((i / 8) * Math.PI) * -5,
        5,
        5,
        "#f4fbff",
      );
    c.save();
    c.translate(25 + swing * 12, 15 - wind * 17);
    c.rotate(phase * 3);
    line(0, -10, 0, 10, "#c5f6ff", 3);
    line(-10, 0, 10, 0, "#c5f6ff", 3);
    line(-7, -7, 7, 7, "#c5f6ff", 2);
    line(-7, 7, 7, -7, "#c5f6ff", 2);
    oval(0, 0, 3 + wind * 3, "white", null);
    c.restore();
    if (hit > 0) {
      oval(30, 12, 14 + hit * 13, 14 + hit * 13, "#9fefff44", "#7bdcf7");
    }
  }
  if (type === 4) {
    path(
      [
        [-25, -15],
        [-22, -30],
        [-8, -37],
        [9, -36],
        [22, -27],
        [24, -15],
      ],
      "#ffc442",
    );
    line(-4, -35, -4, -17, "#ffe7a0", 5);
    oval(0, -16, 28, 4, "#ef9f23");
    line(-21, -6, 21, -6, "#764e27", 4);
    oval(-10, -5, 8, 7, "#ffb331");
    oval(10, -5, 8, 7, "#ffb331");
    oval(-10, -5, 5, 4, "#63d4ef");
    oval(10, -5, 5, 4, "#63d4ef");
    c.save();
    c.translate(23, 10);
    c.rotate(-wind * 1.8 + hit * 0.8);
    line(0, 16, 8, -6, "#9bbacb", 7);
    path(
      [
        [2, -7],
        [2, -17],
        [19, -17],
        [19, -8],
      ],
      "#d1e3ec",
    );
    c.restore();
    if (hit > 0.1) {
      star(31, 32, 12 * hit, "#ffdf72");
    }
  }
  if (type === 5) {
    path(
      [
        [-23, -17],
        [-13, -33],
        [-6, -45],
        [6, -44],
        [19, -34],
        [8, -35],
        [18, -16],
      ],
      "#9354dc",
    );
    oval(0, -16, 29, 7, "#a866ec");
    line(-19, -19, 18, -19, "#efb447", 3);
    star(-4, -31, 6, "#ffdf63");
    star(11, -24, 3, "#ffdf63");
    c.save();
    c.translate(23, 12);
    c.rotate(-wind * 0.9 + hit * 1.1);
    line(0, 14, 6, -13, "#bd8a4a", 4);
    oval(7, -16, 7 + wind * 5, 8 + wind * 5, "#d185ff");
    oval(5, -19, 2, 3, "#fff3ff", null);
    if (hit > 0) {
      star(12, -17, 18 * hit, "#e6b5ff");
    }
    c.restore();
  }
  // A marca de classe aparece também na silhueta e no equipamento, não só na cor.
  c.restore();
}
