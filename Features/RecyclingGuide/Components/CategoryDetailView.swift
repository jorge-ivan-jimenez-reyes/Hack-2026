import SwiftUI

/// Vista de detalle de una categoría de residuos.
/// Se empuja vía NavigationLink con .navigationTransition(.zoom(...)) desde RecyclingGuideView.
struct CategoryDetailView: View {
    let wasteType: GuideWasteType

    private let columns = [
        GridItem(.flexible(), spacing: Spacing.m),
        GridItem(.flexible(), spacing: Spacing.m),
        GridItem(.flexible(), spacing: Spacing.m),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                hero
                content
                    .padding(.vertical, Spacing.xl)
            }
        }
        .scrollIndicators(.hidden)
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .background(Color.cream.ignoresSafeArea())
    }

    // MARK: - Hero

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            // Fondo degradado con color de categoría
            LinearGradient(
                colors: [wasteType.tint, wasteType.tint.opacity(0.75)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 280)

            // Lottie animation (fallback: SF Symbol animado)
            LottiePlayer(
                name: wasteType.lottieAnimation,
                fallbackSymbol: wasteType.symbol
            )
            .foregroundStyle(.white.opacity(0.25))
            .frame(width: 180, height: 180)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.trailing, Spacing.l)
            .padding(.top, 60)

            // Texto en esquina inferior izquierda
            VStack(alignment: .leading, spacing: Spacing.xs) {
                binBadge
                Text(wasteType.title)
                    .font(.appTitle2.weight(.bold))
                    .foregroundStyle(.white)
                Text(wasteType.subtitle)
                    .font(.appCallout)
                    .foregroundStyle(.white.opacity(0.80))
            }
            .padding(.horizontal, Spacing.l)
            .padding(.bottom, Spacing.xl)
        }
    }

    private var binBadge: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(.white)
                .frame(width: 10, height: 10)
            Text("Bolsa \(wasteType.binColorName)")
                .font(.appCaption.weight(.semibold))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, Spacing.m)
        .padding(.vertical, 6)
        .background(.white.opacity(0.20), in: Capsule())
        .overlay { Capsule().stroke(.white.opacity(0.35), lineWidth: 1) }
    }

    // MARK: - Content

    private var content: some View {
        VStack(alignment: .leading, spacing: Spacing.xl) {
            separationSection
            itemsSection
            disposalSection
        }
        .padding(.horizontal, Spacing.l)
    }

    // MARK: Cómo separarlo

    private var separationSection: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            sectionHeader(icon: "hand.raised.fill", title: "Cómo separarlo")

            VStack(spacing: Spacing.s) {
                ForEach(Array(wasteType.separationSteps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: Spacing.m) {
                        ZStack {
                            Circle()
                                .fill(wasteType.tint.opacity(0.15))
                            Text("\(index + 1)")
                                .font(.appCaption.weight(.bold))
                                .foregroundStyle(wasteType.tint)
                        }
                        .frame(width: 28, height: 28)

                        Text(step)
                            .font(.appBody)
                            .foregroundStyle(.inkCharcoal)
                            .fixedSize(horizontal: false, vertical: true)

                        Spacer(minLength: 0)
                    }
                    .padding(Spacing.m)
                    .background {
                        RoundedRectangle(cornerRadius: Radius.m)
                            .fill(.white)
                            .shadow(color: .inkCharcoal.opacity(0.04), radius: 6, y: 2)
                    }
                }
            }
        }
    }

    // MARK: Qué incluye

    private var itemsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            sectionHeader(
                icon: "list.bullet.rectangle.fill",
                title: "Qué incluye",
                badge: "\(wasteType.items.count) objetos"
            )

            LazyVGrid(columns: columns, spacing: Spacing.m) {
                ForEach(wasteType.items) { item in
                    itemCell(item)
                }
            }
        }
    }

    private func itemCell(_ item: GuideWasteItem) -> some View {
        VStack(spacing: Spacing.s) {
            ZStack {
                Circle()
                    .fill(wasteType.tint.opacity(0.10))
                Image(systemName: item.symbol)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(wasteType.tint)
            }
            .frame(width: 52, height: 52)

            Text(item.name)
                .font(.appCaption)
                .foregroundStyle(.inkCharcoal)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(2)
        }
        .padding(Spacing.m)
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: Radius.l)
                .fill(.white)
                .shadow(color: .inkCharcoal.opacity(0.05), radius: 6, y: 2)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(item.name)
    }

    // MARK: Nota de disposición

    private var disposalSection: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            sectionHeader(icon: "info.circle.fill", title: "Dónde entregarlo")

            Text(wasteType.disposalNote)
                .font(.appCallout)
                .foregroundStyle(.inkCharcoal.opacity(0.75))
                .fixedSize(horizontal: false, vertical: true)
                .padding(Spacing.l)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background {
                    RoundedRectangle(cornerRadius: Radius.l)
                        .fill(wasteType.tint.opacity(0.08))
                        .overlay {
                            RoundedRectangle(cornerRadius: Radius.l)
                                .stroke(wasteType.tint.opacity(0.20), lineWidth: 1)
                        }
                }
        }
    }

    // MARK: - Helpers

    @ViewBuilder
    private func sectionHeader(icon: String, title: String, badge: String? = nil) -> some View {
        HStack(spacing: Spacing.s) {
            Image(systemName: icon)
                .foregroundStyle(wasteType.tint)
            Text(title)
                .font(.appHeadline.weight(.semibold))
                .foregroundStyle(.inkCharcoal)
            if let badge {
                Spacer()
                Text(badge)
                    .font(.appCaption.weight(.semibold))
                    .foregroundStyle(wasteType.tint)
                    .padding(.horizontal, Spacing.m)
                    .padding(.vertical, 4)
                    .background(wasteType.tint.opacity(0.12), in: Capsule())
            }
        }
    }
}

#Preview {
    NavigationStack {
        CategoryDetailView(wasteType: .organic)
    }
}

#Preview("Inorgánico") {
    NavigationStack {
        CategoryDetailView(wasteType: .inorganic)
    }
}

#Preview("Sanitario") {
    NavigationStack {
        CategoryDetailView(wasteType: .sanitary)
    }
}
