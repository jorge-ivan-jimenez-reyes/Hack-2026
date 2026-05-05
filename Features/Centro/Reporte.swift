import Foundation

/// Reporte ciudadano que llega al centro. El recolector lo crea desde la app
/// (modelo Milán PULIamo) — el centro lo atiende.
struct Reporte: Identifiable, Hashable {
    let id: Int
    let kind: ReporteKind
    let location: String
    let reporterName: String
    let hoursAgo: Int
    let detail: String
    var status: ReporteStatus
}

enum ReporteKind: String, CaseIterable {
    case bucketDamage      // cubeta dañada
    case unusualSmell      // olor inusual
    case missedPickup      // no pasaron
    case wrongSeparation   // mala separación
    case other

    var label: String {
        switch self {
        case .bucketDamage:    return "Cubeta dañada"
        case .unusualSmell:    return "Olor inusual"
        case .missedPickup:    return "No pasaron"
        case .wrongSeparation: return "Mala separación"
        case .other:           return "Otro"
        }
    }

    var symbol: String {
        switch self {
        case .bucketDamage:    return "trash.slash.fill"
        case .unusualSmell:    return "wind"
        case .missedPickup:    return "clock.badge.xmark.fill"
        case .wrongSeparation: return "exclamationmark.triangle.fill"
        case .other:           return "ellipsis.bubble.fill"
        }
    }
}

enum ReporteStatus: String, CaseIterable {
    case open = "Abierto"
    case inProgress = "En curso"
    case resolved = "Resuelto"

    var symbol: String {
        switch self {
        case .open:       return "circle"
        case .inProgress: return "circle.lefthalf.filled"
        case .resolved:   return "checkmark.circle.fill"
        }
    }
}

extension Reporte {
    static let mock: [Reporte] = [
        Reporte(id: 0, kind: .bucketDamage, location: "Roma 124",
                reporterName: "Jorge Jiménez", hoursAgo: 2,
                detail: "La cubeta está rota en el asa. Necesito una limpia.",
                status: .open),
        Reporte(id: 1, kind: .unusualSmell, location: "Condesa 88",
                reporterName: "Ana López", hoursAgo: 5,
                detail: "Huele raro, creo que alguien metió lácteos.",
                status: .open),
        Reporte(id: 2, kind: .missedPickup, location: "Hipódromo 14",
                reporterName: "Mónica Torres", hoursAgo: 24,
                detail: "El miércoles no pasaron por mi cubeta.",
                status: .inProgress),
        Reporte(id: 3, kind: .wrongSeparation, location: "Roma Norte 37",
                reporterName: "Diego Vega", hoursAgo: 30,
                detail: "Vi que mi vecino metió plástico al orgánico.",
                status: .resolved),
        Reporte(id: 4, kind: .other, location: "Roma Sur 200",
                reporterName: "Carlos Ramírez", hoursAgo: 48,
                detail: "¿Pueden pasar más tarde el sábado?",
                status: .resolved)
    ]
}

enum ReporteFilter: String, CaseIterable, Identifiable {
    case all = "Todos"
    case open = "Abiertos"
    case inProgress = "En curso"
    case resolved = "Resueltos"

    var id: String { rawValue }

    func apply(to reportes: [Reporte]) -> [Reporte] {
        switch self {
        case .all:        return reportes
        case .open:       return reportes.filter { $0.status == .open }
        case .inProgress: return reportes.filter { $0.status == .inProgress }
        case .resolved:   return reportes.filter { $0.status == .resolved }
        }
    }
}
