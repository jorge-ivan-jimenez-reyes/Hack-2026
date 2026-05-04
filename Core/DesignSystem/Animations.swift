import SwiftUI

/// Presets de animación coherentes para toda la app.
/// Usar siempre estos en vez de literales — mantiene la sensación uniforme
/// y permite ajustar el "feel" desde un solo lugar.
enum AppAnimation {
    // Springs
    static let spring = Animation.spring(response: 0.4, dampingFraction: 0.78)
    static let bouncy = Animation.spring(response: 0.5, dampingFraction: 0.62)

    // Curves
    static let smooth   = Animation.smooth(duration: 0.3)
    static let snappy   = Animation.snappy(duration: 0.25)
    static let entrance = Animation.easeOut(duration: 0.4)
    static let exit     = Animation.easeIn(duration: 0.22)

    /// Para animar elementos en cascada (ej. lista de pills en onboarding).
    static func stagger(index: Int, base: Double = 0.07) -> Animation {
        entrance.delay(0.15 + Double(index) * base)
    }
}
