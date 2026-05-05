import Foundation
import SwiftUI

/// Datos agregados del centro durante un mes específico. Mock para hackathon —
/// en prod serían query a SwiftData / backend.
struct CentroWrappedData {
    let monthName: String       // "Mayo"
    let year: Int               // 2026
    let centroName: String      // "Composta Roma Norte"

    // Métricas core
    let kgProcessed: Int                // 2,300 kg
    let co2KgAvoided: Int               // 4,370 kg (factor 1.9)
    let activeRecolectores: Int         // 47
    let cubetasReceived: Int            // 312
    let kgAbonoReturned: Int            // 580 kg
    let lotesCompleted: Int             // 8

    // Comparación con mes anterior
    let kgGrowthPct: Int                // +18% vs abril
    let recolectorGrowthPct: Int        // +12

    // Top contributor
    let topRecolectorName: String
    let topRecolectorKg: Int

    // Equivalencias dramáticas
    var co2EquivCarKm: Int { Int(Double(co2KgAvoided) / 0.21) }   // ~21000 km
    var co2EquivTreesYear: Int { Int(Double(co2KgAvoided) / 22) } // ~200 árboles
}

extension CentroWrappedData {
    static let mock = CentroWrappedData(
        monthName: "Mayo",
        year: 2026,
        centroName: "Composta Roma Norte",
        kgProcessed: 2_300,
        co2KgAvoided: 4_370,
        activeRecolectores: 47,
        cubetasReceived: 312,
        kgAbonoReturned: 580,
        lotesCompleted: 8,
        kgGrowthPct: 18,
        recolectorGrowthPct: 12,
        topRecolectorName: "Jorge Jiménez",
        topRecolectorKg: 142
    )
}
