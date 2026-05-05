import SwiftUI

/// Una página del flujo de onboarding. El contenido es 100% estático y vive
/// junto al modelo para que añadir/quitar páginas sea editar este archivo y nada más.
struct OnboardingPage: Identifiable, Hashable {
    let id: Int
    let symbol: String
    /// Si hay un archivo `<lottieName>.json` en `Resources/Lottie/`,
    /// se usa como hero animado. Si no, fallback al diseño procedural.
    let lottieName: String?
    let title: String
    let subtitle: String
    let accent: Color
    let particleSymbol: String
}

extension OnboardingPage {
    /// Cuenta la historia del combo de 3 modelos validados:
    /// 1. Tu cubeta = inicio del ciclo
    /// 2. Pickup en casa (Hagamos Composta — mata la hueva)
    /// 3. 15 = 1 (incentivo personal: abono de vuelta)
    /// 4. Tu cuadra suma contigo (Bergamo — premio colectivo)
    static let all: [OnboardingPage] = [
        OnboardingPage(
            id: 0,
            symbol: "arrow.3.trianglepath",
            lottieName: "onboarding-cycle",
            title: "Tu cubeta, tu ciclo",
            subtitle: "Separa tu orgánico en casa. Cada cáscara, cada borra de café es el inicio de la economía circular.",
            accent: .limeSpark,
            particleSymbol: "leaf.fill"
        ),
        OnboardingPage(
            id: 1,
            symbol: "house.and.flag.fill",
            lottieName: "onboarding-pickup",
            title: "Nosotros pasamos por ella",
            subtitle: "Cero viajes. Te avisamos el día y la hora. Tú la dejas afuera, nosotros la cambiamos por una limpia.",
            accent: .clay,
            particleSymbol: "circle.fill"
        ),
        OnboardingPage(
            id: 2,
            symbol: "arrow.2.squarepath",
            lottieName: "onboarding-transform",
            title: "15 = 1",
            subtitle: "Por cada 15 cubetas que separas, recibes 1 cubeta de abono real para tu casa, jardín o macetas.",
            accent: .limeSpark,
            particleSymbol: "leaf.fill"
        ),
        OnboardingPage(
            id: 3,
            symbol: "person.3.sequence.fill",
            lottieName: "onboarding-community",
            title: "Tu cuadra suma contigo",
            subtitle: "Cuando tus vecinos también separan, todos ganan: más abono, menos basura, mejor barrio.",
            accent: .moss,
            particleSymbol: "leaf.fill"
        )
    ]
}
