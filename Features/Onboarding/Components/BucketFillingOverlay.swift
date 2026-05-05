import SwiftUI

/// Overlay 2D que va ENCIMA del bucket 3D — muestra 3 cáscaras cayendo
/// staggered desde arriba hacia el rim de la cubeta, dando la sensación
/// de "llenado". Loop de 6s.
///
/// Time-driven con `TimelineView(.animation)`: la posición de cada cáscara
/// se calcula del tiempo continuo, así nunca se desincroniza ni necesita
/// state machine.
///
/// Ordenamiento de fases dentro del loop (todas en segundos):
/// - 0.0 - 0.5: estado inicial (cubeta sola)
/// - 0.5 - 1.4: cáscara 1 cae
/// - 1.3 - 2.2: cáscara 2 cae (overlap mínimo)
/// - 2.1 - 3.0: cáscara 3 cae
/// - 3.0 - 4.5: glow máximo, beat de "llena"
/// - 4.5 - 5.5: glow fade-out
/// - 5.5 - 6.0: blank, prepara siguiente loop
struct BucketFillingOverlay: View {
    var accent: Color = .brand
    var loopDuration: Double = 6.0

    /// Cada shell: símbolo, momento de entrada (s), offset X, rotation rate.
    private let shells: [(symbol: String, startOffset: Double, xOffset: CGFloat, rotationSpeed: Double)] = [
        ("leaf.fill",         0.5, -28,  1.4),
        ("circle.fill",       1.3,  18, -1.1),
        ("leaf.fill",         2.1,  -8,  1.2)
    ]

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 60.0)) { ctx in
            let cycleTime = ctx.date.timeIntervalSinceReferenceDate
                .truncatingRemainder(dividingBy: loopDuration)

            ZStack {
                glow(cycleTime: cycleTime)

                ForEach(0..<shells.count, id: \.self) { i in
                    let shell = shells[i]
                    fallingShell(
                        symbol: shell.symbol,
                        startOffset: shell.startOffset,
                        xOffset: shell.xOffset,
                        rotationSpeed: shell.rotationSpeed,
                        cycleTime: cycleTime
                    )
                }
            }
            .allowsHitTesting(false)
        }
    }

    // MARK: - Falling shell

    @ViewBuilder
    private func fallingShell(
        symbol: String,
        startOffset: Double,
        xOffset: CGFloat,
        rotationSpeed: Double,
        cycleTime: TimeInterval
    ) -> some View {
        let elapsed = cycleTime - startOffset
        let fallDuration = 0.9
        let progress = elapsed / fallDuration

        // Visible solo durante caída + brief bounce after landing
        if elapsed >= 0, elapsed <= fallDuration + 0.15 {
            let isLanding = progress <= 1.0
            let easedProgress = isLanding ? easeInOut(progress) : 1.0
            let yPos = -150.0 + (200.0 * easedProgress)

            let fadeOutAtEnd = isLanding && progress > 0.92
            let opacity: Double = {
                if !isLanding { return 0 }
                if fadeOutAtEnd { return max(0, 1.0 - (progress - 0.92) * 12) }
                return 1.0
            }()

            // Bounce muy sutil al final del fall
            let scaleBoost: Double = {
                if isLanding && progress > 0.85 {
                    let bouncePhase = (progress - 0.85) / 0.15
                    return 1.0 + sin(bouncePhase * .pi) * 0.18
                }
                return 1.0
            }()

            Image(systemName: symbol)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(accent.opacity(0.92))
                .rotationEffect(.degrees(elapsed * rotationSpeed * 360))
                .scaleEffect(scaleBoost)
                .offset(x: xOffset, y: yPos)
                .opacity(opacity)
                .shadow(color: accent.opacity(0.35), radius: 4, y: 2)
        }
    }

    // MARK: - Glow

    /// Glow que intensifica conforme más cáscaras "caen", llega al máximo
    /// cuando las 3 ya están dentro, y hace fade-out al final del loop.
    private func glow(cycleTime: TimeInterval) -> some View {
        let intensity = glowIntensity(at: cycleTime)
        return Circle()
            .fill(
                RadialGradient(
                    colors: [accent.opacity(0.30 * intensity), .clear],
                    center: .center,
                    startRadius: 30,
                    endRadius: 150
                )
            )
            .frame(width: 300, height: 300)
            .blur(radius: 8)
            .offset(y: 24)
            .animation(.smooth(duration: 0.4), value: intensity)
    }

    private func glowIntensity(at time: TimeInterval) -> Double {
        // Curva: cada cáscara aterrizada suma 1/3, máximo entre 3.0-4.5, fade hasta 5.5
        if time < 1.4 { return 0 }
        if time < 2.2 { return 1.0 / 3.0 }
        if time < 3.0 { return 2.0 / 3.0 }
        if time < 4.5 { return 1.0 }
        if time < 5.5 { return max(0, 1.0 - (time - 4.5)) }
        return 0
    }

    // MARK: - Easing

    private func easeInOut(_ t: Double) -> Double {
        if t < 0.5 { return 2 * t * t }
        return 1 - pow(-2 * t + 2, 2) / 2
    }
}

#Preview {
    ZStack {
        Color.cream.ignoresSafeArea()
        ProceduralBucketHero(accent: .brand)
            .frame(width: 340, height: 340)
        BucketFillingOverlay(accent: .brand)
            .frame(width: 340, height: 340)
    }
}
