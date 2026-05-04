import Foundation

protocol LanguageCoach: Sendable {
    func explain(_ classification: Classification, context: CoachContext) async throws -> CoachResponse
    func reply(to message: String, history: [CoachMessage], context: CoachContext) async throws -> CoachResponse
}

struct CoachContext: Sendable {
    var location: String? = nil
    var locale: Locale = .init(identifier: "es_MX")
}

struct CoachMessage: Identifiable, Sendable {
    enum Role: Sendable { case user, assistant }
    let id: UUID
    let role: Role
    let text: String
    let timestamp: Date

    init(role: Role, text: String) {
        self.id = UUID()
        self.role = role
        self.text = text
        self.timestamp = .now
    }
}

struct CoachResponse: Sendable, Equatable {
    let summary: String
    let detail: String
    let tip: String?
    let confidence: Confidence

    enum Confidence: String, Sendable, Equatable { case alta, media, baja }
}

enum CoachError: LocalizedError {
    case unavailable
    case rateLimited
    case generationFailed(reason: String)

    var errorDescription: String? {
        switch self {
        case .unavailable:                "Apple Intelligence no está disponible en este dispositivo."
        case .rateLimited:                "Demasiadas peticiones. Intenta de nuevo en unos segundos."
        case .generationFailed(let r):    "No pude generar la respuesta: \(r)"
        }
    }
}
