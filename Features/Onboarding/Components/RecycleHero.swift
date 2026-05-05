import SwiftUI

/// Hero animado max-impact para página 1. **Mandala recycle**:
/// - 3 capas concéntricas del símbolo rotando a velocidades distintas
///   (16s/10s/6s) en direcciones contrarias → efecto hipnótico
/// - 3D tilt en eje Y para profundidad
/// - Glow radial throbbing
/// - 6 sparkles orbitando en círculo
struct RecycleHero: View {
    var accent: Color = .brand
    var size: CGFloat = 200

    @State private var rotOuter: Double = 0
    @State private var rotMid: Double = 0
    @State private var rotInner: Double = 0
    @State private var pulse: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.5
    @State private var orbitAngle: Double = 0

    var body: some View {
        ZStack {
            glow

            // Capa exterior — más grande, más sutil, más lenta
            Image(systemName: "arrow.3.trianglepath")
                .font(.system(size: size * 1.45, weight: .ultraLight))
                .foregroundStyle(accent.opacity(0.16))
                .rotationEffect(.degrees(rotOuter))
                .blur(radius: 0.5)

            // Capa media — counter-rotate
            Image(systemName: "arrow.3.trianglepath")
                .font(.system(size: size * 1.10, weight: .light))
                .foregroundStyle(accent.opacity(0.45))
                .rotationEffect(.degrees(rotMid))

            // Capa principal — el símbolo "real" con gradient + sombra
            Image(systemName: "arrow.3.trianglepath")
                .font(.system(size: size, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [accent, .limeSpark, accent.opacity(0.85)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .rotationEffect(.degrees(rotInner))
                .scaleEffect(pulse)
                .shadow(color: accent.opacity(0.50), radius: 20, y: 8)
                .rotation3DEffect(
                    .degrees(sin(orbitAngle * .pi / 180) * 12),
                    axis: (x: 0, y: 1, z: 0)
                )

            sparkleOrbit
        }
        .frame(width: size + 100, height: size + 100)
        .onAppear { startAnimations() }
    }

    // MARK: - Components

    /// Glow radial que pulsa
    private var glow: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [accent.opacity(glowOpacity), .clear],
                    center: .center,
                    startRadius: 4,
                    endRadius: size * 0.85
                )
            )
            .frame(width: size * 1.8, height: size * 1.8)
            .blur(radius: 28)
    }

    /// 6 sparkles orbitando en círculo, scale pulsing en sync con rotación
    private var sparkleOrbit: some View {
        ZStack {
            ForEach(0..<6, id: \.self) { i in
                let baseAngle = Double(i) * 60.0
                let angle = baseAngle + orbitAngle
                let radius = size * 0.78

                Image(systemName: "sparkle")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.limeSpark.opacity(0.85))
                    .offset(
                        x: cos(angle * .pi / 180) * radius,
                        y: sin(angle * .pi / 180) * radius
                    )
                    .scaleEffect(0.6 + abs(sin(angle * .pi / 180)) * 0.6)
                    .opacity(0.4 + abs(sin(angle * .pi / 180)) * 0.6)
            }
        }
    }

    // MARK: - Animations

    private func startAnimations() {
        // 3 capas a velocidades distintas, direcciones contrarias = mandala
        withAnimation(.linear(duration: 16).repeatForever(autoreverses: false)) {
            rotOuter = 360
        }
        withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
            rotMid = -360
        }
        withAnimation(.linear(duration: 6).repeatForever(autoreverses: false)) {
            rotInner = 360
        }

        // Sparkles orbitando 8s/vuelta
        withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
            orbitAngle = 360
        }

        // Pulse del símbolo principal
        withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) {
            pulse = 1.08
        }

        // Glow throbbing
        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
            glowOpacity = 0.85
        }
    }
}

#Preview {
    ZStack {
        Color.cream.ignoresSafeArea()
        RecycleHero()
    }
}
