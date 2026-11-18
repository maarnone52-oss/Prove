#!/usr/bin/env python3
"""Compone il sito delle prove in _site: ogni cartella-app viene copiata e
marcata come VERSIONE DI PROVA (striscia rossa, dati separati, icona con la scritta PROVA)."""
import json, os, re, shutil, sys
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, '_site')
APPS = json.load(open(os.path.join(ROOT, 'app.json')))
SHIM = open(os.path.join(ROOT, 'tools', 'prova-shim.js')).read()
try:
    from PIL import Image, ImageDraw, ImageFont
except Exception:
    Image = None

def marca_icona(path):
    if not Image or not os.path.exists(path): return
    im = Image.open(path).convert('RGBA'); w, h = im.size
    d = ImageDraw.Draw(im); bh = int(h * 0.26)
    d.rectangle([0, h - bh, w, h], fill=(224, 38, 43, 255))
    font = None
    for f in ['/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf', '/System/Library/Fonts/Helvetica.ttc']:
        if os.path.exists(f): font = ImageFont.truetype(f, int(bh * 0.62)); break
    font = font or ImageFont.load_default()
    t = 'PROVA'; tw = d.textlength(t, font=font)
    d.text(((w - tw) / 2, h - bh + bh * 0.14), t, fill='white', font=font)
    im.convert('RGB').save(path)

shutil.rmtree(OUT, ignore_errors=True); os.makedirs(OUT)
for a in APPS:
    src = os.path.join(ROOT, a['cartella']); dst = os.path.join(OUT, a['cartella'])
    shutil.copytree(src, dst)
    p = os.path.join(dst, 'index.html'); s = open(p, encoding='utf-8').read()
    s = re.sub(r'(<head[^>]*>)', lambda m: m.group(1) + '\n<script>' + SHIM + '</script>', s, count=1)
    if 'apple-mobile-web-app-title' in s:
        s = re.sub(r'(<meta name="apple-mobile-web-app-title" content=")([^"]*)', r'\1\2 PROVA', s, count=1)
    else:
        s = s.replace('</head>', '<meta name="apple-mobile-web-app-title" content="' + a['nome'] + ' PROVA">\n</head>', 1)
    open(p, 'w', encoding='utf-8').write(s)
    m = os.path.join(dst, 'manifest.webmanifest')
    if os.path.exists(m):
        j = json.load(open(m, encoding='utf-8'))
        for k in ('name', 'short_name'):
            if k in j: j[k] = j[k] + ' PROVA'
        json.dump(j, open(m, 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
    for ic in ('apple-touch-icon.png', 'icon-192.png', 'icon-512.png'):
        marca_icona(os.path.join(dst, ic))

# pagine fisse (es. informative sulla privacy), copiate senza modifiche
if os.path.isdir(os.path.join(ROOT, 'privacy')):
    shutil.copytree(os.path.join(ROOT, 'privacy'), os.path.join(OUT, 'privacy'))

righe = ''.join('<a class="app" href="%s/"><b>%s</b><span>%s</span></a>' % (a['cartella'], a['nome'], a.get('stato', '')) for a in APPS)
open(os.path.join(OUT, 'index.html'), 'w', encoding='utf-8').write('''<!DOCTYPE html><html lang="it"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover"><title>Versioni di prova</title>
<style>body{margin:0;background:#0f1115;color:#e8eaf0;font:16px/1.4 -apple-system,Helvetica,Arial,sans-serif;padding:max(20px,env(safe-area-inset-top)) 18px 30px}
h1{font-size:22px;margin:0 0 4px}h1 b{background:#e0262b;color:#fff;padding:2px 8px;border-radius:6px;font-size:14px;letter-spacing:2px;vertical-align:middle}
p{color:#9aa1ad;font-size:14px}.app{display:block;background:#20242d;border:1px solid #2c313c;border-radius:12px;padding:14px;margin:10px 0;color:#e8eaf0;text-decoration:none}
.app b{display:block;font-size:17px}.app span{color:#9aa1ad;font-size:13px}</style></head><body>
<h1>Versioni di prova <b>PROVA</b></h1>
<p>Copie delle app per verificare le modifiche prima di renderle definitive. I dati (brani recenti, progetti, impostazioni) sono separati da quelli delle app vere.
Per averne una sulla Home: aprila, tocca Condividi › Aggiungi alla schermata Home.</p>''' + righe + '''
<p>© 2026 Maurizio Arnone. Tutti i diritti riservati.</p></body></html>''')
open(os.path.join(OUT, '.nojekyll'), 'w').close()
print('Pronto:', ', '.join(a['cartella'] for a in APPS))
