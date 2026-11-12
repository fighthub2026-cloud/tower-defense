/* Sprites procedurais. Um atlas por classe, duas linhas, 12 quadros por estado. */
'use strict';
window.PenguinArt=(()=>{
const SIZE=96,FRAMES=12;
const classes=[{id:'atirador',name:'Atirador',color:'#328bd4',weapon:'snow'},{id:'ninja',name:'Ninja',color:'#e94b46',weapon:'star'},{id:'canhao',name:'Canhoneiro',color:'#e34b42',weapon:'cannon'},{id:'gelo',name:'Congelador',color:'#44bfee',weapon:'ice'},{id:'engenheiro',name:'Engenheiro',color:'#ffbe35',weapon:'tool'},{id:'mago',name:'Mago',color:'#9256db',weapon:'magic'}];
function draw(c,type,phase,attack){
const spec=classes[type],breath=Math.sin(phase*Math.PI*2),kick=attack?Math.sin(phase*Math.PI):0;
c.save();c.translate(48,49);c.lineWidth=2.2;c.lineJoin='round';c.lineCap='round';
function path(points,fill,stroke='#233b50'){c.beginPath();points.forEach((p,i)=>i?c.lineTo(...p):c.moveTo(...p));c.closePath();c.fillStyle=fill;c.fill();if(stroke){c.strokeStyle=stroke;c.stroke()}}
function oval(x,y,rx,ry,fill,stroke='#233b50'){c.beginPath();c.ellipse(x,y,rx,ry,0,0,Math.PI*2);c.fillStyle=fill;c.fill();if(stroke){c.strokeStyle=stroke;c.stroke()}}
function line(x,y,xx,yy,color,width=3){c.beginPath();c.moveTo(x,y);c.lineTo(xx,yy);c.strokeStyle=color;c.lineWidth=width;c.stroke();c.lineWidth=2.2}
function star(x,y,r,color){const p=[];for(let i=0;i<10;i++){const a=i*Math.PI/5-Math.PI/2,k=i%2?r*.45:r;p.push([x+Math.cos(a)*k,y+Math.sin(a)*k])}path(p,color)}
oval(0,20,28,10,'#376b8523',null);c.translate(0,breath*.8-kick*2);c.rotate(kick*-.08);
oval(-11,19,8,5,'#f6af32');oval(11,19,8,5,'#f6af32');
c.save();c.translate(-21,0);c.rotate(-.3-kick*.4);oval(0,0,7,17,'#22354b');c.restore();c.save();c.translate(21,0);c.rotate(.3-kick*.7);oval(0,0,7,17,'#22354b');c.restore();
const g=c.createLinearGradient(-20,-22,22,23);g.addColorStop(0,'#45576e');g.addColorStop(.6,'#1c2c40');g.addColorStop(1,'#0f2034');oval(0,0,23,27,g);oval(0,6,16,19,'#f4faff');oval(-7,-5,10,10,'#f4faff',null);oval(7,-5,10,10,'#f4faff',null);
if(phase>.84&&!attack){line(-11,-5,-5,-5,'#243449',2);line(5,-5,11,-5,'#243449',2)}else{oval(-8,-6,2.7,3.6,'#162e42',null);oval(8,-6,2.7,3.6,'#162e42',null);oval(-8.6,-7,1,1,'white',null);oval(7.4,-7,1,1,'white',null)}
path([[-6,0],[0,-2],[7,1],[0,7]],'#ffbf34');
if(type===0){path([[-23,-15],[-19,-28],[-3,-34],[16,-29],[22,-15]],'#368cd4');oval(0,-15,25,5,'#5ebcf6');oval(-18,-28,6,6,'#f5fbff');oval(26,8-kick*7,8,8,'#f6fdff');line(21,12,27,14,'#8dd8ef',2)}
if(type===1){path([[-23,-17],[23,-17],[23,-7],[-23,-7]],'#ef4b43');path([[21,-13],[35,-24],[34,-11],[24,-8],[38,-2],[27,2]],'#e4433c');star(29,9-kick*8,11,'#bdced9');oval(29,9-kick*8,2,2,'#25364b',null)}
if(type===2){path([[-23,-16],[-19,-30],[-4,-36],[13,-31],[22,-17]],'#eb544a');oval(0,-17,25,4,'#ff7c59');line(-21,-9,21,-9,'#1c3047',5);oval(-11,-10,8,7,'#f6c16a');oval(9,-10,8,7,'#f6c16a');oval(-11,-10,5,4,'#6de0f7');oval(9,-10,5,4,'#6de0f7');c.save();c.translate(24-kick*5,10);path([[-12,-8],[17,-10],[19,9],[-12,9]],'#546c7e');oval(18,0,7,10,'#263e51');oval(18,0,4,6,'#0c2230');c.restore()}
if(type===3){path([[-25,-8],[-23,-28],[-9,-38],[10,-36],[24,-23],[26,-7]],'#3da9e8');for(let i=0;i<9;i++)oval(-24+i*6,-12+Math.sin(i/8*Math.PI)*-5,5,5,'#f4fbff');line(29,-1,29,18,'#c5f6ff',3);line(20,8,38,8,'#c5f6ff',3);line(22,1,36,15,'#c5f6ff',2);line(22,15,36,1,'#c5f6ff',2);oval(29,8,3,3,'white',null)}
if(type===4){path([[-25,-15],[-22,-30],[-8,-37],[9,-36],[22,-27],[24,-15]],'#ffc442');line(-4,-35,-4,-17,'#ffe7a0',5);oval(0,-16,28,4,'#ef9f23');line(-21,-6,21,-6,'#764e27',4);oval(-10,-5,8,7,'#ffb331');oval(10,-5,8,7,'#ffb331');oval(-10,-5,5,4,'#63d4ef');oval(10,-5,5,4,'#63d4ef');line(24,17-kick*8,33,-2-kick*8,'#708fa1',6);path([[28,-2-kick*8],[26,-9-kick*8],[31,-14-kick*8],[32,-7-kick*8],[36,-6-kick*8],[39,-12-kick*8],[41,-5-kick*8],[35,1-kick*8]],'#b8d3df')}
if(type===5){path([[-23,-17],[-13,-33],[-6,-45],[6,-44],[19,-34],[8,-35],[18,-16]],'#9354dc');oval(0,-16,29,7,'#a866ec');line(-19,-19,18,-19,'#efb447',3);star(-4,-31,6,'#ffdf63');star(11,-24,3,'#ffdf63');line(25,19,30,-4-kick*8,'#bd8a4a',4);oval(31,-7-kick*8,7,8,'#d185ff');oval(29,-10-kick*8,2,3,'#fff3ff',null)}
// A marca de classe aparece também na silhueta e no equipamento, não só na cor.
c.restore();}
const sheets=classes.map((_,type)=>{const canvas=document.createElement('canvas');canvas.width=SIZE*FRAMES;canvas.height=SIZE*2;const ctx=canvas.getContext('2d');for(let state=0;state<2;state++)for(let f=0;f<FRAMES;f++){ctx.save();ctx.translate(f*SIZE,state*SIZE);draw(ctx,type,f/FRAMES,state===1);ctx.restore()}return canvas});
function sprite(c,type,x,y,time,state='idle',scale=1){const rate=state==='attack'?24:12,frame=Math.floor(time*rate)%FRAMES;c.drawImage(sheets[type],frame*SIZE,state==='attack'?SIZE:0,SIZE,SIZE,x-SIZE*scale/2,y-SIZE*scale/2,SIZE*scale,SIZE*scale)}
return {classes,sheets,sprite,SIZE,FRAMES};})();
