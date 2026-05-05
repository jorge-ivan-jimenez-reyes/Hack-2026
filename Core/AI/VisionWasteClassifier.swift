import UIKit
import Vision

/// Clasificador real usando el `VNClassifyImageRequest` integrado en Vision.
/// No requiere `.mlmodel` propio: usa la taxonomía general de Apple
/// (miles de etiquetas como "banana", "bottle", "can", "newspaper", etc.)
/// y mapea grupos de etiquetas a nuestras `WasteCategory`.
///
/// Trade-off: la cobertura no es 100% (no hay clase específica de "PET"
/// vs. "vidrio") pero para el demo del hack es suficiente y corre 100%
/// on-device, sin internet, sin modelo extra.
struct VisionWasteClassifier: WasteClassifier {

    /// Mínima confianza por etiqueta individual antes de considerarla.
    private let perLabelThreshold: Float = 0.10

    /// Mínima confianza acumulada por categoría para no devolver `unknown`.
    private let categoryThreshold: Double = 0.18

    func classify(image: UIImage) async throws -> Classification {
        guard let cgImage = image.cgImage else {
            throw ClassifierError.visionFailure(
                underlying: NSError(domain: "Classifier", code: -1)
            )
        }

        let request = VNClassifyImageRequest()

        let orientation = CGImagePropertyOrientation(image.imageOrientation)
        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation)

        do {
            try handler.perform([request])
        } catch {
            throw ClassifierError.visionFailure(underlying: error)
        }

        guard let observations = request.results, !observations.isEmpty else {
            throw ClassifierError.lowConfidence
        }

        let scores = aggregateScores(from: observations)
        let ranked = scores
            .sorted { $0.value > $1.value }
            .filter { $0.key != .unknown }

        guard let top = ranked.first, top.value >= categoryThreshold else {
            throw ClassifierError.lowConfidence
        }

        let alternatives = ranked
            .dropFirst()
            .prefix(2)
            .filter { $0.value > 0.05 }
            .map {
                Classification.Alternative(category: $0.key, confidence: $0.value)
            }

        return Classification(
            category: top.key,
            confidence: min(top.value, 0.99),
            alternatives: Array(alternatives)
        )
    }

    /// Suma confianzas de todas las etiquetas que mapean a la misma categoría.
    /// Aplana la taxonomía granular de Apple a nuestras 6 cubetas.
    private func aggregateScores(
        from observations: [VNClassificationObservation]
    ) -> [WasteCategory: Double] {
        var scores: [WasteCategory: Double] = [:]
        for obs in observations where obs.confidence >= perLabelThreshold {
            guard let category = WasteCategory.fromVisionLabel(obs.identifier) else { continue }
            scores[category, default: 0] += Double(obs.confidence)
        }
        // Normaliza para que la suma no sobrepase 1 (evita valores >100% al sumar etiquetas duplicadas).
        let total = scores.values.reduce(0, +)
        if total > 1, total > 0 {
            for key in scores.keys { scores[key] = (scores[key] ?? 0) / total }
        }
        return scores
    }
}

// MARK: - Vision label mapping

private extension WasteCategory {
    /// Mapea etiquetas de la taxonomía de Apple Vision a `WasteCategory`.
    /// Lista curada para residuos comunes en CDMX. Ampliar conforme se prueben fotos.
    static func fromVisionLabel(_ identifier: String) -> WasteCategory? {
        let label = identifier.lowercased()

        // Orgánico — comida, frutas, verduras, plantas
        if label.contains("food") || label.contains("fruit") || label.contains("vegetable")
            || label.contains("plant") || label.contains("flower") || label.contains("leaf")
            || label.contains("banana") || label.contains("apple") || label.contains("orange")
            || label.contains("bread") || label.contains("egg") || label.contains("meat")
            || label.contains("coffee") || label.contains("tea") || label.contains("rice")
            || label.contains("salad") || label.contains("herb") || label.contains("nut")
            || label.contains("seed") || label.contains("compost") {
            return .organic
        }

        // PET / plástico — botellas, contenedores plásticos, bolsas
        if label.contains("plastic") || label.contains("bottle") || label.contains("pet")
            || label.contains("polyethylene") || label.contains("packaging")
            || label.contains("container") || label.contains("wrapper")
            || label.contains("bag") {
            return .pet
        }

        // Vidrio — botellas/frascos de vidrio, copas
        if label.contains("glass") || label.contains("jar") || label.contains("wine")
            || label.contains("beer_bottle") || label.contains("wineglass") {
            return .glass
        }

        // Papel y cartón
        if label.contains("paper") || label.contains("cardboard") || label.contains("newspaper")
            || label.contains("magazine") || label.contains("book") || label.contains("envelope")
            || label.contains("box") || label.contains("carton") || label.contains("tissue") {
            return .paper
        }

        // Metal — latas, aluminio
        if label.contains("metal") || label.contains("can") || label.contains("aluminum")
            || label.contains("tin") || label.contains("foil") || label.contains("steel")
            || label.contains("iron") {
            return .metal
        }

        // Electrónico — pilas, cables, dispositivos
        if label.contains("electronic") || label.contains("battery") || label.contains("phone")
            || label.contains("computer") || label.contains("cable") || label.contains("charger")
            || label.contains("device") || label.contains("circuit") {
            return .electronic
        }

        return nil
    }
}

// MARK: - UIImageOrientation → CGImagePropertyOrientation

private extension CGImagePropertyOrientation {
    init(_ uiOrientation: UIImage.Orientation) {
        switch uiOrientation {
        case .up:            self = .up
        case .upMirrored:    self = .upMirrored
        case .down:          self = .down
        case .downMirrored:  self = .downMirrored
        case .left:          self = .left
        case .leftMirrored:  self = .leftMirrored
        case .right:         self = .right
        case .rightMirrored: self = .rightMirrored
        @unknown default:    self = .up
        }
    }
}
