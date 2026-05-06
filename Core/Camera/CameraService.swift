import AVFoundation
import UIKit
import Observation

@Observable @MainActor
final class CameraService: NSObject {
    enum Status: Equatable {
        case idle
        case configuring
        case running
        case paused
        case denied
        case failed(String)
    }

    private(set) var status: Status = .idle
    private(set) var lastCapture: UIImage?

    let session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()
    private let sessionQueue = DispatchQueue(label: "mx.up.hacknacional.camera.session")
    private var captureContinuation: CheckedContinuation<UIImage, Error>?

    /// Marca si ya se hizo el `addInput`/`addOutput` al menos una vez.
    /// Sin esto, re-entrar al ScannerView (cerrar y abrir el sheet) llama
    /// `configureSession` otra vez y `canAddInput` regresa false → la
    /// cámara queda "trabada" en "Iniciando cámara…".
    private var didConfigure = false

    func start() async {
        // Idempotente: si ya está corriendo o configurando, no hacer nada.
        switch status {
        case .running, .configuring:
            return
        case .denied, .failed:
            // permite reintento
            break
        default:
            break
        }

        status = .configuring
        guard await requestAuthorization() else {
            status = .denied
            return
        }
        if didConfigure {
            await resumeSession()
        } else {
            await configureSession()
        }
    }

    func stop() {
        // Pausa la session pero deja la configuración intacta para que
        // el siguiente start sea instantáneo.
        sessionQueue.async { [session] in
            if session.isRunning { session.stopRunning() }
        }
        if status == .running { status = .paused }
    }

    func capture() async throws -> UIImage {
        try await withCheckedThrowingContinuation { continuation in
            self.captureContinuation = continuation
            sessionQueue.async { [output] in
                let settings = AVCapturePhotoSettings()
                output.capturePhoto(with: settings, delegate: self)
            }
        }
    }

    private func requestAuthorization() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: return true
        case .notDetermined: return await AVCaptureDevice.requestAccess(for: .video)
        default: return false
        }
    }

    private func configureSession() async {
        let started = await withCheckedContinuation { (continuation: CheckedContinuation<Bool, Never>) in
            sessionQueue.async { [session, output] in
                session.beginConfiguration()
                session.sessionPreset = .photo

                guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                      let input = try? AVCaptureDeviceInput(device: device),
                      session.canAddInput(input),
                      session.canAddOutput(output) else {
                    session.commitConfiguration()
                    continuation.resume(returning: false)
                    return
                }
                session.addInput(input)
                session.addOutput(output)
                session.commitConfiguration()
                session.startRunning()
                continuation.resume(returning: session.isRunning)
            }
        }
        if started {
            didConfigure = true
            status = .running
        } else {
            status = .failed("No se pudo iniciar la cámara")
        }
    }

    /// Reanuda una session ya configurada — barata, no agrega inputs/outputs.
    private func resumeSession() async {
        let started = await withCheckedContinuation { (cont: CheckedContinuation<Bool, Never>) in
            sessionQueue.async { [session] in
                if !session.isRunning { session.startRunning() }
                cont.resume(returning: session.isRunning)
            }
        }
        status = started ? .running : .failed("No se pudo reanudar la cámara")
    }
}

extension CameraService: AVCapturePhotoCaptureDelegate {
    nonisolated func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        let result: Result<UIImage, Error>
        if let error {
            result = .failure(error)
        } else if let data = photo.fileDataRepresentation(), let image = UIImage(data: data) {
            result = .success(image)
        } else {
            result = .failure(NSError(domain: "Camera", code: -2))
        }
        Task { @MainActor in
            switch result {
            case .success(let image):
                self.lastCapture = image
                self.captureContinuation?.resume(returning: image)
            case .failure(let error):
                self.captureContinuation?.resume(throwing: error)
            }
            self.captureContinuation = nil
        }
    }
}
