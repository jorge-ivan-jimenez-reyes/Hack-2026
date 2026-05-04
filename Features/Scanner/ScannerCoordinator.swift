import SwiftUI
import AVFoundation
import Observation

/// Orquesta el flujo cámara → clasificador → coach.
/// Único caso justificado de "coordinator" porque combina 3 servicios.
/// Las demás vistas usan `@Observable` directo o `@Query`.
@Observable @MainActor
final class ScannerCoordinator {
    enum State {
        case idle
        case capturing
        case classifying
        case explaining(Classification, UIImage)
        case explained(Classification, CoachResponse, UIImage)
        case error(String)
    }

    private(set) var state: State = .idle

    let camera: CameraService
    private let classifier: WasteClassifier
    private let coach: LanguageCoach

    init(
        camera: CameraService = CameraService(),
        classifier: WasteClassifier = MockWasteClassifier(),
        coach: LanguageCoach = MockLanguageCoach()
    ) {
        self.camera = camera
        self.classifier = classifier
        self.coach = coach
    }

    func startCamera() async { await camera.start() }
    func stopCamera() { camera.stop() }

    func captureAndClassify() async {
        do {
            state = .capturing
            let image = try await camera.capture()
            state = .classifying
            let classification = try await classifier.classify(image: image)
            state = .explaining(classification, image)
            let response = try await coach.explain(classification, context: .init())
            state = .explained(classification, response, image)
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func reset() {
        state = .idle
    }
}
