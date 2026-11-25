import UIKit
import AVFoundation

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // L'audio esce anche con il tasto silenzioso attivo e passa dal cavo HDMI.
        // «mixWithOthers»: i lettori nativi del monitor (muti) non devono interrompere l'audio/video della pagina sull'iPhone
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: [.mixWithOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
        Bridge.updatePage()
        return true
    }
}
