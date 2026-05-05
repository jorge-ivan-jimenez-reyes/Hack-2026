import SwiftUI

/// Card del Coach IA. En MVP muestra `tip` estático; en prod
/// vendrá de `FoundationModelsCoach` (on-device, basado en historial).
struct CoachTipCard: View {
    let tip: String
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            HStack(spacing: Spacing.s) {
                Image(systemName: "sparkles")
                    .font(.headline)
                    .foregroundStyle(.brand)
                    .symbolEffect(
                        .variableColor.iterative.reversing,
                        options: .repeat(.continuous)
                    )
                Text("Coach IA")
                    .font(.appHeadline.weight(.semibold))
                    .foregroundStyle(.textPrimary)
                Spacer()
                Text("on-device")
                    .font(.appCaption.weight(.medium))
                    .foregroundStyle(.textSecondary)
                    .padding(.horizontal, Spacing.s)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial, in: .capsule)
            }

            Text(tip)
                .font(.appBody)
                .foregroundStyle(.textPrimary)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

            Button {
                Haptics.tap()
                onTap()
            } label: {
                HStack(spacing: 4) {
                    Text("Ver más tips")
                    Image(systemName: "arrow.right")
                }
                .font(.appCallout.weight(.semibold))
                .foregroundStyle(.brand)
            }
        }
        .padding(Spacing.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: Radius.l)
                .fill(Color.brandSoft.opacity(0.30))
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.l)
                        .stroke(Color.brand.opacity(0.25), lineWidth: 1)
                )
        }
        .padding(.horizontal, Spacing.l)
    }
}
