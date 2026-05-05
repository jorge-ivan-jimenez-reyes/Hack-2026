import Foundation
import ActivityKit

/// Atributos de la Live Activity de pickup. Se comparten entre la app y el
/// widget extension. Los `ContentState` cambian durante la vida de la actividad
/// (tu camión se acerca → llega → terminó). Los atributos estáticos definen
/// el contexto inmutable (centro, dirección).
public struct PickupActivityAttributes: ActivityAttributes {
    public typealias ContentState = PickupContentState

    public let centroName: String
    public let address: String

    public init(centroName: String, address: String) {
        self.centroName = centroName
        self.address = address
    }
}

public struct PickupContentState: Codable, Hashable, Sendable {
    /// Estado del pickup. La UI cambia según el step.
    public enum Step: String, Codable, Sendable {
        case scheduled       // agendado, en camino
        case arriving        // llegando en <5 min
        case arrived         // ya está afuera
        case completed       // recolección hecha
    }

    public var step: Step
    public var etaMinutes: Int
    public var driverName: String
    public var truckPlate: String

    public init(step: Step, etaMinutes: Int, driverName: String, truckPlate: String) {
        self.step = step
        self.etaMinutes = etaMinutes
        self.driverName = driverName
        self.truckPlate = truckPlate
    }
}
