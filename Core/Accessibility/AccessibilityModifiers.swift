import SwiftUI

extension View {
    /// Combina hijos en un solo elemento con label + hint para VoiceOver.
    func accessibleCard(label: String, hint: String? = nil) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
    }

    /// Asegura touch target mínimo de 44pt.
    func minTouchTarget() -> some View {
        frame(minWidth: 44, minHeight: 44)
            .contentShape(Rectangle())
    }

    /// Marca un elemento como en estado de carga para VoiceOver.
    func accessibilityLoading(_ isLoading: Bool, label: String = "Cargando") -> some View {
        accessibilityLabel(isLoading ? label : "")
            .accessibilityAddTraits(isLoading ? .updatesFrequently : [])
    }
}
