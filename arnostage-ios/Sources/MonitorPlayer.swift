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
    static func safeName(_ s: String) -> String { let b = s.components(separatedBy: CharacterSet(charactersIn: "/\\:?*\"<>|")).joined(separator: "-").trimmingCharacters(in: .whitespaces); return b.isEmpty ? "Progetto" : String(b.prefix(80)) }
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

/// Un solo lettore video (decodifica una volta) che disegna sia sull'anteprima dell'iPhone/iPad sia sul monitor HDMI.
/// Il video è caricato SENZA traccia audio: l'audio esce solo dal motore di ArnoStage e non viene disturbato.
final class VideoHub {
    static let shared = VideoHub()
    let player = AVPlayer()
    var monitorLayer: AVPlayerLayer?
    var previewLayer: AVPlayerLayer?
    private var curId: String?
    private var pending: [String: Any]?
    private var lastState: [String: Any]?
    private var ended = false
    private var loading = false
    var monitorEnabled = true { didSet { apply() } }

    init() {
        player.isMuted = true
        player.automaticallyWaitsToMinimizeStalling = false
        player.actionAtItemEnd = .pause
    }
    func makeLayer() -> AVPlayerLayer { let l = AVPlayerLayer(player: player); l.videoGravity = .resizeAspect; l.backgroundColor = UIColor.black.cgColor; return l }

    private func apply() {
        CATransaction.begin(); CATransaction.setDisableActions(true)
        monitorLayer?.isHidden = ended || !monitorEnabled || curId == nil
        previewLayer?.isHidden = ended || curId == nil
        CATransaction.commit()
    }

    func handle(_ m: [String: Any]) {
        switch m["t"] as? String ?? "" {
        case "show": show(m)
        case "state": lastState = m; if !loading { state(m) }
        case "hdmi": monitorEnabled = (m["on"] as? Bool) ?? true
        default: black()
        }
    }
    func fileArrived(_ id: String) { if let p = pending, (p["id"] as? String) == id { pending = nil; show(p) } }

    private func black() { player.pause(); player.replaceCurrentItem(with: nil); curId = nil; pending = nil; ended = false; apply() }

    private func show(_ m: [String: Any]) {
        guard let id = m["id"] as? String else { black(); return }
        if id == curId { state(m); return }
        guard let u = MediaStore.url(for: id) else { pending = m; return }
        pending = nil; curId = id; ended = false; loading = true; lastState = m
        player.pause(); player.replaceCurrentItem(with: nil); apply()
        VideoHub.videoOnlyItem(u) { [weak self] item in
            guard let self = self, self.curId == id else { return }
            self.player.replaceCurrentItem(with: item)
            self.loading = false
            self.apply()
            var so: NSKeyValueObservation?
            so = item.observe(\.status, options: [.new]) { [weak self] it, _ in
                guard it.status == .readyToPlay else { return }
                so?.invalidate(); so = nil
                DispatchQueue.main.async {
                    guard let self = self, self.player.currentItem === it else { return }
                    var st = self.lastState ?? m; st["seek"] = true
                    self.state(st)
                }
            }
        }
    }

    /// Stessa regolazione di ArnoShow: sotto 0,25 s non si tocca nulla, poi si recupera piano; salto solo se molto fuori.
    private func state(_ m: [String: Any]) {
        guard curId != nil, let item = player.currentItem, item.status == .readyToPlay else { return }
        let t = (m["time"] as? Double) ?? 0
        let vd = item.duration.seconds
        let isEnd = vd.isFinite && vd > 0 && t >= vd - 0.05
        if isEnd != ended { ended = isEnd; apply() }
        if isEnd { if player.rate != 0 { player.pause() }; return }
        let playing = ((m["playing"] as? Bool) ?? false) && t >= 0
        let now = player.currentTime().seconds
        let tt = max(0, t)
        if !playing {
            if player.rate != 0 { player.pause() }
            if now.isFinite, abs(now - tt) > 0.15 { player.seek(to: CMTime(seconds: tt, preferredTimescale: 600), toleranceBefore: .zero, toleranceAfter: .zero) }
            return
        }
        guard now.isFinite else { return }
        let d = now - t
        if (m["seek"] as? Bool) == true || abs(d) > 2.0 || player.rate == 0 {
            player.pause()
            player.seek(to: CMTime(seconds: tt + 0.1, preferredTimescale: 600), toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] _ in
                DispatchQueue.main.async { self?.player.rate = 1 }
            }
        } else if abs(d) > 0.25 {
            let r = Float(1 - max(-0.04, min(0.04, d * 0.3)))
            if abs(player.rate - r) > 0.01 { player.rate = r }
        } else if abs(d) < 0.06 && player.rate != 1 { player.rate = 1 }
    }

    /// Solo la traccia video del file (niente audio da decodificare).
    static func videoOnlyItem(_ u: URL, done: @escaping (AVPlayerItem) -> Void) {
        let a = AVURLAsset(url: u)
        Task {
            var item = AVPlayerItem(asset: a)
            if let vt = try? await a.loadTracks(withMediaType: .video).first, let dur = try? await a.load(.duration) {
                let comp = AVMutableComposition()
                if let ct = comp.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid),
                   (try? ct.insertTimeRange(CMTimeRange(start: .zero, duration: dur), of: vt, at: .zero)) != nil {
                    ct.preferredTransform = (try? await vt.load(.preferredTransform)) ?? .identity
                    item = AVPlayerItem(asset: comp)
                }
            }
            let it = item
            await MainActor.run { done(it) }
        }
    }
}

/// Schermo esterno (HDMI): il livello video del lettore condiviso, a tutto schermo.
final class MonitorVC: UIViewController {
    private var layer: AVPlayerLayer!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        layer = VideoHub.shared.makeLayer()
        view.layer.addSublayer(layer)
        VideoHub.shared.monitorLayer = layer
        VideoHub.shared.monitorEnabled = VideoHub.shared.monitorEnabled
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        CATransaction.begin(); CATransaction.setDisableActions(true); layer.frame = view.bounds; CATransaction.commit()
    }
    override var prefersHomeIndicatorAutoHidden: Bool { true }
    deinit { if VideoHub.shared.monitorLayer === layer { VideoHub.shared.monitorLayer = nil } }
}

/// Anteprima sopra la pagina, nel riquadro del video: stesso lettore, nessuna seconda decodifica.
final class PreviewView: UIView {
    private let pl: AVPlayerLayer
    override init(frame: CGRect) {
        pl = VideoHub.shared.makeLayer()
        super.init(frame: frame)
        isUserInteractionEnabled = false
        clipsToBounds = true
        layer.cornerRadius = 10
        backgroundColor = .clear
        layer.addSublayer(pl)
        VideoHub.shared.previewLayer = pl
        isHidden = true
    }
    required init?(coder: NSCoder) { fatalError() }
    /// clip = parte visibile; r = riquadro intero (coordinate della pagina)
    func place(_ m: [String: Any]) {
        let n: (String) -> CGFloat = { CGFloat((m[$0] as? NSNumber)?.doubleValue ?? 0) }
        let on = (m["on"] as? Bool) ?? false
        let clip = CGRect(x: n("cx"), y: n("cy"), width: n("cw"), height: n("ch"))
        let r = CGRect(x: n("x"), y: n("y"), width: n("w"), height: n("h"))
        isHidden = !on || clip.width < 4 || clip.height < 4
        CATransaction.begin(); CATransaction.setDisableActions(true)
        frame = clip
        pl.frame = r.offsetBy(dx: -clip.minX, dy: -clip.minY)
        CATransaction.commit()
    }
}
