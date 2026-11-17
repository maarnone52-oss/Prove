/* Impaginazioni per iPhone fatte con ARNOCANVAS — VERSIONE DI PROVA.
   Verticale: iPhone 15 (393x852) e iPhone 15 Plus (430x932). Orizzontale: iPhone 15 (852x393) e 15 Plus (932x430).
   Riapplica alla pagina vera di ARNOCUT le modifiche disegnate in ARNOCANVAS: gli elementi
   sono quelli veri, quindi le funzioni restano collegate. Solo su iPhone. Girando il telefono
   si passa da un'impaginazione all'altra; se quella orizzontale non è ancora disegnata, si vede la pagina originale.
   Per vedere l'originale: aggiungi ?impaginazione=0 all'indirizzo.
   © 2026 Maurizio Arnone. Tutti i diritti riservati. */
(function(){
'use strict';
var M15={"v":1,"frozen":true,"P":{"body/main[0]/div[0]":{"x":64,"y":9,"w":365,"s":0.734,"x0":14,"y0":63,"w0":365,"h0":146,"mh":151.6},"body/main[0]/section[0]":{"x":44.4,"y":132.4,"w":467.6,"s":0.652,"x0":14,"y0":227,"w0":365,"h0":144,"mh":144},"body/main[0]/section[1]":{"x":15.1,"y":244.1,"w":616.8,"s":0.592,"x0":14,"y0":387.2,"w0":365,"h0":579,"mh":584},"body/main[0]/section[2]":{"x":14,"y":600,"w":365,"s":1,"x0":14,"y0":982.6,"w0":365,"h0":991,"mh":842.8},"body/main[0]/section[3]":{"x":16,"y":1736,"w":365,"s":1,"x0":14,"y0":1997.3,"w0":365,"h0":585},"body/main[0]/section[4]":{"x":14,"y":2216,"w":365,"s":1,"x0":14,"y0":2598.1,"w0":365,"h0":583},"body/main[0]/footer[0]":{"x":16,"y":2816,"w":365,"s":1,"x0":14,"y0":3201,"w0":365,"h0":18},"#mixRack":{"x":-88,"y":1456,"w":486,"s":0.954,"x0":64,"y0":3272,"w0":365,"e":{"b":-27.4,"l":-109},"mh":283.5}},"I":{"#mirrorBox":{"s":0.821,"dx":29.2,"dy":-11},"body/main[0]/section[2]/div[1]":{"s":0.715,"dx":46.7,"dy":-62},"body/main[0]/section[2]/span[0]":{"dy":-8},"body/main[0]/section[2]/div[2]":{"dy":-88,"h":40},"#cutBtn":{"dy":40,"dx":-135},"#snapBtn":{"s":0.715,"dx":19,"dy":5},"#track":{"dy":-96.2,"dx":-19,"h":258,"s":0.924,"w":390},"body/main[0]/section[2]/div[4]":{"dy":-83.6,"h":124},"#clearBtn":{"dy":-38.8,"s":0.924,"dx":2.7},"#selBar/span[3]":{"s":0.854,"dx":8.6,"dy":5.3,"w":363},"body/main[0]/section[2]/div[4]/div[1]":{"h":30,"dy":-23.9,"s":0.942,"dx":9.5},"#mixer":{"dy":-17.2,"s":0.927,"dx":168,"w":240},"#pvBox":{"h":372,"dy":-35.4,"w":303},"#pvScreen":{"s":0.694,"dx":69.2,"dy":-13.3,"h":181,"w":270},"#scrub":{"s":0.635,"dx":10.5,"dy":-41.8,"w":483},"#monRow":{"dy":-88,"dx":-8},"body/main[0]/section[3]/div[2]":{"dy":-247.8,"s":0.966,"dx":8,"h":26},"#pvDetach":{"hide":true},"#expBtn":{"s":1.061,"dx":-7.6,"dy":54.8,"h":68},"#pvBox/div[3]":{"s":0.786,"dx":105.2,"dy":17.4},"#clock":{"dx":-84.7,"dy":-130.2,"s":0.924},"body/main[0]/div[0]/div[0]":{"dy":12,"h":97},"body/main[0]/section[1]/div[0]":{"s":1.43,"dx":-86.4,"dy":-15.7,"w":400},"#addBtn":{"dx":-193.2,"dy":24},"#allBtn":{"dy":-14.4},"#pvBox/div[2]":{"h":51,"dy":18.8,"dx":10},"#frameBtn":{"dy":75.1,"h":38,"s":0.821,"dx":22.5},"#selBar":{"dy":-8.2},"body/main[0]/div[0]/div[1]":{"dy":9.1,"s":1.126,"dx":-8.6},"body/main[0]/div[0]/div[0]/span[0]":{"dx":-32.7},"body/main[0]/div[0]/div[0]/span[1]":{"dy":-43.6,"dx":10.9},"#status":{"dx":-317,"dy":74.1},"#mixRack":{"z":1},"#selBar/button[0]":{"s":0.871,"dx":9.6,"dy":2.2},"#selBar/button[1]":{"s":0.888,"dx":3.8,"dy":1.9},"#cv":{"h":254,"w":266,"dy":-48.5}},"N":[],"MV":[],"seq":1};   // iPhone 15 (393 punti)
var MPL={"v":1,"frozen":true,"P":{"body/main[0]/div[0]":{"x":68.7,"y":9,"w":402,"s":0.734,"x0":14,"y0":63,"w0":402,"h0":146,"mh":151.6},"body/main[0]/section[0]":{"x":47.3,"y":132.4,"w":514.3,"s":0.652,"x0":14,"y0":227,"w0":402,"h0":144,"mh":144},"body/main[0]/section[1]":{"x":15.2,"y":244.1,"w":677.5,"s":0.592,"x0":14,"y0":387.2,"w0":402,"h0":579,"mh":584},"body/main[0]/section[2]":{"x":14,"y":600,"w":402,"s":1,"x0":14,"y0":982.6,"w0":402,"h0":788,"mh":842.8},"body/main[0]/section[3]":{"x":14,"y":1728,"w":402,"s":1,"x0":14,"y0":1794.1,"w0":402,"h0":578},"body/main[0]/section[4]":{"x":16,"y":2216,"w":400,"s":1,"x0":14,"y0":2387.9,"w0":402,"h0":568},"body/main[0]/footer[0]":{"x":14,"y":2816,"w":402,"s":1,"x0":14,"y0":3266.8,"w0":402,"h0":18},"#mixRack":{"x":-96.8,"y":1464,"w":534.4,"s":0.954,"x0":14,"y0":2971.4,"w0":402,"e":{"b":-27.4,"l":-119.3},"mh":283.5,"h0":275}},"I":{"#mirrorBox":{"s":0.821,"dx":31.9,"dy":-11},"body/main[0]/section[2]/div[1]":{"s":0.715,"dx":51.1,"dy":-62},"body/main[0]/section[2]/span[0]":{"dy":-8},"body/main[0]/section[2]/div[2]":{"dy":-88,"h":40},"#cutBtn":{"dy":40,"dx":-147.7},"#snapBtn":{"s":0.715,"dx":20.8,"dy":5},"#track":{"dy":-96.2,"dx":-15.8,"h":258,"s":0.924,"w":427},"body/main[0]/section[2]/div[4]":{"dy":-83.6,"h":124},"#clearBtn":{"dy":-38.8,"s":0.924,"dx":3},"#selBar/span[3]":{"s":0.854,"dx":9.4,"dy":5.3,"w":397},"body/main[0]/section[2]/div[4]/div[1]":{"h":30,"dy":-23.9,"s":0.942,"dx":10.4},"#mixer":{"dy":-17.2,"s":0.927,"dx":183.8,"w":263},"#pvBox":{"h":372,"dy":-35.4,"w":332},"#pvScreen":{"s":0.694,"dx":75.7,"dy":-13.3,"h":181,"w":295},"#scrub":{"s":0.635,"dx":11.5,"dy":-41.8,"w":528},"#monRow":{"dy":-88,"dx":-8.8},"body/main[0]/section[3]/div[2]":{"dy":-247.8,"s":0.966,"dx":8.8,"h":26},"#pvDetach":{"hide":true},"#expBtn":{"s":1.061,"dx":-8.3,"dy":54.8,"h":68},"#pvBox/div[3]":{"s":0.786,"dx":115.1,"dy":17.4},"#clock":{"dx":-92.7,"dy":-130.2,"s":0.924},"body/main[0]/div[0]/div[0]":{"dy":49.4,"h":97,"dx":12.3},"body/main[0]/section[1]/div[0]":{"s":1.43,"dx":-94.5,"dy":-15.7,"w":438},"#addBtn":{"dx":-211.4,"dy":24},"#allBtn":{"dy":-14.4},"#pvBox/div[2]":{"h":51,"dy":18.8,"dx":10.9},"#frameBtn":{"dy":75.1,"h":38,"s":0.821,"dx":24.6},"#selBar":{"dy":-8.2},"body/main[0]/div[0]/div[1]":{"dy":11.9,"s":1.126,"dx":-9.4},"body/main[0]/div[0]/div[0]/span[0]":{"dx":-35.8},"body/main[0]/div[0]/div[0]/span[1]":{"dy":-43.6,"dx":11.9},"#status":{"dx":-346.8,"dy":74.1},"#mixRack":{"z":1},"#selBar/button[0]":{"s":0.871,"dx":10.5,"dy":2.2},"#selBar/button[1]":{"s":0.888,"dx":4.2,"dy":1.9},"#cv":{"h":254,"w":291,"dy":-48.5},"#helpBtn":{"dy":9.8}},"N":[],"MV":[],"seq":1};   // iPhone 15 Plus (430 punti)
var M15O={"v":1,"frozen":true,"P":{"body/main[0]/div[0]":{"x":16,"y":184,"w":822,"s":1,"x0":14,"y0":63,"w0":824,"h0":146,"mh":210},"body/main[0]/section[0]":{"x":16,"y":408,"w":824,"s":1,"x0":14,"y0":227.4,"w0":824,"h0":144},"body/main[0]/section[1]":{"x":0,"y":584,"w":824,"s":0.998,"x0":14,"y0":387.6,"w0":824,"h0":565},"body/main[0]/section[2]":{"x":16,"y":1048,"w":824,"s":1,"x0":14,"y0":969,"w0":824,"h0":884,"e":{"t":-135}},"body/main[0]/section[3]":{"x":16,"y":2016,"w":824,"s":0.989,"x0":14,"y0":1868.9,"w0":824,"h0":737,"e":{"t":-266.9}},"body/main[0]/section[4]":{"x":14,"y":2728,"w":824,"s":1,"x0":14,"y0":2621.4,"w0":824,"h0":305},"#mixRack":{"x":16,"y":1976,"w":808,"s":1,"x0":14,"y0":2942.8,"w0":824,"h0":275,"mh":291},"body/main[0]/footer[0]":{"x":16,"y":3048,"w":824,"s":1,"x0":14,"y0":3238.2,"w0":824,"h0":18}},"I":{"#pvScreen":{"s":0.353,"dx":254.3,"dy":273.1},"#pvBox/div[0]":{"hide":true},"#mirrorBox":{"s":0.56,"dx":122.8,"dy":159.7},"#pvBox/div[3]":{"s":0.759,"dx":95,"dy":6.2},"body/main[0]/section[2]/div[1]":{"s":0.805,"dx":76.9,"dy":6.9},"#mixer":{"dx":6,"dy":-2.4},"body/main[0]/div[0]/div[0]":{"dy":24},"body/main[0]/div[0]/div[1]":{"dy":24},"#helpBtn":{"dy":24},"body/main[0]/div[0]/div[2]":{"dy":24}},"N":[],"MV":[],"seq":1};   // iPhone 15 girato (852 punti) — da ARNOCANVAS 0.8.8
var MPLO={"v":1,"frozen":true,"P":{"body/main[0]/div[0]":{"x":132.6,"y":9,"w":904,"s":0.734,"x0":14,"y0":63,"w0":904,"h0":146,"mh":151.6},"body/main[0]/section[0]":{"x":86.2,"y":132.8,"w":1147.4,"s":0.652,"x0":14,"y0":227.4,"w0":904,"h0":144,"mh":144},"body/main[0]/section[1]":{"x":16.6,"y":244.5,"w":1501.1,"s":0.592,"x0":14,"y0":387.6,"w0":904,"h0":565,"mh":584},"body/main[0]/section[2]":{"x":14,"y":586.4,"w":904,"s":1,"x0":14,"y0":969,"w0":904,"h0":872,"mh":842.8},"body/main[0]/section[3]":{"x":24,"y":1768,"w":904,"s":0.98,"x0":14,"y0":1856.7,"w0":904,"h0":782,"e":{"b":120.4},"det":true,"mh":612.5},"body/main[0]/section[4]":{"x":16,"y":2416,"w":899.7,"s":1,"x0":14,"y0":2654.2,"w0":904,"h0":305},"body/main[0]/footer[0]":{"x":16,"y":2768,"w":904,"s":1,"x0":14,"y0":3271,"w0":904,"h0":18,"mh":20},"#mixRack":{"x":-226.2,"y":1468.2,"w":1191,"s":0.954,"x0":14,"y0":2975.6,"w0":904,"e":{"b":-27.4,"l":-258.6},"mh":283.5,"h0":275}},"I":{"#mirrorBox":{"s":0.821,"dx":69.1,"dy":-11},"body/main[0]/section[2]/div[1]":{"s":0.715,"dx":110.8,"dy":-62},"body/main[0]/section[2]/span[0]":{"dy":-8},"body/main[0]/section[2]/div[2]":{"dy":-88,"h":40},"#cutBtn":{"dy":40,"dx":-320.1},"#snapBtn":{"s":0.715,"dx":45.1,"dy":5},"#track":{"dy":-96.2,"dx":-34.2,"h":258,"s":0.924,"w":925},"body/main[0]/section[2]/div[4]":{"dy":-83.6,"h":124},"#clearBtn":{"dy":-38.8,"s":0.924,"dx":6.5},"#selBar/span[3]":{"s":0.854,"dx":20.4,"dy":5.3,"w":860},"body/main[0]/section[2]/div[4]/div[1]":{"h":30,"dy":-23.9,"s":0.942,"dx":22.5},"#mixer":{"dy":-17.2,"s":0.927,"dx":398.4,"w":570},"#pvBox":{"h":391,"dy":108.5,"w":720,"dx":-190.4},"#pvScreen":{"s":0.553,"dx":445.7,"dy":-57,"h":397,"w":639},"#scrub":{"s":0.635,"dx":259.3,"dy":-41.8,"w":1144},"#monRow":{"dy":-296,"dx":-19.1},"body/main[0]/section[3]/div[2]":{"dy":-68.2,"s":0.966,"dx":19.1,"h":26,"w":866},"#pvDetach":{"hide":true},"#expBtn":{"s":1.061,"dx":-18,"dy":54.8,"h":68},"#pvBox/div[3]":{"s":0.786,"dx":438.1,"dy":-105.6},"#clock":{"dx":-33.7,"dy":-130.6,"s":0.924,"h":19},"body/main[0]/div[0]/div[0]":{"dy":49.4,"h":97,"dx":26.7},"body/main[0]/section[1]/div[0]":{"s":1.43,"dx":-204.8,"dy":-15.7,"w":949},"#addBtn":{"dx":-458.2,"dy":24},"#allBtn":{"dy":-14.4},"#pvBox/div[2]":{"h":51,"dy":18.8,"dx":23.6},"#frameBtn":{"dy":75.1,"h":38,"s":0.821,"dx":53.3},"#selBar":{"dy":-8.2},"body/main[0]/div[0]/div[1]":{"dy":11.9,"s":1.126,"dx":-20.4},"body/main[0]/div[0]/div[0]/span[0]":{"dx":-77.6},"body/main[0]/div[0]/div[0]/span[1]":{"dy":-43.6,"dx":25.8},"#status":{"dx":-751.7,"dy":74.1},"#mixRack":{"z":1},"#selBar/button[0]":{"s":0.871,"dx":22.8,"dy":2.2},"#selBar/button[1]":{"s":0.888,"dx":9.1,"dy":1.9},"#cv":{"h":597,"w":823,"dy":-196.5,"dx":-18.8},"#helpBtn":{"dy":9.8},"body/main[0]/section[3]/span[0]":{"w":866,"dy":15.6},"body/main[0]/section[4]/div[0]":{"dx":-8}},"N":[],"MV":[],"seq":1};   // iPhone 15 Plus girato (932 punti) — da ARNOCANVAS 0.8.8
function pick(){var w=document.documentElement.clientWidth||window.innerWidth,land=window.innerWidth>window.innerHeight;
  if(land)return w>=892?{k:'iphone15pluso',m:MPLO,w:932}:{k:'iphone15o',m:M15O,w:852};
  return w>=412?{k:'iphone15plus',m:MPL,w:430}:{k:'iphone15',m:M15,w:393}}
var M=null,KEY='',BASEW=393;
var q=location.search;
if(/[?&]arnocanvas=/.test(q))return;                       // dentro ARNOCANVAS: ci pensa lui
var off=/[?&]impaginazione=0/.test(q);
var ip=false;try{ip=/iPhone|iPod/i.test(navigator.userAgent)}catch(e){}
if(!ip)return;
var D=document,W=window;
// ogni proprietà toccata viene ricordata col valore di prima, così alla rotazione si può tornare indietro e applicare l'altra impaginazione
var REC=[];
function rec(st,k){var ks=st.__cvk||(st.__cvk={});if(ks[k])return;ks[k]=1;REC.push({st:st,k:k,v:st.getPropertyValue(k),p:st.getPropertyPriority(k)})}
function imp(st,k,v){rec(st,k);st.setProperty(k,v,'important')}
function put(st,k,v){rec(st,k);if(v==='')st.removeProperty(k);else st.setProperty(k,v)}
function resetAll(){for(var i=REC.length-1;i>=0;i--){var r=REC[i];if(r.v)r.st.setProperty(r.k,r.v,r.p);else r.st.removeProperty(r.k);delete r.st.__cvk}REC=[]}
function isNew(el){return !!(el&&el.nodeType===1&&el.hasAttribute('data-cvn'))}
function isMv(el){return !!(el&&el.nodeType===1&&el.hasAttribute('data-cvm'))}
function skip(el){return isNew(el)||isMv(el)}
function resolve(ref){
  if(!ref)return null;var parts=ref.split('/'),h=parts[0],el=null;
  if(h==='body')el=D.body;else if(h==='html')el=D.documentElement;
  else if(h[0]==='#')el=D.getElementById(h.slice(1));
  else if(h[0]==='@')el=D.querySelector('[data-cvn="'+h.slice(1)+'"]');
  else if(h[0]==='%')el=D.querySelector('[data-cvm="'+h.slice(1)+'"]');
  for(var k=1;k<parts.length&&el;k++){
    var m=parts[k].match(/^([a-z0-9-]+)\[(\d+)\]$/i);if(!m)return null;
    var i=+m[2],f=null,tg=m[1].toUpperCase();
    for(var c=el.firstElementChild;c;c=c.nextElementSibling){if(c.tagName.toUpperCase()===tg&&!skip(c)){if(i===0){f=c;break}i--}}
    el=f;
  }
  return el;
}
var IND=false;try{IND=CSS.supports('translate','1px')&&CSS.supports('scale','1')}catch(e){}
function setTS(el,dx,dy,s){var st=el.style;dx=dx||0;dy=dy||0;s=s||1;if(s!==1)put(st,'transform-origin','0 0');
  if(IND){put(st,'translate',(dx||dy)?dx+'px '+dy+'px':'');put(st,'scale',s!==1?String(s):'')}
  else{var t='';if(dx||dy)t+='translate('+dx+'px,'+dy+'px) ';if(s!==1)t+='scale('+s+')';if(t)put(st,'transform',t)}}
function applyItem(ref){
  var it=M.I[ref],el=resolve(ref);if(!it||!el)return;var st=el.style;
  if(it.dx||it.dy||(it.s&&it.s!==1))setTS(el,it.dx,it.dy,it.s);
  if(it.w!=null){imp(st,'box-sizing','border-box');imp(st,'width',it.w+'px');imp(st,'min-width',it.w+'px');imp(st,'max-width','none');imp(st,'flex','none')}
  if(it.h!=null){imp(st,'box-sizing','border-box');imp(st,'height',it.h+'px');imp(st,'min-height',it.h+'px');imp(st,'max-height','none')}
  if(it.hide)imp(st,'display','none');
  if(it.z!=null){if(W.getComputedStyle(el).position==='static')imp(st,'position','relative');imp(st,'z-index',String(it.z))}
  if(it.bg)imp(st,'background',it.bg);if(it.fg)imp(st,'color',it.fg);
  if(it.rad!=null)imp(st,'border-radius',it.rad+'px');if(it.fs)imp(st,'font-size',it.fs+'px');
  if(it.op!=null)imp(st,'opacity',String(it.op));
  if(it.txt!=null&&el.children.length===0)el.textContent=it.txt;
}
function buildNew(n){var e;switch(n.kind){
  case 'panel':e=D.createElement('section');e.className='rack';e.innerHTML='<span class="lbl">Nuovo riquadro</span>';e.style.minHeight='90px';break;
  case 'button':e=D.createElement('button');e.type='button';e.className='btn sm';e.textContent='Nuovo pulsante';break;
  case 'text':e=D.createElement('span');e.className='lbl';e.style.display='inline-block';e.textContent='Scritta';break;
  case 'display':e=D.createElement('div');e.className='lcd';e.style.display='inline-block';e.textContent='0:00.0';break;
  case 'slider':e=D.createElement('input');e.type='range';e.style.width='160px';break;
  case 'select':e=D.createElement('select');e.innerHTML='<option>Opzione 1</option><option>Opzione 2</option>';break;
  case 'row':e=D.createElement('div');e.className='row c';e.style.minHeight='44px';break}return e}
function createNew(n){var par=resolve(n.par);if(!par)return false;var el;
  if(n.kind==='clone'){var src=resolve(n.of);if(!src)return false;el=src.cloneNode(true);
    [el].concat([].slice.call(el.querySelectorAll('[id]'))).forEach(function(x){if(x.id)x.id=x.id+'_'+n.id});
    [].forEach.call(el.querySelectorAll('label[for]'),function(x){x.htmlFor=x.htmlFor+'_'+n.id})}
  else el=buildNew(n);
  if(!el)return true;el.setAttribute('data-cvn',n.id);
  var aft=n.aft?resolve(n.aft):null;if(aft&&aft.parentNode===par)par.insertBefore(el,aft.nextSibling);else par.appendChild(el);return true}
function applyMove(mv){var el=resolve(mv.ref),to=resolve(mv.to);if(!el||!to||el===to||el.contains(to))return false;
  var ph=D.createElement(el.tagName);ph.setAttribute('data-cvph',mv.id);ph.setAttribute('hidden','');ph.style.setProperty('display','none','important');
  el.parentNode.replaceChild(ph,el);el.setAttribute('data-cvm',mv.id);
  var aft=mv.aft?resolve(mv.aft):null;if(aft&&aft.parentNode===to)to.insertBefore(el,aft.nextSibling);else to.appendChild(el);return true}
function vis(el){if(!el||!el.getClientRects().length)return false;var cs=W.getComputedStyle(el);return cs.display!=='none'&&cs.visibility!=='hidden'}
// disegnata per iPhone 15 (393 punti di larghezza): su schermi più larghi (15 Plus, Pro Max…) tutto si centra
function OY(){var b=D.body;if(!b||!b.classList.contains('hasMenu'))return 0;return parseFloat(W.getComputedStyle(D.documentElement).getPropertyValue('--mbh'))||0}   // barra dei menu in alto
function OX(){var w=D.documentElement.clientWidth||W.innerWidth;return Math.max(0,Math.round((w-BASEW)/2))}
function crops(P){var e=(P&&P.e)||{};return {t:Math.max(-(e.t||0),0),r:Math.max(-(e.r||0),0),b:Math.max(-(e.b||0),0),l:Math.max(-(e.l||0),0)}}
function r1(v){return Math.round(v*10)/10}
function posP(el,P,c){var st=el.style,s=P.s||1,e=P.e||{},ad={t:Math.max(e.t||0,0),r:Math.max(e.r||0,0),b:Math.max(e.b||0,0),l:Math.max(e.l||0,0)},cr=crops(P);
  imp(st,'left',r1(P.x+OX()-ad.l*s-c.x)+'px');imp(st,'top',r1(P.y+OY()-ad.t*s-c.y)+'px');imp(st,'width',r1(P.w+ad.l+ad.r)+'px');
  if(P.e)['t','r','b','l'].forEach(function(k){imp(st,'padding-'+{t:'top',r:'right',b:'bottom',l:'left'}[k],r1(c.pad[k]+ad[k])+'px')});
  if(cr.t||cr.r||cr.b||cr.l){var cp='inset('+r1(cr.t)+'px '+r1(cr.r)+'px '+r1(cr.b)+'px '+r1(cr.l)+'px)';imp(st,'clip-path',cp);imp(st,'-webkit-clip-path',cp)}
  if(P.mh){imp(st,'height',r1(P.mh)+'px');imp(st,'min-height','0px');imp(st,'max-height','none');imp(st,'overflow','hidden')}
  if(P.det)imp(st,'overflow','visible');   // oggetti sganciati dalla cornice
  if(P.z)imp(st,'z-index',String(P.z));
  setTS(el,0,0,s)}
function applyAll(){
  var ops=(M.N||[]).map(function(n){return {n:n,q:+String(n.id).slice(1)||0}}).concat((M.MV||[]).map(function(m){return {m:m,q:+String(m.id).slice(1)||0}})).sort(function(a,b){return a.q-b.q});
  for(var pass=0;pass<4&&ops.length;pass++)ops=ops.filter(function(op){return !(op.n?createNew(op.n):applyMove(op.m))});
  Object.keys(M.I).forEach(applyItem);
  if(!M.frozen)return;
  var list=[];Object.keys(M.P).forEach(function(ref){var el=resolve(ref);if(el&&vis(el))list.push({el:el,P:M.P[ref]})});
  list.forEach(function(p){var st=p.el.style;imp(st,'position','absolute');imp(st,'margin','0');imp(st,'box-sizing','border-box');imp(st,'max-width','none');imp(st,'left','0px');imp(st,'top','0px');imp(st,'width',p.P.w+'px')});
  list.forEach(function(p){var r=p.el.getBoundingClientRect(),cs=W.getComputedStyle(p.el);
    p.c={x:r.left+W.pageXOffset,y:r.top+W.pageYOffset,pad:{t:parseFloat(cs.paddingTop)||0,r:parseFloat(cs.paddingRight)||0,b:parseFloat(cs.paddingBottom)||0,l:parseFloat(cs.paddingLeft)||0}}});
  list.forEach(function(p){posP(p.el,p.P,p.c)});
  // la pagina scorre fino all'ultimo riquadro
  var b=0;list.forEach(function(p){var r=p.el.getBoundingClientRect();b=Math.max(b,r.bottom+W.pageYOffset)});
  var m=D.querySelector('main')||D.body;imp(m.style,'min-height',Math.ceil(b+24)+'px');
}
function pill(){var a=D.getElementById('cvLayoutPill');if(!a){a=D.createElement('a');a.id='cvLayoutPill';
  a.style.cssText='position:fixed;z-index:2147483646;right:10px;bottom:10px;background:#04161d;color:#35d0ff;border:1px solid #1aa4d6;font:600 11px/1 -apple-system,Helvetica,Arial,sans-serif;padding:6px 9px;border-radius:8px;text-decoration:none;opacity:.9';
  D.body.appendChild(a)}
  a.textContent=off?'Impaginazione originale · mostra quella iPhone':M?'Impaginazione iPhone '+(KEY.slice(-1)==='o'?'orizzontale ':'')+'(ARNOCANVAS) · mostra originale':'Orizzontale: impaginazione non ancora disegnata';
  a.href=location.pathname+(off?'':'?impaginazione=0');}
// la scelta dipende da larghezza e orientamento; girando il telefono si passa all'altra impaginazione senza ricaricare
function choose(){var p=pick();KEY=p.k;M=p.m;BASEW=p.w}
function relayout(){resetAll();choose();pill();if(!off&&M)applyAll();
  try{if(W.fitCv)W.fitCv();if(W.render)W.render()}catch(e){}}
var lastW=0,lastL=null;
function go(){try{lastW=D.documentElement.clientWidth;lastL=W.innerWidth>W.innerHeight;relayout()}catch(e){if(W.console)console.warn('Impaginazione ARNOCANVAS:',e)}}
var rt=null;W.addEventListener('resize',function(){clearTimeout(rt);rt=setTimeout(function(){var w=D.documentElement.clientWidth,l=W.innerWidth>W.innerHeight;
  if(!lastW||(Math.abs(w-lastW)<2&&l===lastL))return;lastW=w;lastL=l;try{relayout()}catch(e){}},250)});
if(D.readyState==='complete')setTimeout(go,300);else W.addEventListener('load',function(){setTimeout(go,300)});
})();
