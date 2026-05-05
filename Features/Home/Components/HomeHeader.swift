import SwiftUI

/// Header compacto del Home. Saludo, alcaldía y streak con flama animada.
struct HomeHeader: View {
    let name: String
    let alcaldia: String
    let streakDays: Int

    var body: some View {
        HStack(alignment: .center, spacing: Spacing.m) {
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
            Spacer()
            streakBadge
        }
        .padding(.horizontal, Spacing.l)
        .padding(.top, Spacing.s)
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
