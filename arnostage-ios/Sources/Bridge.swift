import UIKit
import WebKit
import AVFoundation

/// Collega la pagina di ArnoStage al motore audio nativo, all'archivio dei file e al monitor HDMI.
final class Bridge: NSObject, WKScriptMessageHandler, WKScriptMessageHandlerWithReply, WKNavigationDelegate {
    static let shared = Bridge()
    static let base = URL(string: "arnostage://app/index.html")!
    /// Da qui l'app scarica in silenzio l'ultima versione della pagina (prova).
    static let remote = URL(string: "https://raw.githubusercontent.com/maarnone52-oss/Prove/main/arnostage/index.html")!
    static let local: URL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent("index.html")

    static func updatePage() {
        var r = URLRequest(url: remote, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 20)
        r.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        URLSession.shared.dataTask(with: r) { d, resp, _ in
            guard let d = d, (resp as? HTTPURLResponse)?.statusCode == 200,
                  let t = String(data: d, encoding: .utf8), t.contains("ArnoStage"), t.contains("</html>") else { return }
            try? FileManager.default.createDirectory(at: local.deletingLastPathComponent(), withIntermediateDirectories: true)
            try? d.write(to: local, options: .atomic)
        }.resume()
    }

    var control: WKWebView?
    var monitorVC: MonitorVC?
    var monitorAttached = false

    func makeWebView() -> WKWebView {
        let c = WKWebViewConfiguration()
        c.allowsInlineMediaPlayback = true
        c.mediaTypesRequiringUserActionForPlayback = []
        c.websiteDataStore = WKWebsiteDataStore.default()
        c.setURLSchemeHandler(PageScheme(), forURLScheme: "arnostage")
        c.userContentController.add(self, name: "mon")
        c.userContentController.addScriptMessageHandler(self, contentWorld: .page, name: "store")
        c.userContentController.addScriptMessageHandler(self, contentWorld: .page, name: "eng")
        let w = WKWebView(frame: .zero, configuration: c)
        w.navigationDelegate = self
        w.uiDelegate = self
        w.isOpaque = false
        w.backgroundColor = .black
        w.scrollView.backgroundColor = .black
        w.scrollView.contentInsetAdjustmentBehavior = .never
        w.scrollView.bounces = false
        w.load(URLRequest(url: Bridge.base))
        StageEngine.shared.onChange = { [weak self] in
            self?.control?.evaluateJavaScript("window.engChanged&&window.engChanged()", completionHandler: nil)
        }
        return w
    }

    // Monitor: {t:"show"/"state"/"black", ...}
    func userContentController(_ ucc: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "mon", let json = message.body as? String, let d = json.data(using: .utf8),
              let m = (try? JSONSerialization.jsonObject(with: d)) as? [String: Any] else { return }
        monitorVC?.handle(m)
    }

    func userContentController(_ ucc: WKUserContentController, didReceive message: WKScriptMessage, replyHandler: @escaping (Any?, String?) -> Void) {
        guard let m = message.body as? [String: Any], let op = m["op"] as? String else { replyHandler(nil, "messaggio non valido"); return }
        if message.name == "eng" {
            StageEngine.shared.handle(m) { r in replyHandler(r, nil) }
            return
        }
        switch op {
        case "has":
            let ids = (m["ids"] as? [String]) ?? []
            replyHandler(ids.filter { MediaStore.has($0) }, nil)
        case "put":
            guard let id = m["id"] as? String, let b64 = m["b64"] as? String, let data = Data(base64Encoded: b64) else { replyHandler(nil, "dati non validi"); return }
            let seq = (m["seq"] as? Int) ?? 0, last = (m["last"] as? Bool) ?? false, ext = (m["ext"] as? String) ?? "wav"
            DispatchQueue.global(qos: .userInitiated).async {
                let ok = MediaStore.append(id: id, ext: ext, seq: seq, last: last, data: data)
                DispatchQueue.main.async {
                    if ok && last { self.monitorVC?.fileArrived(id) }
                    replyHandler(ok, ok ? nil : "scrittura non riuscita")
                }
            }
        case "del":
            if let id = m["id"] as? String { MediaStore.remove(id) }
            replyHandler(true, nil)
        default: replyHandler(nil, "operazione sconosciuta")
        }
    }

    func notifyControl() {
        control?.evaluateJavaScript("window.nativeMonitor&&window.nativeMonitor(\(monitorAttached ? "true" : "false"))", completionHandler: nil)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let v = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?"
        let b = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "?"
        webView.evaluateJavaScript("window.nativeVer='\(v) (\(b))';window.nativeReady&&window.nativeReady()", completionHandler: nil)
        notifyControl()
    }

    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) { webView.reload() }

    func monitorDidDisconnect() { monitorAttached = false; notifyControl() }
}

final class WebVC: UIViewController {
    let web: WKWebView
    init(web: WKWebView) { self.web = web; super.init(nibName: nil, bundle: nil) }
    required init?(coder: NSCoder) { fatalError() }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        web.frame = view.bounds
        web.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(web)
    }
}

/// Serve la pagina: copia scaricata se più recente, altrimenti quella inclusa nell'app.
final class PageScheme: NSObject, WKURLSchemeHandler {
    func webView(_ webView: WKWebView, start task: WKURLSchemeTask) {
        let fm = FileManager.default
        let bundled = Bundle.main.url(forResource: "index", withExtension: "html")
        func mdate(_ u: URL?) -> Date { guard let u = u, let a = try? fm.attributesOfItem(atPath: u.path) else { return .distantPast }; return (a[.modificationDate] as? Date) ?? .distantPast }
        let appDate = max(mdate(bundled), mdate(Bundle.main.executableURL))
        var data: Data? = nil
        if fm.fileExists(atPath: Bridge.local.path), mdate(Bridge.local) > appDate { data = try? Data(contentsOf: Bridge.local) }
        if data == nil, let b = bundled { data = try? Data(contentsOf: b) }
        let body = data ?? Data("<h1>Pagina mancante</h1>".utf8)
        let resp = HTTPURLResponse(url: task.request.url!, statusCode: 200, httpVersion: "HTTP/1.1",
                                   headerFields: ["Content-Type": "text/html; charset=utf-8", "Cache-Control": "no-store"])!
        task.didReceive(resp); task.didReceive(body); task.didFinish()
    }
    func webView(_ webView: WKWebView, stop task: WKURLSchemeTask) {}
}

extension Bridge: WKUIDelegate {
    private func topVC(_ w: WKWebView) -> UIViewController? {
        var vc = w.window?.rootViewController
        while let p = vc?.presentedViewController { vc = p }
        return vc
    }
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        guard let vc = topVC(webView) else { completionHandler(); return }
        let a = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default) { _ in completionHandler() })
        vc.present(a, animated: true)
    }
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        guard let vc = topVC(webView) else { completionHandler(false); return }
        let a = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "Annulla", style: .cancel) { _ in completionHandler(false) })
        a.addAction(UIAlertAction(title: "OK", style: .default) { _ in completionHandler(true) })
        vc.present(a, animated: true)
    }
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        guard let vc = topVC(webView) else { completionHandler(nil); return }
        let a = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)
        a.addTextField { $0.text = defaultText }
        a.addAction(UIAlertAction(title: "Annulla", style: .cancel) { _ in completionHandler(nil) })
        a.addAction(UIAlertAction(title: "OK", style: .default) { _ in completionHandler(a.textFields?.first?.text) })
        vc.present(a, animated: true)
    }
}
