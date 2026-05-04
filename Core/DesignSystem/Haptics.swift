import UIKit

/// Feedback háptico coherente en toda la app.
/// Reglas:
/// - `tap()` para acciones triviales (toggle, switch tab).
/// - `confirm()` para acciones significativas (capture, send).
/// - `success()` cuando algo terminó bien (save).
/// - `warning()` / `error()` para errores recuperables / no.
/// - `selection()` para selección dentro de una lista.
enum Haptics {
    static func tap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func confirm() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    static func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
}
