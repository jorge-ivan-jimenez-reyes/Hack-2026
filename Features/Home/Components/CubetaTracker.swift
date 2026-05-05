import SwiftUI

/// Tracker visual del progreso 15:1. 15 cápsulas horizontales —
/// las completadas se llenan en brand, las pendientes vacías.
/// Animación en cascada cuando cambia `completed`.
struct CubetaTracker: View {
    let completed: Int
    var total: Int = 15

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            HStack {
                Text("Hacia tu abono")
                    .font(.appCallout)
                    .foregroundStyle(.textSecondary)
                Spacer()
                Text("\(completed)/\(total)")
                    .font(.appHeadline.weight(.semibold))
                    .foregroundStyle(.textPrimary)
                    .contentTransition(.numericText())
            }

            HStack(spacing: 4) {
                ForEach(0..<total, id: \.self) { index in
                    Capsule()
                        .fill(index < completed ? Color.brand : Color.brand.opacity(0.15))
                        .frame(height: 8)
                        .animation(
                            AppAnimation.spring.delay(Double(index) * 0.02),
                            value: completed
                        )
                }
            }
        }
        .padding(Spacing.l)
        .background {
            RoundedRectangle(cornerRadius: Radius.l)
                .fill(.ultraThinMaterial)
        }
        .padding(.horizontal, Spacing.l)
    }
}
