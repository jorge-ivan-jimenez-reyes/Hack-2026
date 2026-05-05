import SwiftUI

/// View modifier que monta un `ReminderManager` y muestra el banner cuando
/// hay un reminder activo. Usar `.reminderHost()` en el root de la app.
struct ReminderHostModifier: ViewModifier {
    @State private var manager = ReminderManager()

    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content

            if let reminder = manager.current {
                ReminderBubble(reminder: reminder) {
                    manager.dismiss()
                }
                .padding(.top, 8)
                .transition(
                    .asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .move(edge: .top).combined(with: .opacity)
                    )
                )
                .zIndex(1)
            }
        }
        .onAppear {
            manager.start()
        }
    }
}

extension View {
    /// Monta el host de reminders in-app. Aplicar UNA vez en RootView.
    func reminderHost() -> some View {
        modifier(ReminderHostModifier())
    }
}
