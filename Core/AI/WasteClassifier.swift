import UIKit

protocol WasteClassifier: Sendable {
    func classify(image: UIImage) async throws -> Classification
}

enum ClassifierError: LocalizedError {
    case modelUnavailable
    case lowConfidence
    case visionFailure(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .modelUnavailable: "El modelo de IA no está disponible en este dispositivo."
        case .lowConfidence:    "No estoy seguro de qué es. Intenta otra foto con mejor luz."
        case .visionFailure:    "Hubo un problema procesando la imagen."
        }
    }
}
