import SwiftUI

/// Fondo con `MeshGradient` (iOS 18+) animado sutilmente. Para hero areas
/// (Onboarding, splash, empty states con identidad). NO usar bajo
/// contenido scrolleable — distrae.
struct MeshBackground: View {
    let colors: [Color]
    let speed: Double

    init(
        colors: [Color]? = nil,
        speed: Double = 0.18
    ) {
        self.colors = colors ?? [
            .brandSoft, .brand, .brandSoft,
            .surface, .surfaceElevated, .brandSoft,
            .brandSoft, .surface, .brand
        ]
        self.speed = speed
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { context in
            let t = Float(context.date.timeIntervalSinceReferenceDate * speed)
            let s = sin(t)
            let c = cos(t)

            MeshGradient(
                width: 3,
                height: 3,
                points: [
                    [0, 0],                      [0.5, 0],                       [1, 0],
                    [0, 0.5 + 0.08 * s],         [0.5 + 0.08 * c, 0.5],          [1, 0.5 - 0.08 * s],
                    [0, 1],                      [0.5, 1],                       [1, 1]
                ],
                colors: colors
            )
        }
    }
}

#Preview {
    MeshBackground()
}
