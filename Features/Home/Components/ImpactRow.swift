import SwiftUI

/// Strip horizontal scrolleable de cards de impacto.
/// 3 cards: kg desviados, CO2 evitado, racha.
/// **Family-style rollup**: cada número arranca en 0 al aparecer y sube
/// hasta el valor real con easing — refuerza la sensación de "esto creció".
///
/// Cada card es tappable independiente y dispara un info sheet específico
/// (no el mismo genérico para las 3).
struct ImpactRow: View {
    let totalKg: Double
    let co2Kg: Double
    let streakDays: Int

    /// Llamado con el tipo de stat tappeado, para abrir el sheet correcto.
    var onTap: ((Stat) -> Void)? = nil

    enum Stat { case kg, co2, racha }

    private var nextStreakGoal: Int {
        let goals = [7, 14, 30, 60, 100, 180, 365]
        return goals.first(where: { $0 > streakDays }) ?? (streakDays + 30)
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
                        value: totalKg,
                        format: { String(format: "%.1f", $0) },
                        unit: "kg",
                        label: "desviados",
                        icon: "scalemass.fill",
                        tint: .brand,
                        delay: 0.0,
                        facts: [
                            "≈ \(max(1, Int((totalKg / 5).rounded()))) cubetas",
                            "≈ \(max(1, Int((totalKg / 1.2).rounded()))) bolsas"
                        ],
                        onTap: { onTap?(.kg) }
                    )
                    ImpactCell(
                        value: co2Kg,
                        format: { String(format: "%.0f", $0) },
                        unit: "kg",
                        label: "CO₂ evitado",
                        icon: "leaf.fill",
                        tint: .success,
                        delay: 0.10,
                        facts: [
                            "= \(max(1, Int((co2Kg / 22).rounded()))) árboles/año",
                            "= \(max(1, Int((co2Kg / 0.04).rounded()))) focos LED día"
                        ],
                        onTap: { onTap?(.co2) }
                    )
                    ImpactCell(
                        value: Double(streakDays),
                        format: { "\(Int($0))" },
                        unit: "días",
                        label: "racha",
                        icon: "flame.fill",
                        tint: .orange,
                        delay: 0.20,
                        facts: [
                            "máx \(streakDays) días",
                            "meta \(nextStreakGoal) días"
                        ],
                        onTap: { onTap?(.racha) }
                    )
                }
                .padding(.horizontal, Spacing.l)
            }
        }
    }
}

/// Cell con rollup animado al aparecer. El delay escalona el efecto en la fila.
private struct ImpactCell: View {
    let value: Double
    let format: (Double) -> String
    let unit: String
    let label: String
    let icon: String
    let tint: Color
    let delay: Double
    let facts: [String]
    let onTap: () -> Void

    @State private var displayValue: Double = 0

    var body: some View {
        Button {
            Haptics.tap()
            onTap()
        } label: {
            VStack(alignment: .leading, spacing: Spacing.s) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(tint)
                    .frame(width: 36, height: 36)
                    .background(tint.opacity(0.18), in: .circle)

                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(format(displayValue))
                        .font(.appTitle2.weight(.bold))
                        .foregroundStyle(.textPrimary)
                        .contentTransition(.numericText(value: displayValue))
                    Text(unit)
                        .font(.appCallout)
                        .foregroundStyle(.textSecondary)
                }
                Text(label)
                    .font(.appCaption)
                    .foregroundStyle(.textSecondary)

                if !facts.isEmpty {
                    Divider()
                        .overlay(tint.opacity(0.25))
                        .padding(.vertical, 2)

                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(facts, id: \.self) { fact in
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(tint)
                                    .frame(width: 4, height: 4)
                                Text(fact)
                                    .font(.appCaption)
                                    .foregroundStyle(.textSecondary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                            }
                        }
                    }
                }
            }
            .padding(Spacing.l)
            .frame(width: 168, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: Radius.l)
                    .fill(.ultraThinMaterial)
            }
        }
        .buttonStyle(.plain)
        .onAppear {
            displayValue = 0
            withAnimation(.easeOut(duration: 1.2).delay(delay)) {
                displayValue = value
            }
        }
        .onChange(of: value) { _, newValue in
            withAnimation(.smooth(duration: 0.6)) {
                displayValue = newValue
            }
        }
    }
}
