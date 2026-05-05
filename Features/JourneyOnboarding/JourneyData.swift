import Foundation
import SwiftUI

/// Una estación del journey 3D. Cuenta una parte del cuento.
struct JourneyStation: Identifiable, Hashable {
    let id: Int
    let title: String
    let subtitle: String
    let accent: Color
    /// Posición de la station en el path 3D (eje X).
    let pathPosition: Float
}

extension JourneyStation {
    static let all: [JourneyStation] = [
        JourneyStation(
            id: 0,
            title: "Tu cubeta, tu ciclo",
            subtitle: "Separa tu orgánico en casa. Aquí empieza la economía circular.",
            accent: .brand,
            pathPosition: -2.4
        ),
        JourneyStation(
            id: 1,
            title: "Pasamos por ella",
            subtitle: "Te avisamos el día. Tú la dejas afuera, nosotros la cambiamos.",
            accent: .clay,
            pathPosition: -0.8
        ),
        JourneyStation(
            id: 2,
            title: "15 = 1",
            subtitle: "15 cubetas tuyas se transforman en 1 cubeta de abono real.",
            accent: .limeSpark,
            pathPosition: 0.8
        ),
        JourneyStation(
            id: 3,
            title: "Tu cuadra suma",
            subtitle: "Cuando tus vecinos también separan, todos ganan.",
            accent: .moss,
            pathPosition: 2.4
        )
    ]
}
