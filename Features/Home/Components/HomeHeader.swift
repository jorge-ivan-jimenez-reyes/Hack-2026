import SwiftUI

/// Header compacto del Home. Saludo, alcaldía y streak con flama animada.
/// El bloque de saludo es tappable — abre `SettingsView` cuando `onTapProfile` se pasa.
struct HomeHeader: View {
    let name: String
    let alcaldia: String
    let streakDays: Int
    var onTapProfile: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .center, spacing: Spacing.m) {
            Button {
                Haptics.tap()
                onTapProfile?()
            } label: {
                HStack(spacing: Spacing.s) {
                    avatar
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Hola, \(name) 👋")
                            .font(.appTitle2)
                            .foregroundStyle(.textPrimary)
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .font(.caption)
                            Text(alcaldia)
                                .font(.appCallout)
                        }
                        .foregroundStyle(.textSecondary)
                    }
                }
            }
            .buttonStyle(.plain)
            Spacer()
            streakBadge
        }
        .padding(.horizontal, Spacing.l)
        .padding(.top, Spacing.s)
    }

    private var avatar: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.brand, .brand.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Text(String(name.prefix(1)))
                .font(.appCallout.weight(.bold))
                .foregroundStyle(.cream)
        }
        .frame(width: 36, height: 36)
    }

    private var streakBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
                .font(.callout)
                .foregroundStyle(.orange)
                .symbolEffect(.pulse, options: .repeat(.continuous))
            Text("\(streakDays)")
                .font(.appHeadline.weight(.semibold))
                .foregroundStyle(.textPrimary)
                .contentTransition(.numericText())
        }
        .padding(.horizontal, Spacing.m)
        .padding(.vertical, Spacing.s)
        .glassEffect(.regular.tint(.orange.opacity(0.18)).interactive(), in: .capsule)
        .accessibilityLabel("Racha de \(streakDays) días")
    }
}
