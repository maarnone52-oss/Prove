/* Impaginazione iPhone fatta con ARNOCANVAS 0.9.7 (iPhone 15 Plus, 430x932) — VERSIONE DI PROVA.
   Riapplica alla pagina vera di ARNOSHOW le modifiche disegnate in ARNOCANVAS: gli elementi
   sono quelli veri, quindi le funzioni restano collegate. Solo su iPhone in verticale.
   Per vedere l'originale: aggiungi ?impaginazione=0 all'indirizzo.
   Pulsanti nuovi «STOP»: tornano all'inizio della clip in corso e si fermano sul primo fotogramma.
   © 2026 Maurizio Arnone. Tutti i diritti riservati. */
(function(){
'use strict';
var M={"v":1,"frozen":true,"P":{"body/header[0]":{"x":0,"y":62,"w":430,"s":1,"x0":0,"y0":62,"w0":430,"h0":53,"mh":53},"#stage":{"x":50.4,"y":111,"w":292,"s":1.126,"x0":68.8,"y0":123,"w0":292,"h0":191,"mh":191,"det":true},"#prog":{"x":24,"y":360,"w":386,"s":1,"x0":22,"y0":334,"w0":386,"h0":10,"mh":10},"#listwrap":{"x":0.7,"y":412,"w":476,"s":0.898,"x0":0,"y0":350,"w0":430,"h0":434,"e":{"b":242},"mh":347.9,"det":true},"#bar":{"x":0,"y":742,"w":430,"s":1,"x0":0,"y0":783.8,"w0":430,"h0":20,"mh":20},"#foot":{"x":0,"y":804,"w":430,"s":1,"x0":0,"y0":804,"w0":430,"h0":94,"mh":94,"det":true},"#ctl":{"x":0,"y":912,"w":430,"s":1,"x0":0,"y0":912,"w0":430},"@n2":{"x":176,"y":424,"w":70,"s":1},"@n5":{"x":88,"y":64,"w":62,"s":2.548}},"I":{"#pp":{"dx":48,"dy":-30,"s":0.875},"#go":{"dx":79.4,"s":1.195,"dy":-6.6},"#list/div[0]":{"h":140,"dy":-6.3,"s":1.164,"dx":-2.6,"z":2},"#hdmiout":{"dx":8},"#ztrack":{"h":292,"dy":209.4},"#accord":{"dy":308.9,"dx":158.4,"h":35},"#list":{"h":307,"w":412,"dx":-10,"z":3},"#qprev":{"s":1.269,"dx":-27.3,"dy":-3.7,"z":5},"body/header[0]":{"z":1},"#prog":{"z":2},"#listwrap":{"z":8},"#bar":{"z":3},"#foot":{"z":4},"#stage":{"z":5},"#v":{"z":1},"#scr":{"z":2},"#wait":{"z":3},"#v2":{"z":4},"#tm":{"s":1.269,"dx":-17.1,"dy":-5.4,"bg":"#e22400","fg":"#ffffff"},"@n1":{"s":1.692,"w":81,"txt":"STOP","bg":"#e22400","dx":-187.5,"dy":14},"@n2":{"z":6},"@n5":{"z":7,"op":0},"@n6/span[0]":{"txt":"STOP","fg":"#ffffff"},"#list/div[2]":{"s":0.984,"dx":27.2,"dy":-9.7,"z":4},"#list/div[3]":{"s":0.936,"z":1},"#list/div[1]":{"s":0.982,"dy":3.3,"z":3},"#zrail":{"z":1}},"N":[{"id":"n1","kind":"button","par":"#foot","aft":null},{"id":"n2","kind":"wrap","panel":true,"par":"body","aft":"#foot"},{"id":"n5","kind":"wrap","panel":true,"par":"body","aft":"#foot"},{"id":"n6","kind":"btn_tri","par":"@n5","aft":null}],"MV":[],"G":[],"seq":7};
var q=location.search;
if(/[?&]arnocanvas=/.test(q))return;                       // dentro ARNOCANVAS: ci pensa lui
if(/[?&]impaginazione=0/.test(q))return;
var D=document,W=window;
function phone(){try{return W.matchMedia('(orientation:portrait)').matches&&W.innerWidth<=520}catch(e){return false}}
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
var IND=false;try{IND=CSS.supports('translate','1px')&&CSS.supports('scale','1')&&CSS.supports('rotate','1deg')}catch(e){}
function setTS(el,dx,dy,s,rot){var st=el.style;dx=dx||0;dy=dy||0;s=s||1;rot=rot||0;if(s!==1||rot)st.transformOrigin='0 0';
  if(rot){var a=rot*Math.PI/180,cx=el.offsetWidth*s/2,cy=el.offsetHeight*s/2,ca=Math.cos(a),sa=Math.sin(a);dx+=cx-(ca*cx-sa*cy);dy+=cy-(sa*cx+ca*cy)}
  if(IND){st.translate=(dx||dy)?dx+'px '+dy+'px':'';st.scale=s!==1?String(s):'';st.rotate=rot?rot+'deg':''}
  else{var t='';if(dx||dy)t+='translate('+dx+'px,'+dy+'px) ';if(rot)t+='rotate('+rot+'deg) ';if(s!==1)t+='scale('+s+')';if(t)st.transform=t}}
function applyItem(ref){
  var it=M.I[ref],el=resolve(ref);if(!it||!el)return;var st=el.style;
  if(it.dx||it.dy||(it.s&&it.s!==1)||it.rot)setTS(el,it.dx,it.dy,it.s,it.rot);
  if(it.w!=null){imp(st,'box-sizing','border-box');imp(st,'width',it.w+'px');imp(st,'min-width',it.w+'px');imp(st,'max-width','none');imp(st,'flex','none')}
  if(it.h!=null){imp(st,'box-sizing','border-box');imp(st,'height',it.h+'px');imp(st,'min-height',it.h+'px');imp(st,'max-height','none')}
  if(it.hide)imp(st,'display','none');
  if(it.z!=null){if(W.getComputedStyle(el).position==='static')imp(st,'position','relative');imp(st,'z-index',String(it.z))}
  if(it.bg)imp(st,'background',it.bg);if(it.fg)imp(st,'color',it.fg);
  if(it.rad!=null)imp(st,'border-radius',it.rad+'px');if(it.fs)imp(st,'font-size',it.fs+'px');
  if(it.ff)imp(st,'font-family',it.ff);if(it.fw)imp(st,'font-weight',String(it.fw));if(it.fi)imp(st,'font-style','italic');
  if(it.tt)imp(st,'text-transform',it.tt);if(it.ls!=null)imp(st,'letter-spacing',it.ls+'px');
  if(it.op!=null){imp(st,'opacity',String(it.op));if(!it.op)imp(st,'pointer-events','none')} // trasparente: non ruba i tocchi
  if(it.txt!=null&&el.children.length===0)el.textContent=it.txt;
}
var LIB={btn_tri:'<button type="button" style="width:62px;height:62px;border:0;padding:0;background:linear-gradient(180deg,#7dff9e,#1fae4f);clip-path:polygon(18% 6%,92% 50%,18% 94%);-webkit-clip-path:polygon(18% 6%,92% 50%,18% 94%);display:inline-flex;align-items:center;justify-content:center;color:#04240f;font:800 12px -apple-system,Helvetica,Arial,sans-serif" aria-label="Stop"><span data-cvt style="margin-right:22%"></span></button>'};
function buildNew(n){var e;switch(n.kind){
  case 'panel':e=D.createElement('section');e.className='rack';e.innerHTML='<span class="lbl">Nuovo riquadro</span>';e.style.minHeight='90px';break;
  case 'button':e=D.createElement('button');e.type='button';e.className='btn sm';e.textContent='Nuovo pulsante';break;
  case 'text':e=D.createElement('span');e.className='lbl';e.style.display='inline-block';e.textContent='Scritta';break;
  case 'wrap':e=D.createElement('div');e.className='cv-wrap';e.style.cssText='display:block;margin:0;padding:0;border:0;background:none;box-shadow:none';break;
  default:if(LIB[n.kind]){var t=D.createElement('div');t.innerHTML=LIB[n.kind];e=t.firstElementChild}}
  return e}
function createNew(n){var par=resolve(n.par);if(!par)return false;var el=buildNew(n);
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
  if(P.mh){imp(st,'height',r1(P.mh)+'px');imp(st,'min-height','0px');imp(st,'max-height','none')}
  if(P.det)imp(st,'overflow','visible');
  if(P.z)imp(st,'z-index',String(P.z));
  setTS(el,0,0,s,P.rot||0)}
var built=false,PANELS=['body > header','#stage','#prog','#bar','#ctl','#listwrap','#foot'];
function applyAll(){
  if(!built){built=true;
    var ops=(M.N||[]).map(function(n){return {n:n,q:+String(n.id).slice(1)||0}}).concat((M.MV||[]).map(function(m){return {m:m,q:+String(m.id).slice(1)||0}})).sort(function(a,b){return a.q-b.q});
    for(var pass=0;pass<4&&ops.length;pass++)ops=ops.filter(function(op){return !(op.n?createNew(op.n):applyMove(op.m))});
    Object.keys(M.I).forEach(applyItem);
    stopButtons();
  }
  if(!M.frozen)return;
  var list=[];Object.keys(M.P).forEach(function(ref){var el=resolve(ref);if(el&&vis(el))list.push({el:el,P:M.P[ref]})});
  list.forEach(function(p){var st=p.el.style;imp(st,'position','absolute');imp(st,'margin','0');imp(st,'box-sizing','border-box');imp(st,'max-width','none');imp(st,'left','0px');imp(st,'top','0px');imp(st,'width',p.P.w+'px');setTS(p.el,0,0,1,0)});
  list.forEach(function(p){var r=p.el.getBoundingClientRect(),cs=W.getComputedStyle(p.el);
    p.c={x:r.left+W.pageXOffset,y:r.top+W.pageYOffset,pad:{t:parseFloat(cs.paddingTop)||0,r:parseFloat(cs.paddingRight)||0,b:parseFloat(cs.paddingBottom)||0,l:parseFloat(cs.paddingLeft)||0}}});
  list.forEach(function(p){posP(p.el,p.P,p.c)});
  D.body.classList.add('cvlayout');
  // elementi che compaiono più tardi (es. il numero della clip): si sistemano quando diventano visibili
  Object.keys(M.P).forEach(function(ref){var el=resolve(ref);if(!el||vis(el)||el._cvObs||!W.MutationObserver)return;el._cvObs=1;
    var place=function(){if(!vis(el))return;var P=M.P[ref],st=el.style;imp(st,'position','absolute');imp(st,'margin','0');imp(st,'box-sizing','border-box');imp(st,'max-width','none');imp(st,'left','0px');imp(st,'top','0px');imp(st,'width',P.w+'px');setTS(el,0,0,1,0);
      var r=el.getBoundingClientRect(),cs=W.getComputedStyle(el);posP(el,P,{x:r.left+W.pageXOffset,y:r.top+W.pageYOffset,pad:{t:parseFloat(cs.paddingTop)||0,r:parseFloat(cs.paddingRight)||0,b:parseFloat(cs.paddingBottom)||0,l:parseFloat(cs.paddingLeft)||0}})};
    new MutationObserver(function(){if(vis(el)&&!el._cvDone){el._cvDone=1;place()}else if(!vis(el))el._cvDone=0}).observe(el,{attributes:true,attributeFilter:['hidden','class','style']})});
}
/* funzioni assegnate agli elementi nuovi */
function stopButtons(){['@n1','@n6'].forEach(function(r){var b=resolve(r);if(!b)return;
  if(r==='@n6'){var w=resolve('@n5');if(w&&W.getComputedStyle(w).opacity==='0')imp(w.style,'pointer-events','none')}
  b.title='Stop: torna all\'inizio della clip e si ferma sul primo fotogramma';b.setAttribute('aria-label','Stop');
  b.addEventListener('click',function(e){e.preventDefault();if(W.arnoStopClip)W.arnoStopClip()})})}
var on=false;
function go(){try{if(phone()){applyAll();on=true}}catch(e){if(W.console)console.warn('Impaginazione ARNOCANVAS:',e)}}
// se si gira l'iPhone in orizzontale torna l'impaginazione originale, ricaricando la pagina solo se è ferma
W.addEventListener('orientationchange',function(){setTimeout(function(){if(on!==phone()&&!D.body.classList.contains('isplaying'))location.reload()},400)});
if(D.readyState==='complete')setTimeout(go,600);else W.addEventListener('load',function(){setTimeout(go,600)});
})();
