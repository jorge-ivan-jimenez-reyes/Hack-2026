import SwiftUI

/// Strip horizontal scrolleable de cards de impacto.
/// 4 cards: kg desviados, CO2 evitado, streak, equivalencia chistosa.
struct ImpactRow: View {
    let totalKg: Double
    let co2Kg: Double
    let streakDays: Int

    private var carKmEquivalent: Int {
        // Aproximación: ~0.26 kg CO2 por km en coche promedio
        Int((co2Kg / 0.26).rounded())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            Text("Tu impacto")
                .font(.appHeadline.weight(.semibold))
                .foregroundStyle(.textPrimary)
                .padding(.horizontal, Spacing.l)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.m) {
                    ImpactCell(
                        value: String(format: "%.1f", totalKg),
                        unit: "kg",
                        label: "desviados",
                        icon: "scalemass.fill",
                        tint: .brand
                    )
                    ImpactCell(
                        value: String(format: "%.0f", co2Kg),
                        unit: "kg",
                        label: "CO₂ evitado",
                        icon: "leaf.fill",
                        tint: .success
                    )
                    ImpactCell(
                        value: "\(streakDays)",
                        unit: "días",
                        label: "racha",
                        icon: "flame.fill",
                        tint: .orange
                    )
                    ImpactCell(
                        value: "≈\(carKmEquivalent)",
                        unit: "km",
                        label: "en coche",
                        icon: "car.fill",
                        tint: .info
                    )
                }
                .padding(.horizontal, Spacing.l)
            }
        }
    }
}

private struct ImpactCell: View {
    let value: String
    let unit: String
    let label: String
    let icon: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(tint)
                .frame(width: 36, height: 36)
                .background(tint.opacity(0.18), in: .circle)

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.appTitle2.weight(.bold))
                    .foregroundStyle(.textPrimary)
                    .contentTransition(.numericText())
                Text(unit)
                    .font(.appCallout)
                    .foregroundStyle(.textSecondary)
            }
            Text(label)
                .font(.appCaption)
                .foregroundStyle(.textSecondary)
        }
        .padding(Spacing.l)
        .frame(width: 144, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: Radius.l)
                .fill(.ultraThinMaterial)
        }
    }
}
