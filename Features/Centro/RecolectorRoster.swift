import Foundation

/// Recolector registrado en el centro. Mock para hackathon.
struct RecolectorEntry: Identifiable, Hashable {
    let id: Int
    let name: String
    let initials: String
    let alcaldia: String
    let bucketsCompleted: Int       // 0-15
    let lastDeliveryDaysAgo: Int    // días desde última entrega
    let totalKgDelivered: Double

    /// Está listo para recibir su cubeta de abono (15/15)
    var readyForAbono: Bool { bucketsCompleted >= 15 }

    /// Activo si entregó en los últimos 7 días
    var isActive: Bool { lastDeliveryDaysAgo <= 7 }
}

extension RecolectorEntry {
    static let mock: [RecolectorEntry] = [
        RecolectorEntry(id: 0, name: "Jorge Jiménez", initials: "JJ",
                        alcaldia: "Roma Norte", bucketsCompleted: 15,
                        lastDeliveryDaysAgo: 1, totalKgDelivered: 42.3),
        RecolectorEntry(id: 1, name: "Ana María López", initials: "AM",
                        alcaldia: "Condesa", bucketsCompleted: 14,
                        lastDeliveryDaysAgo: 2, totalKgDelivered: 38.5),
        RecolectorEntry(id: 2, name: "Carlos Ramírez", initials: "CR",
                        alcaldia: "Roma Sur", bucketsCompleted: 12,
                        lastDeliveryDaysAgo: 4, totalKgDelivered: 31.2),
        RecolectorEntry(id: 3, name: "Mónica Torres", initials: "MT",
                        alcaldia: "Hipódromo", bucketsCompleted: 9,
                        lastDeliveryDaysAgo: 5, totalKgDelivered: 24.0),
        RecolectorEntry(id: 4, name: "Diego Vega", initials: "DV",
                        alcaldia: "Roma Norte", bucketsCompleted: 7,
                        lastDeliveryDaysAgo: 3, totalKgDelivered: 18.4),
        RecolectorEntry(id: 5, name: "Sofía Martínez", initials: "SM",
                        alcaldia: "Condesa", bucketsCompleted: 5,
                        lastDeliveryDaysAgo: 12, totalKgDelivered: 12.5),
        RecolectorEntry(id: 6, name: "Esteban Mayoral", initials: "EM",
                        alcaldia: "Roma Norte", bucketsCompleted: 4,
                        lastDeliveryDaysAgo: 8, totalKgDelivered: 9.8),
        RecolectorEntry(id: 7, name: "Mon Navarro", initials: "MN",
                        alcaldia: "Hipódromo", bucketsCompleted: 3,
                        lastDeliveryDaysAgo: 18, totalKgDelivered: 7.2),
        RecolectorEntry(id: 8, name: "Iñaki Robles", initials: "IR",
                        alcaldia: "Roma Sur", bucketsCompleted: 2,
                        lastDeliveryDaysAgo: 21, totalKgDelivered: 4.5)
    ]
}

enum RecolectorFilter: String, CaseIterable, Identifiable {
    case all = "Todos"
    case active = "Activos"
    case readyForAbono = "Para abono"
    case inactive = "Inactivos"

    var id: String { rawValue }

    func apply(to entries: [RecolectorEntry]) -> [RecolectorEntry] {
        switch self {
        case .all:           return entries
        case .active:        return entries.filter { $0.isActive }
        case .readyForAbono: return entries.filter { $0.readyForAbono }
        case .inactive:      return entries.filter { !$0.isActive }
        }
    }
}
