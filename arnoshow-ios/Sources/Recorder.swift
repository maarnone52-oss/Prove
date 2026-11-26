import UIKit
import AVFoundation
import CoreImage
import Photos

/// Ricostruisce in un unico MP4 quello che è andato in onda (dai file originali, a piena qualità).
/// Segmenti: {k:"video",id,from,dur,xf} {k:"hold",id,at,dur,xf} {k:"photo",id,dur,xf} {k:"black",dur,xf}
final class ArnoLayer: NSObject {
    var trackID: CMPersistentTrackID = kCMPersistentTrackID_Invalid
    var photo: CIImage?
    var transform: CGAffineTransform = .identity
    var rampStart: Double = 0, rampDur: Double = 0
}

final class ArnoInstr: NSObject, AVVideoCompositionInstructionProtocol {
    let timeRange: CMTimeRange
    let enablePostProcessing = false
    let containsTweening = true
    let requiredSourceTrackIDs: [NSValue]?
    let passthroughTrackID = kCMPersistentTrackID_Invalid
    let layers: [ArnoLayer]
    init(range: CMTimeRange, layers: [ArnoLayer]) {
        timeRange = range; self.layers = layers
        let ids = layers.compactMap { $0.trackID != kCMPersistentTrackID_Invalid ? NSNumber(value: $0.trackID) : nil }
        requiredSourceTrackIDs = ids.isEmpty ? nil : ids
    }
}

final class ArnoCompositor: NSObject, AVVideoCompositing {
    let sourcePixelBufferAttributes: [String: Any]? = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
    let requiredPixelBufferAttributesForRenderContext: [String: Any] = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
    private let ctx = CIContext(options: [.cacheIntermediates: false])
    func renderContextChanged(_ newRenderContext: AVVideoCompositionRenderContext) {}

    func startRequest(_ req: AVAsynchronousVideoCompositionRequest) {
        guard let ins = req.videoCompositionInstruction as? ArnoInstr, let out = req.renderContext.newPixelBuffer() else {
            req.finish(with: NSError(domain: "ArnoShow", code: 1)); return
        }
        let size = req.renderContext.size
        let rect = CGRect(origin: .zero, size: size)
        let t = req.compositionTime.seconds
        var img = CIImage(color: .black).cropped(to: rect)
        for l in ins.layers {
            var li: CIImage?
            if l.trackID != kCMPersistentTrackID_Invalid, let pb = req.sourceFrame(byTrackID: l.trackID) {
                var c = CIImage(cvPixelBuffer: pb).transformed(by: l.transform)
                c = c.transformed(by: CGAffineTransform(translationX: -c.extent.origin.x, y: -c.extent.origin.y))
                li = c
            } else if let p = l.photo { li = p }
            guard var src = li, src.extent.width > 0, src.extent.height > 0 else { continue }
            let k = min(size.width / src.extent.width, size.height / src.extent.height)
            src = src.transformed(by: CGAffineTransform(scaleX: k, y: k))
            src = src.transformed(by: CGAffineTransform(translationX: (size.width - src.extent.width) / 2 - src.extent.origin.x,
                                                         y: (size.height - src.extent.height) / 2 - src.extent.origin.y))
            var a: CGFloat = 1
            if l.rampDur > 0 { a = CGFloat(max(0, min(1, (t - l.rampStart) / l.rampDur))) }
            if a < 1 { src = src.applyingFilter("CIColorMatrix", parameters: ["inputAVector": CIVector(x: 0, y: 0, z: 0, w: a)]) }
            img = src.composited(over: img)
        }
        ctx.render(img.cropped(to: rect), to: out)
        req.finish(withComposedVideoFrame: out)
    }
}

final class Recorder {
    static let shared = Recorder()
    private var export: AVAssetExportSession?
    private var timer: Timer?

    func render(_ segs: [[String: Any]], progress: @escaping (Double) -> Void, done: @escaping (Bool, String) -> Void) {
        let comp = AVMutableComposition()
        let vt = [comp.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)!,
                  comp.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)!]
        let at = [comp.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)!,
                  comp.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)!]
        let audioParams = [AVMutableAudioMixInputParameters(track: at[0]), AVMutableAudioMixInputParameters(track: at[1])]
        struct Placed { let start: Double; let end: Double; let xf: Double; let layer: ArnoLayer }
        var placed: [Placed] = []
        var T = 0.0, prevDur = 0.0, slot = 0
        func ct(_ s: Double) -> CMTime { CMTime(seconds: max(0, s), preferredTimescale: 600) }

        for s in segs {
            let k = s["k"] as? String ?? "black"
            let dur = max(0.04, (s["dur"] as? Double) ?? 0)
            var xf = max(0, (s["xf"] as? Double) ?? 0)
            xf = placed.isEmpty ? 0 : min(xf, prevDur * 0.9, dur * 0.9)
            let start = max(0, T - xf)
            let layer = ArnoLayer()
            layer.rampStart = start; layer.rampDur = xf
            let id = s["id"] as? String ?? ""
            if (k == "video" || k == "hold"), let u = MediaStore.url(for: id) {
                let asset = AVURLAsset(url: u)
                if let src = asset.tracks(withMediaType: .video).first {
                    let i = slot % 2; slot += 1
                    layer.trackID = vt[i].trackID
                    layer.transform = src.preferredTransform
                    let assetDur = asset.duration.seconds
                    if k == "video" {
                        let from = max(0, min((s["from"] as? Double) ?? 0, max(0, assetDur - 0.05)))
                        let len = min(dur, max(0.04, assetDur - from))
                        try? vt[i].insertTimeRange(CMTimeRange(start: ct(from), duration: ct(len)), of: src, at: ct(start))
                        if len < dur - 0.04 {   // la clip è finita prima: si tiene l'ultimo fotogramma
                            let last = max(0, from + len - 0.04)
                            try? vt[i].insertTimeRange(CMTimeRange(start: ct(last), duration: ct(0.034)), of: src, at: ct(start + len))
                            vt[i].scaleTimeRange(CMTimeRange(start: ct(start + len), duration: ct(0.034)), toDuration: ct(dur - len))
                        }
                        if let a = asset.tracks(withMediaType: .audio).first {
                            try? at[i].insertTimeRange(CMTimeRange(start: ct(from), duration: ct(len)), of: a, at: ct(start))
                            let p = audioParams[i]
                            if xf > 0 { p.setVolumeRamp(fromStartVolume: 0, toEndVolume: 1, timeRange: CMTimeRange(start: ct(start), duration: ct(xf))) }
                            else { p.setVolume(1, at: ct(start)) }
                        }
                    } else {
                        let a0 = max(0, min((s["at"] as? Double) ?? 0, max(0, assetDur - 0.05)))
                        try? vt[i].insertTimeRange(CMTimeRange(start: ct(a0), duration: ct(0.034)), of: src, at: ct(start))
                        vt[i].scaleTimeRange(CMTimeRange(start: ct(start), duration: ct(0.034)), toDuration: ct(dur))
                    }
                }
            } else if k == "photo", let u = MediaStore.url(for: id), let im = CIImage(contentsOf: u, options: [.applyOrientationProperty: true]) {
                layer.photo = im
            }
            // l'audio della clip precedente sfuma durante la dissolvenza
            if xf > 0, let prev = placed.last, prev.layer.trackID != kCMPersistentTrackID_Invalid,
               let idx = vt.firstIndex(where: { $0.trackID == prev.layer.trackID }) {
                audioParams[idx].setVolumeRamp(fromStartVolume: 1, toEndVolume: 0, timeRange: CMTimeRange(start: ct(start), duration: ct(xf)))
            }
            placed.append(Placed(start: start, end: start + dur, xf: xf, layer: layer))
            T = start + dur; prevDur = dur
        }
        guard T > 0.1 else { done(false, "Niente da registrare"); return }

        // istruzioni: intervalli tra tutti gli inizi/fine/fine-dissolvenza
        var cuts = Set<Double>([0, T])
        for p in placed { cuts.insert(p.start); cuts.insert(p.end); if p.xf > 0 { cuts.insert(p.start + p.xf) } }
        let pts = cuts.filter { $0 >= 0 && $0 <= T }.sorted()
        var ins: [ArnoInstr] = []
        for j in 0..<(pts.count - 1) {
            let a = pts[j], b = pts[j + 1]
            guard b - a > 0.0005 else { continue }
            let mid = (a + b) / 2
            let act = placed.filter { $0.start <= mid && mid < $0.end }.map { $0.layer }
            let r = CMTimeRange(start: CMTime(seconds: a, preferredTimescale: 600), end: CMTime(seconds: b, preferredTimescale: 600))
            ins.append(ArnoInstr(range: r, layers: act))
        }
        // fa combaciare gli intervalli esattamente (niente buchi)
        var fixed: [ArnoInstr] = []
        var cursor = CMTime.zero
        for i in ins { let r = CMTimeRange(start: cursor, end: i.timeRange.end); fixed.append(ArnoInstr(range: r, layers: i.layers)); cursor = i.timeRange.end }
        let vc = AVMutableVideoComposition()
        vc.customVideoCompositorClass = ArnoCompositor.self
        vc.frameDuration = CMTime(value: 1, timescale: 30)
        vc.renderSize = CGSize(width: 1920, height: 1080)
        vc.instructions = fixed
        let mix = AVMutableAudioMix(); mix.inputParameters = audioParams

        let outURL = FileManager.default.temporaryDirectory.appendingPathComponent("ArnoShow-\(Int(Date().timeIntervalSince1970)).mp4")
        guard let ex = AVAssetExportSession(asset: comp, presetName: AVAssetExportPresetHighestQuality) else { done(false, "Esportazione non disponibile"); return }
        ex.outputURL = outURL; ex.outputFileType = .mp4
        ex.videoComposition = vc; ex.audioMix = mix
        ex.timeRange = CMTimeRange(start: .zero, duration: CMTime(seconds: T, preferredTimescale: 600))
        export = ex
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in progress(Double(ex.progress)) }
        ex.exportAsynchronously {
            DispatchQueue.main.async {
                self.timer?.invalidate(); self.timer = nil
                guard ex.status == .completed else { done(false, ex.error?.localizedDescription ?? "Esportazione non riuscita"); return }
                PHPhotoLibrary.requestAuthorization(for: .addOnly) { st in
                    guard st == .authorized || st == .limited else { DispatchQueue.main.async { done(false, "Consenti ad ArnoShow di aggiungere a Foto (Impostazioni)") }; return }
                    PHPhotoLibrary.shared().performChanges({ PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outURL) }) { ok, err in
                        try? FileManager.default.removeItem(at: outURL)
                        DispatchQueue.main.async { done(ok, ok ? "Video salvato in Foto (\(Int(T.rounded())) s)" : (err?.localizedDescription ?? "Salvataggio non riuscito")) }
                    }
                }
            }
        }
    }
}
