#!/bin/bash
# ARNOCANVAS PROVA (Chrome): apre la versione di prova di ARNOCANVAS in una finestra di Google Chrome
# senza barra degli indirizzi. Pensata per High Sierra e Mojave. © 2026 Maurizio Arnone.
URL="https://maarnone52-oss.github.io/Prove/arnocanvas/"
if open -Ra "Google Chrome" >/dev/null 2>&1; then
  open -na "Google Chrome" --args --app="$URL" --window-size=1280,800
else
  osascript -e 'display dialog "ARNOCANVAS ha bisogno di Google Chrome.\n\nOra si apre la pagina per scaricarlo: installalo, poi riapri ARNOCANVAS." buttons {"OK"} default button 1 with title "ARNOCANVAS" with icon caution' >/dev/null 2>&1
  open "https://www.google.com/chrome/"
fi
