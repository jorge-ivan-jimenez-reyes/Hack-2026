import Foundation

struct MockLanguageCoach: LanguageCoach {
    func explain(_ classification: Classification, context: CoachContext) async throws -> CoachResponse {
        try await Task.sleep(for: .milliseconds(650))
        return CoachResponse(
            summary: "Esto va al bote \(classification.category.binColor.lowercased()).",
            detail: "Identifiqué \(classification.category.displayName) con \(classification.confidencePercentage)% de confianza. Antes de tirarlo, enjuágalo si está sucio para evitar contaminación cruzada en el reciclaje.",
            tip: "Un envase mal lavado puede inutilizar todo un lote de reciclaje.",
            confidence: classification.isConfident ? .alta : .media
        )
    }

    func reply(to message: String, history: [CoachMessage], context: CoachContext) async throws -> CoachResponse {
        try await Task.sleep(for: .milliseconds(550))
        return CoachResponse(
            summary: "Pregunta interesante.",
            detail: "Respuesta de prueba sobre: \"\(message)\". Cuando se conecte Foundation Models, esto vendrá del LLM on-device.",
            tip: nil,
            confidence: .media
        )
    }
}
