import SwiftUI

/// Ripple ondulante que se dispara cuando `trigger` cambia.
/// 3 anillos blancos concéntricos que se expanden desde el centro y
/// se desvanecen — refuerza visualmente el momento de capture.
struct CaptureRipple: View {
    var trigger: Int

    var body: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { i in
                RipplePiece(index: i)
                    .id("\(trigger)-\(i)")
            }
        }
    }
}

private struct RipplePiece: View {
    let index: Int

    @State private var animated = false

    private var startDelay: Double { Double(index) * 0.12 }

    var body: some View {
        Circle()
            .stroke(.white.opacity(0.7), lineWidth: 3)
            .frame(width: 84, height: 84)
            .scaleEffect(animated ? 2.4 : 1.0)
            .opacity(animated ? 0 : 0.7)
            .onAppear {
                withAnimation(.easeOut(duration: 1.0).delay(startDelay)) {
                    animated = true
                }
            }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        CaptureRipple(trigger: 1)
    }
}
