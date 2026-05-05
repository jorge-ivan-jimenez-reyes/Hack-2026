import SwiftUI

/// Color flash sutil que aparece UNA vez por cambio de página.
/// Reemplaza el LightSweep blur-heavy anterior. **Performance-friendly**:
/// solo un color plano con opacity fade, sin blur ni shapes grandes.
///
/// 200ms total: 80ms fade-in 18% opacity → 120ms fade-out a 0.
/// Da el "wow" del cambio sin tirar frames.
struct LightSweep: View {
    let trigger: Int
    var color: Color = .brand

    @State private var opacity: Double = 0
    @State private var lastTrigger: Int = -1

    var body: some View {
        color
            .opacity(opacity)
            .ignoresSafeArea()
            .allowsHitTesting(false)
            .blendMode(.plusLighter)
            .onChange(of: trigger) { _, new in
                guard new != lastTrigger else { return }
                lastTrigger = new
                flash()
            }
            .onAppear {
                lastTrigger = trigger
            }
    }

    private func flash() {
        withAnimation(.easeOut(duration: 0.10)) {
            opacity = 0.16
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) {
            withAnimation(.easeIn(duration: 0.22)) {
                opacity = 0
            }
        }
    }
}

/// Pulse sutil del hero al cambiar página — mantenido pero más ligero.
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
        withAnimation(.spring(response: 0.25, dampingFraction: 0.65)) {
            scale = 1.04
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
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
