import AVFoundation
import UIKit
import Observation

@Observable @MainActor
final class CameraService: NSObject {
    enum Status: Equatable {
        case idle
        case configuring
        case running
        case denied
        case failed(String)
    }

    private(set) var status: Status = .idle
    private(set) var lastCapture: UIImage?

    let session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()
    private let sessionQueue = DispatchQueue(label: "mx.up.hacknacional.camera.session")
    private var captureContinuation: CheckedContinuation<UIImage, Error>?

    func start() async {
        status = .configuring
        guard await requestAuthorization() else {
            status = .denied
            return
        }
        await configureSession()
    }

    func stop() {
        sessionQueue.async { [session] in
            if session.isRunning { session.stopRunning() }
        }
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
        status = started ? .running : .failed("No se pudo iniciar la cámara")
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
