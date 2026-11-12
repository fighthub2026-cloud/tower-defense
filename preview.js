'use strict';
const canvas=document.getElementById('game'),c=canvas.getContext('2d'),atlas=document.getElementById('atlas'),A=PenguinArt;
let time=0,last=performance.now(),paused=false,chosen=5,placing=false,selected=0,pointer=null;
const units=[{type:5,x:380,y:240},{type:2,x:805,y:345},{type:3,x:465,y:565},{type:1,x:880,y:600},{type:0,x:980,y:200},{type:4,x:230,y:420}];
const shots=[];const route=[[0,345],[380,345],[475,345],[475,165],[710,165],[710,450],[360,450],[360,670],[970,670],[970,820]];
const lengths=route.slice(1).map((p,i)=>Math.hypot(p[0]-route[i][0],p[1]-route[i][1])),total=lengths.reduce((a,b)=>a+b,0);
function along(d){d=((d%total)+total)%total;for(let i=0;i<lengths.length;i++){if(d<=lengths[i]){const t=d/lengths[i];return{x:route[i][0]+(route[i+1][0]-route[i][0])*t,y:route[i][1]+(route[i+1][1]-route[i][1])*t}}d-=lengths[i]}return{x:0,y:345}}
function rr(x,y,w,h,r,fill,stroke){c.beginPath();c.roundRect(x,y,w,h,r);c.fillStyle=fill;c.fill();if(stroke){c.strokeStyle=stroke;c.lineWidth=2;c.stroke()}}
function text(s,x,y,size=18,color='#264e62',align='left'){c.font=`700 ${size}px system-ui`;c.fillStyle=color;c.textAlign=align;c.fillText(s,x,y)}
const bg=document.createElement('canvas');bg.width=1240;bg.height=820;const b=bg.getContext('2d');b.fillStyle='#edf8fc';b.fillRect(0,0,1240,820);
let seed=91;function rand(){seed=(seed*1664525+1013904223)>>>0;return seed/4294967296}
for(let i=0;i<380;i++){b.fillStyle=i%2?'#d9edf355':'#ffffffaa';b.beginPath();b.ellipse(rand()*1240,rand()*820,2+rand()*5,1,0,0,7);b.fill()}
function road(color,width){b.beginPath();route.forEach((p,i)=>i?b.lineTo(...p):b.moveTo(...p));b.lineWidth=width;b.strokeStyle=color;b.lineJoin='round';b.lineCap='round';b.stroke()}
road('#b7dce9',72);road('#fff',66);road('#8bd8ec',58);road('#a5e4f1',44);
for(const [x,y] of [[40,90],[85,70],[1190,160],[1150,110],[70,740],[115,780],[1160,745]]){b.fillStyle='#387888';b.beginPath();b.ellipse(x,y+28,24,8,0,0,7);b.fill();for(let j=0;j<3;j++){b.beginPath();b.moveTo(x,y-40+j*18);b.lineTo(x-23+j*4,y+5+j*13);b.quadraticCurveTo(x,y+15+j*13,x+23-j*4,y+5+j*13);b.closePath();b.fillStyle=j%2?'#cdeef5':'#fff';b.fill();b.strokeStyle='#9bcedc';b.lineWidth=1;b.stroke()}}
function updateAtlas(){const a=atlas.getContext('2d');a.clearRect(0,0,atlas.width,atlas.height);a.drawImage(A.sheets[chosen],0,0);document.getElementById('notice').textContent=A.classes[chosen].name+' · 24 quadros em cache';}
function attack(){const u=units[selected];if(!u)return;u.attack=time;shots.push({x:u.x+20,y:u.y,type:u.type,start:time})}
function render(now){const dt=Math.min((now-last)/1000,.05);last=now;if(!paused)time+=dt*Number(document.getElementById('speed').value);c.clearRect(0,0,1440,820);c.drawImage(bg,0,0);
// Poucos objetos decorativos deixam a área de construção livre.
text('♥ 100',26,39,25,'#e05d63');text('● $1.250',153,39,25,'#a17d24');text('PRÉVIA DE ARTE',1204,35,14,'#7497a8','right');text('Vale Congelado',26,791,16,'#7497a8');
for(let i=0;i<8;i++){const p=along(time*31+i*55+150),s=Math.sin(time*5+i);c.save();c.translate(p.x,p.y);c.scale(1+s*.06,1-s*.08);c.fillStyle='#2b7c9522';c.beginPath();c.ellipse(0,14,18,6,0,0,7);c.fill();c.beginPath();c.moveTo(-18,8);c.bezierCurveTo(-20,-4,-12,-21,0,-20);c.bezierCurveTo(13,-20,21,-4,18,8);c.bezierCurveTo(14,18,-14,18,-18,8);c.fillStyle=['#4ac8f1','#8bda69','#b880ed'][i%3];c.fill();c.strokeStyle='#2b738e';c.lineWidth=2;c.stroke();c.fillStyle='white';c.beginPath();c.ellipse(-7,-10,4,3,-.5,0,7);c.fill();c.fillStyle='#21465c';for(const x of [-6,6]){c.beginPath();c.ellipse(x,2,2,3,0,0,7);c.fill()}c.restore()}
const u=units[selected];if(u){c.beginPath();c.arc(u.x,u.y,116,0,7);c.fillStyle='#84bbd317';c.fill();c.strokeStyle='#7eb5ca88';c.setLineDash([5,7]);c.stroke();c.setLineDash([])}
for(const unit of [...units].sort((a,b)=>a.y-b.y)){const attacking=unit.attack!==undefined&&time-unit.attack<.5;A.sprite(c,unit.type,unit.x,unit.y,attacking?time-unit.attack:time+(unit.x%9)/9,attacking?'attack':'idle',.9)}
for(let i=shots.length-1;i>=0;i--){const s=shots[i],age=time-s.start;if(age>1){shots.splice(i,1);continue}c.beginPath();c.arc(s.x+age*240,s.y-Math.sin(age*3)*25,5+Math.sin(age*4)*2,0,7);c.fillStyle=A.classes[s.type].color;c.fill();c.strokeStyle='white';c.lineWidth=2;c.stroke()}
if(placing&&pointer&&pointer.x<1240){const valid=validSpot(pointer.x,pointer.y);c.globalAlpha=.65;A.sprite(c,chosen,pointer.x,pointer.y,time,'idle',.9);c.globalAlpha=1;c.beginPath();c.arc(pointer.x,pointer.y,36,0,7);c.strokeStyle=valid?'#4bb692':'#e46772';c.stroke()}
rr(1240,0,200,820,0,'#d4b88f');text('PINGUINS',1340,37,21,'#5b4936','center');text('Escolha e posicione',1340,60,12,'#76644e','center');
A.classes.forEach((spec,i)=>{const y=80+i*105;rr(1254,y,172,94,12,i===chosen?'#f7fdff':'#ecdfc9',i===chosen?'#69b9cf':'#bea681');A.sprite(c,i,1294,y+45,time,'idle',.75);text(spec.name,1330,y+43,13);text('Ver animação',1330,y+63,10,'#7c929b')});
rr(1254,728,172,65,12,'#f9f3e8');text('ARTE PROCEDURAL',1340,754,12,'#7c6a52','center');text('6 classes • 144 quadros',1340,776,11,'#7c6a52','center');
requestAnimationFrame(render)}
function validSpot(x,y){if(x<35||x>1205||y<85||y>760||units.some(u=>Math.hypot(u.x-x,u.y-y)<65))return false;for(let i=0;i<lengths.length;i++){const a=route[i],b=route[i+1],t=Math.max(0,Math.min(1,((x-a[0])*(b[0]-a[0])+(y-a[1])*(b[1]-a[1]))/(lengths[i]**2)));if(Math.hypot(x-a[0]-t*(b[0]-a[0]),y-a[1]-t*(b[1]-a[1]))<65)return false}return true}
function pos(e){const r=canvas.getBoundingClientRect();return{x:(e.clientX-r.left)*1440/r.width,y:(e.clientY-r.top)*820/r.height}}
canvas.onpointermove=e=>pointer=pos(e);canvas.onpointerleave=()=>pointer=null;
canvas.onclick=e=>{const p=pos(e);if(p.x>=1240){const i=Math.floor((p.y-80)/105);if(i>=0&&i<6){chosen=i;placing=true;updateAtlas()}return}if(placing){if(validSpot(p.x,p.y)){units.push({type:chosen,x:p.x,y:p.y});selected=units.length-1;placing=false}return}selected=units.findIndex(u=>Math.hypot(p.x-u.x,p.y-u.y)<40);if(selected>=0){chosen=units[selected].type;updateAtlas()}};
document.getElementById('pause').onclick=e=>{paused=!paused;e.target.textContent=paused?'Retomar animações':'Pausar animações'};document.getElementById('attack').onclick=attack;document.getElementById('speed').onchange=()=>{};document.getElementById('export').onclick=()=>{const a=document.createElement('a');a.download=`pinguim-${A.classes[chosen].id}-96px-12quadros.png`;a.href=A.sheets[chosen].toDataURL();a.click()};window.onkeydown=e=>{if(e.key==='Escape')placing=false;if(e.code==='Space'){e.preventDefault();attack()}};updateAtlas();requestAnimationFrame(render);
