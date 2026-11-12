# Pinguins vs. Gosmas

Base própria de jogo 2D para navegador, sem engine ou bibliotecas externas. O servidor Node.js entrega os módulos em localhost; a simulação e a renderização rodam no navegador usando Canvas 2D. O HTML é somente o ponto de entrada.

## Iniciar

Instale **Node.js 20 ou superior** uma vez. Não é necessário executar `npm install`.

- **Windows:** dê dois cliques em `Iniciar.bat`. Ele inicia o servidor e abre o navegador. Para um atalho na área de trabalho, clique com o botão direito no arquivo e escolha Enviar para → Área de trabalho (criar atalho).
- **macOS:** no primeiro uso, execute `chmod +x Iniciar.command` no Terminal; depois abra `Iniciar.command`.
- **Linux ou terminal:** execute `npm start` na pasta do projeto.

Endereço: **http://localhost:3000**. Mantenha o terminal aberto; Ctrl+C encerra o servidor. Para outra porta: `PORT=3001 npm start` (Linux/macOS), ou `set PORT=3001` antes de iniciar (Windows). Sem acesso externo: o servidor escuta somente em 127.0.0.1. Após instalar Node, funciona offline.

## Organização

```
tools/server.mjs             Servidor local e abertura do navegador
src/main.js                  Inicialização e ligação dos módulos
src/engine/loop.js            Passo fixo de simulação a 60 Hz
src/engine/renderer.js        Canvas e resolução da tela
src/engine/input.js           Ponteiro e teclado
src/engine/sprites.js         Atlas em cache e reprodução dos quadros
src/engine/audio.js           Sons sintetizados
src/game/data.js             Definições das classes
src/game/art/                Desenho procedural de mapa e personagens
src/game/entities/           Pinguins, gosmas e projéteis
src/game/systems/            Combate e posicionamento no mapa
src/ui/                     Interface, estilos e visualização do mundo
tests/                      Testes de combate, posicionamento e servidor
```

## Estado atual

Laboratório funcional de combate com seis classes: Atirador, Ninja, Canhoneiro, Congelador, Engenheiro e Mago. Os personagens são desenhados por código e renderizados em atlas de 24 quadros de repouso e 24 de ataque por classe (288 quadros em cache). Cada ataque tem preparação, soltura e recuperação; o projétil é criado no instante da soltura. O canhão recua e causa dano em área; o gelo desacelera; o engenheiro coloca armadilhas consumíveis na pista. As demais classes têm projéteis e animações próprios; perfuração e melhorias ainda serão implementadas.

As torres iniciais atacam automaticamente. Escolha uma classe na lateral e clique na neve para construir; o dinheiro é consumido. Clique numa torre para ver o alcance. Esc cancela construção. Os controles pausam, aceleram, reiniciam e ligam o som.

Esta é a primeira base da engine, ainda não o jogo completo: as gosmas surgem continuamente para testar o combate. Não há campanha de 60 ondas, vitória, upgrades, loja permanente ou salvamento nesta versão. O contador de vida é informativo neste laboratório, sem tela de derrota.

## Verificação

Execute `npm test`. Os testes verificam dano de todas as classes, sincronização inicial do ataque, bloqueio de construção, estabilidade de simulação por três minutos e servidor local.
