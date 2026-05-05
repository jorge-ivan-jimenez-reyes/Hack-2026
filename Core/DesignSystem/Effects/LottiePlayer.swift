import SwiftUI
import Lottie

/// Wrapper SwiftUI sobre `LottieView`. Si el JSON no existe en el bundle,
/// usa el SF Symbol como fallback animado — la pantalla NUNCA queda vacía
/// por falta de un Lottie.
///
/// Uso:
/// ```swift
/// LottiePlayer(name: "onboarding-leaf", fallbackSymbol: "leaf.circle.fill")
///     .frame(width: 160, height: 160)
/// ```
struct LottiePlayer: View {
    let name: String
    let fallbackSymbol: String

    private var animation: LottieAnimation? {
        LottieAnimation.named(name)
    }

    /// Verifica si un Lottie JSON existe en el bundle. Útil para decidir entre
    /// LottiePlayer y otro hero antes de instanciar.
    static func exists(_ name: String) -> Bool {
        Bundle.main.url(forResource: name, withExtension: "json") != nil ||
        LottieAnimation.named(name) != nil
    }

    var body: some View {
        if let anim = animation {
            LottieView(animation: anim)
                .looping()
                .resizable()
        } else {
            Image(systemName: fallbackSymbol)
                .resizable()
                .scaledToFit()
                .symbolEffect(.pulse, options: .repeat(.continuous))
        }
    }
}

#Preview {
    LottiePlayer(name: "doesnt-exist", fallbackSymbol: "leaf.circle.fill")
        .foregroundStyle(.brand)
        .frame(width: 160, height: 160)
}
