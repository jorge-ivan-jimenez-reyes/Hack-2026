import SwiftUI

/// Token (hoja verde) que cae desde lo alto y aterriza en el centro-superior
/// del Home — donde vive la cubeta. Se dispara cuando `trigger` cambia y
/// conecta visualmente "guardé un scan" con "la cubeta avanzó".
///
/// Se monta como overlay encima del Home; `.allowsHitTesting(false)` para
/// no robar taps.
struct FallingLeafToken: View {
    var trigger: Int

    var body: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { i in
                LeafPiece(index: i)
                    .id("\(trigger)-\(i)")
            }
        }
        .allowsHitTesting(false)
    }
}

private struct LeafPiece: View {
    let index: Int

    @State private var animated = false
    @State private var startX: CGFloat = 0

    private var spawnDelay: Double { Double(index) * 0.10 }

    var body: some View {
        GeometryReader { geo in
            let originX = geo.size.width / 2 + startX
            let originY: CGFloat = -40
            let landingX = geo.size.width / 2 + CGFloat.random(in: -40...40)
            // Cubeta vive ~280pt debajo del top (header + wrappedTeaser slot + parte alta de hero)
            let landingY: CGFloat = 320

            Image(systemName: "leaf.fill")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(.brand)
                .shadow(color: .brand.opacity(0.30), radius: 6, y: 3)
                .position(
                    x: animated ? landingX : originX,
                    y: animated ? landingY : originY
                )
                .rotationEffect(.degrees(animated ? Double.random(in: -180...180) : 0))
                .opacity(animated ? 0 : 1)
                .scaleEffect(animated ? 0.4 : 1.0)
                .onAppear {
                    startX = CGFloat.random(in: -60...60)
                    withAnimation(
                        .timingCurve(0.30, 0.05, 0.55, 0.95, duration: 1.1)
                            .delay(spawnDelay)
                    ) {
                        animated = true
                    }
                }
        }
    }
}

#Preview {
    ZStack {
        Color.cream.ignoresSafeArea()
        FallingLeafToken(trigger: 1)
    }
}
