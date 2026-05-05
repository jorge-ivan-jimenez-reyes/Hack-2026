import SwiftUI

/// Onda de luz radial que se expande desde el centro al cambiar página.
/// Apple Watch / Liquid Glass style — un anillo de color que se infla y desvanece.
/// Da el "wow" del cambio sin romper la continuidad del hero.
struct LightSweep: View {
    let trigger: Int
    var color: Color = .limeSpark

    @State private var radius: CGFloat = 60
    @State private var opacity: Double = 0
    @State private var lastTrigger: Int = -1

    var body: some View {
        Circle()
            .stroke(color, lineWidth: 80)
            .frame(width: radius, height: radius)
            .opacity(opacity)
            .blur(radius: 36)
            .blendMode(.plusLighter)
            .allowsHitTesting(false)
            .onChange(of: trigger) { _, new in
                guard new != lastTrigger else { return }
                lastTrigger = new
                fire()
            }
            .onAppear {
                lastTrigger = trigger
            }
    }

    private func fire() {
        // Reset al estado inicial
        radius = 60
        opacity = 0.85

        // Expand + fade — 0.9s smooth
        withAnimation(.smooth(duration: 0.9)) {
            radius = 1100
            opacity = 0
        }
    }
}

/// Pulse sutil del hero al cambiar página — scale 1.0 → 1.06 → 1.0 con bounce.
/// Tied al mismo trigger que LightSweep para que se sientan UNO.
struct HeroPulse: ViewModifier {
    let trigger: Int

    @State private var scale: CGFloat = 1.0

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .onChange(of: trigger) { _, _ in
                pulse()
            }
    }

    private func pulse() {
        withAnimation(.spring(response: 0.30, dampingFraction: 0.55)) {
            scale = 1.06
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.30) {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.70)) {
                scale = 1.0
            }
        }
    }
}

extension View {
    func heroPulse(trigger: Int) -> some View {
        modifier(HeroPulse(trigger: trigger))
    }
}
