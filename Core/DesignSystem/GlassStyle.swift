import SwiftUI

/// Wrappers consistentes sobre `.glassEffect()` (iOS 26 Liquid Glass).
///
/// Reglas (de Apple HIG):
/// - Glass solo en navegación, CTAs flotantes, toolbars. NO en contenido scrolleable.
/// - Cuando hay >1 elemento glass agrupado, envolver en `GlassEffectContainer`.
/// - Tint debe convey semantic meaning (estado, prioridad), no decoración.

extension View {
    /// Glass card primaria — tarjetas flotantes sobre contenido.
    func glassCard(cornerRadius: CGFloat = Radius.l) -> some View {
        self
            .padding(Spacing.l)
            .glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
    }

    /// Glass card con tint semántico (ej. estado, marca).
    func glassCardTinted(_ color: Color, cornerRadius: CGFloat = Radius.l) -> some View {
        self
            .padding(Spacing.l)
            .glassEffect(.regular.tint(color), in: .rect(cornerRadius: cornerRadius))
    }

    /// Glass clear — para overlays sobre cámara o media.
    func glassOverlay(cornerRadius: CGFloat = Radius.m) -> some View {
        self
            .padding(Spacing.m)
            .glassEffect(.clear, in: .rect(cornerRadius: cornerRadius))
    }
}
