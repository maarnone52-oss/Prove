/* Impaginazione per Mac fatta con ARNOCANVAS 0.7.7 (schermo mac13 1280x800) — VERSIONE DI PROVA.
   Riapplica alla pagina vera di ARNOVIDEO le modifiche disegnate in ARNOCANVAS: gli elementi
   sono quelli veri, quindi le funzioni restano collegate. Solo su Mac (niente schermo touch,
   finestra larga almeno 900 punti). Per vedere l'originale: aggiungi ?impaginazione=0 all'indirizzo.
   © 2026 Maurizio Arnone. Tutti i diritti riservati. */
(function(){
'use strict';
var M={"v":1,"frozen":true,"P":{"body/main[0]/div[0]":{"x":-80,"y":16,"w":1072,"s":0.791,"x0":104,"y0":22,"w0":1072,"h0":149,"e":{"r":-576,"l":-152,"b":27}},"body/main[0]/section[0]":{"x":368,"y":24,"w":343.6,"s":0.652,"x0":104,"y0":189,"w0":1072,"h0":151},"body/main[0]/section[1]":{"x":40,"y":232,"w":870.5,"s":0.579,"x0":104,"y0":356,"w0":1072,"h0":301,"mh":414.5,"e":{"r":-41.5}},"body/main[0]/section[2]":{"x":544,"y":160,"w":708.9,"s":0.564,"x0":104,"y0":673,"w0":1072,"h0":1119,"e":{"b":-9.7},"mh":562.9},"body/main[0]/section[3]":{"x":824,"y":152,"w":895.6,"s":0.677,"x0":104,"y0":1808,"w0":1072,"h0":845,"e":{"r":-292.9,"l":-306.1},"mh":200.9},"body/main[0]/section[4]":{"x":648,"y":8,"w":1072,"s":0.545,"x0":104,"y0":2669,"w0":1072,"h0":234},"body/main[0]/footer[0]":{"x":-272,"y":176,"w":1066.7,"s":0.892,"x0":104,"y0":2923,"w0":1072,"h0":18,"e":{"r":-349.2,"l":-349.2}},"#tlRack":{"x":40,"y":496,"w":2030,"s":0.599,"x0":-136,"y0":3080,"w0":1072,"e":{"b":-6},"mh":380},"#mixRack":{"x":976,"y":304,"w":177.3,"s":0.587,"x0":-136,"y0":3512,"w0":1072,"e":{"b":1.7}}},"I":{"#lib":{"w":769,"h":211,"s":1.053},"body/main[0]/section[1]/div[0]":{"w":669,"s":1.438,"h":66,"dy":-14.4},"body/main[0]/section[1]/span[0]":{"h":29,"w":669},"body/main[0]/section[0]/div[0]":{"w":713,"dx":-216.9},"body/main[0]/section[0]/span[0]":{"w":713,"dx":-216.9},"body/main[0]/section[0]/div[1]":{"w":713,"dx":-216.9},"body/main[0]/div[0]/div[2]":{"w":336,"dy":-3,"dx":136},"#helpBtn":{"w":148,"dx":-134,"dy":-1,"h":32},"body/main[0]/div[0]/div[1]":{"w":336,"dx":136,"dy":7},"body/main[0]/div[0]/div[0]":{"w":95,"dx":-312.5,"dy":2},"body/main[0]/div[0]":{"z":3},"body/main[0]/section[1]":{"z":9},"body/main[0]/section[0]":{"z":8},"body/main[0]/section[2]":{"z":4},"body/main[0]/section[3]":{"z":5},"body/main[0]/section[4]":{"z":6},"body/main[0]/footer[0]":{"z":7},"%m2":{"s":0.338,"h":240,"dx":-126,"dy":-84.2},"%m3":{"w":448,"dx":-748.1,"dy":337.6},"#tlRack":{"z":1},"#mixRack":{"z":2},"#track":{"w":1944,"h":219},"#mixRack/span[0]":{"w":150,"dx":-10.3,"dy":-10.3},"#mixer":{"w":150,"dx":-10.3,"dy":-10.3},"body/main[0]/section[4]/div[0]/label[2]":{"h":59,"dy":77.1,"dx":-264.1},"#defDur":{"h":30},"body/main[0]/section[4]/div[0]/label[3]":{"h":59,"dy":-2.3,"dx":-248.2},"body/main[0]/section[4]/div[0]/label[1]":{"h":62,"dy":-2},"body/main[0]/section[4]/div[0]/label[0]":{"h":63,"dy":-2},"body/main[0]/section[4]/div[0]/label[7]":{"h":60,"dy":2.1,"dx":-261.2},"body/main[0]/section[4]/div[0]/label[4]":{"dx":536.8,"dy":-17.7,"w":456,"h":102},"body/main[0]/section[4]/div[0]":{"dx":0.9,"dy":-2.3},"body/main[0]/section[4]/div[0]/label[4]/div[0]":{"w":277},"#cacheRes":{"h":139,"dx":-0.9,"dy":20.4,"w":496},"#pvBox":{"dx":21,"dy":2,"hide":true},"#tlRack/div[2]":{"dx":-5.6,"dy":-2.8},"#frameBtn":{"dx":-167.8,"dy":74.1},"body/main[0]/section[3]/span[0]":{"w":1034},"body/main[0]/section[3]/div[2]":{"w":1034}},"N":[],"MV":[{"id":"m2","ref":"@n1/span[0]","to":"body/main[0]/section[2]","aft":null,"from":"Nuovo riquadro"},{"id":"m3","ref":"#mixer","to":"@n1","aft":null,"from":"2 · Timeline"}],"seq":4};
var q=location.search;
if(/[?&]arnocanvas=/.test(q))return;                       // dentro ARNOCANVAS: ci pensa lui
var off=/[?&]impaginazione=0/.test(q);
var mac=false;try{mac=navigator.maxTouchPoints===0&&window.innerWidth>=900}catch(e){}
if(!mac)return;
var D=document,W=window;
function imp(st,k,v){st.setProperty(k,v,'important')}
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
function setTS(el,dx,dy,s){var st=el.style;dx=dx||0;dy=dy||0;s=s||1;if(s!==1)st.transformOrigin='0 0';
  if(IND){st.translate=(dx||dy)?dx+'px '+dy+'px':'';st.scale=s!==1?String(s):''}
  else{var t='';if(dx||dy)t+='translate('+dx+'px,'+dy+'px) ';if(s!==1)t+='scale('+s+')';if(t)st.transform=t}}
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
function crops(P){var e=(P&&P.e)||{};return {t:Math.max(-(e.t||0),0),r:Math.max(-(e.r||0),0),b:Math.max(-(e.b||0),0),l:Math.max(-(e.l||0),0)}}
function r1(v){return Math.round(v*10)/10}
function posP(el,P,c){var st=el.style,s=P.s||1,e=P.e||{},ad={t:Math.max(e.t||0,0),r:Math.max(e.r||0,0),b:Math.max(e.b||0,0),l:Math.max(e.l||0,0)},cr=crops(P);
  imp(st,'left',r1(P.x-ad.l*s-c.x)+'px');imp(st,'top',r1(P.y-ad.t*s-c.y)+'px');imp(st,'width',r1(P.w+ad.l+ad.r)+'px');
  if(P.e)['t','r','b','l'].forEach(function(k){imp(st,'padding-'+{t:'top',r:'right',b:'bottom',l:'left'}[k],r1(c.pad[k]+ad[k])+'px')});
  if(cr.t||cr.r||cr.b||cr.l){var cp='inset('+r1(cr.t)+'px '+r1(cr.r)+'px '+r1(cr.b)+'px '+r1(cr.l)+'px)';imp(st,'clip-path',cp);imp(st,'-webkit-clip-path',cp)}
  if(P.mh){imp(st,'height',r1(P.mh)+'px');imp(st,'min-height','0px');imp(st,'max-height','none');imp(st,'overflow','hidden')}
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
function pill(){var a=D.createElement('a');a.id='cvLayoutPill';
  a.textContent=off?'Impaginazione originale · mostra quella Mac':'Impaginazione Mac (ARNOCANVAS) · mostra originale';
  a.href=location.pathname+(off?'':'?impaginazione=0');
  a.style.cssText='position:fixed;z-index:2147483646;right:10px;bottom:10px;background:#04161d;color:#35d0ff;border:1px solid #1aa4d6;font:600 11px/1 -apple-system,Helvetica,Arial,sans-serif;padding:6px 9px;border-radius:8px;text-decoration:none;opacity:.9';
  D.body.appendChild(a)}
function go(){try{pill();if(!off)applyAll()}catch(e){if(W.console)console.warn('Impaginazione ARNOCANVAS:',e)}}
if(D.readyState==='complete')setTimeout(go,300);else W.addEventListener('load',function(){setTimeout(go,300)});
})();
