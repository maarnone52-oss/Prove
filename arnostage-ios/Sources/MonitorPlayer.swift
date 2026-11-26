import UIKit
import AVFoundation

/// Archivio dei file (tracce audio e video) nella memoria dell'app.
enum MediaStore {
    static let dir: URL = {
        let d = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent("media", isDirectory: true)
        try? FileManager.default.createDirectory(at: d, withIntermediateDirectories: true)
        return d
    }()
    static func safe(_ s: String) -> String { String(s.unicodeScalars.filter { CharacterSet.alphanumerics.contains($0) || $0 == "-" || $0 == "_" }) }
    static func url(for id: String) -> URL? {
        let p = safe(id) + "."
        let list = (try? FileManager.default.contentsOfDirectory(atPath: dir.path)) ?? []
        guard let n = list.first(where: { $0.hasPrefix(p) && !$0.hasSuffix(".part") }) else { return nil }
        return dir.appendingPathComponent(n)
    }
    static func has(_ id: String) -> Bool { url(for: id) != nil }
    static func remove(_ id: String) { if let u = url(for: id) { try? FileManager.default.removeItem(at: u) } }
    static func append(id: String, ext: String, seq: Int, last: Bool, data: Data) -> Bool {
        let part = dir.appendingPathComponent(safe(id) + ".part")
        if seq == 0 { try? FileManager.default.removeItem(at: part); FileManager.default.createFile(atPath: part.path, contents: nil) }
        guard let h = try? FileHandle(forWritingTo: part) else { return false }
        h.seekToEndOfFile(); h.write(data); try? h.close()
        if last {
            remove(id)
            let e = safe(ext).isEmpty ? "bin" : safe(ext).lowercased()
            try? FileManager.default.moveItem(at: part, to: dir.appendingPathComponent(safe(id) + "." + e))
        }
        return true
    }
}

/// Schermo esterno (HDMI): il video del brano, muto, a tempo con l'audio. Nessuna dissolvenza né elaborazione.
final class MonitorVC: UIViewController {
    private let player = AVPlayer()
    private var layer: AVPlayerLayer!
    private let info = UILabel()
    private var curId: String?
    private var pending: [String: Any]?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        player.isMuted = true
        player.automaticallyWaitsToMinimizeStalling = false
        player.actionAtItemEnd = .pause
        layer = AVPlayerLayer(player: player)
        layer.videoGravity = .resizeAspect
        view.layer.addSublayer(layer)
        info.textColor = UIColor(white: 1, alpha: 0.5)
        info.font = .systemFont(ofSize: 22, weight: .semibold)
        info.textAlignment = .center
        info.numberOfLines = 0
        info.frame = view.bounds
        info.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        info.text = "ArnoStage · monitor collegato"
        view.addSubview(info)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        CATransaction.begin(); CATransaction.setDisableActions(true); layer.frame = view.bounds; CATransaction.commit()
    }
    override var prefersHomeIndicatorAutoHidden: Bool { true }

    func handle(_ m: [String: Any]) {
        switch m["t"] as? String ?? "" {
        case "show": show(m)
        case "state": state(m)
        default: black()
        }
    }

    func fileArrived(_ id: String) {
        if let p = pending, (p["id"] as? String) == id { pending = nil; show(p) }
    }

    private func black() {
        player.pause(); player.replaceCurrentItem(with: nil)
        curId = nil; pending = nil
        info.text = ""; info.isHidden = true
    }

    private func show(_ m: [String: Any]) {
        guard let id = m["id"] as? String else { black(); return }
        if id == curId { state(m); return }
        guard let u = MediaStore.url(for: id) else { pending = m; info.text = "Preparo il video per il monitor…"; info.isHidden = false; return }
        pending = nil; info.isHidden = true
        player.replaceCurrentItem(with: MonitorVC.silentItem(u))
        curId = id
        let t = (m["time"] as? Double) ?? 0
        player.seek(to: CMTime(seconds: max(0, t), preferredTimescale: 600), toleranceBefore: .zero, toleranceAfter: .zero)
        if (m["playing"] as? Bool) == true && t >= 0 { player.play() }
    }

    /// Segue il tempo dell'audio: piccoli scarti si recuperano piano, grandi con un salto.
    private func state(_ m: [String: Any]) {
        guard curId != nil, player.currentItem != nil else { return }
        let t = (m["time"] as? Double) ?? 0
        let playing = ((m["playing"] as? Bool) ?? false) && t >= 0
        let now = player.currentTime().seconds
        let tt = max(0, t)
        if !playing {
            if player.rate != 0 { player.pause() }
            if now.isFinite, abs(now - tt) > 0.08 { player.seek(to: CMTime(seconds: tt, preferredTimescale: 600), toleranceBefore: .zero, toleranceAfter: .zero) }
            return
        }
        guard now.isFinite else { return }
        let d = now - t
        if (m["seek"] as? Bool) == true || abs(d) > 1.0 || player.rate == 0 {
            player.pause()
            player.seek(to: CMTime(seconds: tt, preferredTimescale: 600), toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] _ in
                DispatchQueue.main.async { self?.player.preroll(atRate: 1) { _ in DispatchQueue.main.async { self?.player.rate = 1 } } }
            }
        } else if abs(d) > 0.04 {
            let r = Float(1 - max(-0.05, min(0.05, d * 0.5)))
            if abs(player.rate - r) > 0.005 { player.rate = r }
        } else if player.rate != 1 { player.rate = 1 }
    }

    /// Elemento senza audio: l'audio esce solo dal motore di ArnoStage.
    static func silentItem(_ u: URL) -> AVPlayerItem {
        let it = AVPlayerItem(url: u)
        it.audioTimePitchAlgorithm = .varispeed
        let mix = AVMutableAudioMix()
        it.audioMix = mix
        Task { @MainActor in
            if let tracks = try? await it.asset.loadTracks(withMediaType: .audio) {
                mix.inputParameters = tracks.map { t in let p = AVMutableAudioMixInputParameters(track: t); p.setVolume(0, at: .zero); return p }
                it.audioMix = mix
            }
        }
        return it
    }
}
