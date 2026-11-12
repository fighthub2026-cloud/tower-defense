import { CLASSES } from "../game/data.js";
import { validSpot } from "../game/systems/map.js";
import { createMapArt } from "../game/art/map.js";
export class WorldView {
  constructor(renderer, atlas) {
    this.renderer = renderer;
    this.atlas = atlas;
    this.background = createMapArt();
  }
  render(game, ui, pointer) {
    const { context: c } = this.renderer;
    this.renderer.clear();
    c.drawImage(this.background, 0, 0);
    const text = (s, x, y, size = 18, color = "#264e62", align = "left") => {
      c.font = `700 ${size}px system-ui`;
      c.fillStyle = color;
      c.textAlign = align;
      c.fillText(s, x, y);
    };
    const box = (x, y, w, h, color) => {
      c.beginPath();
      c.roundRect(x, y, w, h, 10);
      c.fillStyle = color;
      c.fill();
    };
    text("COLÔNIA", 24, 29, 11, "#6d939f");
    text("♥ " + Math.max(0, 100 - game.escaped), 24, 59, 23, "#d66a70");
    text("$ " + game.money, 139, 59, 23, "#aa8530");
    text("LABORATÓRIO DE COMBATE", 1214, 30, 12, "#7497a8", "right");
    text(`${game.kills} gosmas derrotadas`, 1214, 53, 14, "#538397", "right");
    const chosen = game.units[ui.selected];
    if (chosen) {
      c.beginPath();
      c.arc(chosen.x, chosen.y, CLASSES[chosen.type].range, 0, Math.PI * 2);
      c.fillStyle = "#84bbd30d";
      c.fill();
      c.strokeStyle = "#7eb5ca66";
      c.setLineDash([4, 8]);
      c.stroke();
      c.setLineDash([]);
    }
    for (const s of game.slimes) {
      const bounce = Math.sin(game.time * 7 + s.id);
      c.save();
      c.translate(s.x, s.y);
      c.scale(1 + bounce * 0.06, 1 - bounce * 0.08);
      c.beginPath();
      c.ellipse(0, 13, 18, 5, 0, 0, 7);
      c.fillStyle = "#2b7c9522";
      c.fill();
      c.beginPath();
      c.moveTo(-18, 8);
      c.bezierCurveTo(-20, -4, -12, -21, 0, -20);
      c.bezierCurveTo(13, -20, 21, -4, 18, 8);
      c.bezierCurveTo(14, 18, -14, 18, -18, 8);
      c.fillStyle =
        s.flash > 0
          ? "#fff"
          : s.slow > 0
            ? "#bcefff"
            : ["#4ac8f1", "#8bda69", "#b880ed"][s.type];
      c.fill();
      c.strokeStyle = "#2b738e";
      c.lineWidth = 2;
      c.stroke();
      for (const x of [-6, 6]) {
        c.beginPath();
        c.ellipse(x, 2, 2, 3, 0, 0, 7);
        c.fillStyle = "#21465c";
        c.fill();
      }
      c.beginPath();
      c.ellipse(-7, -10, 4, 3, -0.5, 0, 7);
      c.fillStyle = "#ffffffbb";
      c.fill();
      if (s.hp < s.maxHp) {
        c.fillStyle = "#416978";
        c.fillRect(-18, -29, 36, 4);
        c.fillStyle = "#7ee0a9";
        c.fillRect(-18, -29, (36 * s.hp) / s.maxHp, 4);
      }
      c.restore();
    }
    for (const u of [...game.units].sort((a, b) => a.y - b.y))
      this.atlas.draw(
        c,
        u.type,
        u.x,
        u.y,
        u.attackTime >= 0 ? u.attackTime : game.time + (u.x % 5),
        u.attackTime >= 0,
        0.82,
        u.flip,
      );
    for (const t of game.traps) {
      box(t.x - 17, t.y - 9, 34, 18, "#566b7b");
      for (let i = 0; i < 3; i++) {
        c.beginPath();
        c.moveTo(t.x - 13 + i * 10, t.y + 4);
        c.lineTo(t.x - 8 + i * 10, t.y - 12);
        c.lineTo(t.x - 3 + i * 10, t.y + 4);
        c.fillStyle = "#c9e8f3";
        c.fill();
      }
    }
    for (const p of game.projectiles) {
      c.save();
      c.translate(p.x, p.y);
      if (p.type === 1) {
        c.rotate(game.time * 20);
        c.beginPath();
        for (let i = 0; i < 8; i++) {
          const a = (i * Math.PI) / 4,
            r = i % 2 ? 3 : 11;
          c.lineTo(Math.cos(a) * r, Math.sin(a) * r);
        }
        c.closePath();
        c.fillStyle = "#7093a9";
        c.fill();
        c.strokeStyle = "#e4f9ff";
        c.stroke();
      } else {
        c.beginPath();
        c.arc(0, 0, p.type === 2 ? 9 : 7, 0, 7);
        c.fillStyle =
          p.type === 0
            ? "#fff"
            : p.type === 2
              ? "#354e63"
              : CLASSES[p.type].color;
        c.shadowBlur = p.type === 5 ? 15 : 0;
        c.shadowColor = CLASSES[p.type].color;
        c.fill();
        c.strokeStyle = "#ffffffaa";
        c.lineWidth = 2;
        c.stroke();
      }
      c.restore();
    }
    for (const e of game.effects) {
      c.save();
      c.globalAlpha = e.life / e.max;
      c.strokeStyle = CLASSES[e.type].color;
      c.lineWidth = 3;
      c.beginPath();
      c.arc(
        e.x,
        e.y,
        8 + (1 - e.life / e.max) * (e.type === 2 ? 60 : 28),
        0,
        7,
      );
      c.stroke();
      for (let i = 0; i < 7; i++) {
        const angle = (i * 7) / 7,
          r = (1 - e.life / e.max) * 30;
        c.fillStyle = CLASSES[e.type].color;
        c.fillRect(e.x + Math.cos(angle) * r, e.y + Math.sin(angle) * r, 4, 4);
      }
      c.restore();
    }
    if (ui.placing && pointer && pointer.x < 1240) {
      c.globalAlpha = 0.6;
      this.atlas.draw(
        c,
        ui.chosen,
        pointer.x,
        pointer.y,
        game.time,
        false,
        0.82,
      );
      c.globalAlpha = 1;
      c.beginPath();
      c.arc(pointer.x, pointer.y, 35, 0, 7);
      c.strokeStyle = validSpot(pointer.x, pointer.y, game.units)
        ? "#42af8b"
        : "#dd6671";
      c.stroke();
    }
    box(1240, 0, 200, 820, "#d4b88f");
    text("PINGUINS", 1340, 36, 21, "#5b4936", "center");
    text("Selecione para construir", 1340, 59, 11, "#76644e", "center");
    CLASSES.forEach((s, i) => {
      const y = 80 + i * 103;
      box(1253, y, 174, 94, i === ui.chosen ? "#f7fdff" : "#ecdfc9");
      this.atlas.draw(c, i, 1293, y + 44, game.time, false, 0.68);
      text(s.name, 1330, y + 38, 12);
      text(
        "$ " + s.cost,
        1330,
        y + 60,
        14,
        game.money < s.cost ? "#c76c72" : "#68834e",
      );
    });
    box(1253, 710, 174, 95, "#f8f0e1");
    if (chosen) {
      text(CLASSES[chosen.type].name, 1340, 735, 15, "#614e38", "center");
      text(
        chosen.attackTime >= 0 ? "Atacando" : "Buscando alvo",
        1340,
        758,
        12,
        "#7c6a52",
        "center",
      );
      text(chosen.kills + " derrotadas", 1340, 782, 12, "#7c6a52", "center");
    } else {
      text("Defenda a colônia", 1340, 755, 13, "#7c6a52", "center");
    }
  }
}
