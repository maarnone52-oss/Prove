# Versioni di prova

**https://maarnone52-oss.github.io/Prove/**

Qui stanno le copie di prova delle app di Maurizio Arnone. Ogni modifica viene messa prima qui,
provata sull'iPhone o sul Mac, e solo dopo la conferma passa all'app definitiva.

| Cartella | App | Indirizzo della prova |
|---|---|---|
| `arnoclick/` | ARNOCLICK (pagina offuscata, come la pubblica) | /Prove/arnoclick/ |
| `arnovideo/` | ARNOCUT (ex ARNOVIDEO) | /Prove/arnovideo/ |
| `podpro/` | POD Pro Remote | /Prove/podpro/ |
| `arnodesign/` | ARNODESIGN | /Prove/arnodesign/ |
| `arnocanvas/` | ARNOCANVAS (prototipo, editor delle interfacce) | /Prove/arnocanvas/ |
| `arnoshow/` | ARNOSHOW (riproduttore video, foto e audio con uscita HDMI) | /Prove/arnoshow/ |

Al momento della pubblicazione `tools/prepara.py` marca ogni copia come **PROVA**:
striscia rossa in alto, icona con la scritta PROVA, nome «… PROVA» sulla Home,
dati separati da quelli dell'app definitiva e nessuna copia offline.

**ARNOCANVAS per Mac (prova):** pagina Releases › «ARNOCANVAS PROVA per Mac» — `.pkg`/`.dmg` per Catalina e successivi,
più «ARNOCANVAS PROVA Chrome» per High Sierra e Mojave. Le app aprono la pagina /Prove/arnocanvas/,
quindi si aggiornano da sole (sorgenti in `arnocanvas-mac/`).

`app.json` dice per ogni app da quale versione parte la prova e che modifiche contiene.

© 2026 Maurizio Arnone. Tutti i diritti riservati.
