import UIKit
import AVFoundation

/// Archivio dei file per il monitor: copia dei video/foto importati, nella memoria dell'app.
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
            let e = safe(ext).isEmpty ? "mov" : safe(ext).lowercased()
            try? FileManager.default.moveItem(at: part, to: dir.appendingPathComponent(safe(id) + "." + e))
        }
        return true
    }
}

/// Schermo esterno: lettore video nativo Apple (AVPlayer), due lettori a rotazione per passaggi puliti e dissolvenze.
final class MonitorVC: UIViewController {
    private let players = [AVPlayer(), AVPlayer()]
    private var layers: [AVPlayerLayer] = []
    private let img = UIImageView()
    private let info = UILabel()
    private var active = 0
    private var curId: String?
    private var preId: String?
    private var pending: [String: Any]?
    private var obs: [NSKeyValueObservation] = []
    private var token = 0
    private var transitioning = false
    private var pendingPre: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        for p in players {
            p.isMuted = true                       // l'audio esce dall'iPhone
            p.automaticallyWaitsToMinimizeStalling = false
            p.actionAtItemEnd = .pause
            let l = AVPlayerLayer(player: p)
            l.videoGravity = .resizeAspect
            l.backgroundColor = UIColor.clear.cgColor
            l.opacity = 0
            view.layer.addSublayer(l)
            layers.append(l)
        }
        img.contentMode = .scaleAspectFit
        img.isHidden = true
        img.frame = view.bounds
        img.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(img)
        info.textColor = UIColor(white: 1, alpha: 0.55)
        info.font = .systemFont(ofSize: 22, weight: .semibold)
        info.textAlignment = .center
        info.numberOfLines = 0
        info.frame = view.bounds
        info.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        info.text = "ArnoShow · monitor collegato\nTocca «Invia su HDMI» sull'iPhone"
        view.addSubview(info)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        CATransaction.begin(); CATransaction.setDisableActions(true)
        layers.forEach { $0.frame = view.bounds }
        CATransaction.commit()
    }
    override var prefersHomeIndicatorAutoHidden: Bool { true }

    func handle(_ m: [String: Any]) {
        switch m["t"] as? String ?? "" {
        case "show": show(m)
        case "state": state(m)
        case "pre": if let id = m["id"] as? String { preload(id) }
        default: black()
        }
    }

    /// Chiamato quando un file arriva nell'archivio: se il monitor lo stava aspettando, lo mostra.
    func fileArrived(_ id: String) {
        if let p = pending, (p["id"] as? String) == id { pending = nil; show(p) }
    }

    private func black() {
        token += 1
        players.forEach { $0.pause(); $0.replaceCurrentItem(with: nil) }
        setOpacity(layers[0], 0, 0); setOpacity(layers[1], 0, 0)
        img.isHidden = true; img.image = nil
        curId = nil; preId = nil; pending = nil; pendingPre = nil; transitioning = false
        info.isHidden = true
    }

    private func preload(_ id: String) {
        // durante un cambio il lettore libero è ancora quello uscente: si precarica appena il cambio è finito
        if transitioning { pendingPre = id; return }
        guard id != curId, id != preId, let u = MediaStore.url(for: id) else { return }
        let idx = 1 - active
        let p = players[idx]
        let item = MonitorVC.silentItem(u)
        p.replaceCurrentItem(with: item)
        p.pause()
        setOpacity(layers[idx], 0, 0)
        preId = id
        // «scalda» il decodificatore: preroll quando l'elemento è pronto
        var so: NSKeyValueObservation?
        so = item.observe(\.status, options: [.new]) { it, _ in
            if it.status == .readyToPlay { so?.invalidate(); so = nil; DispatchQueue.main.async { if p.currentItem === it, p.rate == 0 { p.preroll(atRate: 1, completionHandler: nil) } } }
        }
    }

    private func state(_ m: [String: Any]) {
        guard curId != nil, img.isHidden else { return }
        let p = players[active]
        let t = (m["time"] as? Double) ?? 0
        let playing = (m["playing"] as? Bool) ?? false
        let now = p.currentTime().seconds
        if !playing { if p.rate != 0 { p.pause() }; if now.isFinite, abs(now - t) > 0.15 { p.seek(to: CMTime(seconds: t, preferredTimescale: 600), toleranceBefore: .zero, toleranceAfter: .zero) }; return }
        guard now.isFinite else { return }
        let d = now - t
        if (m["seek"] as? Bool) == true || abs(d) > 2.0 {   // spostamento con la barra, o molto fuori tempo: si salta   // solo se molto fuori tempo si salta
            p.seek(to: CMTime(seconds: t, preferredTimescale: 600), toleranceBefore: .zero, toleranceAfter: .zero)
            p.rate = 1
        } else if abs(d) > 0.08 {   // altrimenti si recupera piano, senza scatti
            p.rate = Float(1 - max(-0.06, min(0.06, d * 0.5)))
        } else if p.rate != 1 { p.rate = 1 }
    }

    private func show(_ m: [String: Any]) {
        guard let id = m["id"] as? String else { return }
        let kind = m["kind"] as? String ?? "video"
        if id == curId { state(m); return }
        guard let u = MediaStore.url(for: id) else { pending = m; info.text = "Preparo il file per il monitor…"; info.isHidden = false; return }   // file non ancora copiato: arriva tra poco
        pending = nil
        info.isHidden = true
        token += 1
        let tk = token
        let xf = max(0, (m["xf"] as? Double) ?? 0)

        if kind == "photo" {
            let old = players[active]
            img.alpha = 0; img.image = UIImage(contentsOfFile: u.path); img.isHidden = false
            transitioning = true
            UIView.animate(withDuration: xf > 0 ? xf : 0.001, animations: { self.img.alpha = 1 }) { _ in
                guard tk == self.token else { return }
                old.pause(); self.setOpacity(self.layers[self.active], 0, 0)
                self.transitioning = false
                if let n = self.pendingPre { self.pendingPre = nil; self.preload(n) }
            }
            curId = id
            return
        }

        let idx = 1 - active
        let p = players[idx], l = layers[idx]
        let oldIdx = active
        if preId != id { p.replaceCurrentItem(with: MonitorVC.silentItem(u)) }
        preId = nil
        let t = (m["time"] as? Double) ?? 0
        if t > 0.3 { p.seek(to: CMTime(seconds: t, preferredTimescale: 600), toleranceBefore: .zero, toleranceAfter: .zero) }
        let playing = (m["playing"] as? Bool) ?? true
        if playing { p.play() }
        active = idx
        curId = id
        transitioning = true

        // si passa alla nuova clip quando ha l'immagine pronta e (se suona) sta davvero scorrendo
        var done = false
        let go: () -> Void = { [weak self] in
            guard let self = self, !done, tk == self.token else { return }
            done = true
            self.obs.removeAll()
            l.zPosition = 1; self.layers[oldIdx].zPosition = 0
            self.setOpacity(l, 1, xf)
            let fade = xf
            DispatchQueue.main.asyncAfter(deadline: .now() + fade + 0.05) {
                guard tk == self.token else { return }
                self.players[oldIdx].pause()
                self.setOpacity(self.layers[oldIdx], 0, 0)
                self.players[oldIdx].replaceCurrentItem(with: nil)
                if !self.img.isHidden { self.img.isHidden = true }
                self.transitioning = false
                if let n = self.pendingPre { self.pendingPre = nil; self.preload(n) }
            }
            if !self.img.isHidden { UIView.animate(withDuration: max(fade, 0.001)) { self.img.alpha = 0 } completion: { _ in if tk == self.token { self.img.isHidden = true; self.img.alpha = 1 } } }
        }
        let start = p.currentTime().seconds.isFinite ? p.currentTime().seconds : 0
        var tobs: Any?
        let check: () -> Void = {
            guard l.isReadyForDisplay else { return }
            if !playing { DispatchQueue.main.async(execute: go); return }
            let c = p.currentTime().seconds
            if p.timeControlStatus == .playing, c.isFinite, c - start > 0.12 { DispatchQueue.main.async(execute: go) }
        }
        tobs = p.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 60), queue: .main) { _ in check() }
        let cleanupObs = { if let o = tobs { p.removeTimeObserver(o); tobs = nil } }
        obs = [l.observe(\.isReadyForDisplay, options: [.new]) { _, _ in check() },
               p.observe(\.timeControlStatus, options: [.new]) { _, _ in check() }]
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { cleanupObs() }
        check()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2, execute: go)
    }

    /// Elemento senza traccia audio: il monitor non tocca mai l'audio (che esce dall'iPhone)
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

    private func setOpacity(_ l: AVPlayerLayer, _ v: Float, _ dur: Double) {
        if dur > 0 {
            let a = CABasicAnimation(keyPath: "opacity")
            a.fromValue = l.presentation()?.opacity ?? l.opacity
            a.toValue = v
            a.duration = dur
            a.timingFunction = CAMediaTimingFunction(name: .linear)
            l.add(a, forKey: "fade")
        }
        CATransaction.begin(); CATransaction.setDisableActions(true); l.opacity = v; CATransaction.commit()
    }
}
