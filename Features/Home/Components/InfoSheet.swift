import SwiftUI

/// Sheet genérico que explica qué significa cada métrica del Home.
/// Usado en tap de cada card (cubeta, tracker, impacto, coach, cuadra).
struct InfoSheet: View {
    let title: String
    let symbol: String
    let tint: Color
    let descriptionText: String
    let extraLines: [String]
    let cta: (label: String, action: () -> Void)?

    @Environment(\.dismiss) private var dismiss

    init(
        title: String,
        symbol: String,
        tint: Color,
        body: String,
        extraLines: [String] = [],
        cta: (label: String, action: () -> Void)? = nil
    ) {
        self.title = title
        self.symbol = symbol
        self.tint = tint
        self.descriptionText = body
        self.extraLines = extraLines
        self.cta = cta
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.l) {
                // Hero icon
                ZStack {
                    Circle()
                        .fill(tint.opacity(0.15))
                    Image(systemName: symbol)
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundStyle(tint)
                        .symbolEffect(.bounce, options: .repeat(2))
                }
                .frame(width: 84, height: 84)
                .padding(.top, Spacing.l)

                Text(title)
                    .font(.appLargeTitle)
                    .foregroundStyle(.inkCharcoal)
                    .multilineTextAlignment(.center)

                Text(descriptionText)
                    .font(.appBody)
                    .foregroundStyle(.inkCharcoal.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, Spacing.l)

                if !extraLines.isEmpty {
                    VStack(alignment: .leading, spacing: Spacing.s) {
                        ForEach(extraLines, id: \.self) { line in
                            HStack(alignment: .top, spacing: Spacing.s) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(tint)
                                    .padding(.top, 2)
                                Text(line)
                                    .font(.appBody)
                                    .foregroundStyle(.inkCharcoal.opacity(0.75))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(Spacing.l)
                    .background {
                        RoundedRectangle(cornerRadius: Radius.l)
                            .fill(tint.opacity(0.08))
                    }
                    .padding(.horizontal, Spacing.l)
                }

                if let cta = cta {
                    Button {
                        Haptics.confirm()
                        cta.action()
                        dismiss()
                    } label: {
                        Text(cta.label)
                            .font(.appHeadline.weight(.semibold))
                            .foregroundStyle(.cream)
                            .frame(maxWidth: .infinity, minHeight: 52)
                            .padding(.horizontal, Spacing.l)
                            .glassEffect(
                                .regular.tint(tint.opacity(0.95)).interactive(),
                                in: .capsule
                            )
                    }
                    .padding(.horizontal, Spacing.l)
                }

                Spacer(minLength: Spacing.l)
            }
        }
        .background(Color.cream)
        .scrollIndicators(.hidden)
    }
}

/// Catálogo de explicaciones para cada métrica del Home. Centralizado para
/// fácil edición de copy.
@MainActor
enum HomeInfoCatalog {
    static let cubeta = InfoSheet(
        title: "Tu cubeta",
        symbol: "bucket.fill",
        tint: .brand,
        body: "Es donde separas tu orgánico en casa. El % indica qué tan llena está. Cuando llegue al 100%, agendas la entrega o la llevas al centro más cercano.",
        extraLines: [
            "Sí va: cáscaras de fruta y verdura, café molido, hojas, papel",
            "No va: lácteos, huesos de pollo, cítricos, carne, plásticos",
            "Mientras más detalles separas, mejor abono produces"
        ]
    )

    static let tracker = InfoSheet(
        title: "Hacia tu abono",
        symbol: "arrow.2.squarepath",
        tint: .brand,
        body: "Cada vez que entregas una cubeta llena al centro de acopio, sumas 1. Cuando llegues a 15, recibes 1 cubeta de abono real para tu casa, jardín o macetas.",
        extraLines: [
            "15 cubetas tuyas = 1 cubeta de abono de regreso",
            "Modelo validado por Hagamos Composta (CDMX)",
            "Toma ~3 meses si entregas cada semana"
        ]
    )

    static let impacto = InfoSheet(
        title: "Tu impacto",
        symbol: "leaf.fill",
        tint: .moss,
        body: "Mide qué tanto desviaste del relleno sanitario. Cada kg orgánico que NO va a relleno evita ~1.9 kg de CO₂ (porque no se descompone con metano).",
        extraLines: [
            "kg desviados: lo que entregaste en cubetas",
            "kg CO₂ evitado: tu contribución directa al clima",
            "Días seguidos: tu racha actual sin romper el flujo"
        ]
    )

    static let coach = InfoSheet(
        title: "Coach IA",
        symbol: "sparkles",
        tint: .clay,
        body: "Es tu guía personal. Analiza tu historial y te da tips específicos para mejorar tu separación. Corre 100% en tu iPhone (Apple Intelligence on-device) — tus datos nunca salen.",
        extraLines: [
            "Análisis de tu historial real",
            "Tips personalizados según tu volumen",
            "Privado: nada sale de tu iPhone"
        ]
    )

    static let cuadra = InfoSheet(
        title: "Tu cuadra",
        symbol: "house.lodge.fill",
        tint: .moss,
        body: "Cuando varios vecinos de tu colonia separan, todos suman al mismo objetivo. Si llegan al premio comunitario, todos reciben abono extra.",
        extraLines: [
            "Modelo validado por Bergamo (Italia)",
            "Tu kg cuenta para el premio colectivo",
            "Top % CDMX = ranking entre cuadras"
        ]
    )
}
