import UIKit
import AVFoundation

/// Sorgente live: la fotocamera di questo dispositivo. I fotogrammi vanno a più «schermi» (anteprima sulla console e monitor HDMI).
final class LiveCamera: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    static let shared = LiveCamera()
    private let session = AVCaptureSession()
    private let out = AVCaptureVideoDataOutput()
    private let q = DispatchQueue(label: "arnoshow.live")
    private var input: AVCaptureDeviceInput?
    private(set) var position: AVCaptureDevice.Position = .back
    private var sinks: [AVSampleBufferDisplayLayer] = []
    private var configured = false
    private var orient: AVCaptureVideoOrientation = .landscapeRight

    override init() {
        super.init()
        // il live segue come è girato il dispositivo: in verticale immagine verticale, in orizzontale orizzontale
        DispatchQueue.main.async {
            UIDevice.current.beginGeneratingDeviceOrientationNotifications()
            NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: .main) { [weak self] _ in self?.followDevice() }
            self.followDevice()
        }
    }
    private func followDevice() {
        let o: AVCaptureVideoOrientation
        switch UIDevice.current.orientation {
        case .portrait: o = .portrait
        case .portraitUpsideDown: o = .portraitUpsideDown
        case .landscapeLeft: o = .landscapeRight
        case .landscapeRight: o = .landscapeLeft
        default: return   // a faccia in su/giù: si tiene l'ultimo verso
        }
        q.async {
            guard o != self.orient else { return }
            self.orient = o
            if let c = self.out.connection(with: .video), c.isVideoOrientationSupported { c.videoOrientation = o }
        }
    }

    func addSink(_ l: AVSampleBufferDisplayLayer) { q.async { if !self.sinks.contains(where: { $0 === l }) { self.sinks.append(l) } } }
    func removeSink(_ l: AVSampleBufferDisplayLayer) { q.async { self.sinks.removeAll { $0 === l } } }

    func start(position pos: AVCaptureDevice.Position, done: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { ok in
            guard ok else { DispatchQueue.main.async { done(false) }; return }
            self.q.async {
                self.configure(pos)
                if !self.session.isRunning { self.session.startRunning() }
                DispatchQueue.main.async { done(true) }
            }
        }
    }
    func stop() { q.async { if self.session.isRunning { self.session.stopRunning() } } }

    private func configure(_ pos: AVCaptureDevice.Position) {
        session.beginConfiguration()
        if !configured {
            session.sessionPreset = .hd1920x1080
            out.alwaysDiscardsLateVideoFrames = true
            out.setSampleBufferDelegate(self, queue: q)
            if session.canAddOutput(out) { session.addOutput(out) }
            configured = true
        }
        if input == nil || position != pos {
            if let i = input { session.removeInput(i) }
            if let d = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: pos),
               let i = try? AVCaptureDeviceInput(device: d), session.canAddInput(i) {
                session.addInput(i); input = i; position = pos
            }
        }
        if let c = out.connection(with: .video) {
            if c.isVideoOrientationSupported { c.videoOrientation = orient }
            if c.isVideoMirroringSupported { c.automaticallyAdjustsVideoMirroring = false; c.isVideoMirrored = (pos == .front) }
        }
        session.commitConfiguration()
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sb: CMSampleBuffer, from connection: AVCaptureConnection) {
        for l in sinks {
            if l.status == .failed { l.flush() }
            if l.isReadyForMoreMediaData { l.enqueue(sb) }
        }
    }
}

/// Riquadro live sopra la pagina della console, nella posizione del riquadro video.
final class LiveView: UIView {
    let disp = AVSampleBufferDisplayLayer()
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        isUserInteractionEnabled = false
        clipsToBounds = true
        layer.cornerRadius = 7
        disp.videoGravity = .resizeAspect
        layer.addSublayer(disp)
        alpha = 0
        isHidden = true
    }
    required init?(coder: NSCoder) { fatalError() }
    override func layoutSubviews() { super.layoutSubviews(); CATransaction.begin(); CATransaction.setDisableActions(true); disp.frame = bounds; CATransaction.commit() }
}
