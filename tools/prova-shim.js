/* VERSIONE DI PROVA — inserito automaticamente da tools/prepara.py.
   Tiene separati i dati della prova da quelli dell'app definitiva (stesso sito)
   e non installa la copia offline. */
(function(){
  var P='prova:';
  try{
    var S=Storage.prototype,gi=S.getItem,si=S.setItem,ri=S.removeItem,ky=S.key;
    function mine(st){var a=[];for(var j=0;j<st.length;j++){var x=ky.call(st,j);if(x&&x.indexOf(P)===0)a.push(x)}return a}
    S.getItem=function(k){return gi.call(this,P+k)};
    S.setItem=function(k,v){return si.call(this,P+k,v)};
    S.removeItem=function(k){return ri.call(this,P+k)};
    S.key=function(i){var a=mine(this);return a[i]===undefined?null:a[i].slice(P.length)};
    S.clear=function(){var t=this;mine(t).forEach(function(x){ri.call(t,x)})};
  }catch(e){}
  try{
    var F=IDBFactory.prototype,op=F.open,dd=F.deleteDatabase;
    F.open=function(n,v){return v===undefined?op.call(this,P+n):op.call(this,P+n,v)};
    F.deleteDatabase=function(n){return dd.call(this,P+n)};
  }catch(e){}
  try{
    var C=CacheStorage.prototype,co=C.open,cd=C['delete'],ch=C.has,ck=C.keys;
    C.open=function(n){return co.call(this,P+n)};
    C['delete']=function(n){return cd.call(this,P+n)};
    C.has=function(n){return ch.call(this,P+n)};
    C.keys=function(){return ck.call(this).then(function(a){return a.filter(function(x){return x.indexOf(P)===0}).map(function(x){return x.slice(P.length)})})};
  }catch(e){}
  try{if(navigator.serviceWorker)navigator.serviceWorker.register=function(){return Promise.reject(new Error('Versione di prova: niente copia offline'))}}catch(e){}
  function badge(){if(document.getElementById('provaBadge'))return;try{if(window.top!==window)return}catch(e){return}
    var m=location.pathname.match(/\/Prove\/([^\/]+)\//i),app=m?m[1]:'',edit=app&&app.toLowerCase()!=='arnodesign';
    var b=document.createElement(edit?'a':'div');b.id='provaBadge';b.textContent=edit?'PROVA · ✎ Modifica':'PROVA';
    if(edit){b.href=location.pathname.replace(/\/[^\/]+\/[^\/]*$/,'/')+'arnodesign/#importa-'+app;b.title='Apri questa app in ARNODESIGN per modificarne la grafica'}
    b.style.cssText='position:fixed;z-index:2147483647;left:50%;transform:translateX(-50%);top:env(safe-area-inset-top,0);margin-top:2px;background:#e0262b;color:#fff;font:700 11px/1 -apple-system,Helvetica,Arial,sans-serif;letter-spacing:1.5px;padding:5px 10px;border-radius:0 0 8px 8px;box-shadow:0 2px 6px #0008;opacity:.95;text-decoration:none;white-space:nowrap;'+(edit?'':'pointer-events:none;left:auto;right:8px;transform:none;top:auto;bottom:calc(env(safe-area-inset-bottom,0px) + 70px);border-radius:8px;');
    document.body.appendChild(b)}
  function mark(){badge();try{if(document.title.indexOf('PROVA')!==0)document.title='PROVA – '+document.title}catch(e){}}
  if(document.readyState==='loading')document.addEventListener('DOMContentLoaded',mark);else mark();
})();
