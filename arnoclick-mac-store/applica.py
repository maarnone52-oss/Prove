#!/usr/bin/env python3
"""Collega la cattura dal vivo a WebViewController.swift (sorgente pubblico di ARNOCLICK).
Uso: python3 applica.py <percorso di Mac/WebViewController.swift>
Si ferma con errore se i punti da modificare non si trovano esattamente una volta."""
import sys
p = sys.argv[1]
s = open(p, encoding='utf-8').read()

def una_volta(vecchio, nuovo):
    global s
    n = s.count(vecchio)
    if n != 1:
        sys.exit("ERRORE: trovato %d volte: %r" % (n, vecchio[:70]))
    s = s.replace(vecchio, nuovo)

una_volta('        contentController.add(self, name: "outs")\n',
          '        contentController.add(self, name: "outs")\n'
          '        contentController.addUserScript(WKUserScript(source: LiveShim.source, injectionTime: .atDocumentStart, forMainFrameOnly: true))\n')
una_volta('        if message.name == "inputs" {\n',
          '        if message.name == "inputs" {\n'
          '            if let body = message.body as? [String: Any], let cap = body["cap"] as? String {\n'
          '                LiveCapture.shared.handle(cap) { [weak self] js in self?.webView.evaluateJavaScript(js, completionHandler: nil) }\n'
          '                return\n'
          '            }\n')
open(p, 'w', encoding='utf-8').write(s)
print("WebViewController.swift collegato")
