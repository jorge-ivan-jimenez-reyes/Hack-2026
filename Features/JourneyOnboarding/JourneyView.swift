import SwiftUI

/// Onboarding nuevo tipo journey 3D — un camioncito viaja por 4 stations.
/// Reemplaza al `OnboardingView` cuando esté activado en RootView.
struct JourneyView: View {
    let onContinue: () -> Void

    @State private var stationIndex = 0

    private let stations = JourneyStation.all

    private var isLast: Bool { stationIndex == stations.count - 1 }
    private var currentStation: JourneyStation { stations[stationIndex] }

    var body: some View {
        ZStack {
            background

            // Escena 3D ocupa el top
            VStack(spacing: 0) {
                topBar

                JourneyScene(stationIndex: stationIndex)
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: .infinity)
                    .ignoresSafeArea(edges: .horizontal)

                bottomCard
            }
        }
        .preferredColorScheme(.light)
    }

    // MARK: - Sections

    /// Fondo cream con sutil gradient hacia arriba simulando cielo.
    private var background: some View {
        LinearGradient(
            colors: [
                Color.cream.opacity(0.4),
                Color.cream,
                Color.cream
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private var topBar: some View {
        HStack {
            // Skip
            if !isLast {
                Button {
                    Haptics.tap()
                    onContinue()
                } label: {
                    Text("Saltar")
                        .font(.appCallout.weight(.medium))
                        .foregroundStyle(.inkCharcoal.opacity(0.65))
                        .padding(.horizontal, Spacing.m)
                        .padding(.vertical, Spacing.s)
                        .glassEffect(.regular.tint(.inkCharcoal.opacity(0.06)).interactive(), in: .capsule)
                }
                .accessibilityHint("Omite el onboarding")
            } else {
                Color.clear.frame(height: 36)
            }

            Spacer()

            // Page indicator compacto
            HStack(spacing: 6) {
                ForEach(0..<stations.count, id: \.self) { i in
                    Capsule()
                        .fill(i == stationIndex ? currentStation.accent : Color.inkCharcoal.opacity(0.18))
                        .frame(width: i == stationIndex ? 22 : 6, height: 6)
                        .animation(.smooth(duration: 0.4), value: stationIndex)
                }
            }
            .padding(.horizontal, Spacing.m)
            .padding(.vertical, 6)
            .glassEffect(.regular.tint(.cream.opacity(0.85)), in: .capsule)
        }
        .padding(.horizontal, Spacing.l)
        .padding(.top, Spacing.s)
    }

    /// Card glass con título + subtítulo + CTA Continuar.
    /// Texto cambia con cross-fade al avanzar station.
    private var bottomCard: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            VStack(alignment: .leading, spacing: Spacing.s) {
                Text(currentStation.title)
                    .font(.appLargeTitle)
                    .foregroundStyle(.inkCharcoal)
                    .contentTransition(.opacity)
                    .id("title-\(stationIndex)")
                    .transition(.move(edge: .bottom).combined(with: .opacity))

                Text(currentStation.subtitle)
                    .font(.appBody)
                    .foregroundStyle(.inkCharcoal.opacity(0.65))
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .id("subtitle-\(stationIndex)")
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .animation(.smooth(duration: 0.5, extraBounce: 0.05), value: stationIndex)

            ctaButton
        }
        .padding(Spacing.l)
        .background {
            RoundedRectangle(cornerRadius: Radius.xl, style: .continuous)
                .fill(.ultraThickMaterial)
                .shadow(color: Color.inkCharcoal.opacity(0.10), radius: 24, y: -4)
        }
        .padding(.horizontal, Spacing.m)
        .padding(.bottom, Spacing.l)
    }

    private var ctaButton: some View {
        Button {
            if isLast {
                Haptics.confirm()
                onContinue()
            } else {
                Haptics.tap()
                withAnimation(.smooth(duration: 0.55, extraBounce: 0.05)) {
                    stationIndex += 1
                }
            }
        } label: {
            HStack(spacing: Spacing.s) {
                Text(isLast ? "Empezar" : "Continuar")
                    .font(.appHeadline.weight(.semibold))
                Image(systemName: isLast ? "arrow.right.circle.fill" : "arrow.right")
                    .symbolEffect(.bounce, value: stationIndex)
            }
            .foregroundStyle(.cream)
            .frame(maxWidth: .infinity, minHeight: 52)
            .padding(.horizontal, Spacing.l)
            .glassEffect(
                .regular.tint(currentStation.accent.opacity(0.95)).interactive(),
                in: .capsule
            )
            .shadow(color: currentStation.accent.opacity(0.30), radius: 16, y: 6)
        }
        .accessibilityLabel(isLast ? "Empezar a usar la app" : "Continuar al siguiente paso")
    }
}

#Preview {
    JourneyView(onContinue: {})
}
