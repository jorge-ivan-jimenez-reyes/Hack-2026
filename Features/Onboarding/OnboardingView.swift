import SwiftUI

/// Flujo de onboarding paginado. Coordina las páginas y el CTA, pero NO
/// renderiza el contenido de cada página — eso vive en `OnboardingPageView`.
///
/// Disparar `onContinue` cierra el onboarding (lo decide `RootView` via
/// `@AppStorage("didOnboard")`).
struct OnboardingView: View {
    let onContinue: () -> Void

    @State private var index = 0
    @State private var dragTilt: CGSize = .zero

    private let pages = OnboardingPage.all

    private var isLast: Bool { index == pages.count - 1 }
    private var currentAccent: Color { pages[index].accent }

    var body: some View {
        ZStack {
            background

            VStack(spacing: 0) {
                topBar
                pagesTabView
                footer
            }

            // Capa fija ENCIMA del TabView con la cubeta + overlay storytelling.
            // Render UNA vez (no por página) — solución al "tarda en cargar"
            // problema de RealityView reinstanciándose.
            sharedHeroLayer
                .allowsHitTesting(false)

            // Color flash global al cambiar de página (200ms total, sin blur)
            pageFlashLayer
        }
        .preferredColorScheme(.light)
    }

    /// Cubeta 3D compartida + overlay storytelling de la página activa.
    /// Posicionada para alinearse con el área superior del TabView.
    private var sharedHeroLayer: some View {
        VStack(spacing: 0) {
            Color.clear.frame(height: 100)  // espacio para topBar + offset

            ZStack {
                // Hero PERSISTENTE — RealityView se queda, solo accent cambia
                heroForCurrentPage
                    .frame(width: 340, height: 340)
                    .heroPulse(trigger: index)

                storyOverlay
                    .frame(width: 340, height: 340)
            }

            Spacer(minLength: 0)
        }
    }

    /// Color flash cubre toda la pantalla — fuera del heroLayer para que sea
    /// global. Performance: un solo Color overlay con opacity fade, sin blur.
    private var pageFlashLayer: some View {
        LightSweep(trigger: index, color: currentAccent)
    }

    /// Hero compartido. NO se re-instancia al cambiar de página — solo
    /// cambia el `accent` que internamente actualiza el material.
    /// Esto da continuidad visual (no hay "snap" entre páginas).
    @ViewBuilder
    private var heroForCurrentPage: some View {
        ProceduralBucketHero(accent: currentAccent, tilt: dragTilt)
    }


    /// Overlay storytelling de la página activa — switch por index.
    @ViewBuilder
    private var storyOverlay: some View {
        switch index {
        case 0: BucketFillingOverlay(accent: currentAccent)
        case 1: BucketPickupOverlay(accent: currentAccent)
        case 2: BucketTransformOverlay(accent: currentAccent)
        case 3: BucketCommunityOverlay(accent: currentAccent)
        default: EmptyView()
        }
    }

    private var pagesTabView: some View {
        TabView(selection: $index) {
            ForEach(pages) { page in
                pageView(for: page)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(AppAnimation.smooth, value: index)
        .simultaneousGesture(parallaxDrag)
    }

    @ViewBuilder
    private func pageView(for page: OnboardingPage) -> some View {
        let isActive = (page.id == index)
        OnboardingPageView(page: page, isActive: isActive)
            .tag(page.id)
            .padding(.horizontal, Spacing.l)
    }

    /// Drag que tilt-ea el hero (parallax 3D). Va en `simultaneousGesture` para
    /// no robar el swipe del TabView (que cambia de página).
    private var parallaxDrag: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                let tx = max(-60, min(60, value.translation.width))
                let ty = max(-40, min(40, value.translation.height))
                dragTilt = CGSize(width: tx, height: ty)
            }
            .onEnded { _ in
                withAnimation(.spring(response: 0.55, dampingFraction: 0.75)) {
                    dragTilt = .zero
                }
            }
    }

    // MARK: - Sections

    /// Fondo blanco-cream dominante con un susurro de verde — el accent
    /// de la página activa solo aparece como tint sutil (5-8% opacity).
    /// Casi imperceptible pero da "vida" sin saturar. Apple Health DNA.
    private var background: some View {
        ZStack {
            backgroundBase
            backgroundMesh
        }
    }

    private var backgroundBase: some View {
        Color.cream.ignoresSafeArea()
    }

    private var backgroundMesh: some View {
        MeshBackground(colors: meshColors, speed: 0.06)
            .ignoresSafeArea()
            .opacity(0.55)
            .animation(.smooth(duration: 0.8, extraBounce: 0.05), value: index)
    }

    private var meshColors: [Color] {
        let accent = currentAccent.opacity(0.07)
        let cream = Color.cream
        let brandSoft = Color.brand.opacity(0.05)
        return [
            cream,    accent,   cream,
            brandSoft, cream,   accent,
            cream,    brandSoft, cream
        ]
    }

    private var topBar: some View {
        HStack {
            Spacer()
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
                        .glassEffect(.regular.tint(.inkCharcoal.opacity(0.05)).interactive(), in: .capsule)
                }
                .accessibilityHint("Omite el onboarding")
            }
        }
        .padding(.horizontal, Spacing.l)
        .padding(.top, Spacing.s)
        .frame(height: 44)
    }

    private var footer: some View {
        VStack(spacing: Spacing.l) {
            PageIndicator(count: pages.count, current: index, tint: .brand)

            Button {
                if isLast {
                    Haptics.confirm()
                    onContinue()
                } else {
                    Haptics.tap()
                    withAnimation(.smooth(duration: 0.55, extraBounce: 0.05)) {
                        index += 1
                    }
                }
            } label: {
                HStack(spacing: Spacing.s) {
                    Text(isLast ? "Empezar" : "Continuar")
                        .font(.appHeadline.weight(.semibold))
                    Image(systemName: isLast ? "arrow.right.circle.fill" : "arrow.right")
                }
                .foregroundStyle(.cream)
                .frame(maxWidth: .infinity, minHeight: 52)
                .padding(.horizontal, Spacing.l)
                .glassEffect(
                    .regular.tint(Color.brand.opacity(0.95)).interactive(),
                    in: .capsule
                )
                .shadow(color: Color.brand.opacity(0.20), radius: 16, y: 6)
            }
            .accessibilityLabel(isLast ? "Empezar a usar la app" : "Continuar al siguiente paso")
        }
        .padding(.horizontal, Spacing.l)
        .padding(.bottom, Spacing.l)
    }
}


#Preview {
    OnboardingView(onContinue: {})
}
