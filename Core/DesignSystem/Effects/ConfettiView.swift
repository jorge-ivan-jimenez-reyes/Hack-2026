import SwiftUI

/// Confeti efímero al confirmar una acción positiva (ej. guardar un scan).
/// Cada vez que `trigger` cambia, dispara una nueva ráfaga.
///
/// Sin dependencias externas — usa SwiftUI puro.
struct ConfettiView: View {
    var trigger: Int
    var count: Int = 28

    var body: some View {
        ZStack {
            ForEach(0..<count, id: \.self) { i in
                ConfettiPiece(index: i)
                    .id("\(trigger)-\(i)")
            }
        }
        .allowsHitTesting(false)
    }
}

private struct ConfettiPiece: View {
    let index: Int

    @State private var animated = false
    @State private var dx: CGFloat = 0
    @State private var dy: CGFloat = 0
    @State private var rotation: Double = 0
    @State private var color: Color = .brand
    @State private var size: CGFloat = 8

    var body: some View {
        RoundedRectangle(cornerRadius: 1.5)
            .fill(color)
            .frame(width: size, height: size * 0.45)
            .rotationEffect(.degrees(animated ? rotation : 0))
            .offset(x: animated ? dx : 0, y: animated ? dy : -180)
            .opacity(animated ? 0 : 1)
            .onAppear {
                let palette: [Color] = [
                    .brand, .wasteOrganic, .wastePET,
                    .wasteGlass, .warning, .brandSoft
                ]
                color = palette[index % palette.count]
                dx = .random(in: -140...140)
                dy = .random(in: 360...520)
                rotation = .random(in: -540...540)
                size = .random(in: 6...12)

                withAnimation(.easeOut(duration: .random(in: 1.4...2.0))) {
                    animated = true
                }
            }
    }
}

#Preview {
    @Previewable @State var trigger = 0
    return ZStack {
        Color.black.ignoresSafeArea()
        ConfettiView(trigger: trigger)
        Button("Disparar") { trigger += 1 }
            .buttonStyle(.glassProminent)
    }
}
