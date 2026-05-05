import Foundation

/// Rol del usuario en el ecosistema. Guardado en `@AppStorage("userRole")`.
/// El ProfileSelectionView lo asigna y RootView decide qué Home mostrar.
enum UserRole: String, CaseIterable, Identifiable {
    case recolector
    case centro

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .recolector: return "Recolector"
        case .centro:     return "Centro de acopio"
        }
    }
}
