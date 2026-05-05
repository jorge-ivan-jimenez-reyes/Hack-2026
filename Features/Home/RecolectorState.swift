import Foundation
import SwiftUI

/// Etapa del usuario en el ciclo 15:1. El Home es state-aware:
/// el Hero card cambia según en cuál de estas etapas estés.
enum RecolectorJourneyStage: Hashable {
    case onboardingPending
    case filling           // separando, cubeta < 100%
    case bucketReady       // cubeta llena, pendiente agendar pickup
    case waitingPickup     // pickup agendado, contando días
    case justDelivered     // pickup completado hoy
    case abonoReady        // 15/15 — toca recibir abono
}

/// Estado entero del recolector que alimenta el Home.
/// Para hackathon usamos `mock` con datos plausibles. En prod esto vendría
/// de SwiftData / backend.
/// Modalidad de servicio: pickup paid en casa o drop-off free al centro.
enum ServiceMode: String {
    case pickup     // suscripción pagada — pasamos a domicilio
    case dropOff    // gratis — usuario lleva al centro
}

/// Info del centro de acopio más cercano para el modo drop-off.
struct NearestCenter {
    var name: String
    var distanceKm: Double
    var nextOpeningDate: Date
}

struct RecolectorState {
    var name: String
    var alcaldia: String
    var streakDays: Int

    var stage: RecolectorJourneyStage
    var currentBucketProgress: Double  // 0.0 - 1.0
    var bucketsCompleted: Int          // 0 - 15

    var serviceMode: ServiceMode
    var nextPickupDate: Date?          // si serviceMode == .pickup
    var nearestCenter: NearestCenter?  // si serviceMode == .dropOff

    var totalKgDiverted: Double
    var co2SavedKg: Double

    var cuadraKgWeek: Double
    var cuadraRankPercentile: Int      // top X%
    var cuadraPremioGoalKg: Double

    var coachTip: String
}

extension RecolectorState {
    /// Estado del usuario nuevo — acaba de completar setup, todo en cero.
    /// Solo el centro más cercano está disponible (lo calculamos por su alcaldía).
    static let empty = RecolectorState(
        name: "Jorge",
        alcaldia: "Roma Norte",
        streakDays: 0,
        stage: .onboardingPending,
        currentBucketProgress: 0,
        bucketsCompleted: 0,
        serviceMode: .dropOff,
        nextPickupDate: nil,
        nearestCenter: NearestCenter(
            name: "Composta Roma Norte",
            distanceKm: 0.4,
            nextOpeningDate: Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now
        ),
        totalKgDiverted: 0,
        co2SavedKg: 0,
        cuadraKgWeek: 0,
        cuadraRankPercentile: 100,
        cuadraPremioGoalKg: 400,
        coachTip: "Acabas de empezar. Tu primera cubeta será la más importante — separa todo lo orgánico (cáscaras, café, restos de comida sin lácteos ni cítricos)."
    )

    /// Estado de demo — para presentaciones / pitch. Usuario "avanzado".
    static let mock = RecolectorState(
        name: "Jorge",
        alcaldia: "Roma Norte",
        streakDays: 12,
        stage: .filling,
        currentBucketProgress: 0.47,
        bucketsCompleted: 7,
        serviceMode: .dropOff,
        nextPickupDate: Calendar.current.date(byAdding: .day, value: 1, to: .now),
        nearestCenter: NearestCenter(
            name: "Composta Roma Norte",
            distanceKm: 0.4,
            nextOpeningDate: Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now
        ),
        totalKgDiverted: 42.3,
        co2SavedKg: 89.0,
        cuadraKgWeek: 287,
        cuadraRankPercentile: 12,
        cuadraPremioGoalKg: 400,
        coachTip: "Esta semana separaste muy bien. Tip: agrega borra de café para balancear el orgánico — ayuda a la planta a procesar más rápido."
    )
}
