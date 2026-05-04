import SwiftUI

/// Línea horizontal que recorre verticalmente un área. Se usa como overlay
/// sobre el preview de cámara mientras la IA está clasificando.
///
/// Implementado con `TimelineView(.animation)` + módulo del tiempo,
/// así no hay snap visible al loopear.
struct ScanLineEffect: View {
    var color: Color = .brand
    var duration: Double = 1.6

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 60.0)) { context in
            GeometryReader { geo in
                let elapsed = context.date.timeIntervalSinceReferenceDate
                let phase = elapsed.truncatingRemainder(dividingBy: duration) / duration

                LinearGradient(
                    colors: [
                        color.opacity(0),
                        color.opacity(0.85),
                        color.opacity(0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 90)
                .offset(y: -45 + phase * geo.size.height)
                .opacity(opacityCurve(phase))
                .blur(radius: 0.5)
            }
        }
        .allowsHitTesting(false)
    }

    /// Fade en los extremos para que el loop no se note.
    private func opacityCurve(_ phase: Double) -> Double {
        if phase < 0.06 { return phase / 0.06 }
        if phase > 0.94 { return (1 - phase) / 0.06 }
        return 1
    }
}

#Preview {
    ScanLineEffect()
        .background(.black)
}
