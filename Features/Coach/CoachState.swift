import Foundation
import Observation

@Observable @MainActor
final class CoachState {
    var input: String = ""
    var messages: [CoachMessage] = []
    var isThinking: Bool = false
    var availabilityNote: String?

    private let coach: LanguageCoach

    init(coach: LanguageCoach = MockLanguageCoach()) {
        self.coach = coach
        if case .unavailable(let reason) = AIAvailability.foundationModels {
            availabilityNote = reason + " Usando respuestas locales por ahora."
        }
    }

    func send() async {
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        input = ""
        messages.append(.init(role: .user, text: text))
        isThinking = true
        defer { isThinking = false }

        do {
            let response = try await coach.reply(to: text, history: messages, context: .init())
            let combined = [response.summary, response.detail, response.tip]
                .compactMap { $0 }
                .filter { !$0.isEmpty }
                .joined(separator: "\n\n")
            messages.append(.init(role: .assistant, text: combined))
        } catch {
            messages.append(.init(role: .assistant, text: "Error: \(error.localizedDescription)"))
        }
    }
}
