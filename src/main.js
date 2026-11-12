import { Loop } from "./engine/loop.js";
import { Renderer } from "./engine/renderer.js";
import { Input } from "./engine/input.js";
import { Audio } from "./engine/audio.js";
import { SpriteAtlas } from "./engine/sprites.js";
import { drawPenguin } from "./game/art/penguins.js";
import { Combat } from "./game/systems/combat.js";
import { Penguin } from "./game/entities/entities.js";
import { CLASSES } from "./game/data.js";
import { validSpot } from "./game/systems/map.js";
import { WorldView } from "./ui/world-view.js";
try {
  const renderer = new Renderer(document.getElementById("game")),
    audio = new Audio(),
    atlas = new SpriteAtlas(drawPenguin, CLASSES.length),
    game = new Combat(audio),
    view = new WorldView(renderer, atlas);
  const ui = { chosen: 5, selected: 0, placing: false },
    hint = document.getElementById("hint");
  const input = new Input(
    renderer.canvas,
    1440,
    820,
    (p) => {
      if (p.x >= 1240) {
        const i = Math.floor((p.y - 80) / 103);
        if (p.y >= 80 && p.y < 698 && i < 6) {
          ui.chosen = i;
          ui.placing = true;
          hint.textContent = `${CLASSES[i].name}: clique na neve para construir. Esc cancela.`;
        }
        return;
      }
      if (ui.placing) {
        const spec = CLASSES[ui.chosen];
        if (game.money < spec.cost) {
          hint.textContent = "Dinheiro insuficiente.";
          return;
        }
        if (!validSpot(p.x, p.y, game.units)) {
          hint.textContent = "Escolha uma área livre, fora da pista.";
          return;
        }
        game.money -= spec.cost;
        game.units.push(new Penguin(ui.chosen, p.x, p.y));
        ui.selected = game.units.length - 1;
        ui.placing = false;
        hint.textContent =
          "Pinguim construído. Ele ataca automaticamente ao encontrar um alvo.";
      } else {
        ui.selected = game.units.findIndex(
          (u) => Math.hypot(u.x - p.x, u.y - p.y) < 40,
        );
      }
    },
    () => {
      ui.placing = false;
      hint.textContent = "Selecione um pinguim na lateral e clique na neve.";
    },
  );
  const loop = new Loop(
    (dt) => game.update(dt),
    () => {
      view.render(game, ui, input.pointer);
      document.getElementById("status").textContent =
        `${loop.paused ? "PAUSADO" : "EM COMBATE"} · ${game.projectiles.length} projéteis · 288 quadros em cache`;
    },
  );
  document.getElementById("pause").onclick = (e) => {
    loop.paused = !loop.paused;
    e.target.textContent = loop.paused ? "Continuar" : "Pausar";
  };
  document.getElementById("speed").onclick = (e) => {
    loop.speed = loop.speed === 1 ? 2 : 1;
    e.target.textContent = loop.speed + "×";
  };
  document.getElementById("reset").onclick = () => {
    game.reset();
    ui.selected = 0;
    ui.placing = false;
    loop.accumulator = 0;
  };
  document.getElementById("sound").onclick = (e) => {
    const enabled = audio.toggle();
    e.target.textContent = enabled ? "Som: ligado" : "Som: desligado";
    e.target.setAttribute("aria-pressed", enabled);
  };
  document.getElementById("export").onclick = () => {
    const a = document.createElement("a");
    a.download = `pinguim-${CLASSES[ui.chosen].id}-128px.png`;
    a.href = atlas.sheets[ui.chosen].toDataURL("image/png");
    a.click();
  };
  loop.start();
} catch (error) {
  document.getElementById("error").hidden = false;
  document.getElementById("error").textContent =
    "Não foi possível iniciar: " + error.message;
  throw error;
}
