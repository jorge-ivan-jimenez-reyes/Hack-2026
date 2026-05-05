import SwiftUI

/// Render del TEXTO de UNA página del onboarding. La cubeta 3D y los overlays
/// storytelling viven en `OnboardingView` (compartidos), no aquí — esta vista
/// solo aporta el texto y el espacio donde flotará la cubeta.
struct OnboardingPageView: View {
    let page: OnboardingPage
    let isActive: Bool

    @State private var titleOffset: CGFloat = 16
    @State private var titleOpacity: Double = 0
    @State private var subtitleOffset: CGFloat = 12
    @State private var subtitleOpacity: Double = 0

    var body: some View {
        VStack(spacing: Spacing.xxl) {
            // Espacio donde "flota" la cubeta compartida (renderizada arriba)
            Color.clear.frame(height: 360)

            textBlock

            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(page.title). \(page.subtitle)")
        .onAppear { if isActive { play() } else { reset() } }
        .onChange(of: isActive) { _, nowActive in
            if nowActive { play() } else { reset() }
        }
    }

    private var textBlock: some View {
        VStack(spacing: Spacing.m) {
            Text(page.title)
                .font(.appLargeTitle)
                .foregroundStyle(.inkCharcoal)
                .multilineTextAlignment(.center)
                .offset(y: titleOffset)
                .opacity(titleOpacity)

            Text(page.subtitle)
                .font(.appBody)
                .foregroundStyle(.inkCharcoal.opacity(0.65))
                .multilineTextAlignment(.center)
                .lineLimit(4)
                .fixedSize(horizontal: false, vertical: true)
                .offset(y: subtitleOffset)
                .opacity(subtitleOpacity)
        }
        .padding(.horizontal, Spacing.xl)
    }

    private func play() {
        reset()
        withAnimation(.smooth(duration: 0.55, extraBounce: 0.05).delay(0.18)) {
            titleOffset = 0
            titleOpacity = 1
        }
        withAnimation(.smooth(duration: 0.55, extraBounce: 0.05).delay(0.30)) {
            subtitleOffset = 0
            subtitleOpacity = 1
        }
    }

    private func reset() {
        titleOffset = 16
        titleOpacity = 0
        subtitleOffset = 12
        subtitleOpacity = 0
    }
}

#Preview {
    ZStack {
        Color.cream.ignoresSafeArea()
        OnboardingPageView(page: OnboardingPage.all[0], isActive: true)
    }
}
