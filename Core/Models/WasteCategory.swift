import SwiftUI

enum WasteCategory: String, CaseIterable, Codable, Sendable, Identifiable {
    case organic
    case pet
    case glass
    case paper
    case metal
    case electronic
    case unknown

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .organic:    "Orgánico"
        case .pet:        "PET / plástico"
        case .glass:      "Vidrio"
        case .paper:      "Papel y cartón"
        case .metal:      "Metal"
        case .electronic: "Electrónico"
        case .unknown:    "No identificado"
        }
    }

    var binColor: String {
        switch self {
        case .organic:    "Verde"
        case .pet:        "Amarillo"
        case .glass:      "Azul"
        case .paper:      "Gris"
        case .metal:      "Rojo"
        case .electronic: "Negro (especial)"
        case .unknown:    "—"
        }
    }

    var symbolName: String {
        switch self {
        case .organic:    "leaf.fill"
        case .pet:        "drop.fill"
        case .glass:      "wineglass.fill"
        case .paper:      "doc.fill"
        case .metal:      "wrench.adjustable.fill"
        case .electronic: "bolt.fill"
        case .unknown:    "questionmark.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .organic:    .wasteOrganic
        case .pet:        .wastePET
        case .glass:      .wasteGlass
        case .paper:      .wastePaper
        case .metal:      .wasteMetal
        case .electronic: .wasteElectronic
        case .unknown:    .textTertiary
        }
    }
}
