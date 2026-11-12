# Pinguins vs. Gosmas — Godot

Projeto nativo em **Godot 4.6**, com renderizador Compatibility e GDScript. Esta versão substitui a base web anterior, que continua disponível no histórico do Git.

## Abrir e jogar

1. Instale o **Godot 4.6 Standard**, sem .NET, em https://godotengine.org/download/.
2. Baixe o repositório como ZIP e extraia a pasta.
3. No gerenciador do Godot, clique em **Importar** e selecione `project.godot`.
4. Abra o projeto e pressione **F5**. Escolha a dificuldade, construa os pinguins e inicie a primeira onda.

Não usa Node, npm, localhost ou navegador. O jogo roda em janela própria. Para distribuir um `.exe` independente, instale os templates de exportação da mesma versão do Godot e configure a exportação Windows Desktop. Os templates não estão incluídos neste repositório.

## Organização

```
project.godot                 Configuração do projeto
assets/
  icon.svg                    Ícone original
  sprites/penguin_layers.png  Atlas aprovado: corpos, asas/armas e projéteis
scenes/
  main.tscn                   Cena principal, mundo e HUD
  actors/                     Cenas reutilizáveis de pinguim e gosma
  ui/                         Cena do HUD
scripts/
  core/                       Partida, mapa, dados e cache de texturas
  actors/                     Pinguins, gosmas, projéteis e impactos
  systems/                    Ondas e geração de inimigos
  visuals/                    Montagem em camadas e animações
  ui/                         Construção da interface e menus
tests/                       Testes executáveis pelo Godot headless
docs/                        Notas técnicas
```

## Implementado nesta base

- Mapa limpo com caminho curvo de gelo e interface fora da área de jogo.
- Seis classes com a arte aérea aprovada, montada em `Sprite2D` por camadas. `AnimationPlayer` interpola preparação, soltura, recuperação e recarga. As asas ficam atrás da cabeça, com ombro fixo na lateral.
- Flecha da besta, estrela ninja e bola de neve usam a mesma textura na arma/mão e no voo; somem na soltura (0,30 s) e reaparecem na recarga (0,70 s). Os tempos são acelerados proporcionalmente pelas melhorias de cadência.
- Pinguins giram em 360° para mirar. O projétil nasce na posição do objeto carregado, compensando a posição lateral da arma.
- A ponta da varinha carrega o brilho, solta a esfera e recupera a energia.
- A bola de neve gruda na gosma e mantém pedaços visíveis enquanto a lentidão durar.
- Compra e posicionamento válido, seleção, alcance, venda com reembolso de 70%.
- Três caminhos de melhoria funcional por torre: dano (duração da lentidão no congelador), cadência e alcance. Apenas um pode atingir nível 3; com um no máximo, os demais ficam limitados ao nível 1. Para liberar o nível 3, os outros caminhos precisam estar no nível 0 ou 1.
- Canhão com área de impacto; gelo com desaceleração e **zero dano**, inclusive com melhorias; engenheiro com armadilhas consumíveis persistentes na pista; magia e canhão ignoram a redução de dano da armadura.
- Oito classes de gosma com atlas animado desenhado em Canvas 2D: comum, saltadora, divisora (gera dois fragmentos), blindada, polar (resiste à lentidão), regeneradora, dourada e Rei das Gosmas.
- Gerador de 60 ondas, três dificuldades, chefões a cada dez ondas, vitória e continuação infinita.
- Recompensa de vitória em Moedas de Gelo, salva em `user://progress.cfg` e mantida no infinito.
- Pausa, velocidade 2×, reinício, vitória e derrota.

## Controles

Mouse: comprar, posicionar e selecionar. **Espaço** inicia a próxima onda. **Esc** cancela construção ou abre pausa.

## Escopo

É a primeira base jogável em Godot. A arte aérea aprovada foi separada em camadas e ainda pode ser refinada; não representa o acabamento final das referências. As 60 ondas são geradas por fórmula e ainda precisam de balanceamento de campanha. Ainda não inclui áudio, agentes especiais, coleção, novas classes, opções de configuração ou efeitos exclusivos de cada ramo de upgrade. A exportação executável final não faz parte desta etapa.

## Testes

Na pasta do projeto, com Godot no PATH:

```
godot --headless --editor --path . --import
godot --headless --path . --scripttests/smoke_test.gd
```

## Conferir as animações

No editor, abra `scenes/animation_gallery.tscn` e pressione **F6** para ver os seis pinguins atacando alvos. **F5** continua abrindo a partida normal. O teste de animação verifica origem, direção, soltura única, objeto visível/invisível, recarga, camadas das asas e neve aderente.

### Verificação visual de camadas

Com uma tela gráfica disponível, execute `godot --path . --script tests/render_layers_test.gd` **sem `--headless`**. O teste renderiza os seis pinguins em direções diferentes sobre o mapa e compara os pixels com e sem asas, detectando armas escondidas atrás da neve. `GODOT_TEST_SCREENSHOT` pode definir um caminho para salvar a captura.

## Interface e arte procedural

O HUD segue a proposta aprovada: vida/dinheiro flutuantes sobre a neve, onda e engrenagem no canto e loja estreita de madeira com duas colunas. Usa os **seis pinguins existentes**, sem substituir os personagens pelas ilustrações do mockup. O painel de melhorias aparece apenas ao selecionar uma torre colocada; o tabuleiro se ajusta para manter a área de jogo visível.

Ao escolher um pinguim na loja, o botão de iniciar/acompanhar a onda vira um **X vermelho para cancelar**. Ao cancelar ou construir, o botão recupera o estado anterior da onda. A prévia de construção mostra o alcance e a validade da posição. **Esc** também cancela.

`tools/art/index.html` e `tools/art/generate.js` são as fontes de criação em **Canvas 2D** dos ícones, cartões, botões, madeira, neve, árvores, cristais e do atlas de gosmas. Abra a ferramenta no navegador para baixar cada PNG. O jogo utiliza apenas os PNG locais; essa ferramenta não é necessária para jogar.

O congelador não altera a vida nem produz flashes de dano. O primeiro caminho aumenta a duração da lentidão. As marcas de neve são pequenas placas nas bordas da gosma e derretem ao expirar o efeito. A flecha carregada e o projétil em voo têm o mesmo tamanho, aumentado para ficar legível.

Novos testes: `godot --headless --path . --script tests/mechanics_ui_test.gd`. A cena `scenes/enemy_gallery.tscn` (F6) apresenta os oito tipos de gosma. `tests/capture_preview.gd` permite capturar o HUD real com `GODOT_CAPTURE_DIR` apontando para uma pasta existente, usando renderização gráfica.
