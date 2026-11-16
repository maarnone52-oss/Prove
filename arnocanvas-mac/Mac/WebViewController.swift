import Cocoa
import WebKit

/// Mostra ARNOCANVAS dalla pagina delle prove. Le app da modificare (ARNOCLICK, ARNOVIDEO,
/// ARNODESIGN) stanno sullo stesso sito, così ARNOCANVAS le può aprire e modificare.
/// © 2026 Maurizio Arnone. Tutti i diritti riservati.
final class WebViewController: NSViewController, WKScriptMessageHandler, WKNavigationDelegate, WKUIDelegate {
    static let home = URL(string: "https://maarnone52-oss.github.io/Prove/arnocanvas/")!
    static let host = "maarnone52-oss.github.io"

    private var webView: WKWebView!

    override func loadView() {
        let contentController = WKUserContentController()
        contentController.add(self, name: "retry")

        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        config.websiteDataStore = .default()   // le modifiche restano salvate tra un'apertura e l'altra

        webView = ArnoWebView(frame: NSRect(x: 0, y: 0, width: 1280, height: 800), configuration: config)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        if #available(macOS 13.3, *) { webView.isInspectable = true }
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadHome()
    }

    private func loadHome() {
        webView.load(URLRequest(url: Self.home, cachePolicy: .reloadRevalidatingCacheData, timeoutInterval: 30))
    }

    /// Voce di menu. "c:id" preme il pulsante con quell'id; "q:selettore" preme il primo
    /// elemento che corrisponde; "m:voce" apre il menu ☰ e sceglie quella voce.
    @objc func menuCommand(_ sender: NSMenuItem) {
        guard let command = sender.representedObject as? String else { return }
        let parts = command.split(separator: ":", maxSplits: 1).map(String.init)
        guard parts.count == 2 else { return }
        let arg = Self.jsString(parts[1])
        let js: String
        switch parts[0] {
        case "c":
            js = "(function(){var b=document.getElementById(\(arg));if(b&&!b.disabled)b.click()})()"
        case "q":
            js = "(function(){var b=document.querySelector(\(arg));if(b&&!b.disabled)b.click()})()"
        default:
            js = "(function(){var m=document.getElementById('menuB');if(!m)return;m.click();setTimeout(function(){var b=document.querySelector('#shC [data-m='+JSON.stringify(\(arg))+']');if(b)b.click()},30)})()"
        }
        webView.evaluateJavaScript(js, completionHandler: nil)
    }

    private static func jsString(_ s: String) -> String {
        let data = (try? JSONSerialization.data(withJSONObject: [s])) ?? Data("[\"\"]".utf8)
        let arr = String(data: data, encoding: .utf8) ?? "[\"\"]"
        return String(arr.dropFirst().dropLast())
    }

    // MARK: - Senza internet

    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        if message.name == "retry" { loadHome() }
    }

    private func showOffline(_ error: Error) {
        let ns = error as NSError
        if ns.domain == NSURLErrorDomain && ns.code == NSURLErrorCancelled { return }
        let html = """
        <!DOCTYPE html><html lang="it"><head><meta charset="utf-8"><style>
        body{margin:0;height:100vh;display:flex;align-items:center;justify-content:center;background:#0d0e10;color:#eceef0;
        font:15px/1.5 -apple-system,Helvetica,Arial,sans-serif;text-align:center}
        h1{font-size:20px;margin:0 0 8px}h1 .a{color:#ffb21e}h1 .b{color:#35d0ff}p{color:#8a909a;max-width:440px;margin:0 auto 18px}
        button{font:inherit;font-weight:650;padding:10px 22px;border-radius:9px;border:1px solid #ffcf6b;background:linear-gradient(180deg,#ffc44d,#e89a00);color:#1b1305;cursor:pointer}
        </style></head><body><div><h1><span class="a">ARNO</span><span class="b">CANVAS</span> PROVA</h1>
        <p>Non riesco ad aprire la pagina delle prove. ARNOCANVAS ha bisogno di internet perché lavora sulle versioni di prova delle tue app, che stanno online.</p>
        <button onclick="window.webkit.messageHandlers.retry.postMessage(1)">Riprova</button></div></body></html>
        """
        webView.loadHTMLString(html, baseURL: nil)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        showOffline(error)
    }

    // MARK: - Avvisi e conferme della pagina (es. «Ripristina tutto»)

    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = NSAlert()
        alert.messageText = message
        alert.addButton(withTitle: "OK")
        alert.runModal()
        completionHandler()
    }

    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = NSAlert()
        alert.messageText = message
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Annulla")
        completionHandler(alert.runModal() == .alertFirstButtonReturn)
    }

    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String,
                 defaultText: String?, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (String?) -> Void) {
        let alert = NSAlert()
        alert.messageText = prompt
        let field = NSTextField(frame: NSRect(x: 0, y: 0, width: 280, height: 24))
        field.stringValue = defaultText ?? ""
        alert.accessoryView = field
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Annulla")
        completionHandler(alert.runModal() == .alertFirstButtonReturn ? field.stringValue : nil)
    }

    // MARK: - Scelta dei file (in «▶ Usa», per caricare brani o video nell'app)

    func webView(_ webView: WKWebView, runOpenPanelWith parameters: WKOpenPanelParameters,
                 initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping ([URL]?) -> Void) {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = parameters.allowsMultipleSelection
        panel.message = "Scegli il file"
        let finish: (NSApplication.ModalResponse) -> Void = { result in
            completionHandler(result == .OK ? panel.urls : nil)
        }
        if let window = view.window { panel.beginSheetModal(for: window, completionHandler: finish) }
        else { finish(panel.runModal()) }
    }

    // MARK: - Collegamenti: il sito delle prove resta qui, il resto si apre nel browser

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else { return decisionHandler(.allow) }
        let scheme = url.scheme ?? ""
        if scheme == "about" || scheme == "blob" || scheme == "data" || url.host == Self.host {
            decisionHandler(.allow)
        } else if navigationAction.targetFrame?.isMainFrame == false {
            decisionHandler(.allow)
        } else if scheme == "http" || scheme == "https" || scheme == "mailto" {
            NSWorkspace.shared.open(url)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.cancel)
        }
    }

    /// Finestre nuove (target=_blank): si aprono nel browser.
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let url = navigationAction.request.url { NSWorkspace.shared.open(url) }
        return nil
    }

    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        loadHome()
    }
}

/// WKWebView senza «Ricarica» nel menu del tasto destro.
final class ArnoWebView: WKWebView {
    override func willOpenMenu(_ menu: NSMenu, with event: NSEvent) {
        for item in menu.items where item.identifier?.rawValue == "WKMenuItemIdentifierReload" {
            menu.removeItem(item)
        }
        while let first = menu.items.first, first.isSeparatorItem { menu.removeItem(first) }
        while let last = menu.items.last, last.isSeparatorItem { menu.removeItem(last) }
        super.willOpenMenu(menu, with: event)
    }
}
