import SwiftUI

/// Sheet que permite cambiar entre drop_off (gratis, llevar al centro)
/// y pickup (suscripción, pasamos a domicilio). Mismo layout de cards
/// que el step 5 del RecolectorSetup.
struct ChangeModalitySheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var serviceMode: String

    var body: some View {
        ZStack {
            Color.cream.ignoresSafeArea()

            VStack(spacing: Spacing.l) {
                VStack(spacing: Spacing.s) {
                    Text("Cambiar modalidad")
                        .font(.appLargeTitle)
                        .foregroundStyle(.inkCharcoal)
                    Text("Cambia cómo entregas tu cubeta cuando quieras.")
                        .font(.appBody)
                        .foregroundStyle(.inkCharcoal.opacity(0.65))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, Spacing.l)
                .padding(.horizontal, Spacing.l)

                VStack(spacing: Spacing.m) {
                    modeCard(
                        value: "drop_off",
                        icon: "mappin.circle.fill",
                        label: "Yo la llevo al centro",
                        subtitle: "Gratis. Te avisamos cuándo abren los centros cercanos.",
                        tagText: "Gratis",
                        tagTint: .brand
                    )
                    modeCard(
                        value: "pickup",
                        icon: "shippingbox.fill",
                        label: "Pasen por mi cubeta",
                        subtitle: "Suscripción. Pasamos a domicilio el día que prefieras.",
                        tagText: "Suscripción",
                        tagTint: .clay
                    )
                }
                .padding(.horizontal, Spacing.l)

                Spacer(minLength: 0)
            }
        }
    }

    private func modeCard(
        value: String,
        icon: String,
        label: String,
        subtitle: String,
        tagText: String,
        tagTint: Color
    ) -> some View {
        let selected = (serviceMode == value)
        return Button {
            Haptics.confirm()
            withAnimation(.snappy(duration: 0.25)) {
                serviceMode = value
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                dismiss()
            }
        } label: {
            HStack(alignment: .top, spacing: Spacing.m) {
                Image(systemName: icon)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(selected ? .brand : .inkCharcoal.opacity(0.40))
                    .symbolEffect(.bounce, value: selected)
                    .frame(width: 44, height: 44)
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(label)
                            .font(.appHeadline.weight(.semibold))
                            .foregroundStyle(.inkCharcoal)
                        Spacer()
                        Text(tagText)
                            .font(.appCaption.weight(.semibold))
                            .foregroundStyle(tagTint)
                            .padding(.horizontal, Spacing.s)
                            .padding(.vertical, 3)
                            .background(tagTint.opacity(0.15), in: .capsule)
                    }
                    Text(subtitle)
                        .font(.appCallout)
                        .foregroundStyle(.inkCharcoal.opacity(0.65))
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(Spacing.l)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: Radius.l)
                    .fill(selected ? Color.brand.opacity(0.10) : Color.white)
                    .shadow(
                        color: selected ? Color.brand.opacity(0.14) : Color.inkCharcoal.opacity(0.04),
                        radius: selected ? 12 : 6,
                        y: selected ? 4 : 2
                    )
            }
            .overlay {
                RoundedRectangle(cornerRadius: Radius.l)
                    .stroke(selected ? Color.brand.opacity(0.40) : Color.clear, lineWidth: 1.5)
            }
        }
        .buttonStyle(.plain)
    }
}
