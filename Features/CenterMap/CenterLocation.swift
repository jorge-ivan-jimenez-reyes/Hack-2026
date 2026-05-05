import Foundation
import CoreLocation

/// Centro de acopio con datos para el mapa. Mock para hackathon —
/// en prod vendrían de backend / SEDEMA API.
struct CenterLocation: Identifiable, Hashable {
    let id: Int
    let name: String
    let alcaldia: String
    let coordinate: CLLocationCoordinate2D
    let openDays: [String]    // "Lun", "Mar", etc.
    let openHours: String     // "8:00 - 14:00"
    let capacityKgPerWeek: Int
    let acceptsAbono: Bool    // ¿devuelven abono al ciudadano?

    var openDaysShort: String {
        openDays.joined(separator: " · ")
    }
}

extension CenterLocation: Equatable {
    static func == (lhs: CenterLocation, rhs: CenterLocation) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension CenterLocation {
    /// Centros mock — coordenadas reales en CDMX (Roma, Condesa, Coyoacán).
    static let mock: [CenterLocation] = [
        CenterLocation(
            id: 0,
            name: "Composta Roma Norte",
            alcaldia: "Cuauhtémoc",
            coordinate: CLLocationCoordinate2D(latitude: 19.4156, longitude: -99.1626),
            openDays: ["Mar", "Jue", "Sáb"],
            openHours: "8:00 - 14:00",
            capacityKgPerWeek: 800,
            acceptsAbono: true
        ),
        CenterLocation(
            id: 1,
            name: "Centro Condesa",
            alcaldia: "Cuauhtémoc",
            coordinate: CLLocationCoordinate2D(latitude: 19.4109, longitude: -99.1718),
            openDays: ["Lun", "Mié", "Vie"],
            openHours: "9:00 - 13:00",
            capacityKgPerWeek: 600,
            acceptsAbono: true
        ),
        CenterLocation(
            id: 2,
            name: "Bordo Poniente (SEDEMA)",
            alcaldia: "Iztapalapa",
            coordinate: CLLocationCoordinate2D(latitude: 19.3500, longitude: -99.0300),
            openDays: ["Lun", "Mar", "Mié", "Jue", "Vie"],
            openHours: "7:00 - 16:00",
            capacityKgPerWeek: 5000,
            acceptsAbono: false
        ),
        CenterLocation(
            id: 3,
            name: "Composta Coyoacán",
            alcaldia: "Coyoacán",
            coordinate: CLLocationCoordinate2D(latitude: 19.3500, longitude: -99.1620),
            openDays: ["Sáb", "Dom"],
            openHours: "10:00 - 14:00",
            capacityKgPerWeek: 400,
            acceptsAbono: true
        )
    ]
}
