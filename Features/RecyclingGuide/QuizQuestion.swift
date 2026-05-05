import Foundation

/// Una pregunta del quiz "¿Va a composta?". El usuario hace swipe right
/// (sí) o left (no). Las preguntas con `goesInCompost = false` que parecen
/// orgánicas (cítricos, lácteos, huesos) son las EDUCATIVAS — la mayoría
/// no sabe que NO van a composta casera.
struct QuizQuestion: Identifiable, Hashable {
    let id: Int
    let symbol: String           // SF Symbol del objeto
    let name: String             // "Cáscara de plátano"
    let goesInCompost: Bool      // respuesta correcta
    let explanation: String      // por qué (se muestra después de responder)
}

extension QuizQuestion {
    /// Banco de preguntas — mezcla obvias y educativas (las que la mayoría
    /// se equivoca). El reto del día toma 5 random de aquí.
    static let bank: [QuizQuestion] = [
        QuizQuestion(
            id: 0,
            symbol: "leaf.fill",
            name: "Cáscara de plátano",
            goesInCompost: true,
            explanation: "Sí. La cáscara aporta potasio y se descompone en 1-2 semanas."
        ),
        QuizQuestion(
            id: 1,
            symbol: "cup.and.saucer.fill",
            name: "Borra de café",
            goesInCompost: true,
            explanation: "Sí. El café molido es nitrógeno puro y acelera la composta."
        ),
        QuizQuestion(
            id: 2,
            symbol: "carrot.fill",
            name: "Restos de verduras",
            goesInCompost: true,
            explanation: "Sí. Cualquier vegetal crudo va — entre más picado, más rápido se descompone."
        ),
        QuizQuestion(
            id: 3,
            symbol: "fork.knife",
            name: "Huesos de pollo",
            goesInCompost: false,
            explanation: "No. Los huesos atraen plagas y tardan años en descomponerse en composta casera."
        ),
        QuizQuestion(
            id: 4,
            symbol: "drop.fill",
            name: "Lácteos / queso",
            goesInCompost: false,
            explanation: "No. Generan mal olor, atraen ratas y desbalancean la composta."
        ),
        QuizQuestion(
            id: 5,
            symbol: "circle.hexagongrid.fill",
            name: "Cáscara de naranja",
            goesInCompost: false,
            explanation: "No. Los cítricos son muy ácidos y matan a los microorganismos buenos."
        ),
        QuizQuestion(
            id: 6,
            symbol: "egg.fill",
            name: "Cascarón de huevo",
            goesInCompost: true,
            explanation: "Sí. Aporta calcio. Tritúralo antes para que se descomponga más rápido."
        ),
        QuizQuestion(
            id: 7,
            symbol: "newspaper.fill",
            name: "Periódico",
            goesInCompost: true,
            explanation: "Sí, en pedazos chicos. Aporta carbono (verde/marrón balance). Evita el papel brilloso."
        ),
        QuizQuestion(
            id: 8,
            symbol: "fish.fill",
            name: "Restos de pescado",
            goesInCompost: false,
            explanation: "No. Mismo problema que los lácteos: mal olor + plagas."
        ),
        QuizQuestion(
            id: 9,
            symbol: "leaf.arrow.circlepath",
            name: "Hojas secas",
            goesInCompost: true,
            explanation: "Sí. Material marrón ideal — balancea los húmedos (cáscaras, café)."
        )
    ]

    /// 5 preguntas random para el reto diario. Mezcla 3 fáciles + 2 educativas.
    static func dailyChallenge() -> [QuizQuestion] {
        Array(bank.shuffled().prefix(5))
    }
}
