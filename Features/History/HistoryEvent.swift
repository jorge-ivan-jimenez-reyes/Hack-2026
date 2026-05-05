import Foundation
import SwiftUI

/// Evento del historial del recolector. Tres tipos:
/// - escaneo de objeto (ScanRecord)
/// - entrega de cubeta al centro de acopio
/// - recepción de abono
///
/// La vista los junta en un solo timeline cronológico.
enum HistoryEvent: Identifiable {
    case scan(id: UUID, date: Date, category: WasteCategory, summary: String)
    case delivery(id: UUID, date: Date, kg: Double, centro: String)
    case abono(id: UUID, date: Date, kg: Double)

    var id: UUID {
        switch self {
        case .scan(let id, _, _, _): id
        case .delivery(let id, _, _, _): id
        case .abono(let id, _, _): id
        }
    }

    var date: Date {
        switch self {
        case .scan(_, let d, _, _): d
        case .delivery(_, let d, _, _): d
        case .abono(_, let d, _): d
        }
    }

    var title: String {
        switch self {
        case .scan(_, _, let c, _):       c.displayName
        case .delivery(_, _, let kg, _):  "Entregaste cubeta · \(kgFormatted(kg)) kg"
        case .abono(_, _, let kg):        "Recibiste abono · \(kgFormatted(kg)) kg"
        }
    }

    var subtitle: String {
        switch self {
        case .scan(_, _, _, let summary):     summary
        case .delivery(_, _, _, let centro):  "En \(centro)"
        case .abono:                          "Composta lista para tus plantas"
        }
    }

    var icon: String {
        switch self {
        case .scan(_, _, let c, _): c.symbolName
        case .delivery:             "tray.full.fill"
        case .abono:                "leaf.fill"
        }
    }

    var color: Color {
        switch self {
        case .scan(_, _, let c, _): c.color
        case .delivery:             .clay
        case .abono:                .moss
        }
    }

    private func kgFormatted(_ kg: Double) -> String {
        kg < 10 ? String(format: "%.1f", kg) : "\(Int(kg))"
    }
}

/// Mock events para demo. En producción vendrían de queries reales.
enum HistoryMock {
    static func events(now: Date = .now) -> [HistoryEvent] {
        let cal = Calendar.current
        func at(daysAgo: Int, hour: Int, minute: Int = 0) -> Date {
            let base = cal.date(byAdding: .day, value: -daysAgo, to: now) ?? now
            return cal.date(bySettingHour: hour, minute: minute, second: 0, of: base) ?? base
        }

        return [
            .abono(id: UUID(), date: at(daysAgo: 1, hour: 10),
                   kg: 4.2),
            .delivery(id: UUID(), date: at(daysAgo: 2, hour: 9, minute: 15),
                      kg: 3.1, centro: "Composta Roma Norte"),
            .scan(id: UUID(), date: at(daysAgo: 3, hour: 19, minute: 30),
                  category: .organic,
                  summary: "Cáscaras de plátano y café molido"),
            .scan(id: UUID(), date: at(daysAgo: 4, hour: 13, minute: 5),
                  category: .pet,
                  summary: "Botella PET — bote amarillo"),
            .delivery(id: UUID(), date: at(daysAgo: 7, hour: 9),
                      kg: 2.8, centro: "Composta Roma Norte"),
            .scan(id: UUID(), date: at(daysAgo: 8, hour: 20),
                  category: .organic,
                  summary: "Restos de verdura fresca"),
            .scan(id: UUID(), date: at(daysAgo: 10, hour: 11),
                  category: .glass,
                  summary: "Frasco de mermelada — bote azul"),
            .abono(id: UUID(), date: at(daysAgo: 14, hour: 10),
                   kg: 3.6),
            .delivery(id: UUID(), date: at(daysAgo: 15, hour: 9, minute: 20),
                      kg: 2.4, centro: "Composta Roma Norte"),
            .scan(id: UUID(), date: at(daysAgo: 16, hour: 18),
                  category: .organic,
                  summary: "Bolsitas de té y peladura"),
            .delivery(id: UUID(), date: at(daysAgo: 22, hour: 9),
                      kg: 2.1, centro: "Composta Roma Norte"),
        ]
    }
}
