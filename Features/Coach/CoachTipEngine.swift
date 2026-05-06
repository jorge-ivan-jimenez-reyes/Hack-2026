import Foundation

/// Genera tips del Coach IA contextuales al progreso del recolector.
/// El Home usa esto en vez de un string estático para que el coaching
/// se sienta vivo: cambia con tu cubeta, tu racha y tu ciclo 15:1.
///
/// Cada tip incluye:
/// - `text`: lo que se muestra en la `CoachTipCard`
/// - `prompt`: la pregunta semilla que se envía al Coach si tappeas
///   "hablar más" — abre la conversación con contexto, no en blanco.
struct ContextualCoachTip: Equatable {
    let text: String
    let prompt: String
    let symbolName: String
}

enum CoachTipEngine {
    static func tip(
        bucketProgress: Double,
        bucketsCompleted: Int,
        streakDays: Int
    ) -> ContextualCoachTip {

        // 1. Cierre de ciclo — máxima prioridad
        if bucketsCompleted >= RecolectorProgress.bucketsForAbono {
            return ContextualCoachTip(
                text: "Cerraste el ciclo 15:1. Te toca recibir abono — úsalo en tus plantas o regálalo a un vecino.",
                prompt: "Acabo de cerrar mi ciclo de 15 cubetas. ¿Cómo aprovecho mejor el abono que voy a recibir?",
                symbolName: "sparkles"
            )
        }

        // 2. Cubeta llena, pendiente programar entrega
        if bucketProgress >= 1.0 {
            return ContextualCoachTip(
                text: "Tu cubeta está al 100%. Programa la entrega antes de que empiece a oler — tienes ~2 días.",
                prompt: "Mi cubeta ya está llena. ¿Qué pasa si la dejo unos días antes de entregarla?",
                symbolName: "checkmark.seal.fill"
            )
        }

        // 3. Casi llena (80-99%)
        if bucketProgress >= 0.80 {
            let remaining = Int(((1.0 - bucketProgress) * 15).rounded(.up))
            return ContextualCoachTip(
                text: "Te faltan ~\(remaining) elementos para llenar la cubeta. Empieza a pensar en cuándo la entregas esta semana.",
                prompt: "Mi cubeta está casi llena. ¿Cuál es la mejor forma de mantenerla sin olor mientras la termino?",
                symbolName: "leaf.fill"
            )
        }

        // 4. Cerca del abono (13-14 cubetas completadas)
        if bucketsCompleted >= 13 {
            let toGo = RecolectorProgress.bucketsForAbono - bucketsCompleted
            return ContextualCoachTip(
                text: "Estás a \(toGo) cubeta\(toGo == 1 ? "" : "s") de recibir tu primer abono. La constancia paga 🌱",
                prompt: "Estoy a \(toGo) cubeta\(toGo == 1 ? "" : "s") del abono. ¿Cómo me aseguro de que mi composta sea de buena calidad?",
                symbolName: "flame.fill"
            )
        }

        // 5. Mitad de cubeta (45-79%)
        if bucketProgress >= 0.45 {
            return ContextualCoachTip(
                text: "Vas a la mitad. Tip: agrega un puñado de hojas secas o cartón roto para balancear humedad.",
                prompt: "¿Cómo balanceo verdes (cáscaras) y secos (hojas, cartón) en mi cubeta?",
                symbolName: "leaf.fill"
            )
        }

        // 6. Streak fuerte pero cubeta apenas empezando (raro pero posible al iniciar ciclo nuevo)
        if streakDays >= 14 && bucketProgress < 0.30 {
            return ContextualCoachTip(
                text: "Llevas \(streakDays) días de racha — increíble constancia. Sigue separando aunque sea poquito cada día.",
                prompt: "Llevo \(streakDays) días separando. ¿Qué hábitos refuerzan la racha en cocina?",
                symbolName: "flame.fill"
            )
        }

        // 7. Empezando — primeros días
        if streakDays <= 3 || bucketProgress < 0.15 {
            return ContextualCoachTip(
                text: "Empieza por lo más fácil: cáscaras de fruta, café molido, restos de verdura. Evita lácteos, cítricos y carne.",
                prompt: "Soy nuevo en composta. ¿Cuáles son los 3 errores más comunes que debo evitar?",
                symbolName: "sparkles"
            )
        }

        // 8. Default — fase normal de llenado
        return ContextualCoachTip(
            text: "Tip: la borra de café acelera la descomposición. Si la guardas todo el día, échala de una vez — funciona mejor que poco a poco.",
            prompt: "¿Qué residuos aceleran más la composta?",
            symbolName: "sparkles"
        )
    }
}
