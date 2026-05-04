import SwiftUI

struct OnboardingView: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()
            Image(systemName: "leaf.circle.fill")
                .font(.system(size: 96))
                .foregroundStyle(.brand)
                .accessibilityHidden(true)

            VStack(spacing: Spacing.s) {
                Text("Bienvenido")
                    .font(.appLargeTitle)
                Text("Identifica residuos y aprende a reducirlos, todo desde tu iPhone.")
                    .font(.appBody)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, Spacing.l)

            VStack(alignment: .leading, spacing: Spacing.l) {
                pill(icon: "camera.fill",   title: "Escanea con la cámara",  subtitle: "Identifica residuos al instante.")
                pill(icon: "lock.shield",   title: "100% privado",            subtitle: "Tus fotos nunca salen del dispositivo.")
                pill(icon: "sparkles",      title: "Coach con IA on-device",  subtitle: "Tips personalizados sin conexión.")
                pill(icon: "accessibility", title: "Diseñado para todos",     subtitle: "VoiceOver, texto dinámico, alto contraste.")
            }
            .padding(.horizontal, Spacing.l)

            Spacer()

            PrimaryButton("Empezar", systemImage: "arrow.right.circle.fill", action: onContinue)
                .padding(.horizontal, Spacing.l)
                .padding(.bottom, Spacing.l)
        }
        .background(Color.surface)
    }

    private func pill(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: Spacing.m) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.brand)
                .frame(width: 44, height: 44)
                .background(Color.brandSoft.opacity(0.4), in: .circle)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.appHeadline)
                Text(subtitle).font(.appCallout).foregroundStyle(.secondary)
            }
        }
        .accessibleCard(label: "\(title). \(subtitle)")
    }
}

#Preview {
    OnboardingView(onContinue: {})
}
