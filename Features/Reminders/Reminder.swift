import SwiftUI

/// Un reminder/tip del Coach IA que se muestra como banner in-app.
/// Estilo notificación pero NO push real (sin permisos de sistema).
struct Reminder: Identifiable, Hashable {
    let id: Int
    let symbol: String
    let title: String
    let body: String
    let tint: Color
    let kind: ReminderKind
}

enum ReminderKind {
    case tip            // consejo del coach
    case streak         // recordatorio de racha
    case pickup         // pickup proximamente
    case center         // centro abre pronto
    case cuadra         // cuadra cerca de premio
    case achievement    // logro desbloqueado
}

extension Reminder {
    /// Banco de reminders mock. En prod estos los genera Foundation Models
    /// on-device en base al historial real del usuario.
    static let bank: [Reminder] = [
        Reminder(
            id: 0,
            symbol: "flame.fill",
            title: "12 días seguidos",
            body: "No rompas la racha. Saca tu cubeta hoy.",
            tint: .orange,
            kind: .streak
        ),
        Reminder(
            id: 1,
            symbol: "sparkles",
            title: "Tip del Coach",
            body: "Esta semana tienes mucho café. Agrega cartón seco para balancear.",
            tint: .brand,
            kind: .tip
        ),
        Reminder(
            id: 2,
            symbol: "mappin.circle.fill",
            title: "Tu centro abre en 30 min",
            body: "Composta Roma Norte · 8:00am · Lleva tu cubeta para entrega.",
            tint: .info,
            kind: .center
        ),
        Reminder(
            id: 3,
            symbol: "house.lodge.fill",
            title: "Tu cuadra está cerca",
            body: "Faltan 13 kg para el premio comunitario. Vamos.",
            tint: .moss,
            kind: .cuadra
        ),
        Reminder(
            id: 4,
            symbol: "leaf.fill",
            title: "Sabías que…",
            body: "Cítricos NO van a composta casera. Son ácidos y matan microorganismos.",
            tint: .clay,
            kind: .tip
        ),
        Reminder(
            id: 5,
            symbol: "trophy.fill",
            title: "¡Nuevo logro!",
            body: "Completaste 7 cubetas. Faltan 8 para tu cubeta de abono.",
            tint: .clay,
            kind: .achievement
        ),
        Reminder(
            id: 6,
            symbol: "shippingbox.fill",
            title: "Pickup mañana 6am",
            body: "Saca tu cubeta a la banqueta antes de las 6:00am del martes.",
            tint: .info,
            kind: .pickup
        )
    ]
}
