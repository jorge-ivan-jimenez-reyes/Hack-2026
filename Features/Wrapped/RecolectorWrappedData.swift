import Foundation

/// Datos agregados del recolector durante un mes específico. Mock para hackathon —
/// en prod serían query a SwiftData (ScanRecord + entregas) / backend.
struct RecolectorWrappedData {
    let monthName: String
    let year: Int
    let recolectorName: String
    let alcaldia: String

    // Esfuerzo
    let cubetasFilled: Int          // 7
    let kgDiverted: Double          // 42.3
    let streakDays: Int             // 21
    let bestDay: String             // "Domingo"

    // Composición de lo que separó
    let topCategory: String         // "Cáscaras de fruta"
    let topCategoryPct: Int         // 38

    // Impacto
    let co2KgAvoided: Double        // 89

    // Cuadra
    let cuadraRankPercentile: Int   // top 12%
    let cuadraNeighbors: Int        // 47
    let cuadraTotalKg: Int          // 287

    // Devolución
    let kgAbonoRecibido: Double     // 18

    // Comparación con mes anterior
    let kgGrowthPct: Int            // +24%

    // Equivalencias
    var co2EquivCarKm: Int { Int(co2KgAvoided / 0.21) }       // ~424 km
    var co2EquivTreesYear: Double { co2KgAvoided / 22 }       // ~4 árboles
    var co2EquivLedHours: Int { Int(co2KgAvoided / 0.005) }   // ~17,800 hrs LED 10W
}

extension RecolectorWrappedData {
    static let mock = RecolectorWrappedData(
        monthName: "Mayo",
        year: 2026,
        recolectorName: "Jorge",
        alcaldia: "Roma Norte",
        cubetasFilled: 7,
        kgDiverted: 42.3,
        streakDays: 21,
        bestDay: "Domingo",
        topCategory: "Cáscaras de fruta",
        topCategoryPct: 38,
        co2KgAvoided: 89,
        cuadraRankPercentile: 12,
        cuadraNeighbors: 47,
        cuadraTotalKg: 287,
        kgAbonoRecibido: 18,
        kgGrowthPct: 24
    )
}
