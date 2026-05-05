import SwiftUI

/// Wrapped mensual estilo Spotify para el Centro de Acopio.
/// 6 slides full-screen con auto-advance + tap para skip + share final.
struct WrappedView: View {
    let data: CentroWrappedData

    @Environment(\.dismiss) private var dismiss
    @State private var currentIndex = 0
    @State private var autoAdvanceTimer: Timer?

    private let slideDuration: TimeInterval = 5.0
    private let totalSlides = 6

    var body: some View {
        ZStack {
            // Fondo gradient cambia por slide
            slideBackground
                .ignoresSafeArea()
                .animation(.smooth(duration: 0.8), value: currentIndex)

            // Contenido del slide actual
            currentSlide
                .id(currentIndex)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))

            // Top: progress bars + close
            VStack {
                topBar
                Spacer()
            }

            // Tap zones (left/right) for manual nav
            HStack(spacing: 0) {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { goToPrev() }
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { goToNext() }
            }
            .ignoresSafeArea()
        }
        .preferredColorScheme(.dark)
        .onAppear { startAutoAdvance() }
        .onDisappear { stopAutoAdvance() }
    }

    // MARK: - Top bar

    private var topBar: some View {
        VStack(spacing: 8) {
            // Progress segments
            HStack(spacing: 4) {
                ForEach(0..<totalSlides, id: \.self) { i in
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.white.opacity(0.30))
                            if i == currentIndex {
                                Capsule()
                                    .fill(Color.white)
                                    .frame(width: geo.size.width * progressForCurrent)
                            } else if i < currentIndex {
                                Capsule()
                                    .fill(Color.white)
                            }
                        }
                    }
                    .frame(height: 3)
                }
            }
            .padding(.horizontal, Spacing.l)

            HStack {
                Text(data.centroName)
                    .font(.appCallout.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.85))
                Spacer()
                Button {
                    Haptics.tap()
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(.white.opacity(0.20), in: .circle)
                }
            }
            .padding(.horizontal, Spacing.l)
        }
        .padding(.top, Spacing.s)
    }

    @State private var progressForCurrent: CGFloat = 0
    @State private var progressTimer: Timer?

    // MARK: - Slide content

    @ViewBuilder
    private var currentSlide: some View {
        switch currentIndex {
        case 0: introSlide
        case 1: kgSlide
        case 2: co2Slide
        case 3: recolectoresSlide
        case 4: comparisonSlide
        case 5: outroSlide
        default: EmptyView()
        }
    }

    private var slideBackground: some View {
        let colors: [[Color]] = [
            [.brand, .moss],                              // Intro
            [.clay, .clay.opacity(0.7)],                  // kg
            [.moss, .brand],                              // CO2
            [.brand, .limeSpark],                         // Recolectores
            [.brand.opacity(0.8), .clay.opacity(0.7)],    // Comparison
            [.forestDeep, .brand]                         // Outro
        ]
        let safeIndex = max(0, min(colors.count - 1, currentIndex))
        return LinearGradient(
            colors: colors[safeIndex],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Slides

    private var introSlide: some View {
        VStack(spacing: Spacing.l) {
            Spacer()
            Image(systemName: "sparkles")
                .font(.system(size: 56))
                .foregroundStyle(.white)
                .symbolEffect(.bounce, options: .repeat(2))

            Text("Tu mes")
                .font(.appBody.weight(.medium))
                .foregroundStyle(.white.opacity(0.85))

            Text("\(data.monthName) \(String(data.year))")
                .font(.system(size: 56, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            Text("Mira lo que lograste en tu centro este mes 👀")
                .font(.appBody)
                .foregroundStyle(.white.opacity(0.85))
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xl)

            Spacer()
        }
    }

    private var kgSlide: some View {
        VStack(spacing: Spacing.m) {
            Spacer()
            Text("Procesaste")
                .font(.appBody.weight(.medium))
                .foregroundStyle(.white.opacity(0.85))

            HStack(alignment: .firstTextBaseline) {
                Text("\(data.kgProcessed)")
                    .font(.system(size: 96, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText(value: Double(data.kgProcessed)))
                Text("kg")
                    .font(.appLargeTitle)
                    .foregroundStyle(.white.opacity(0.85))
            }

            Text("de orgánico ✨")
                .font(.appTitle2)
                .foregroundStyle(.white.opacity(0.95))

            Spacer()

            VStack(spacing: 4) {
                Text("Eso equivale a")
                    .font(.appCallout)
                    .foregroundStyle(.white.opacity(0.75))
                Text("\(data.kgProcessed / 50) bolsas de basura grandes 🗑️")
                    .font(.appHeadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.xl)
            }
            .padding(.bottom, 60)
        }
    }

    private var co2Slide: some View {
        VStack(spacing: Spacing.m) {
            Spacer()
            Image(systemName: "leaf.fill")
                .font(.system(size: 48))
                .foregroundStyle(.white)
                .symbolEffect(.bounce, options: .repeat(2))

            Text("Evitaste")
                .font(.appBody.weight(.medium))
                .foregroundStyle(.white.opacity(0.85))

            HStack(alignment: .firstTextBaseline) {
                Text("\(data.co2KgAvoided)")
                    .font(.system(size: 96, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText(value: Double(data.co2KgAvoided)))
                Text("kg")
                    .font(.appLargeTitle)
                    .foregroundStyle(.white.opacity(0.85))
            }

            Text("de CO₂ ☁️")
                .font(.appTitle2)
                .foregroundStyle(.white.opacity(0.95))

            Spacer()

            VStack(spacing: 6) {
                equivalenceRow(icon: "car.fill", text: "≈ \(data.co2EquivCarKm) km en auto")
                equivalenceRow(icon: "tree.fill", text: "≈ \(data.co2EquivTreesYear) árboles capturando 1 año")
            }
            .padding(.bottom, 60)
        }
    }

    private func equivalenceRow(icon: String, text: String) -> some View {
        HStack(spacing: Spacing.s) {
            Image(systemName: icon).foregroundStyle(.white)
            Text(text)
                .font(.appCallout.weight(.semibold))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, Spacing.m)
        .padding(.vertical, Spacing.s)
        .background(.white.opacity(0.18), in: .capsule)
    }

    private var recolectoresSlide: some View {
        VStack(spacing: Spacing.m) {
            Spacer()
            Image(systemName: "person.3.sequence.fill")
                .font(.system(size: 48))
                .foregroundStyle(.white)
                .symbolEffect(.bounce, options: .repeat(2))

            Text("Atendiste a")
                .font(.appBody.weight(.medium))
                .foregroundStyle(.white.opacity(0.85))

            Text("\(data.activeRecolectores)")
                .font(.system(size: 120, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .contentTransition(.numericText(value: Double(data.activeRecolectores)))

            Text("recolectores activos 🌱")
                .font(.appTitle2)
                .foregroundStyle(.white.opacity(0.95))

            Spacer()

            VStack(spacing: 6) {
                Text("Tu MVP del mes")
                    .font(.appCallout)
                    .foregroundStyle(.white.opacity(0.75))
                HStack(spacing: Spacing.s) {
                    Image(systemName: "trophy.fill")
                        .foregroundStyle(.white)
                    Text(data.topRecolectorName)
                        .font(.appHeadline.weight(.bold))
                        .foregroundStyle(.white)
                    Text("· \(data.topRecolectorKg) kg")
                        .font(.appCallout)
                        .foregroundStyle(.white.opacity(0.85))
                }
                .padding(.horizontal, Spacing.l)
                .padding(.vertical, Spacing.s)
                .background(.white.opacity(0.18), in: .capsule)
            }
            .padding(.bottom, 60)
        }
    }

    private var comparisonSlide: some View {
        VStack(spacing: Spacing.m) {
            Spacer()
            Image(systemName: "arrow.up.right.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.white)
                .symbolEffect(.bounce, options: .repeat(2))

            Text("Creciste")
                .font(.appBody.weight(.medium))
                .foregroundStyle(.white.opacity(0.85))

            HStack(alignment: .firstTextBaseline) {
                Text("+\(data.kgGrowthPct)")
                    .font(.system(size: 120, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                Text("%")
                    .font(.appLargeTitle)
                    .foregroundStyle(.white.opacity(0.85))
            }

            Text("vs el mes pasado 📈")
                .font(.appTitle2)
                .foregroundStyle(.white.opacity(0.95))

            Spacer()

            VStack(spacing: Spacing.s) {
                comparisonRow(metric: "Recolectores", value: "+\(data.recolectorGrowthPct)%")
                comparisonRow(metric: "Cubetas", value: "+\(data.cubetasReceived) total")
                comparisonRow(metric: "Lotes terminados", value: "\(data.lotesCompleted)")
            }
            .padding(.horizontal, Spacing.xl)
            .padding(.bottom, 60)
        }
    }

    private func comparisonRow(metric: String, value: String) -> some View {
        HStack {
            Text(metric)
                .font(.appBody)
                .foregroundStyle(.white.opacity(0.85))
            Spacer()
            Text(value)
                .font(.appBody.weight(.bold))
                .foregroundStyle(.white)
        }
        .padding(Spacing.m)
        .background(.white.opacity(0.15), in: RoundedRectangle(cornerRadius: Radius.l))
    }

    private var outroSlide: some View {
        VStack(spacing: Spacing.l) {
            Spacer()
            Image(systemName: "sparkles")
                .font(.system(size: 64))
                .foregroundStyle(.white)
                .symbolEffect(.variableColor.iterative.reversing, options: .repeat(.continuous))

            Text("Tu centro le devolvió")
                .font(.appBody.weight(.medium))
                .foregroundStyle(.white.opacity(0.85))

            HStack(alignment: .firstTextBaseline) {
                Text("\(data.kgAbonoReturned)")
                    .font(.system(size: 96, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                Text("kg")
                    .font(.appLargeTitle)
                    .foregroundStyle(.white.opacity(0.85))
            }

            Text("de abono a la comunidad 🌳")
                .font(.appTitle2)
                .foregroundStyle(.white.opacity(0.95))
                .multilineTextAlignment(.center)

            Spacer()

            VStack(spacing: Spacing.s) {
                Button {
                    Haptics.confirm()
                    shareWrapped()
                } label: {
                    HStack(spacing: Spacing.s) {
                        Image(systemName: "square.and.arrow.up")
                        Text("Compartir reporte")
                            .font(.appHeadline.weight(.semibold))
                    }
                    .foregroundStyle(.brand)
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .background(.white, in: .capsule)
                }
                .padding(.horizontal, Spacing.l)

                Button {
                    Haptics.tap()
                    dismiss()
                } label: {
                    Text("Cerrar")
                        .font(.appBody.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.85))
                        .padding(.vertical, Spacing.s)
                }
            }
            .padding(.bottom, 40)
        }
    }

    // MARK: - Navigation

    private func goToNext() {
        Haptics.tap()
        if currentIndex < totalSlides - 1 {
            withAnimation(.smooth(duration: 0.5)) {
                currentIndex += 1
            }
            restartProgress()
        }
    }

    private func goToPrev() {
        Haptics.tap()
        if currentIndex > 0 {
            withAnimation(.smooth(duration: 0.5)) {
                currentIndex -= 1
            }
            restartProgress()
        }
    }

    private func startAutoAdvance() {
        progressForCurrent = 0
        startProgressTimer()
        autoAdvanceTimer = Timer.scheduledTimer(withTimeInterval: slideDuration, repeats: true) { _ in
            Task { @MainActor in
                if currentIndex < totalSlides - 1 {
                    withAnimation(.smooth(duration: 0.5)) {
                        currentIndex += 1
                    }
                    restartProgress()
                } else {
                    stopAutoAdvance()
                }
            }
        }
    }

    private func stopAutoAdvance() {
        autoAdvanceTimer?.invalidate()
        autoAdvanceTimer = nil
        progressTimer?.invalidate()
        progressTimer = nil
    }

    private func startProgressTimer() {
        progressForCurrent = 0
        let step: TimeInterval = 0.05
        let increment: CGFloat = CGFloat(step / slideDuration)
        progressTimer = Timer.scheduledTimer(withTimeInterval: step, repeats: true) { _ in
            Task { @MainActor in
                progressForCurrent = min(1, progressForCurrent + increment)
            }
        }
    }

    private func restartProgress() {
        progressTimer?.invalidate()
        progressForCurrent = 0
        startProgressTimer()
    }

    private func shareWrapped() {
        // TODO: implementar UIActivityViewController real
    }
}

#Preview {
    WrappedView(data: .mock)
}
