import UIKit
import WebKit
import AVFoundation

/// Collega la pagina di controllo (iPhone) alla pagina "monitor" (schermo esterno).
final class Bridge: NSObject, WKScriptMessageHandler, WKScriptMessageHandlerWithReply, WKNavigationDelegate {
    static let shared = Bridge()
    /// Pagina servita dall'app stessa (funziona senza internet).
    static let base = URL(string: "arnoshow://app/index.html")!
    /// Da qui l'app scarica in silenzio l'ultima versione della pagina (prova).
    static let remote = URL(string: "https://raw.githubusercontent.com/maarnone52-oss/Prove/main/arnoshow/index.html")!
    static let local: URL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent("index.html")

    /// Scarica la pagina aggiornata: verrà usata dalla prossima apertura dell'app.
    static func updatePage() {
        var r = URLRequest(url: remote, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 20)
        r.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        URLSession.shared.dataTask(with: r) { d, resp, _ in
            guard let d = d, (resp as? HTTPURLResponse)?.statusCode == 200,
                  let t = String(data: d, encoding: .utf8), t.contains("ArnoShow"), t.contains("</html>") else { return }
            try? FileManager.default.createDirectory(at: local.deletingLastPathComponent(), withIntermediateDirectories: true)
            try? d.write(to: local, options: .atomic)
        }.resume()
    }

    var control: WKWebView?
    var monitor: WKWebView?
    var monitorVC: MonitorVC?
    var monitorAttached = false
    var monitorReady = false

    func makeWebView(monitorMode: Bool) -> WKWebView {
        let c = WKWebViewConfiguration()
        c.allowsInlineMediaPlayback = true
        c.mediaTypesRequiringUserActionForPlayback = []
        c.websiteDataStore = WKWebsiteDataStore.default()
        c.setURLSchemeHandler(PageScheme(), forURLScheme: "arnoshow")
        if !monitorMode {
            c.userContentController.add(self, name: "mon")
            c.userContentController.add(self, name: "live")
            c.userContentController.addScriptMessageHandler(self, contentWorld: .page, name: "store")
        }
        let w = WKWebView(frame: .zero, configuration: c)
        w.navigationDelegate = self
        w.isOpaque = false
        w.backgroundColor = .black
        w.scrollView.backgroundColor = .black
        w.scrollView.contentInsetAdjustmentBehavior = .never
        w.scrollView.bounces = false
        var u = URLComponents(url: Bridge.base, resolvingAgainstBaseURL: false)!
        if monitorMode { u.queryItems = [URLQueryItem(name: "monitor", value: "1")] }
        w.load(URLRequest(url: u.url!))
        if !monitorMode { startStats() }
        return w
    }

    // Messaggio dalla pagina di controllo -> inoltrato alla pagina monitor
    // Live dalla fotocamera di questo dispositivo: {on, cam:"back"/"front", xf, rect:{x,y,w,h}}
    let liveView = LiveView()
    private var liveOn = false
    func handleLive(_ m: [String: Any]) {
        if let r = m["rect"] as? [String: Any], let x = r["x"] as? Double, let y = r["y"] as? Double, let w = r["w"] as? Double, let h = r["h"] as? Double {
            liveView.frame = CGRect(x: x, y: y, width: w, height: h)
        }
        if let c = m["radius"] as? Double { liveView.layer.cornerRadius = c }
        guard let on = m["on"] as? Bool else { return }
        let xf = max(0.001, (m["xf"] as? Double) ?? 0)
        if on {
            let pos: AVCaptureDevice.Position = (m["cam"] as? String) == "front" ? .front : .back
            if liveView.superview == nil, let host = control?.superview { host.addSubview(liveView) }
            LiveCamera.shared.addSink(liveView.disp)
            LiveCamera.shared.start(position: pos) { ok in
                if !ok { self.control?.evaluateJavaScript("window.liveDenied&&window.liveDenied()", completionHandler: nil); return }
                self.liveView.isHidden = false
                UIView.animate(withDuration: xf) { self.liveView.alpha = 1 }
            }
            liveOn = true
        } else if liveOn {
            liveOn = false
            UIView.animate(withDuration: xf, animations: { self.liveView.alpha = 0 }) { _ in
                if !self.liveOn { self.liveView.isHidden = true; if !(self.monitorVC?.liveShown ?? false) { LiveCamera.shared.stop() } }
            }
        }
    }

    func userContentController(_ ucc: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "live" {
            if let json = message.body as? String, let d = json.data(using: .utf8), let m = (try? JSONSerialization.jsonObject(with: d)) as? [String: Any] { handleLive(m) }
            return
        }
        guard let json = message.body as? String, monitorReady,
              let d = json.data(using: .utf8),
              let m = (try? JSONSerialization.jsonObject(with: d)) as? [String: Any] else { return }
        monitorVC?.handle(m)
    }

    // Archivio dei file per il monitor: la pagina chiede quali file ci sono e manda quelli che mancano, a pezzi
    func userContentController(_ ucc: WKUserContentController, didReceive message: WKScriptMessage, replyHandler: @escaping (Any?, String?) -> Void) {
        guard let m = message.body as? [String: Any], let op = m["op"] as? String else { replyHandler(nil, "messaggio non valido"); return }
        switch op {
        case "has":
            let ids = (m["ids"] as? [String]) ?? []
            replyHandler(ids.filter { MediaStore.has($0) }, nil)
        case "put":
            guard let id = m["id"] as? String, let b64 = m["b64"] as? String, let data = Data(base64Encoded: b64) else { replyHandler(nil, "dati non validi"); return }
            let seq = (m["seq"] as? Int) ?? 0, last = (m["last"] as? Bool) ?? false, ext = (m["ext"] as? String) ?? "mov"
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

    // Dice alla pagina di controllo se il monitor è collegato e pronto
    func notifyControl() {
        let on = monitorAttached && monitorReady
        control?.evaluateJavaScript("window.nativeMonitor&&window.nativeMonitor(\(on ? "true" : "false"))", completionHandler: nil)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if webView === control {
            let v = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?"
            let b = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "?"
            webView.evaluateJavaScript("window.nativeVer='\(v) (\(b))'", completionHandler: nil)
        }
        if webView === monitor { monitorReady = true }
        notifyControl()
    }

    // Se iOS chiude la pagina del monitor per mancanza di memoria, la si ricarica subito
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        if webView === monitor { monitorReady = false; notifyControl() }
        webView.reload()
    }

    // Diagnostica: ogni 3 secondi temperatura, memoria e fotogrammi persi sul monitor
    private var statsTimer: Timer?
    func startStats() {
        statsTimer?.invalidate()
        statsTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let th: Int
            switch ProcessInfo.processInfo.thermalState { case .nominal: th = 0; case .fair: th = 1; case .serious: th = 2; case .critical: th = 3; @unknown default: th = 0 }
            var info = task_vm_info_data_t(); var count = mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.size / MemoryLayout<natural_t>.size)
            let kr = withUnsafeMutablePointer(to: &info) { $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &count) } }
            let mem = kr == KERN_SUCCESS ? Int(info.phys_footprint / 1_048_576) : -1
            let dropped = self.monitorVC?.droppedFrames() ?? -1
            self.control?.evaluateJavaScript("window.nativeStats&&window.nativeStats({th:\(th),mem:\(mem),mdrop:\(dropped)})", completionHandler: nil)
        }
    }

    func monitorDidDisconnect() {
        monitor = nil
        monitorAttached = false
        monitorReady = false
        notifyControl()
    }
}

/// Contenitore a tutto schermo per una pagina web.
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

/// Serve la pagina: copia scaricata se c'è, altrimenti quella inclusa nell'app.
final class PageScheme: NSObject, WKURLSchemeHandler {
    func webView(_ webView: WKWebView, start task: WKURLSchemeTask) {
        let fm = FileManager.default
        // si usa la copia scaricata solo se è più recente di quella dentro l'app (dopo un aggiornamento TestFlight vale quella nuova)
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
