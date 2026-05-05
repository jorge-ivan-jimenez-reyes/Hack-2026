import SwiftUI

/// Capa decorativa de partículas (hojas) flotando en loop infinito.
/// Sin dependencias — SwiftUI puro. Usar SOBRE el hero, debajo del texto.
///
/// Se posicionan random al aparecer y flotan en patrón sinusoidal lento.
/// Cada partícula tiene su propia fase para que NO se vean sincronizadas.
struct FloatingParticles: View {
    var count: Int = 7
    var color: Color = .limeSpark
    var symbol: String = "leaf.fill"

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { context in
            let time = context.date.timeIntervalSinceReferenceDate
            ZStack {
                ForEach(0..<count, id: \.self) { i in
                    Particle(index: i, time: time, color: color, symbol: symbol)
                }
            }
        }
        .allowsHitTesting(false)
    }
}

private struct Particle: View {
    let index: Int
    let time: TimeInterval
    let color: Color
    let symbol: String

    /// Cada partícula tiene una "semilla" propia derivada del index para
    /// que su trayectoria sea distinta a las demás.
    private var seed: Double { Double(index) * 1.618 }

    /// Posición base random pero estable por index.
    private var basePosition: CGPoint {
        // Pseudo-random determinista por index
        let x = sin(seed * 7.3) * 0.5 + 0.5      // 0..1
        let y = cos(seed * 5.7) * 0.5 + 0.5
        return CGPoint(x: x, y: y)
    }

    private var size: CGFloat {
        12 + CGFloat(sin(seed * 3.1) + 1) * 6   // 12..24
    }

    private var speed: Double {
        0.25 + abs(sin(seed * 2.0)) * 0.4       // 0.25..0.65
    }

    private var opacity: Double {
        0.25 + abs(cos(seed * 1.7)) * 0.35      // 0.25..0.60
    }

    var body: some View {
        GeometryReader { geo in
            let t = time * speed + seed

            // Movimiento sinusoidal en 2 ejes
            let dx = sin(t) * 32
            let dy = cos(t * 0.7) * 24

            // Rotación lenta
            let rotation = Angle.degrees(sin(t * 0.5) * 25 + seed * 30)

            Image(systemName: symbol)
                .font(.system(size: size, weight: .regular))
                .foregroundStyle(color)
                .opacity(opacity)
                .rotationEffect(rotation)
                .position(
                    x: geo.size.width * basePosition.x + dx,
                    y: geo.size.height * basePosition.y + dy
                )
                .blur(radius: 0.4)
        }
    }
}

#Preview {
    ZStack {
        Color.forestDeep.ignoresSafeArea()
        FloatingParticles()
    }
}
