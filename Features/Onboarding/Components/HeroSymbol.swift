import SwiftUI

/// Hero del onboarding: símbolo central con glow + 3 capas de glass
/// orbitando para dar sensación de profundidad SIN modelos 3D.
///
/// Cuando `isActive` cambia, reproduce la animación de entrada.
/// Acepta `tilt` (de drag horizontal) para un parallax 3D al cambiar página.
struct HeroSymbol: View {
    let symbol: String
    let accent: Color
    let isActive: Bool
    var tilt: CGSize = .zero

    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var glowScale: CGFloat = 0.7
    @State private var orbit1: CGFloat = 0.92
    @State private var orbit2: CGFloat = 0.92
    @State private var orbit3: CGFloat = 0.92

    var body: some View {
        ZStack {
            // Glow exterior — luz que emana
            Circle()
                .fill(
                    RadialGradient(
                        colors: [accent.opacity(0.85), accent.opacity(0)],
                        center: .center,
                        startRadius: 8,
                        endRadius: 220
                    )
                )
                .blur(radius: 50)
                .frame(width: 380, height: 380)
                .scaleEffect(glowScale)

            // Capa orbital 3 (la más exterior, más sutil)
            orbitDisk(diameter: 280, opacity: 0.06, strokeOpacity: 0.18, scale: orbit3)
                .rotation3DEffect(
                    .degrees(tilt.width * 0.05),
                    axis: (x: 0, y: 1, z: 0)
                )

            // Capa orbital 2
            orbitDisk(diameter: 240, opacity: 0.10, strokeOpacity: 0.28, scale: orbit2)
                .rotation3DEffect(
                    .degrees(tilt.width * 0.10),
                    axis: (x: 0, y: 1, z: 0)
                )

            // Capa orbital 1 (la más cercana al símbolo)
            orbitDisk(diameter: 200, opacity: 0.16, strokeOpacity: 0.45, scale: orbit1)
                .rotation3DEffect(
                    .degrees(tilt.width * 0.18),
                    axis: (x: 0, y: 1, z: 0)
                )

            // Símbolo central con sombra de color
            Image(systemName: symbol)
                .font(.system(size: 96, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.cream, accent.opacity(0.85)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .symbolEffect(.pulse, options: .repeat(.continuous))
                .shadow(color: accent.opacity(0.7), radius: 24, y: 10)
                .scaleEffect(scale)
                .opacity(opacity)
                .rotation3DEffect(
                    .degrees(tilt.width * 0.25),
                    axis: (x: 0, y: 1, z: 0)
                )
                .rotation3DEffect(
                    .degrees(-tilt.height * 0.15),
                    axis: (x: 1, y: 0, z: 0)
                )
        }
        .frame(width: 320, height: 320)
        .onAppear { if isActive { play() } else { reset() } }
        .onChange(of: isActive) { _, nowActive in
            if nowActive { play() } else { reset() }
        }
    }

    @ViewBuilder
    private func orbitDisk(diameter: CGFloat, opacity: Double, strokeOpacity: Double, scale: CGFloat) -> some View {
        Circle()
            .fill(.white.opacity(opacity))
            .background(
                Circle().fill(.ultraThinMaterial)
            )
            .overlay(
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                accent.opacity(strokeOpacity),
                                .white.opacity(strokeOpacity * 0.4),
                                accent.opacity(strokeOpacity * 0.6)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .frame(width: diameter, height: diameter)
            .scaleEffect(scale)
    }

    private func play() {
        reset()
        withAnimation(.spring(response: 0.55, dampingFraction: 0.62).delay(0.05)) {
            scale = 1
            opacity = 1
            glowScale = 1
        }
        withAnimation(.spring(response: 0.65, dampingFraction: 0.75).delay(0.15)) {
            orbit1 = 1
        }
        withAnimation(.spring(response: 0.75, dampingFraction: 0.78).delay(0.25)) {
            orbit2 = 1
        }
        withAnimation(.spring(response: 0.85, dampingFraction: 0.80).delay(0.35)) {
            orbit3 = 1
        }
    }

    private func reset() {
        scale = 0.5
        opacity = 0
        glowScale = 0.7
        orbit1 = 0.92
        orbit2 = 0.92
        orbit3 = 0.92
    }
}

#Preview {
    ZStack {
        Color.forestDeep.ignoresSafeArea()
        HeroSymbol(symbol: "leaf.fill", accent: .limeSpark, isActive: true)
    }
}
