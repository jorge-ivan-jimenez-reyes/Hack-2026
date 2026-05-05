import SwiftUI

/// Floating Action Button del scanner. Siempre flotante en bottom-trailing,
/// glass tinted con brand para destacar sobre el surface del Home.
/// Es la acción #1 del producto — debe ser de 1 tap desde Home.
struct ScanFAB: View {
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.confirm()
            action()
        } label: {
            HStack(spacing: Spacing.s) {
                Image(systemName: "camera.viewfinder")
                    .font(.title3.weight(.semibold))
                Text("Escanear")
                    .font(.appHeadline.weight(.semibold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, Spacing.l)
            .padding(.vertical, Spacing.m)
            .glassEffect(
                .regular.tint(Color.brand.opacity(0.92)).interactive(),
                in: .capsule
            )
            .shadow(color: Color.brand.opacity(0.35), radius: 18, y: 8)
        }
        .accessibilityLabel("Escanear residuo con la cámara")
    }
}
