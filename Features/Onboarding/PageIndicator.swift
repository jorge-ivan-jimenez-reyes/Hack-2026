import SwiftUI

/// Indicador de páginas premium — la cápsula del dot activo **se desliza**
/// entre posiciones via `matchedGeometryEffect`, dando la sensación de que
/// es UN solo elemento que viaja en lugar de 4 dots fading.
/// Apple Health/Fitness DNA.
struct PageIndicator: View {
    let count: Int
    let current: Int
    var tint: Color = .brand

    @Namespace private var indicatorNamespace

    var body: some View {
        HStack(spacing: Spacing.s) {
            ForEach(0..<count, id: \.self) { index in
                ZStack {
                    if index == current {
                        Capsule()
                            .fill(tint)
                            .frame(width: 28, height: 8)
                            .matchedGeometryEffect(id: "active", in: indicatorNamespace)
                    } else {
                        Capsule()
                            .fill(tint.opacity(0.18))
                            .frame(width: 8, height: 8)
                    }
                }
                .frame(width: 28, height: 8, alignment: .center)
            }
        }
        .animation(.smooth(duration: 0.45, extraBounce: 0.05), value: current)
        .accessibilityElement()
        .accessibilityLabel("Página \(current + 1) de \(count)")
    }
}

#Preview {
    @Previewable @State var page = 0
    VStack(spacing: Spacing.l) {
        PageIndicator(count: 4, current: page)
        Button("Next") { page = (page + 1) % 4 }
    }
    .padding()
    .background(Color.cream)
}
