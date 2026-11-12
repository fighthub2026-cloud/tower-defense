# Organização técnica

`Game` coordena economia, seleção e estado da partida; `Waves` controla emissão de inimigos e conclusão da onda. O mapa mantém uma `Curve2D`, usada tanto no desenho do caminho quanto no deslocamento e na validação de construção.

Os personagens usam o atlas `penguin_layers.png`, separado em corpo, asa/arma descarregada e projétil. `SpriteLibrary` compartilha os recortes `AtlasTexture`. `PenguinVisual` monta a figura com `Sprite2D` e cria uma animação nativa `AnimationPlayer`: a asa gira em um ombro fixo atrás da cabeça. O alvo é escolhido por avanço na pista dentro do alcance.

Uma faixa de métodos emite a soltura aos 0,30 s. A faixa de visibilidade oculta o objeto carregado no mesmo instante. `Penguin` cria o projétil com a mesma textura e na posição global do objeto na arma; a mira compensa a posição lateral e a rotação de preparação da asa. Aos 0,70 s, a recarga mostra o próximo objeto com uma breve transição. Ao terminar a animação, volta ao repouso. A melhoria de cadência também aumenta a velocidade de reprodução da animação para não limitar a taxa de disparos.

O projétil de neve adiciona marcas à própria gosma; marcas e lentidão expiram juntas. O mago usa uma camada de brilho na ponta da varinha que cresce na preparação e descarrega ao lançar a esfera. A cena `animation_gallery.tscn` permite conferir os seis ataques pelo editor.

A simulação usa `_physics_process`; efeitos visuais usam `_process`. O Godot cuida do ciclo, das transformações e do desenho. O HUD fica em `CanvasLayer`, tem processamento durante pausa e ocupa áreas próprias fora do mapa. Referências a inimigos e torres são validadas antes do uso.

Sem dependências externas em tempo de execução. O projeto utiliza Godot Standard e GDScript; as texturas são locais. A versão web anterior está preservada no histórico do repositório.

## Ordem de desenho

O cenário usa profundidade 0, a asa/arma usa 1, a cabeça usa 2 e os projéteis usam 3. A asa não pode usar profundidade negativa: isso a coloca atrás de todo o mapa, não apenas da cabeça. O teste `render_layers_test.gd` verifica a presença real de pixels das asas/armas no renderizador, incluindo personagens girados.

## HUD, seleção e efeitos de controle

Os componentes de interface são PNGs individuais aprovados, aplicados como `StyleBoxTexture` e `Texture2D` pelo cache de `HudArt`. O HUD não usa uma barra superior: os indicadores são controles independentes sobre o mapa. A loja só contém as seis torres implementadas.

O botão principal da loja tem três estados: `next`, `active` e `cancel`. A construção tem prioridade de interação sobre a onda ativa; cancelar não compra, não inicia uma onda e não altera a simulação. Ao selecionar uma torre colocada, `TowerUpgrades` substitui `TowerShop` na mesma lateral. O mundo mantém escala e posição fixas. A posição do mouse é convertida pelas transformações do mundo.

O congelador segue uma rota de controle exclusiva: seu projétil chama `stick_snow` e retorna sem chamar `hit`. Isso garante zero dano mesmo com metadados incorretos de projétil. A melhoria de impacto é substituída por duração da lentidão na interface e nas regras.

O atlas de gosmas tem oito linhas de tipos e doze quadros por tipo. Os dados de cada classe ficam em `TowerData.ENEMIES`; as ondas liberam os tipos progressivamente. Divisão em fragmentos, armadura, regeneração e resistência ao gelo têm regras próprias e testes de integração.

## Recursos da interface

`assets/ui/approved/` contém as 19 peças individuais. Os estados de cartão usam suas próprias texturas; controles com preço e texto são montados sobre as bases. A fonte é local e licenciada. O renderizador reaproveita as mesmas texturas em vez de carregar cópias por torre.

A lateral tem estados `shop` e `upgrades`. Vender remove a torre e retorna à loja. Fechar, voltar e Esc apenas removem a seleção. Os controles de onda/velocidade continuam no rodapé da lateral em ambos os estados. Não há painel inferior nem alteração de câmera durante a seleção.
