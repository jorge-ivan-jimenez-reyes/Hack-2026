import SwiftUI

/// Empty state estandarizado: ícono circular + título + subtitle + acción opcional.
/// Reusado en Lotes, Coach, Historial, etc. Mantiene voz consistente.
struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    var tint: Color = .brand
    var actionLabel: String? = nil
    var action: (() -> Void)? = nil

    @State private var bouncePulse = 0

    var body: some View {
        VStack(spacing: Spacing.l) {
            ZStack {
                Circle()
                    .fill(tint.opacity(0.12))
                    .frame(width: 96, height: 96)
                Image(systemName: icon)
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundStyle(tint)
                    .symbolEffect(.bounce, value: bouncePulse)
            }
            VStack(spacing: Spacing.s) {
                Text(title)
                    .font(.appTitle2.weight(.semibold))
                    .foregroundStyle(.inkCharcoal)
                    .multilineTextAlignment(.center)
                Text(subtitle)
                    .font(.appBody)
                    .foregroundStyle(.inkCharcoal.opacity(0.65))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.l)
            }
            if let label = actionLabel, let action {
                Button {
                    Haptics.tap()
                    action()
                } label: {
                    Text(label)
                        .font(.appHeadline.weight(.semibold))
                        .foregroundStyle(.cream)
                        .padding(.horizontal, Spacing.l)
                        .padding(.vertical, Spacing.m)
                        .background(tint, in: .capsule)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.xl)
        .onAppear {
            Task {
                while !Task.isCancelled {
                    try? await Task.sleep(for: .seconds(2.5))
                    bouncePulse += 1
                }
            }
        }
    }
}

#Preview("Lotes empty") {
    EmptyStateView(
        icon: "leaf.arrow.circlepath",
        title: "Aún no tienes lotes",
        subtitle: "Cuando recibas cubetas, podrás formar lotes y monitorear su salud aquí."
    )
}

#Preview("Filter empty") {
    EmptyStateView(
        icon: "line.3.horizontal.decrease.circle",
        title: "Sin resultados",
        subtitle: "No hay items que coincidan con este filtro."
    )
}

#Preview("Action") {
    EmptyStateView(
        icon: "tray",
        title: "Tu historial empezará a llenarse",
        subtitle: "Aquí verás tus escaneos, entregas y abono recibido.",
        actionLabel: "Empezar"
    ) {}
}
