import SwiftUI

/// Overlay para la **página 4 — "Tu cuadra suma contigo"**.
/// Loop 5s. La cubeta central es la del usuario. Aparecen 6 cubetas
/// pequeñas en formación radial (los vecinos uniéndose), conectadas por
/// un anillo verde sutil. Pulse comunitario al cerrar.
struct BucketCommunityOverlay: View {
    var accent: Color = .moss
    var loopDuration: Double = 5.0

    private let neighborCount = 6

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 60.0)) { ctx in
            let t = ctx.date.timeIntervalSinceReferenceDate
                .truncatingRemainder(dividingBy: loopDuration)

            ZStack {
                // Anillo conector
                connectingRing(time: t)

                // 6 cubetas vecinas en formación radial
                ForEach(0..<neighborCount, id: \.self) { i in
                    neighbor(index: i, time: t)
                }
            }
            .allowsHitTesting(false)
        }
    }

    private func neighbor(index: Int, time t: TimeInterval) -> some View {
        let angle = (Double(index) / Double(neighborCount)) * 2 * .pi - .pi / 2
        let appearAt = Double(index) * 0.18 + 0.4
        let radius: Double = 145

        let x = cos(angle) * radius
        let y = sin(angle) * radius

        let opacity: Double = {
            if t < appearAt { return 0 }
            if t < appearAt + 0.4 { return (t - appearAt) / 0.4 }
            if t > 4.0 { return max(0, 1 - (t - 4.0) / 0.5) }
            return 1
        }()

        let scale: Double = {
            if t < appearAt { return 0.3 }
            if t < appearAt + 0.4 {
                let p = (t - appearAt) / 0.4
                return 0.3 + p * 0.7 + sin(p * .pi) * 0.15
            }
            return 1.0
        }()

        return Image(systemName: "person.fill")
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(accent.opacity(opacity))
            .scaleEffect(scale)
            .offset(x: x, y: y)
            .shadow(color: accent.opacity(0.30), radius: 6, y: 2)
    }

    private func connectingRing(time t: TimeInterval) -> some View {
        // El anillo aparece después de las cubetas (~2s), pulsa, y se desvanece
        let progress: Double = {
            if t < 1.8 { return 0 }
            if t < 2.6 { return (t - 1.8) / 0.8 }
            if t > 4.0 { return max(0, 1 - (t - 4.0) / 0.5) }
            return 1
        }()

        return Circle()
            .stroke(
                LinearGradient(
                    colors: [accent.opacity(0.55), .brand.opacity(0.35), accent.opacity(0.55)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1.5
            )
            .frame(width: 290, height: 290)
            .opacity(progress)
            .scaleEffect(0.95 + sin(t * 1.5) * 0.02)
    }
}

#Preview {
    ZStack {
        Color.cream.ignoresSafeArea()
        ProceduralBucketHero(accent: .moss)
            .frame(width: 340, height: 340)
        BucketCommunityOverlay(accent: .moss)
            .frame(width: 340, height: 340)
    }
}
