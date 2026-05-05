import Foundation
import SwiftUI

/// Una "tanda" de composta en proceso en el centro. Datos del operador
/// + análisis del IA on-device.
struct CompostBatch: Identifiable, Hashable {
    let id: Int
    var name: String                     // "Lote #18"
    var startDate: Date                  // cuándo empezó el proceso
    var temperatureCelsius: Double       // 0-80°C típico
    var humidityPercent: Double          // 0-100%
    var lastTurnDaysAgo: Int             // días desde último volteo
    var smell: SmellLevel
    var mixType: MixType
    var photoTone: PhotoTone?            // resultado de análisis de foto, opcional
    var photoCapturedAgo: Int?           // hace cuántos días se subió la foto

    /// Días en proceso (calculado desde startDate)
    var daysInProcess: Int {
        Calendar.current.dateComponents([.day], from: startDate, to: .now).day ?? 0
    }

    /// Etapa típica del proceso de composta
    var phase: CompostPhase {
        switch daysInProcess {
        case 0..<7:    return .mesophilic     // Inicial — bacteria activándose
        case 7..<35:   return .thermophilic   // Activa — la temperatura sube
        case 35..<90:  return .cooling        // Enfriamiento + maduración
        default:       return .curing         // Curado final
        }
    }
}

enum SmellLevel: String, CaseIterable, Identifiable {
    case normal = "Normal"
    case slight = "Leve"
    case strong = "Fuerte"

    var id: String { rawValue }
    var symbol: String {
        switch self {
        case .normal: return "wind"
        case .slight: return "wind.snow"
        case .strong: return "exclamationmark.triangle.fill"
        }
    }
    var tint: Color {
        switch self {
        case .normal: return .brand
        case .slight: return .warning
        case .strong: return .danger
        }
    }
}

enum MixType: String, CaseIterable, Identifiable {
    case balanced = "Balanceada"
    case greenHeavy = "Mucho verde"
    case brownHeavy = "Mucho marrón"

    var id: String { rawValue }
    var symbol: String {
        switch self {
        case .balanced:   return "scale.3d"
        case .greenHeavy: return "leaf.fill"
        case .brownHeavy: return "leaf.arrow.circlepath"
        }
    }
    var description: String {
        switch self {
        case .balanced:   return "Verde + marrón en equilibrio"
        case .greenHeavy: return "Demasiado nitrógeno (cáscaras, café)"
        case .brownHeavy: return "Demasiado carbono (papel, hojas secas)"
        }
    }
}

enum PhotoTone: String, CaseIterable, Identifiable {
    case darkBrown = "Café oscuro"
    case green = "Verde"
    case lightDry = "Claro / seco"
    case mixed = "Mezclado"

    var id: String { rawValue }
    var interpretation: String {
        switch self {
        case .darkBrown: return "Composta avanzada, cerca de listo"
        case .green:     return "Mucho material reciente sin descomponer"
        case .lightDry:  return "Falta humedad, posible exceso de marrón"
        case .mixed:     return "En proceso saludable"
        }
    }
}

enum CompostPhase: String {
    case mesophilic   = "Mesofílica"     // 0-7 días
    case thermophilic = "Termofílica"    // 7-35 días — debería estar caliente
    case cooling      = "Enfriamiento"   // 35-90 días
    case curing       = "Curado"         // 90+ días

    var idealTempRange: ClosedRange<Double> {
        switch self {
        case .mesophilic:   return 25...40
        case .thermophilic: return 50...65
        case .cooling:      return 35...50
        case .curing:       return 20...35
        }
    }

    var idealHumidityRange: ClosedRange<Double> {
        50...60   // siempre 50-60% es ideal
    }

    var maxTurnDays: Int {
        switch self {
        case .mesophilic:   return 3
        case .thermophilic: return 5
        case .cooling:      return 10
        case .curing:       return 15
        }
    }
}

enum RiskLevel: String, Comparable {
    case low = "Bajo"
    case medium = "Medio"
    case high = "Alto"

    static func < (lhs: RiskLevel, rhs: RiskLevel) -> Bool {
        let order: [RiskLevel: Int] = [.low: 0, .medium: 1, .high: 2]
        return (order[lhs] ?? 0) < (order[rhs] ?? 0)
    }

    var tint: Color {
        switch self {
        case .low: return .brand
        case .medium: return .warning
        case .high: return .danger
        }
    }
    var symbol: String {
        switch self {
        case .low: return "checkmark.circle.fill"
        case .medium: return "exclamationmark.circle.fill"
        case .high: return "exclamationmark.triangle.fill"
        }
    }
}

extension CompostBatch {
    /// Mock — 5 lotes con distintas condiciones para demo.
    static let mock: [CompostBatch] = [
        // Lote saludable
        CompostBatch(
            id: 18,
            name: "Lote #18",
            startDate: Calendar.current.date(byAdding: .day, value: -14, to: .now)!,
            temperatureCelsius: 58,
            humidityPercent: 55,
            lastTurnDaysAgo: 2,
            smell: .normal,
            mixType: .balanced,
            photoTone: .mixed,
            photoCapturedAgo: 1
        ),
        // Lote con problema medio — temp baja
        CompostBatch(
            id: 21,
            name: "Lote #21",
            startDate: Calendar.current.date(byAdding: .day, value: -10, to: .now)!,
            temperatureCelsius: 38,
            humidityPercent: 52,
            lastTurnDaysAgo: 6,
            smell: .normal,
            mixType: .greenHeavy,
            photoTone: .green,
            photoCapturedAgo: 3
        ),
        // Lote con problema alto — humedad excesiva
        CompostBatch(
            id: 23,
            name: "Lote #23",
            startDate: Calendar.current.date(byAdding: .day, value: -18, to: .now)!,
            temperatureCelsius: 42,
            humidityPercent: 78,
            lastTurnDaysAgo: 4,
            smell: .strong,
            mixType: .greenHeavy,
            photoTone: nil,
            photoCapturedAgo: nil
        ),
        // Lote en curado — listo casi
        CompostBatch(
            id: 12,
            name: "Lote #12",
            startDate: Calendar.current.date(byAdding: .day, value: -75, to: .now)!,
            temperatureCelsius: 28,
            humidityPercent: 50,
            lastTurnDaysAgo: 8,
            smell: .normal,
            mixType: .balanced,
            photoTone: .darkBrown,
            photoCapturedAgo: 5
        ),
        // Lote nuevo
        CompostBatch(
            id: 25,
            name: "Lote #25",
            startDate: Calendar.current.date(byAdding: .day, value: -3, to: .now)!,
            temperatureCelsius: 32,
            humidityPercent: 60,
            lastTurnDaysAgo: 1,
            smell: .normal,
            mixType: .balanced,
            photoTone: nil,
            photoCapturedAgo: nil
        )
    ]
}
