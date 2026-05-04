import UIKit
import Vision
import CoreML

/// Implementación real con Vision + Core ML.
///
/// TODO día del hack:
/// 1. Drag .mlmodel (o .mlpackage) a Resources/MLModels/
/// 2. Reemplazar `loadModel()` con la clase autogenerada por Xcode.
/// 3. Ajustar `WasteCategory.init?(rawIdentifier:)` a los labels reales.
struct VisionWasteClassifier: WasteClassifier {
    func classify(image: UIImage) async throws -> Classification {
        guard let cgImage = image.cgImage else {
            throw ClassifierError.visionFailure(
                underlying: NSError(domain: "Classifier", code: -1)
            )
        }

        let model = try loadModel()
        let request = VNCoreMLRequest(model: model)
        request.imageCropAndScaleOption = .centerCrop

        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: .up)
        try await Task.detached { try handler.perform([request]) }.value

        guard let results = request.results as? [VNClassificationObservation],
              let top = results.first else {
            throw ClassifierError.lowConfidence
        }

        return Classification(
            category: WasteCategory(rawIdentifier: top.identifier) ?? .unknown,
            confidence: Double(top.confidence),
            alternatives: results.dropFirst().prefix(2).map {
                Classification.Alternative(
                    category: WasteCategory(rawIdentifier: $0.identifier) ?? .unknown,
                    confidence: Double($0.confidence)
                )
            }
        )
    }

    private func loadModel() throws -> VNCoreMLModel {
        // TODO: try VNCoreMLModel(for: WasteClassifierV1(configuration: .init()).model)
        throw ClassifierError.modelUnavailable
    }
}

private extension WasteCategory {
    init?(rawIdentifier: String) {
        switch rawIdentifier.lowercased() {
        case "organic", "compost", "food":          self = .organic
        case "plastic", "pet", "bottle":            self = .pet
        case "glass":                               self = .glass
        case "paper", "cardboard":                  self = .paper
        case "metal", "aluminum", "can":            self = .metal
        case "electronic", "ewaste", "battery":     self = .electronic
        default:                                    return nil
        }
    }
}
