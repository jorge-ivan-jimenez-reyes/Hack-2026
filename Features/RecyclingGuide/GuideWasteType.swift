import SwiftUI

/// Tres tipos de residuos del sistema de clasificación municipal mexicano
/// (basado en la Guía de Reciclaje de bolsas de color).
///
/// DIFERENTE de `WasteCategory` — ese enum es para el scanner/clasificador de CV.
/// Este modelo es para la sección educativa de la guía.
enum GuideWasteType: String, CaseIterable, Identifiable, Hashable {
    case organic   // Bolsa / contenedor verde
    case inorganic // Bolsa / contenedor azul
    case sanitary  // Bolsa / contenedor naranja

    var id: String { rawValue }

    var title: String {
        switch self {
        case .organic:   "Residuos Orgánicos"
        case .inorganic: "Residuos Inorgánicos"
        case .sanitary:  "Residuos Sanitarios"
        }
    }

    var subtitle: String {
        switch self {
        case .organic:   "De origen biológico y compostables"
        case .inorganic: "Reciclables y reutilizables"
        case .sanitary:  "Con riesgo de contaminación"
        }
    }

    var binColorName: String {
        switch self {
        case .organic:   "Verde"
        case .inorganic: "Azul"
        case .sanitary:  "Naranja"
        }
    }

    var tint: Color {
        switch self {
        case .organic:   .brand
        case .inorganic: .info
        case .sanitary:  .clay
        }
    }

    var symbol: String {
        switch self {
        case .organic:   "leaf.fill"
        case .inorganic: "arrow.3.trianglepath"
        case .sanitary:  "cross.case.fill"
        }
    }

    /// Nombre del JSON en Resources/Lottie/ — LottiePlayer tiene fallback automático.
    var lottieAnimation: String {
        switch self {
        case .organic:   "guide-organic"
        case .inorganic: "guide-inorganic"
        case .sanitary:  "guide-sanitary"
        }
    }

    var separationSteps: [String] {
        switch self {
        case .organic:
            return [
                "Enjuaga ligeramente",
                "Aplasta y/o corta en trozos",
                "Evita mezclar con otros residuos"
            ]
        case .inorganic:
            return [
                "Enjuaga los envases",
                "Aplasta para reducir volumen",
                "Separa por tipo de material si es posible"
            ]
        case .sanitary:
            return [
                "Cierra bien la bolsa naranja",
                "Identifica con la tira clasificadora del municipio",
                "Entrega al servicio de manejo integral"
            ]
        }
    }

    var disposalNote: String {
        switch self {
        case .organic:
            return "Si puedes compostar en casa úsalo como abono o alimento para animales — es la mejor opción. Si no, entrega en bolsa o contenedor verde al servicio municipal."
        case .inorganic:
            return "Entrega en bolsa o contenedor azul al servicio de manejo integral de residuos público o privado de tu municipio."
        case .sanitary:
            return "Entrega en bolsa o contenedor naranja. El aceite comestible se deposita en recipiente cerrado por separado."
        }
    }

    var items: [GuideWasteItem] { GuideWasteItem.items(for: self) }
}

// MARK: - GuideWasteItem

struct GuideWasteItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let symbol: String
}

extension GuideWasteItem {
    static func items(for type: GuideWasteType) -> [GuideWasteItem] {
        switch type {
        case .organic:   organicItems
        case .inorganic: inorganicItems
        case .sanitary:  sanitaryItems
        }
    }

    static let organicItems: [GuideWasteItem] = [
        .init(name: "Restos de comida",              symbol: "fork.knife"),
        .init(name: "Cáscaras de frutas y verduras", symbol: "leaf.fill"),
        .init(name: "Cascarón de huevo",             symbol: "egg.fill"),
        .init(name: "Pelo",                          symbol: "sparkles"),
        .init(name: "Restos de café y té",           symbol: "cup.and.saucer.fill"),
        .init(name: "Filtros de café y té",          symbol: "doc.fill"),
        .init(name: "Pan y tortillas",               symbol: "circle.fill"),
        .init(name: "Bagazo de frutas",              symbol: "carrot.fill"),
        .init(name: "Productos lácteos",             symbol: "drop.fill"),
        .init(name: "Servilletas con alimento",      symbol: "doc.plaintext.fill"),
        .init(name: "Residuos de jardín",            symbol: "tree.fill"),
        .init(name: "Tierra y polvo",                symbol: "globe.americas.fill"),
        .init(name: "Ceniza y aserrín",              symbol: "cloud.fill"),
        .init(name: "Huesos y productos cárnicos",   symbol: "fish.fill"),
    ]

    static let inorganicItems: [GuideWasteItem] = [
        .init(name: "Papel",                   symbol: "doc.fill"),
        .init(name: "Periódico",               symbol: "newspaper.fill"),
        .init(name: "Cartón",                  symbol: "shippingbox.fill"),
        .init(name: "Plásticos",               symbol: "drop.fill"),
        .init(name: "Vidrio",                  symbol: "wineglass.fill"),
        .init(name: "Metales",                 symbol: "wrench.adjustable.fill"),
        .init(name: "Textiles",                symbol: "scissors"),
        .init(name: "Maderas procesadas",      symbol: "hammer.fill"),
        .init(name: "Envases de multicapas",   symbol: "archivebox.fill"),
        .init(name: "Bolsas de frituras",      symbol: "bag.fill"),
        .init(name: "Utensilios de cocina",    symbol: "fork.knife"),
        .init(name: "Cerámica",                symbol: "cup.and.saucer.fill"),
        .init(name: "Juguetes",                symbol: "gamecontroller.fill"),
        .init(name: "Calzado",                 symbol: "figure.walk"),
        .init(name: "Cuero",                   symbol: "creditcard.fill"),
        .init(name: "Radiografías",            symbol: "rays"),
        .init(name: "CD's y cartuchos",        symbol: "opticaldisc"),
    ]

    static let sanitaryItems: [GuideWasteItem] = [
        .init(name: "Papel Sanitario",              symbol: "doc.fill"),
        .init(name: "Pañales desechables",          symbol: "person.2.fill"),
        .init(name: "Toallas Sanitarias",           symbol: "bandage.fill"),
        .init(name: "Material de curación",         symbol: "cross.case.fill"),
        .init(name: "Pañuelos desechables",         symbol: "wind"),
        .init(name: "Rastrillos de rasurar",        symbol: "scissors"),
        .init(name: "Preservativos",                symbol: "minus.circle.fill"),
        .init(name: "Jeringas desechables",         symbol: "syringe.fill"),
        .init(name: "Agujas desechables",           symbol: "pin.fill"),
        .init(name: "Excretas de animales",         symbol: "pawprint.fill"),
        .init(name: "Colillas de cigarro",          symbol: "flame.fill"),
        .init(name: "Aceite comestible",            symbol: "drop.fill"),
        .init(name: "Fibras para aseo",             symbol: "sparkles"),
        .init(name: "Medicamentos caducos",         symbol: "pills.fill"),
        .init(name: "Residuos domésticos peligrosos", symbol: "exclamationmark.triangle.fill"),
    ]
}
