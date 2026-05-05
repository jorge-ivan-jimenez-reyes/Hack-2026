import SwiftUI

/// Card de categoría de residuos. Usa matchedTransitionSource para el zoom
/// nativo al empujar CategoryDetailView vía NavigationLink.
/// LottiePlayer en el ícono — fallback automático a SF Symbol si no hay JSON.
struct CategoryCard: View {
    let wasteType: GuideWasteType
    let namespace: Namespace.ID

    var body: some View {
        NavigationLink(value: wasteType) {
            cardLabel
                .matchedTransitionSource(id: wasteType.id, in: namespace)
        }
        .buttonStyle(.plain)
    }

    private var cardLabel: some View {
        HStack(spacing: Spacing.m) {
            // Ícono con Lottie (fallback: SF Symbol pulsante)
            ZStack {
                Circle()
                    .fill(wasteType.tint.opacity(0.15))
                LottiePlayer(
                    name: wasteType.lottieAnimation,
                    fallbackSymbol: wasteType.symbol
                )
                .foregroundStyle(wasteType.tint)
                .frame(width: 32, height: 32)
            }
            .frame(width: 52, height: 52)

            VStack(alignment: .leading, spacing: 2) {
                Text(wasteType.title)
                    .font(.appHeadline.weight(.semibold))
                    .foregroundStyle(.inkCharcoal)
                Text("\(wasteType.items.count) objetos · Bolsa \(wasteType.binColorName)")
                    .font(.appCaption)
                    .foregroundStyle(.inkCharcoal.opacity(0.55))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.callout.weight(.semibold))
                .foregroundStyle(.inkCharcoal.opacity(0.30))
        }
        .padding(Spacing.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: Radius.l)
                .fill(.white)
                .shadow(color: Color.inkCharcoal.opacity(0.05), radius: 8, y: 3)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(wasteType.title), \(wasteType.items.count) objetos")
        .accessibilityHint("Toca para ver qué va en bolsa \(wasteType.binColorName)")
    }
}
