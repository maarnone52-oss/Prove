import UIKit

/// Schermo dell'iPhone: la pagina di controllo.
class MainSceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options: UIScene.ConnectionOptions) {
        guard let ws = scene as? UIWindowScene else { return }
        let w = UIWindow(windowScene: ws)
        let web = Bridge.shared.makeWebView(monitorMode: false)
        Bridge.shared.control = web
        w.rootViewController = WebVC(web: web)
        w.makeKeyAndVisible()
        window = w
    }
}

/// Schermo esterno (cavo HDMI): solo il video, a tutto schermo.
class MonitorSceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options: UIScene.ConnectionOptions) {
        guard let ws = scene as? UIWindowScene else { return }
        let w = UIWindow(windowScene: ws)
        let web = Bridge.shared.makeWebView(monitorMode: true)
        Bridge.shared.monitor = web
        Bridge.shared.monitorAttached = true
        Bridge.shared.monitorReady = false
        w.rootViewController = WebVC(web: web)
        w.isHidden = false
        window = w
    }
    func sceneDidDisconnect(_ scene: UIScene) {
        window = nil
        Bridge.shared.monitorDidDisconnect()
    }
}
