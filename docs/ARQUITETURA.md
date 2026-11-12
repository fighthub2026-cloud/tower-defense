# Organização técnica

`Game` coordena economia, seleção e estado da partida; `Waves` controla emissão de inimigos e conclusão da onda. O mapa mantém uma `Curve2D`, usada tanto no desenho do caminho quanto no deslocamento e na validação de construção.

Os personagens são cenas reutilizáveis. `SpriteLibrary` compartilha recursos `SpriteFrames` com recortes de um único atlas PNG. `Penguin` muda de repouso para ataque, observa o evento `frame_changed` e cria o projétil na soltura. `animation_finished` retorna ao repouso. O alvo é escolhido por avanço na pista dentro do alcance.

A simulação usa `_physics_process`; efeitos visuais usam `_process`. O Godot cuida do ciclo, das transformações e do desenho. O HUD fica em `CanvasLayer`, tem processamento durante pausa e ocupa áreas próprias fora do mapa. Referências a inimigos e torres são validadas antes do uso.

Sem dependências externas em tempo de execução. O projeto utiliza Godot Standard e GDScript; as texturas são locais. A versão web anterior está preservada no histórico do repositório.
