import Foundation
import SwiftUI

/// Modelo agregado de inteligencia operacional para el Centro de Acopio.
/// Mock para hackathon — en prod vendrá de SwiftData/backend con queries
/// agregados sobre cubetas + reportes + lotes.
///
/// **Diferenciador del producto**: el centro recibe data rica que la libreta
/// de papel jamás daría. Aquí concentramos KPIs, series, heatmaps y los
/// "insights auto-generados" que son la capa de valor real.
struct CentroInsights {
    let monthLabel: String           // "Mayo 2026"

    // KPIs hero
    let kgThisMonth: Int
    let kgGrowthPct: Int             // delta vs mes pasado
    let activeRecolectores: Int
    let recolectorGrowthPct: Int
    let cubetasPerDay: Double
    let cubetasGrowthPct: Int

    // Series tiempo (últimos 30 días)
    let dailyVolume: [DailyVolumePoint]

    // Heatmap 7×24 (días × horas) con intensidad relativa 0..1
    let heatmap: [[Double]]

    // Top recolectores
    let topRecolectores: [TopRecolector]

    // Distribución por zona/colonia
    let zoneDistribution: [ZoneSlice]

    // Insights auto-generados (la magia)
    let autoInsights: [AutoInsight]

    // Salud operacional
    let healthScore: Int             // 0..100
    let healthBreakdown: [HealthFactor]
}

struct DailyVolumePoint: Identifiable, Hashable {
    let id = UUID()
    let date: Date
    let kg: Double
}

struct TopRecolector: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let kg: Int
    let cubetas: Int
}

struct ZoneSlice: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let pct: Double             // 0..1
    let tint: Color
}

/// Insight auto-generado por el sistema. El "label" categoriza el tono
/// (oportunidad / advertencia / celebración) y maneja iconografía + tint.
struct AutoInsight: Identifiable, Hashable {
    let id = UUID()
    let kind: Kind
    let title: String
    let body: String

    enum Kind: Hashable {
        case opportunity   // 🔥 puedes hacer X
        case alert         // ⚠️ revisa Y
        case win           // 🎉 vas bien
        case projection    // 📈 estimación

        var icon: String {
            switch self {
            case .opportunity: "bolt.fill"
            case .alert:       "exclamationmark.triangle.fill"
            case .win:         "sparkles"
            case .projection:  "chart.line.uptrend.xyaxis"
            }
        }

        var tint: Color {
            switch self {
            case .opportunity: .warning
            case .alert:       .danger
            case .win:         .brand
            case .projection:  .forestDeep
            }
        }

        var label: String {
            switch self {
            case .opportunity: "OPORTUNIDAD"
            case .alert:       "ALERTA"
            case .win:         "WIN"
            case .projection:  "PROYECCIÓN"
            }
        }
    }
}

struct HealthFactor: Identifiable, Hashable {
    let id = UUID()
    let label: String
    let score: Int      // 0..100
    let icon: String
}

// MARK: - Mock data

extension CentroInsights {
    static let mock: CentroInsights = {
        let cal = Calendar.current
        let today = Date()

        // 30 días con tendencia ligera al alza + ruido + pico el día 22
        let daily: [DailyVolumePoint] = (0..<30).reversed().map { offset in
            let day = cal.date(byAdding: .day, value: -offset, to: today)!
            let base = 60.0 + Double(29 - offset) * 1.4
            let noise = Double.random(in: -12...18)
            let weekendDip = (cal.component(.weekday, from: day) == 1 || cal.component(.weekday, from: day) == 7) ? -15.0 : 0
            let spike = (offset == 8) ? 35.0 : 0   // día pico ~hace 8 días
            return DailyVolumePoint(date: day, kg: max(20, base + noise + weekendDip + spike))
        }

        // Heatmap 7×24. Pico Mar 8am, secundario Jue 6pm.
        let heatmap: [[Double]] = (0..<7).map { dayIdx in
            (0..<24).map { hour in
                let isWorkHour = (7...20).contains(hour)
                guard isWorkHour else { return Double.random(in: 0.0...0.05) }
                let dayWeight: Double = [0.4, 0.95, 0.85, 0.90, 0.70, 0.55, 0.30][dayIdx]
                let hourBell = exp(-pow(Double(hour) - 9.0, 2) / 18.0)
                let evenBump = exp(-pow(Double(hour) - 18.0, 2) / 8.0) * 0.7
                let intensity = min(1.0, (hourBell + evenBump) * dayWeight + Double.random(in: -0.05...0.08))
                return max(0, intensity)
            }
        }

        let tops: [TopRecolector] = [
            TopRecolector(name: "Jorge Jiménez", kg: 142, cubetas: 24),
            TopRecolector(name: "Ana Mendoza",   kg: 128, cubetas: 21),
            TopRecolector(name: "Carlos Reyes",  kg: 110, cubetas: 18),
            TopRecolector(name: "Lucía Pérez",   kg:  95, cubetas: 16),
            TopRecolector(name: "Diego Herrera", kg:  82, cubetas: 14),
        ]

        let zones: [ZoneSlice] = [
            ZoneSlice(name: "Roma",      pct: 0.35, tint: .forestDeep),
            ZoneSlice(name: "Condesa",   pct: 0.28, tint: .clay),
            ZoneSlice(name: "Hipódromo", pct: 0.20, tint: .warning),
            ZoneSlice(name: "Juárez",    pct: 0.10, tint: .moss),
            ZoneSlice(name: "Otras",     pct: 0.07, tint: .info),
        ]

        let insights: [AutoInsight] = [
            AutoInsight(
                kind: .opportunity,
                title: "Tu pico es martes 8 am",
                body: "Si abres 1 h antes, los datos sugieren capturar +18 kg/día. Coordina con María."
            ),
            AutoInsight(
                kind: .projection,
                title: "Cierras el mes ~15% arriba",
                body: "Al ritmo actual: ~2,640 kg vs 2,300 del mes pasado. Prepara espacio para 60 cubetas extra."
            ),
            AutoInsight(
                kind: .alert,
                title: "Reportes de 'olor' subieron 40%",
                body: "Concentrados en lotes 6 y 7 — ambos en fase termofílica. Voltear hoy y aumentar marrones."
            ),
            AutoInsight(
                kind: .win,
                title: "Roma supera a Condesa por primera vez",
                body: "35% del volumen. La campaña con vecinos de marzo está pegando."
            ),
        ]

        let health: [HealthFactor] = [
            HealthFactor(label: "Cubetas en tiempo",     score: 92, icon: "clock.fill"),
            HealthFactor(label: "Reportes resueltos",    score: 78, icon: "checkmark.seal.fill"),
            HealthFactor(label: "Lotes saludables",      score: 85, icon: "leaf.fill"),
            HealthFactor(label: "Retención recolectores", score: 88, icon: "person.3.fill"),
        ]

        let healthScore = health.map(\.score).reduce(0, +) / health.count

        return CentroInsights(
            monthLabel: "Mayo 2026",
            kgThisMonth: 2_300,
            kgGrowthPct: 18,
            activeRecolectores: 47,
            recolectorGrowthPct: 12,
            cubetasPerDay: 10.4,
            cubetasGrowthPct: 9,
            dailyVolume: daily,
            heatmap: heatmap,
            topRecolectores: tops,
            zoneDistribution: zones,
            autoInsights: insights,
            healthScore: healthScore,
            healthBreakdown: health
        )
    }()
}
