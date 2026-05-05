import SwiftUI

/// Overlay para la **página 3 — "15 = 1"**.
/// Loop 6s. 15 hojas pequeñas aparecen orbitando la cubeta, convergen al
/// centro, y al final aparece un GRAN "1" pulsando — el abono que recibes.
/// Cuenta el trato: 15 entregas tuyas → 1 cubeta de abono real.
struct BucketTransformOverlay: View {
    var accent: Color = .limeSpark
    var loopDuration: Double = 6.0

    private let leafCount = 15

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 60.0)) { ctx in
            let t = ctx.date.timeIntervalSinceReferenceDate
                .truncatingRemainder(dividingBy: loopDuration)

            ZStack {
                // 15 hojas orbitando + convergiendo
                ForEach(0..<leafCount, id: \.self) { i in
                    leaf(index: i, time: t)
                }

                // El "1" mega-grande aparece al final
                bigOne(time: t)
            }
            .allowsHitTesting(false)
        }
    }

    private func leaf(index: Int, time t: TimeInterval) -> some View {
        let angle = (Double(index) / Double(leafCount)) * 2 * .pi
        let baseRadius: Double = 130
        let appearDelay = Double(index) * 0.12

        // Fases: 0..2.4s = aparecen orbitando, 2.4..3.4s = convergen al centro,
        // 3.4..4.5s = invisibles (ya están dentro), 4.5..6 = vuelven gradual
        let phase: Double = {
            if t < appearDelay { return 0 }                           // aún no aparece
            if t < 2.4 + appearDelay * 0.5 { return 1 }                // orbitando
            if t < 3.4 { return 2 }                                    // convergiendo
            if t < 5.5 { return 3 }                                    // ya consumida
            return 4                                                    // reaparece
        }()

        let radius: Double = {
            switch phase {
            case 1: return baseRadius
            case 2:
                let p = (t - 2.4 - appearDelay * 0.5) / 1.0
                return baseRadius * (1 - min(1, max(0, p)))
            default: return baseRadius
            }
        }()

        let x = cos(angle + t * 0.3) * radius
        let y = sin(angle + t * 0.3) * radius

        let opacity: Double = {
            switch phase {
            case 0: return 0
            case 1:
                let inProgress = (t - appearDelay) / 0.4
                return min(1, max(0, inProgress))
            case 2:
                let p = (t - 2.4 - appearDelay * 0.5) / 1.0
                return max(0, 1 - p * 1.2)
            case 3: return 0
            case 4:
                let p = (t - 5.5) / 0.5
                return max(0, p * 0.5)
            default: return 0
            }
        }()

        let scale: Double = {
            switch phase {
            case 2:
                let p = (t - 2.4 - appearDelay * 0.5) / 1.0
                return 1.0 - p * 0.4
            default: return 1.0
            }
        }()

        return Image(systemName: "leaf.fill")
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(accent.opacity(opacity))
            .scaleEffect(scale)
            .offset(x: x, y: y)
    }

    private func bigOne(time t: TimeInterval) -> some View {
        // Aparece justo cuando convergen las hojas (~3.4s), permanece hasta 5.0s
        let visible = t >= 3.0 && t <= 5.0
        let pulse = 1.0 + sin((t - 3.0) * .pi * 3) * 0.05
        let opacity: Double = {
            if !visible { return 0 }
            if t < 3.4 { return (t - 3.0) / 0.4 }
            if t > 4.7 { return max(0, 1 - (t - 4.7) / 0.3) }
            return 1
        }()

        return Text("1")
            .font(.system(size: 96, weight: .black, design: .rounded))
            .foregroundStyle(
                LinearGradient(
                    colors: [.brand, accent],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .scaleEffect(pulse)
            .opacity(opacity)
            .shadow(color: accent.opacity(0.45), radius: 20, y: 6)
    }
}

#Preview {
    ZStack {
        Color.cream.ignoresSafeArea()
        ProceduralBucketHero(accent: .limeSpark)
            .frame(width: 340, height: 340)
        BucketTransformOverlay(accent: .limeSpark)
            .frame(width: 340, height: 340)
    }
}
