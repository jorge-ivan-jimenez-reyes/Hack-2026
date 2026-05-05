import Foundation
import ActivityKit

/// Controller para iniciar/actualizar/terminar la Live Activity de pickup.
/// Disparado desde el flow de "Programar entrega" cuando agendas un pickup.
@MainActor
enum PickupLiveActivityController {

    /// Inicia la Live Activity. Devuelve true si se pudo arrancar
    /// (requiere permisos del usuario y que el dispositivo soporte Live Activities).
    @discardableResult
    static func start(
        centroName: String,
        address: String,
        driverName: String = "Mauricio",
        truckPlate: String = "MX-7821",
        initialEtaMinutes: Int = 25
    ) -> Bool {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            return false
        }

        let attributes = PickupActivityAttributes(centroName: centroName, address: address)
        let state = PickupContentState(
            step: .scheduled,
            etaMinutes: initialEtaMinutes,
            driverName: driverName,
            truckPlate: truckPlate
        )

        do {
            _ = try Activity.request(
                attributes: attributes,
                content: .init(state: state, staleDate: nil),
                pushType: nil
            )
            return true
        } catch {
            return false
        }
    }

    /// Actualiza el estado de la activity actual (si hay).
    static func update(step: PickupContentState.Step, etaMinutes: Int) async {
        for activity in Activity<PickupActivityAttributes>.activities {
            let updated = PickupContentState(
                step: step,
                etaMinutes: etaMinutes,
                driverName: activity.content.state.driverName,
                truckPlate: activity.content.state.truckPlate
            )
            await activity.update(.init(state: updated, staleDate: nil))
        }
    }

    /// Termina la Live Activity. Si `final` es true, deja el último estado visible
    /// hasta que el usuario lo cierre (post-pickup completado).
    static func end(final: Bool = true) async {
        for activity in Activity<PickupActivityAttributes>.activities {
            let dismissalPolicy: ActivityUIDismissalPolicy = final ? .default : .immediate
            await activity.end(activity.content, dismissalPolicy: dismissalPolicy)
        }
    }
}
