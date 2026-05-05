import SwiftUI

/// Custom transition Apple-grade para el cambio de hero entre páginas del onboarding.
/// Combina **scale + opacity + blur radius** animados juntos. El elemento que sale
/// se contrae y desenfoca; el que entra emerge desde un estado borroso y agrandado.
///
/// Mucho más impacto que un crossfade simple — sensación de "pasamos a otro plano".
struct HeroMorphTransition: Transition {
    func body(content: Content, phase: TransitionPhase) -> some View {
        content
            .scaleEffect(scale(for: phase))
            .opacity(opacity(for: phase))
            .blur(radius: blur(for: phase))
    }

    private func scale(for phase: TransitionPhase) -> CGFloat {
        switch phase {
        case .identity:        return 1.0
        case .willAppear:      return 0.55   // emerge desde pequeño
        case .didDisappear:    return 1.45   // se va expandiendo
        }
    }

    private func opacity(for phase: TransitionPhase) -> Double {
        phase.isIdentity ? 1.0 : 0.0
    }

    private func blur(for phase: TransitionPhase) -> CGFloat {
        phase.isIdentity ? 0 : 24
    }
}

extension Transition where Self == HeroMorphTransition {
    /// Use `.heroMorph` en `.transition(...)` para este efecto.
    static var heroMorph: HeroMorphTransition { .init() }
}

// MARK: - Page Change Burst

/// Burst de sparkles que aparece UNA vez por cambio de página, da impacto extra.
/// Se dispara con un trigger value (típicamente el `index` actual).
struct PageChangeBurst: View {
    let trigger: Int
    var color: Color = .limeSpark

    @State private var burstId = 0
    @State private var sparkles: [BurstSparkle] = []

    var body: some View {
        ZStack {
            ForEach(sparkles) { s in
                Image(systemName: "sparkle")
                    .font(.system(size: s.size, weight: .semibold))
                    .foregroundStyle(color)
                    .opacity(s.opacity)
                    .scaleEffect(s.scale)
                    .offset(x: s.dx, y: s.dy)
                    .rotationEffect(.degrees(s.rotation))
            }
        }
        .allowsHitTesting(false)
        .onChange(of: trigger) { _, _ in
            fireBurst()
        }
    }

    private func fireBurst() {
        // Solo 5 sparkles, más sutiles, no compiten con el LightSweep
        sparkles = (0..<5).map { i in
            BurstSparkle(
                id: burstId * 100 + i,
                size: CGFloat.random(in: 10...16),
                dx: 0, dy: 0,
                opacity: 0.85,
                scale: 0.4,
                rotation: .random(in: -90...90)
            )
        }
        burstId += 1

        for i in sparkles.indices {
            let angle = Double.random(in: 0...(2 * .pi))
            let distance = CGFloat.random(in: 60...120)
            let targetX = cos(angle) * distance
            let targetY = sin(angle) * distance

            withAnimation(.smooth(duration: 0.7, extraBounce: 0.05)) {
                sparkles[i].dx = targetX
                sparkles[i].dy = targetY
                sparkles[i].scale = 0.85
                sparkles[i].rotation += Double.random(in: 90...360)
            }
            withAnimation(.easeIn(duration: 0.7)) {
                sparkles[i].opacity = 0
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.85) {
            sparkles = []
        }
    }
}

struct BurstSparkle: Identifiable {
    let id: Int
    var size: CGFloat
    var dx: CGFloat
    var dy: CGFloat
    var opacity: Double
    var scale: Double
    var rotation: Double
}
