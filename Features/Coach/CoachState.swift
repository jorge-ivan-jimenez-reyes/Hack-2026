import Foundation
import Observation

@Observable @MainActor
final class CoachState {
    /// Mensaje del chat. Para el rol assistant guardamos opcionalmente la respuesta
    /// estructurada del coach (summary/detail/tip) para renderizar con secciones.
    struct Entry: Identifiable, Sendable {
        let id: UUID = UUID()
        let role: CoachMessage.Role
        let text: String
        let response: CoachResponse?
        let timestamp: Date = .now

        init(role: CoachMessage.Role, text: String, response: CoachResponse? = nil) {
            self.role = role
            self.text = text
            self.response = response
        }
    }

    var input: String = ""
    var entries: [Entry] = []
    var isThinking: Bool = false
    var availabilityNote: String?

    /// Sugerencias para arrancar la conversación. Se ocultan tras el primer mensaje.
    let suggestions: [String] = [
        "¿Qué hago con pilas usadas?",
        "¿El café molido es orgánico?",
        "¿Cómo sé si un plástico es PET?",
        "Tips para reducir basura en la cocina"
    ]

    private let coach: LanguageCoach

    init(coach: LanguageCoach? = nil) {
        self.coach = coach ?? AIServices.defaultCoach()
        if case .unavailable(let reason) = AIAvailability.foundationModels {
            availabilityNote = reason + " Estoy usando respuestas locales por ahora."
        }
    }

    func send(_ override: String? = nil) async {
        let text = (override ?? input).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        input = ""
        entries.append(.init(role: .user, text: text))
        isThinking = true

        let history = entries
            .filter { $0.response == nil ? true : true }
            .map { CoachMessage(role: $0.role, text: $0.text) }

        do {
            let response = try await coach.reply(to: text, history: history, context: .init())
            entries.append(.init(role: .assistant, text: response.summary, response: response))
        } catch {
            entries.append(.init(
                role: .assistant,
                text: "No pude responder ahorita. \(error.localizedDescription)"
            ))
        }
        isThinking = false
    }

    func reset() {
        entries.removeAll()
        input = ""
    }
}
