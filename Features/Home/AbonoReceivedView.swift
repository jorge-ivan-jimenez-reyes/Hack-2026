import SwiftUI

/// Pantalla de cierre del ciclo 15:1 — el usuario llegó a 15 cubetas y ahora
/// "recibe abono". Es el momento emotivo del producto: cierra el loop de
/// economía circular y resetea el contador para empezar otro ciclo.
struct AbonoReceivedView: View {
    @Environment(\.dismiss) private var dismiss

    /// Kilos de abono que recibe — regla aproximada: ~1.5 kg por cubeta.
    let kgAbono: Double

    @State private var revealed = false
    @State private var confettiTrigger = 0
    @State private var animatedKg: Double = 0
    @State private var sparklePulse = 0

    var body: some View {
        ZStack {
            background
            ConfettiView(trigger: confettiTrigger)
                .ignoresSafeArea()

            VStack {
                topBar
                Spacer()
                heroContent
                Spacer()
                bottomActions
            }
            .padding(.horizontal, Spacing.l)
        }
        .preferredColorScheme(.dark)
        .onAppear { runEntrance() }
    }

    private var background: some View {
        LinearGradient(
            colors: [.forestDeep, .brand, .moss, .limeSpark],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private var topBar: some View {
        HStack {
            Spacer()
            Button {
                Haptics.tap()
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.body.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(.white.opacity(0.20), in: .circle)
            }
            .buttonStyle(.plain)
            .opacity(revealed ? 1 : 0)
        }
        .padding(.top, Spacing.s)
    }

    private var heroContent: some View {
        VStack(spacing: Spacing.l) {
            // Trofeo + sparkles
            ZStack {
                Circle()
                    .fill(.white.opacity(0.18))
                    .frame(width: 180, height: 180)
                    .scaleEffect(revealed ? 1 : 0.6)
                Image(systemName: "sparkles")
                    .font(.system(size: 28))
                    .foregroundStyle(.white.opacity(0.85))
                    .offset(x: -60, y: -50)
                    .symbolEffect(.bounce, value: sparklePulse)
                Image(systemName: "sparkles")
                    .font(.system(size: 22))
                    .foregroundStyle(.white.opacity(0.75))
                    .offset(x: 65, y: -30)
                    .symbolEffect(.bounce, value: sparklePulse)
                Image(systemName: "leaf.circle.fill")
                    .font(.system(size: 96))
                    .foregroundStyle(.white)
                    .symbolEffect(.bounce, value: revealed)
                    .scaleEffect(revealed ? 1 : 0.5)
            }
            .opacity(revealed ? 1 : 0)

            VStack(spacing: Spacing.s) {
                Text("¡Llegaste a 15!")
                    .font(.system(size: 40, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                Text("Cerraste el ciclo. Tu orgánico regresa convertido en composta.")
                    .font(.appBody)
                    .foregroundStyle(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.m)
            }
            .opacity(revealed ? 1 : 0)
            .offset(y: revealed ? 0 : 16)

            // Hero number — kg de abono
            VStack(alignment: .leading, spacing: Spacing.s) {
                Text("RECIBES")
                    .font(.appCaption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.75))
                HStack(alignment: .firstTextBaseline) {
                    Text(kgString(animatedKg))
                        .font(.system(size: 84, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())
                    Text("kg")
                        .font(.appLargeTitle)
                        .foregroundStyle(.white.opacity(0.85))
                }
                Text("de composta lista para tus plantas 🌱")
                    .font(.appBody)
                    .foregroundStyle(.white.opacity(0.85))
            }
            .padding(Spacing.l)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: Radius.xl)
                    .fill(.white.opacity(0.18))
            }
            .overlay {
                RoundedRectangle(cornerRadius: Radius.xl)
                    .stroke(.white.opacity(0.25), lineWidth: 1)
            }
            .opacity(revealed ? 1 : 0)
            .offset(y: revealed ? 0 : 24)
        }
    }

    private var bottomActions: some View {
        VStack(spacing: Spacing.s) {
            Button {
                Haptics.confirm()
            } label: {
                HStack(spacing: Spacing.s) {
                    Image(systemName: "square.and.arrow.up")
                    Text("Compartir mi logro")
                        .font(.appHeadline.weight(.semibold))
                }
                .foregroundStyle(.brand)
                .frame(maxWidth: .infinity, minHeight: 52)
                .background(.white, in: .capsule)
                .shadow(color: .black.opacity(0.15), radius: 12, y: 6)
            }
            .buttonStyle(.plain)

            Button {
                Haptics.success()
                RecolectorProgress.resetCycle()
                dismiss()
            } label: {
                HStack(spacing: Spacing.s) {
                    Image(systemName: "arrow.counterclockwise.circle.fill")
                    Text("Empezar nuevo ciclo")
                        .font(.appHeadline.weight(.semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, minHeight: 52)
                .background(.white.opacity(0.15), in: .capsule)
                .overlay {
                    Capsule().stroke(.white.opacity(0.30), lineWidth: 1)
                }
            }
            .buttonStyle(.plain)
        }
        .opacity(revealed ? 1 : 0)
        .padding(.bottom, Spacing.l)
    }

    // MARK: - Animation

    private func runEntrance() {
        Haptics.success()
        withAnimation(.smooth(duration: 0.8)) {
            revealed = true
        }
        withAnimation(.easeOut(duration: 1.4).delay(0.3)) {
            animatedKg = kgAbono
        }
        // Confetti staggered
        Task {
            try? await Task.sleep(for: .milliseconds(200))
            confettiTrigger += 1
            try? await Task.sleep(for: .milliseconds(800))
            confettiTrigger += 1
        }
        // Sparkle pulse loop
        Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1.5))
                sparklePulse += 1
            }
        }
    }

    private func kgString(_ kg: Double) -> String {
        kg < 10 ? String(format: "%.1f", kg) : "\(Int(kg))"
    }
}

#Preview {
    AbonoReceivedView(kgAbono: 22.5)
}
