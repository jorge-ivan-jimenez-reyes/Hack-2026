import SwiftUI

/// Card del leaderboard de cuadra (modelo Bergamo). Premio comunitario:
/// si la cuadra junta `premioGoalKg`, todos los vecinos reciben recompensa.
struct CuadraCard: View {
    let weeklyKg: Double
    let percentile: Int
    let premioGoalKg: Double
    let onTap: () -> Void

    private var progress: Double {
        min(weeklyKg / premioGoalKg, 1.0)
    }

    private var remaining: Int {
        max(0, Int((premioGoalKg - weeklyKg).rounded()))
    }

    var body: some View {
        Button {
            Haptics.tap()
            onTap()
        } label: {
            VStack(alignment: .leading, spacing: Spacing.m) {
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "house.lodge.fill")
                            .foregroundStyle(.brand)
                        Text("Tu cuadra esta semana")
                            .font(.appHeadline.weight(.semibold))
                            .foregroundStyle(.textPrimary)
                    }
                    Spacer()
                    Text("Top \(percentile)% CDMX")
                        .font(.appCaption.weight(.semibold))
                        .foregroundStyle(.success)
                        .padding(.horizontal, Spacing.s)
                        .padding(.vertical, 4)
                        .background(.success.opacity(0.18), in: .capsule)
                }

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(String(format: "%.0f", weeklyKg))
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(.textPrimary)
                        .contentTransition(.numericText())
                    Text("kg")
                        .font(.appHeadline)
                        .foregroundStyle(.textSecondary)
                }

                ProgressView(value: progress)
                    .tint(.brand)

                if remaining > 0 {
                    Text("Faltan **\(remaining) kg** para el premio comunitario")
                        .font(.appCaption)
                        .foregroundStyle(.textSecondary)
                } else {
                    Text("¡Lograron el premio! 🎉")
                        .font(.appCaption.weight(.semibold))
                        .foregroundStyle(.success)
                }
            }
            .padding(Spacing.l)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: Radius.l)
                    .fill(.ultraThinMaterial)
            }
        }
        .buttonStyle(.plain)
        .padding(.horizontal, Spacing.l)
    }
}
