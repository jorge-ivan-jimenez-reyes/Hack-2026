import SwiftUI

/// Overlay para la **página 2 — "Nosotros pasamos por ella"**.
/// Loop 4.5s. Cuenta visualmente que la cubeta es recogida en casa:
/// chevrons sube hacia arriba (lift away), aparece silueta de casa al fondo,
/// luego sparkles indicando "cambio por una limpia".
struct BucketPickupOverlay: View {
    var accent: Color = .clay
    var loopDuration: Double = 4.5

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 60.0)) { ctx in
            let t = ctx.date.timeIntervalSinceReferenceDate
                .truncatingRemainder(dividingBy: loopDuration)

            ZStack {
                // Casa al fondo (atrás de la cubeta)
                Image(systemName: "house.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(accent.opacity(houseOpacity(t)))
                    .offset(x: 90, y: 110)
                    .blur(radius: 0.5)

                // 3 chevrons subiendo en stagger (lift)
                ForEach(0..<3) { i in
                    chevron(index: i, time: t)
                }

                // Sparkle de "limpia/lista" al final del ciclo
                if t > 3.2 && t < 4.2 {
                    let sparkleProgress = (t - 3.2) / 1.0
                    Image(systemName: "sparkle")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.brand.opacity(1.0 - sparkleProgress * 0.6))
                        .scaleEffect(0.6 + sparkleProgress * 0.8)
                        .offset(x: -60, y: 20)
                        .symbolEffect(.variableColor.iterative.reversing, options: .repeat(.continuous))
                }
            }
            .allowsHitTesting(false)
        }
    }

    private func chevron(index: Int, time t: TimeInterval) -> some View {
        let stagger = Double(index) * 0.32
        let phase = (t - stagger).truncatingRemainder(dividingBy: 1.6)
        let visible = phase >= 0 && phase <= 1.4
        let yPos: CGFloat = -40 - CGFloat(phase * 80)
        let opacity: Double = {
            if !visible { return 0 }
            if phase < 0.15 { return phase / 0.15 }
            if phase > 1.1 { return max(0, (1.4 - phase) / 0.3) }
            return 0.9
        }()

        return Image(systemName: "chevron.up")
            .font(.system(size: 22, weight: .bold))
            .foregroundStyle(accent.opacity(opacity))
            .offset(y: yPos)
    }

    private func houseOpacity(_ t: TimeInterval) -> Double {
        let breath = 0.18 + abs(sin(t * .pi / 2.5)) * 0.10
        return breath
    }
}

#Preview {
    ZStack {
        Color.cream.ignoresSafeArea()
        ProceduralBucketHero(accent: .clay)
            .frame(width: 340, height: 340)
        BucketPickupOverlay(accent: .clay)
            .frame(width: 340, height: 340)
    }
}
