import UIKit

/// Schermo dell'iPhone/iPad: la pagina di controllo.
class MainSceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options: UIScene.ConnectionOptions) {
        guard let ws = scene as? UIWindowScene else { return }
        let w = UIWindow(windowScene: ws)
        let web = Bridge.shared.makeWebView()
        Bridge.shared.control = web
        w.rootViewController = WebVC(web: web)
        w.makeKeyAndVisible()
        window = w
    }
    /// copertura nera: l'istantanea che iOS mostra alla riapertura non contiene la schermata precedente
    private var cover: UIView?
    func sceneWillResignActive(_ scene: UIScene) { addCover() }
    func sceneDidEnterBackground(_ scene: UIScene) {
        addCover()
        Bridge.shared.control?.evaluateJavaScript("window.appBackground&&window.appBackground()", completionHandler: nil)
    }
    func sceneDidBecomeActive(_ scene: UIScene) {
        Bridge.shared.control?.evaluateJavaScript("window.appResume&&window.appResume()", completionHandler: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            UIView.animate(withDuration: 0.2, animations: { self?.cover?.alpha = 0 }) { _ in self?.cover?.removeFromSuperview(); self?.cover = nil }
        }
    }
    private func addCover() {
        guard cover == nil, let w = window else { return }
        let v = UIView(frame: w.bounds); v.backgroundColor = .black; v.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        w.addSubview(v); cover = v
    }
}

/// Schermo esterno (cavo HDMI): solo il video, a tutto schermo.
class MonitorSceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options: UIScene.ConnectionOptions) {
        guard let ws = scene as? UIWindowScene else { return }
        let w = UIWindow(windowScene: ws)
        let vc = MonitorVC()
        Bridge.shared.monitorVC = vc
        Bridge.shared.monitorAttached = true
        w.rootViewController = vc
        w.isHidden = false
        window = w
        Bridge.shared.notifyControl()
    }
    func sceneDidDisconnect(_ scene: UIScene) {
        window = nil
        Bridge.shared.monitorVC = nil
        Bridge.shared.monitorDidDisconnect()
    }
}
