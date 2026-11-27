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
    weak var webVC: WebVC?
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
        if (m["t"] as? String) == "rect" { webVC?.preview.place(m); return }
        VideoHub.shared.handle(m)
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
                    if ok && last { VideoHub.shared.fileArrived(id) }
                    replyHandler(ok, ok ? nil : "scrittura non riuscita")
                }
            }
        case "export":   // crea il .zip del progetto e apre Condividi (AirDrop, Messaggi, File…)
            let name = MediaStore.safeName((m["name"] as? String) ?? "Progetto")
            let json = (m["json"] as? String) ?? "{}"
            let files = (m["files"] as? [[String: String]]) ?? []
            DispatchQueue.global(qos: .userInitiated).async {
                var last = Date.distantPast
                let url = ZipOut.make(name: name, json: json, files: files) { done, total, file in
                    let now = Date(); if now.timeIntervalSince(last) < 0.15 && done < total { return }; last = now
                    let f = file.replacingOccurrences(of: "\\", with: "").replacingOccurrences(of: "'", with: "\\'")
                    DispatchQueue.main.async { self.control?.evaluateJavaScript("window.zipProg&&window.zipProg(\(done),\(total),'\(f)')", completionHandler: nil) }
                }
                DispatchQueue.main.async {
                    guard let url = url else { replyHandler(false, "zip non riuscito"); return }
                    self.share(url)
                    replyHandler(true, nil)
                }
            }
        case "extract":   // estrae solo l'audio di un video in .m4a (per l'esportazione «solo audio»)
            guard let id = m["id"] as? String, let nid = m["nid"] as? String, let u = MediaStore.url(for: id) else { replyHandler(nil, "file mancante"); return }
            if let e = MediaStore.url(for: nid) {
                let sz = ((try? FileManager.default.attributesOfItem(atPath: e.path))?[.size] as? NSNumber)?.doubleValue ?? 0
                replyHandler(["ok": true, "size": sz], nil); return
            }
            guard let ex = AVAssetExportSession(asset: AVURLAsset(url: u), presetName: AVAssetExportPresetAppleM4A) else { replyHandler(nil, "estrazione non disponibile"); return }
            let out = MediaStore.dir.appendingPathComponent(MediaStore.safe(nid) + ".m4a.part")
            try? FileManager.default.removeItem(at: out)
            ex.outputURL = out; ex.outputFileType = .m4a
            ex.exportAsynchronously {
                DispatchQueue.main.async {
                    guard ex.status == .completed else { try? FileManager.default.removeItem(at: out); replyHandler(nil, ex.error?.localizedDescription ?? "estrazione non riuscita"); return }
                    let fin = MediaStore.dir.appendingPathComponent(MediaStore.safe(nid) + ".m4a")
                    try? FileManager.default.removeItem(at: fin)
                    try? FileManager.default.moveItem(at: out, to: fin)
                    let sz = ((try? FileManager.default.attributesOfItem(atPath: fin.path))?[.size] as? NSNumber)?.doubleValue ?? 0
                    replyHandler(["ok": true, "size": sz], nil)
                }
            }
        case "del":
            if let id = m["id"] as? String { MediaStore.remove(id) }
            replyHandler(true, nil)
        default: replyHandler(nil, "operazione sconosciuta")
        }
    }

    func share(_ url: URL) {
        guard let vc = webVC else { return }
        let a = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        if let pop = a.popoverPresentationController { pop.sourceView = vc.view; pop.sourceRect = CGRect(x: vc.view.bounds.midX, y: 60, width: 1, height: 1) }
        var top: UIViewController = vc
        while let p = top.presentedViewController { top = p }
        top.present(a, animated: true)
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
    let preview = PreviewView(frame: .zero)
    init(web: WKWebView) { self.web = web; super.init(nibName: nil, bundle: nil) }
    required init?(coder: NSCoder) { fatalError() }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        web.frame = view.bounds
        web.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(web)
        web.addSubview(preview)   // sopra la pagina, segue il riquadro del video
        Bridge.shared.webVC = self
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

/// Scrive un .zip «senza compressione» (i file audio/video sono già compressi o grandi): arnostage.json + media/.
enum ZipOut {
    private static let table: [UInt32] = (0..<256).map { i -> UInt32 in
        var c = UInt32(i); for _ in 0..<8 { c = (c & 1) != 0 ? 0xEDB88320 ^ (c >> 1) : c >> 1 }; return c
    }
    static func crc(_ u: URL, _ step: (Int) -> Void = { _ in }) -> (UInt32, UInt64)? {
        guard let h = try? FileHandle(forReadingFrom: u) else { return nil }
        defer { try? h.close() }
        var c: UInt32 = 0xFFFFFFFF, n: UInt64 = 0
        while true {
            let d = h.readData(ofLength: 4 << 20); if d.isEmpty { break }
            n += UInt64(d.count); step(d.count)
            d.withUnsafeBytes { (p: UnsafeRawBufferPointer) in for b in p { c = table[Int((c ^ UInt32(b)) & 0xFF)] ^ (c >> 8) } }
        }
        return (c ^ 0xFFFFFFFF, n)
    }
    static func make(name: String, json: String, files: [[String: String]], progress: (UInt64, UInt64, String) -> Void = { _, _, _ in }) -> URL? {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent("export", isDirectory: true)
        try? FileManager.default.removeItem(at: dir)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let jsonURL = dir.appendingPathComponent("arnostage.json")
        guard (try? json.data(using: .utf8)!.write(to: jsonURL)) != nil else { return nil }
        var entries: [(String, URL)] = [("arnostage.json", jsonURL)]
        for f in files { if let id = f["id"], let path = f["path"], let u = MediaStore.url(for: id) { entries.append((path, u)) } }
        var total: UInt64 = 0
        for (_, u) in entries { total += UInt64(((try? FileManager.default.attributesOfItem(atPath: u.path))?[.size] as? NSNumber)?.uint64Value ?? 0) }
        total *= 2   // lettura per il controllo + scrittura
        var done: UInt64 = 0
        let out = dir.appendingPathComponent(name + ".arnostage.zip")
        FileManager.default.createFile(atPath: out.path, contents: nil)
        guard let w = try? FileHandle(forWritingTo: out) else { return nil }
        defer { try? w.close() }
        var central = Data(), off: UInt64 = 0
        func le16(_ v: Int) -> Data { var x = UInt16(truncatingIfNeeded: v).littleEndian; return Data(bytes: &x, count: 2) }
        func le32(_ v: UInt64) -> Data { var x = UInt32(truncatingIfNeeded: v).littleEndian; return Data(bytes: &x, count: 4) }
        for (path, u) in entries {
            let fname = (path as NSString).lastPathComponent
            guard let (c, size) = crc(u, { done += UInt64($0); progress(done, total, fname) }) else { continue }
            if off > 0xFFFF_FFF0 || size > 0xFFFF_FFF0 { return nil }  // oltre 4 GB non supportato
            let nm = Data(path.utf8)
            var lh = Data(); lh += le32(0x04034b50); lh += le16(20); lh += le16(0x0800); lh += le16(0); lh += le16(0); lh += le16(0x21)
            lh += le32(UInt64(c)); lh += le32(size); lh += le32(size); lh += le16(nm.count); lh += le16(0); lh += nm
            w.write(lh)
            if let r = try? FileHandle(forReadingFrom: u) {
                while true { let d = r.readData(ofLength: 4 << 20); if d.isEmpty { break }; w.write(d); done += UInt64(d.count); progress(done, total, fname) }
                try? r.close()
            }
            var ch = Data(); ch += le32(0x02014b50); ch += le16(20); ch += le16(20); ch += le16(0x0800); ch += le16(0); ch += le16(0); ch += le16(0x21)
            ch += le32(UInt64(c)); ch += le32(size); ch += le32(size); ch += le16(nm.count); ch += le16(0); ch += le16(0); ch += le16(0); ch += le16(0)
            ch += le32(0); ch += le32(off); ch += nm
            central += ch
            off += UInt64(lh.count) + size
        }
        var end = Data(); end += le32(0x06054b50); end += le16(0); end += le16(0); end += le16(entries.count); end += le16(entries.count)
        end += le32(UInt64(central.count)); end += le32(off); end += le16(0)
        w.write(central); w.write(end)
        return out
    }
}
