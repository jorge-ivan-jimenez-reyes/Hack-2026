import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif

/// Implementación con Apple Foundation Models (LLM on-device).
/// Requiere iOS 26+ y Apple Intelligence habilitado.
///
/// TODO día del hack:
/// - Ajustar `systemInstructions` al reto específico anunciado.
/// - Validar parsing real de la respuesta del modelo.
/// - Considerar `Generable` structures para output estructurado.
struct FoundationModelsCoach: LanguageCoach {

    func explain(_ classification: Classification, context: CoachContext) async throws -> CoachResponse {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            let session = LanguageModelSession(instructions: systemInstructions)
            let prompt = """
            Acabo de identificar un residuo: \(classification.category.displayName) \
            (confianza \(classification.confidencePercentage)%, va al bote \(classification.category.binColor)).
            Genera:
            - Un resumen de 1 frase.
            - Una explicación de 2-3 frases sobre por qué pertenece a ese bote y cómo prepararlo.
            - Un tip accionable para reducir o reusar este tipo de residuo.
            Sé claro y directo. No inventes datos.
            """
            let response = try await session.respond(to: prompt)
            return parseResponse(
                response.content,
                fallbackConfidence: classification.isConfident ? .alta : .media
            )
        }
        #endif
        throw CoachError.unavailable
    }

    func reply(to message: String, history: [CoachMessage], context: CoachContext) async throws -> CoachResponse {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            let session = LanguageModelSession(instructions: systemInstructions)
            // TODO: pasar `history` como transcript real al session.
            let response = try await session.respond(to: message)
            return parseResponse(response.content, fallbackConfidence: .media)
        }
        #endif
        throw CoachError.unavailable
    }

    private var systemInstructions: String {
        """
        Eres un asistente de reciclaje y reducción de residuos en español mexicano.
        Sé breve, concreto y respetuoso. Cuando no estés seguro, dilo.
        Estructura tu respuesta así:
        - Resumen (1 frase)
        - Explicación (2-3 frases)
        - Tip accionable (opcional, 1 línea)
        Nunca inventes datos. Si la pregunta es ambigua, pide aclaración.
        """
    }

    private func parseResponse(
        _ text: String,
        fallbackConfidence: CoachResponse.Confidence
    ) -> CoachResponse {
        let lines = text
            .split(whereSeparator: \.isNewline)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        let summary = lines.first ?? text
        let detail = lines.dropFirst().first ?? ""
        let tip: String? = lines.count > 2 ? lines[2] : nil

        return CoachResponse(
            summary: summary,
            detail: detail,
            tip: tip,
            confidence: fallbackConfidence
        )
    }
}
