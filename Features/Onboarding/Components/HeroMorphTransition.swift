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
        sparkles = (0..<10).map { i in
            BurstSparkle(
                id: burstId * 100 + i,
                size: CGFloat.random(in: 14...22),
                dx: 0, dy: 0,
                opacity: 1,
                scale: 0.5,
                rotation: .random(in: -180...180)
            )
        }
        burstId += 1

        // Lanzar cada sparkle en una dirección random
        for i in sparkles.indices {
            let angle = Double.random(in: 0...(2 * .pi))
            let distance = CGFloat.random(in: 80...160)
            let targetX = cos(angle) * distance
            let targetY = sin(angle) * distance

            withAnimation(.smooth(duration: 0.85, extraBounce: 0.05)) {
                sparkles[i].dx = targetX
                sparkles[i].dy = targetY
                sparkles[i].scale = 1.0
                sparkles[i].rotation += Double.random(in: 180...720)
            }
            withAnimation(.easeIn(duration: 0.85)) {
                sparkles[i].opacity = 0
            }
        }

        // Limpiar sparkles después de 1s
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
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
