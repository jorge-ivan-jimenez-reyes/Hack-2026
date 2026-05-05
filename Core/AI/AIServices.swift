import Foundation
import UIKit

/// Resolución única de los servicios de IA.
/// El coordinator no debe saber si está corriendo en simulator (mock)
/// o en device real (Vision + Foundation Models).
enum AIServices {
    /// Clasificador con Vision real por default. En simulator (sin cámara real
    /// ni etiquetas confiables) usar `MockWasteClassifier()` directo.
    static func defaultClassifier() -> WasteClassifier {
        #if targetEnvironment(simulator)
        return MockWasteClassifier()
        #else
        return ResilientClassifier(
            primary: VisionWasteClassifier(),
            fallback: MockWasteClassifier()
        )
        #endif
    }

    /// Coach con Foundation Models si está disponible, mock si no.
    static func defaultCoach() -> LanguageCoach {
        if case .ready = AIAvailability.foundationModels {
            return ResilientCoach(
                primary: FoundationModelsCoach(),
                fallback: MockLanguageCoach()
            )
        }
        return MockLanguageCoach()
    }
}

/// Wrapper que intenta el clasificador real y cae al mock si falla
/// (modelo no disponible, low confidence, etc.). Garantiza que el demo
/// nunca termine en pantalla de error si la foto no se puede clasificar.
struct ResilientClassifier: WasteClassifier {
    let primary: WasteClassifier
    let fallback: WasteClassifier

    func classify(image: UIImage) async throws -> Classification {
        do {
            return try await primary.classify(image: image)
        } catch {
            return try await fallback.classify(image: image)
        }
    }
}

struct ResilientCoach: LanguageCoach {
    let primary: LanguageCoach
    let fallback: LanguageCoach

    func explain(_ classification: Classification, context: CoachContext) async throws -> CoachResponse {
        do { return try await primary.explain(classification, context: context) }
        catch { return try await fallback.explain(classification, context: context) }
    }

    func reply(to message: String, history: [CoachMessage], context: CoachContext) async throws -> CoachResponse {
        do { return try await primary.reply(to: message, history: history, context: context) }
        catch { return try await fallback.reply(to: message, history: history, context: context) }
    }
}
