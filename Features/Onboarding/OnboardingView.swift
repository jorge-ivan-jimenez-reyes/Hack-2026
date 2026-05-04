import SwiftUI

struct OnboardingView: View {
    let onContinue: () -> Void

    @State private var appeared = false

    var body: some View {
        ZStack {
            MeshBackground()
                .opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: Spacing.xl) {
                Spacer()

                Image(systemName: "leaf.circle.fill")
                    .font(.system(size: 96))
                    .foregroundStyle(.brand)
                    .symbolEffect(.pulse, options: .repeat(.continuous))
                    .accessibilityHidden(true)
                    .scaleEffect(appeared ? 1 : 0.6)
                    .opacity(appeared ? 1 : 0)
                    .animation(AppAnimation.bouncy, value: appeared)

                VStack(spacing: Spacing.s) {
                    Text("Bienvenido")
                        .font(.appLargeTitle)
                    Text("Identifica residuos y aprende a reducirlos, todo desde tu iPhone.")
                        .font(.appBody)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, Spacing.l)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 16)
                .animation(AppAnimation.entrance.delay(0.1), value: appeared)

                VStack(alignment: .leading, spacing: Spacing.l) {
                    pill(icon: "camera.fill",   title: "Escanea con la cámara",  subtitle: "Identifica residuos al instante.",        index: 0)
                    pill(icon: "lock.shield",   title: "100% privado",            subtitle: "Tus fotos nunca salen del dispositivo.",  index: 1)
                    pill(icon: "sparkles",      title: "Coach con IA on-device",  subtitle: "Tips personalizados sin conexión.",       index: 2)
                    pill(icon: "accessibility", title: "Diseñado para todos",     subtitle: "VoiceOver, texto dinámico, alto contraste.", index: 3)
                }
                .padding(.horizontal, Spacing.l)

                Spacer()

                PrimaryButton("Empezar", systemImage: "arrow.right.circle.fill") {
                    Haptics.confirm()
                    onContinue()
                }
                .padding(.horizontal, Spacing.l)
                .padding(.bottom, Spacing.l)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 12)
                .animation(AppAnimation.entrance.delay(0.55), value: appeared)
            }
        }
        .background(Color.surface)
        .onAppear { appeared = true }
    }

    private func pill(icon: String, title: String, subtitle: String, index: Int) -> some View {
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
        .opacity(appeared ? 1 : 0)
        .offset(x: appeared ? 0 : -24)
        .animation(AppAnimation.stagger(index: index), value: appeared)
    }
}

#Preview {
    OnboardingView(onContinue: {})
}
