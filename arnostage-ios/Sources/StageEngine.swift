import Foundation
import AVFoundation
import UIKit

/// Motore audio di ArnoStage: suona insieme tutte le tracce del brano (base stereo, click, ecc.),
/// ognuna con volume, panorama, muto e uscita della scheda audio scelti dal mixer della pagina.
/// Gli ingressi della scheda possono andare in uscita (per suonare sulle basi).
final class StageEngine {
    static let shared = StageEngine()

    /// Una traccia decodificata: campioni a 16 bit interlacciati (1 o 2 canali).
    final class Track {
        let sr: Double, ch: Int, frames: Int
        let data: UnsafeMutablePointer<Int16>
        init(sr: Double, ch: Int, frames: Int, data: UnsafeMutablePointer<Int16>) { self.sr = sr; self.ch = ch; self.frames = frames; self.data = data }
        deinit { data.deallocate() }
        var duration: Double { sr > 0 ? Double(frames) / sr : 0 }
    }

    /// Una striscia del mixer pronta per il thread audio.
    private final class Voice {
        let tr: Track
        var gL: Float = 1, gR: Float = 1, out = 0, st = true
        var off = 0.0   // ritardo in secondi (audio del video spostato col sync)
        init(_ t: Track) { tr = t }
    }

    private var tracks: [String: Track] = [:]
    private var voices: [Voice] = []
    private var stripIds: [String] = []

    private let engine = AVAudioEngine()
    private var source: AVAudioNode?
    private var sink: AVAudioNode?
    private(set) var channels = 2
    private var hwRate = 48000.0
    private var observing = false
    private var needRebuild = false
    private var lastRebuild = Date.distantPast
    private var rebuildPending = false
    var onChange: (() -> Void)?

    private let lockP: UnsafeMutablePointer<os_unfair_lock> = {
        let p = UnsafeMutablePointer<os_unfair_lock>.allocate(capacity: 1); p.initialize(to: os_unfair_lock()); return p
    }()
    private func lock() { os_unfair_lock_lock(lockP) }
    private func unlock() { os_unfair_lock_unlock(lockP) }
    private let outs = UnsafeMutablePointer<UnsafeMutablePointer<Float>>.allocate(capacity: 128)
    /// picchi per gli indicatori di livello (uno per striscia, più l'ingresso)
    private let peaks: UnsafeMutablePointer<Float> = { let p = UnsafeMutablePointer<Float>.allocate(capacity: 66); p.initialize(repeating: 0, count: 66); return p }()

    private var playing = false
    private var ended = false
    private var pos = 0.0                 // secondi
    private var length = 0.0
    private var master: Float = 1

    // Ingressi della scheda
    private(set) var inOn = false
    private var inA = 0, inB = 1, inGain: Float = 1, inOut = 0, inOutSt = true, inMute = false
    private var inChannels = 0
    private let ringSize = 16384
    private let ringA = UnsafeMutablePointer<Float>.allocate(capacity: 16384)
    private let ringB = UnsafeMutablePointer<Float>.allocate(capacity: 16384)
    private var ringW = 0, ringR = 0
    private let ringLock: UnsafeMutablePointer<os_unfair_lock> = {
        let p = UnsafeMutablePointer<os_unfair_lock>.allocate(capacity: 1); p.initialize(to: os_unfair_lock()); return p
    }()
    private var inPeak: Float = 0
    private var mPeakL: Float = 0, mPeakR: Float = 0
    /// picchi prima del fader (per il LED del click: lampeggia anche con la traccia muta)
    private let raws: UnsafeMutablePointer<Float> = { let p = UnsafeMutablePointer<Float>.allocate(capacity: 66); p.initialize(repeating: 0, count: 66); return p }()
    private var sessionActive = false

    // MARK: - Scheda audio

    @discardableResult
    func prepare() -> Bool {
        let s = AVAudioSession.sharedInstance()
        if inOn {
            if s.category != .playAndRecord {
                try? s.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetoothA2DP]); sessionActive = false
            }
        } else if s.category != .playback {
            try? s.setCategory(.playback, mode: .default, options: []); sessionActive = false
        }
        if !sessionActive { try? s.setPreferredIOBufferDuration(0.005); try? s.setActive(true); sessionActive = true }
        if s.maximumOutputNumberOfChannels > 2 && s.outputNumberOfChannels < s.maximumOutputNumberOfChannels {
            try? s.setPreferredOutputNumberOfChannels(s.maximumOutputNumberOfChannels)
        }
        if inOn && s.maximumInputNumberOfChannels > 1 && s.inputNumberOfChannels < s.maximumInputNumberOfChannels {
            try? s.setPreferredInputNumberOfChannels(s.maximumInputNumberOfChannels)
        }
        let hw = engine.outputNode.outputFormat(forBus: 0)
        let n = max(2, Int(hw.channelCount))
        let rate = hw.sampleRate > 0 ? hw.sampleRate : 48000
        if source != nil && n == channels && rate == hwRate && !needRebuild && (sink != nil) == inOn {
            if !engine.isRunning { try? engine.start() }
            return engine.isRunning
        }
        engine.stop()
        if let old = source { engine.detach(old); source = nil }
        if let old = sink { engine.disconnectNodeInput(old); engine.detach(old); sink = nil }
        needRebuild = false
        channels = n; hwRate = rate
        let fmt: AVAudioFormat?
        if n <= 2 {
            fmt = AVAudioFormat(standardFormatWithSampleRate: rate, channels: AVAudioChannelCount(n))
        } else if let hwLayout = hw.channelLayout, hw.channelCount == AVAudioChannelCount(n) {
            // stesso schema di canali della scheda (come ARNOCLICK): niente uscite spostate
            fmt = AVAudioFormat(standardFormatWithSampleRate: rate, channelLayout: hwLayout)
        } else if let layout = AVAudioChannelLayout(layoutTag: kAudioChannelLayoutTag_DiscreteInOrder | UInt32(n)) {
            fmt = AVAudioFormat(standardFormatWithSampleRate: rate, channelLayout: layout)
        } else { fmt = nil }
        guard let format = fmt else { return false }
        let node = AVAudioSourceNode(format: format) { [unowned self] _, _, frameCount, abl -> OSStatus in
            self.render(Int(frameCount), UnsafeMutableAudioBufferListPointer(abl))
            return noErr
        }
        engine.attach(node)
        engine.connect(node, to: engine.outputNode, format: format)
        source = node
        inChannels = 0
        if inOn {
            let inFmt = engine.inputNode.outputFormat(forBus: 0)
            if inFmt.channelCount > 0 && inFmt.sampleRate > 0 {
                inChannels = Int(inFmt.channelCount)
                let sk = AVAudioSinkNode { [unowned self] _, frameCount, abl -> OSStatus in
                    self.capture(Int(frameCount), abl)
                    return noErr
                }
                engine.attach(sk)
                engine.connect(engine.inputNode, to: sk, format: inFmt)
                sink = sk
            }
        }
        if !observing {
            observing = true
            NotificationCenter.default.addObserver(forName: .AVAudioEngineConfigurationChange, object: engine, queue: .main) { [weak self] _ in
                guard let self = self else { return }
                self.needRebuild = true
                if Date().timeIntervalSince(self.lastRebuild) < 0.4 {
                    if self.rebuildPending { return }
                    self.rebuildPending = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
                        guard let self = self else { return }
                        self.rebuildPending = false; self.lastRebuild = Date()
                        self.prepare(); self.onChange?()
                    }
                    return
                }
                self.lastRebuild = Date()
                self.prepare(); self.onChange?()
            }
            NotificationCenter.default.addObserver(forName: AVAudioSession.routeChangeNotification, object: nil, queue: .main) { [weak self] _ in
                self?.onChange?()
            }
        }
        engine.prepare()
        do { try engine.start() } catch { return false }
        return true
    }

    func info() -> [String: Any] {
        let s = AVAudioSession.sharedInstance()
        let name = s.currentRoute.outputs.first?.portName ?? "iPhone"
        let inName = s.currentRoute.inputs.first?.portName ?? ""
        let ic = inOn ? max(inChannels, s.inputNumberOfChannels) : s.maximumInputNumberOfChannels
        let all = s.currentRoute.outputs.map { $0.portName }
        return ["outs": all, "out": channels, "in": ic, "name": name, "inName": inName, "rate": hwRate, "inOn": inOn]
    }

    // MARK: - Decodifica (fuori dal thread principale)

    static func decode(url: URL) -> Track? {
        let asset = AVURLAsset(url: url)
        guard let at = asset.tracks(withMediaType: .audio).first else { return nil }
        var sr = 44100.0, ch = 2
        if let fd = at.formatDescriptions.first {
            let desc = fd as! CMAudioFormatDescription
            if let asbd = CMAudioFormatDescriptionGetStreamBasicDescription(desc)?.pointee {
                if asbd.mSampleRate > 0 { sr = asbd.mSampleRate }
                ch = Int(asbd.mChannelsPerFrame) >= 2 ? 2 : 1
            }
        }
        guard let reader = try? AVAssetReader(asset: asset) else { return nil }
        let settings: [String: Any] = [AVFormatIDKey: kAudioFormatLinearPCM, AVLinearPCMBitDepthKey: 16,
                                       AVLinearPCMIsFloatKey: false, AVLinearPCMIsBigEndianKey: false,
                                       AVLinearPCMIsNonInterleaved: false, AVSampleRateKey: sr, AVNumberOfChannelsKey: ch]
        let out = AVAssetReaderTrackOutput(track: at, outputSettings: settings)
        out.alwaysCopiesSampleData = false
        guard reader.canAdd(out) else { return nil }
        reader.add(out)
        guard reader.startReading() else { return nil }
        var buf = Data()
        let est = asset.duration.seconds
        if est.isFinite && est > 0 { buf.reserveCapacity(Int(est * sr) * ch * 2 + 4096) }
        while let sb = out.copyNextSampleBuffer() {
            if let bb = CMSampleBufferGetDataBuffer(sb) {
                let len = CMBlockBufferGetDataLength(bb)
                var chunk = Data(count: len)
                chunk.withUnsafeMutableBytes { p in _ = CMBlockBufferCopyDataBytes(bb, atOffset: 0, dataLength: len, destination: p.baseAddress!) }
                buf.append(chunk)
            }
        }
        guard reader.status == .completed, buf.count >= ch * 2 else { return nil }
        let count = buf.count / 2
        let p = UnsafeMutablePointer<Int16>.allocate(capacity: count)
        buf.withUnsafeBytes { raw in
            if let b = raw.baseAddress { memcpy(p, b, count * 2) }
        }
        return Track(sr: sr, ch: ch, frames: count / ch, data: p)
    }

    // MARK: - Messaggi dalla pagina (thread principale); reply con il risultato

    func handle(_ m: [String: Any], reply: @escaping (Any?) -> Void) {
        let op = m["op"] as? String ?? ""
        let num: (String) -> Double = { (m[$0] as? NSNumber)?.doubleValue ?? 0 }
        switch op {
        case "info":
            prepare(); reply(info())
        case "picker":   // finestra di sistema per scegliere l'uscita audio (scheda, HDMI, iPhone…)
            RoutePicker.show(); reply(true)
        case "load":
            guard let id = m["id"] as? String else { reply(["ok": false]); return }
            if let t = tracks[id] { reply(["ok": true, "dur": t.duration, "ch": t.ch]); return }
            guard let u = MediaStore.url(for: id) else { reply(["ok": false, "err": "missing"]); return }
            DispatchQueue.global(qos: .userInitiated).async {
                let t = StageEngine.decode(url: u)
                DispatchQueue.main.async {
                    guard let t = t else { reply(["ok": false, "err": "decode"]); return }
                    self.tracks[id] = t
                    reply(["ok": true, "dur": t.duration, "ch": t.ch])
                }
            }
        case "keep":   // libera la memoria delle tracce che non servono più
            let keep = Set((m["ids"] as? [String]) ?? [])
            let inUse = Set(stripIds)
            for k in tracks.keys where !keep.contains(k) && !inUse.contains(k) { tracks[k] = nil }
            reply(true)
        case "song":
            let list = (m["strips"] as? [[String: Any]]) ?? []
            var vs: [Voice] = [], ids: [String] = [], len = 0.0
            for s in list {
                guard let id = s["id"] as? String, let t = tracks[id] else { continue }
                let v = Voice(t); StageEngine.apply(v, s); vs.append(v); ids.append(id); len = max(len, t.duration + max(0, v.off))
            }
            prepare()
            lock()
            voices = vs; stripIds = ids; length = len
            playing = false; ended = false; pos = 0
            for i in 0..<66 { peaks[i] = 0 }
            unlock()
            reply(["ok": true, "dur": len, "n": vs.count])
        case "strip":
            let i = Int(num("i"))
            lock(); if i >= 0 && i < voices.count { StageEngine.apply(voices[i], m); length = voices.reduce(0) { max($0, $1.tr.duration + max(0, $1.off)) } }; unlock()
            reply(true)
        case "master":
            lock(); master = Float(num("g")); unlock(); reply(true)
        case "play":
            prepare()
            lock()
            if m["from"] != nil { pos = max(0, num("from")) }
            if pos >= length { pos = 0 }
            playing = !voices.isEmpty; ended = false
            unlock()
            reply(true)
        case "stop":
            lock(); playing = false; unlock(); reply(true)
        case "seek":
            lock(); pos = max(0, min(num("t"), length)); ended = false; unlock(); reply(true)
        case "pos":
            lock()
            var pk: [Double] = []
            var rk: [Double] = []
            for i in 0..<voices.count { pk.append(Double(peaks[i])); peaks[i] = 0; if i < 66 { rk.append(Double(raws[i])); raws[i] = 0 } }
            let ip = Double(inPeak); inPeak = 0
            let ml = Double(mPeakL), mr = Double(mPeakR); mPeakL = 0; mPeakR = 0
            let r: [String: Any] = ["t": pos, "playing": playing, "ended": ended, "pk": pk, "ip": ip, "ml": ml, "mr": mr, "rk": rk]
            unlock()
            reply(r)
        case "input":
            let on = (m["on"] as? Bool) ?? false
            inA = max(0, Int(num("a"))); inB = Int(num("b")); inGain = Float(num("gain"))
            inOut = max(0, Int(num("out"))); inOutSt = (m["om"] as? String) != "mono"; inMute = (m["mute"] as? Bool) ?? false
            if on != inOn {
                inOn = on
                needRebuild = true
                os_unfair_lock_lock(ringLock); ringW = 0; ringR = 0; os_unfair_lock_unlock(ringLock)
                if on {
                    AVAudioSession.sharedInstance().requestRecordPermission { ok in
                        DispatchQueue.main.async {
                            if !ok { self.inOn = false }
                            self.prepare(); self.onChange?()
                            reply(["ok": ok])
                        }
                    }
                    return
                }
                prepare(); onChange?()
            }
            reply(["ok": true])
        default: reply(nil)
        }
    }

    private static func apply(_ v: Voice, _ s: [String: Any]) {
        let g = Float((s["g"] as? NSNumber)?.doubleValue ?? 1)
        let pan = Float((s["pan"] as? NSNumber)?.doubleValue ?? 0)
        let mute = (s["mute"] as? Bool) ?? false
        let gg = mute ? 0 : g
        v.gL = gg * min(1, 1 - pan); v.gR = gg * min(1, 1 + pan)
        v.out = max(0, Int((s["out"] as? NSNumber)?.intValue ?? 0))
        v.st = (s["om"] as? String) != "mono"
        v.off = (s["off"] as? NSNumber)?.doubleValue ?? 0
    }

    // MARK: - Thread audio

    private func capture(_ n: Int, _ abl: UnsafePointer<AudioBufferList>) {
        let list = UnsafeMutableAudioBufferListPointer(UnsafeMutablePointer(mutating: abl))
        var pa: UnsafeMutablePointer<Float>? = nil, pb: UnsafeMutablePointer<Float>? = nil
        var idx = 0
        for b in list {
            if idx == inA { pa = b.mData?.assumingMemoryBound(to: Float.self) }
            if idx == inB { pb = b.mData?.assumingMemoryBound(to: Float.self) }
            idx += 1
            if idx > max(inA, inB) { break }
        }
        guard let a = pa else { return }
        let mask = ringSize - 1
        os_unfair_lock_lock(ringLock)
        for i in 0..<n {
            let w = (ringW + i) & mask
            ringA[w] = a[i]
            ringB[w] = pb?[i] ?? a[i]
        }
        ringW += n
        if ringW - ringR > ringSize { ringR = ringW - ringSize }
        os_unfair_lock_unlock(ringLock)
    }

    private func mixInputs(_ n: Int, _ nOut: Int) {
        guard inOn, sink != nil, os_unfair_lock_trylock(ringLock) else { return }
        defer { os_unfair_lock_unlock(ringLock) }
        var avail = ringW - ringR
        if avail > n * 3 { ringR = ringW - n; avail = n }   // il ritardo non deve crescere
        let k = min(n, avail)
        if k <= 0 { return }
        let mask = ringSize - 1
        let o0 = min(inOut, nOut - 1), o1 = min(inOut + 1, nOut - 1)
        let two = inB >= 0 && inB != inA
        let g = inMute ? 0 : inGain
        var pk: Float = 0
        for f in 0..<k {
            let r = (ringR + f) & mask
            let ra = ringA[r], rb = two ? ringB[r] : ringA[r]
            let a = abs(ra) > abs(rb) ? abs(ra) : abs(rb); if a > pk { pk = a }
            let va = ra * g, vb = rb * g
            if inOutSt && o1 != o0 { outs[o0][f] += va; outs[o1][f] += vb }
            else { outs[o0][f] += two ? (va + vb) * 0.5 : va }
        }
        if pk > inPeak { inPeak = pk }
        ringR += k
    }

    @inline(__always) private func sample(_ t: Track, _ p: Double, _ c: Int) -> Float {
        let i = Int(p)
        if i < 0 || i >= t.frames { return 0 }
        let f = Float(p - Double(i))
        let ch = c < t.ch ? c : t.ch - 1
        let a = Float(t.data[i * t.ch + ch])
        let b = i + 1 < t.frames ? Float(t.data[(i + 1) * t.ch + ch]) : a
        return (a + (b - a) * f) * (1.0 / 32768.0)
    }

    private func render(_ n: Int, _ bufs: UnsafeMutableAudioBufferListPointer) {
        var nOut = 0
        for b in bufs where nOut < 128 {
            guard let p = b.mData?.assumingMemoryBound(to: Float.self) else { continue }
            let cnt = Int(b.mDataByteSize) / MemoryLayout<Float>.size
            p.initialize(repeating: 0, count: cnt)
            outs[nOut] = p; nOut += 1
        }
        guard nOut > 0 else { return }
        mixInputs(n, nOut)
        guard os_unfair_lock_trylock(lockP) else { return }
        defer { os_unfair_lock_unlock(lockP) }
        guard playing else { return }
        let dt = 1.0 / hwRate
        let mg = master
        for (vi, v) in voices.enumerated() {
            let t = v.tr
            let o0 = min(v.out, nOut - 1), o1 = min(v.out + 1, nOut - 1)
            let stereo = v.st && o1 != o0
            var p = (pos - v.off) * t.sr
            let step = t.sr * dt
            var pk: Float = 0
            let gl = v.gL * mg, gr = v.gR * mg
            for f in 0..<n {
                let l = sample(t, p, 0), r = t.ch > 1 ? sample(t, p, 1) : l
                let a = abs(l) > abs(r) ? abs(l) : abs(r); if a > pk { pk = a }
                if stereo { outs[o0][f] += l * gl; outs[o1][f] += r * gr }
                else { outs[o0][f] += (l * gl + r * gr) * 0.5 }
                p += step
            }
            let lv = pk * max(v.gL, v.gR) * mg
            if vi < 66 && lv > peaks[vi] { peaks[vi] = lv }
            if vi < 66 && pk > raws[vi] { raws[vi] = pk }
        }
        // VU master: uscite dispari = sinistra, pari = destra
        var pl: Float = 0, pr: Float = 0
        for c in 0..<nOut { let o = outs[c]; var m: Float = 0; for f in 0..<n { let a = abs(o[f]); if a > m { m = a } }; if c % 2 == 0 { if m > pl { pl = m } } else { if m > pr { pr = m } } }
        if nOut == 1 { pr = pl }
        if pl > mPeakL { mPeakL = pl }; if pr > mPeakR { mPeakR = pr }
        pos += Double(n) * dt
        if pos >= length { playing = false; ended = true; pos = length }
    }
}

import AVKit
/// Pulsante di sistema (invisibile) per scegliere dove esce l'audio.
enum RoutePicker {
    static let view: AVRoutePickerView = { let v = AVRoutePickerView(frame: CGRect(x: 0, y: 0, width: 1, height: 1)); v.alpha = 0.01; return v }()
    static func show() {
        if view.superview == nil, let host = Bridge.shared.control?.superview { host.addSubview(view) }
        for sub in view.subviews { if let b = sub as? UIButton { b.sendActions(for: .touchUpInside); return } }
    }
}
