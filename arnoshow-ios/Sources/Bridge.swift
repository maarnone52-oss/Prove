import UIKit
import WebKit

/// Collega la pagina di controllo (iPhone) alla pagina "monitor" (schermo esterno).
final class Bridge: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
    static let shared = Bridge()
    /// Pagina ospitata (versione di prova). Per la definitiva si cambierà solo questo indirizzo.
    static let base = URL(string: "https://maarnone52-oss.github.io/Prove/arnoshow/")!

    var control: WKWebView?
    var monitor: WKWebView?
    var monitorAttached = false
    var monitorReady = false

    func makeWebView(monitorMode: Bool) -> WKWebView {
        let c = WKWebViewConfiguration()
        c.allowsInlineMediaPlayback = true
        c.mediaTypesRequiringUserActionForPlayback = []
        c.websiteDataStore = WKWebsiteDataStore.default()
        if !monitorMode { c.userContentController.add(self, name: "mon") }
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
        return w
    }

    // Messaggio dalla pagina di controllo -> inoltrato alla pagina monitor
    func userContentController(_ ucc: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let json = message.body as? String, monitorReady else { return }
        monitor?.evaluateJavaScript("window.monitorCmd&&window.monitorCmd(\(json))", completionHandler: nil)
    }

    // Dice alla pagina di controllo se il monitor è collegato e pronto
    func notifyControl() {
        let on = monitorAttached && monitorReady
        control?.evaluateJavaScript("window.nativeMonitor&&window.nativeMonitor(\(on ? "true" : "false"))", completionHandler: nil)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if webView === monitor { monitorReady = true }
        notifyControl()
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
