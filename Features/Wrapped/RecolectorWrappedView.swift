import SwiftUI

/// Wrapped del Recolector — 5 slides estilo Spotify con su impacto personal del mes.
/// Mismo shell que el del Centro pero contenido personalizado y emocional.
struct RecolectorWrappedView: View {
    let data: RecolectorWrappedData

    @Environment(\.dismiss) private var dismiss
    @State private var currentIndex = 0
    @State private var progress: CGFloat = 0
    @State private var advanceTimer: Timer?
    @State private var progressTimer: Timer?

    private let slideDuration: TimeInterval = 6.0
    private let totalSlides = 5

    var body: some View {
        ZStack {
            slideBackground
                .ignoresSafeArea()
                .animation(.smooth(duration: 0.8), value: currentIndex)

            currentSlide
                .id(currentIndex)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                .padding(.top, 90)
                .padding(.bottom, 40)
                .padding(.horizontal, Spacing.l)

            VStack(spacing: 0) {
                Color.clear.frame(height: 90)
                HStack(spacing: 0) {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture { goToPrev() }
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture { goToNext() }
                }
            }
            .ignoresSafeArea(edges: .bottom)

            VStack {
                topBar
                Spacer()
            }
        }
        .preferredColorScheme(.dark)
        .onAppear { startTimers() }
        .onDisappear { stopTimers() }
    }

    // MARK: - Background

    private var slideBackground: some View {
        let gradients: [[Color]] = [
            [.brand, .moss],                      // 0 Overview
            [.clay, .brand],                      // 1 Esfuerzo
            [.moss, .limeSpark, .brand],          // 2 Impacto
            [.brand, .clay],                      // 3 Cuadra
            [.forestDeep, .moss]                  // 4 Outro
        ]
        let safe = max(0, min(gradients.count - 1, currentIndex))
        return LinearGradient(colors: gradients[safe], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    // MARK: - Top bar

    private var topBar: some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                ForEach(0..<totalSlides, id: \.self) { i in
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(.white.opacity(0.30))
                            if i == currentIndex {
                                Capsule().fill(.white).frame(width: geo.size.width * progress)
                            } else if i < currentIndex {
                                Capsule().fill(.white)
                            }
                        }
                    }
                    .frame(height: 3)
                }
            }
            .padding(.horizontal, Spacing.l)

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(data.recolectorName)
                        .font(.appCallout.weight(.semibold))
                        .foregroundStyle(.white)
                    Text("Tu mes en composta")
                        .font(.appCaption)
                        .foregroundStyle(.white.opacity(0.65))
                }
                Spacer()
                Button {
                    Haptics.tap()
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.body.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(.white.opacity(0.20), in: .circle)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, Spacing.l)
        }
        .padding(.top, Spacing.s)
    }

    // MARK: - Slides

    @ViewBuilder
    private var currentSlide: some View {
        switch currentIndex {
        case 0: overviewSlide
        case 1: esfuerzoSlide
        case 2: impactoSlide
        case 3: cuadraSlide
        case 4: outroSlide
        default: EmptyView()
        }
    }

    // Slide 0: Overview
    private var overviewSlide: some View {
        VStack(alignment: .leading, spacing: Spacing.l) {
            slideHeader(
                eyebrow: "TU MES",
                title: "\(data.monthName) \(String(data.year))",
                subtitle: "Hola \(data.recolectorName), mira lo que lograste 👀"
            )

            LazyVGrid(columns: [GridItem(.flexible(), spacing: Spacing.m), GridItem(.flexible(), spacing: Spacing.m)], spacing: Spacing.m) {
                miniCard(value: "\(data.cubetasFilled)", unit: "", label: "Cubetas llenas", icon: "circle.grid.3x3.fill")
                miniCard(value: kgString(data.kgDiverted), unit: "kg", label: "Desviaste", icon: "scalemass.fill")
                miniCard(value: "\(data.streakDays)", unit: "días", label: "Racha activa", icon: "flame.fill")
                miniCard(value: "\(data.kgGrowthPct >= 0 ? "+" : "")\(data.kgGrowthPct)%", unit: "", label: "vs mes anterior", icon: "arrow.up.right")
            }

            Spacer()
        }
    }

    // Slide 1: Esfuerzo personal
    private var esfuerzoSlide: some View {
        VStack(alignment: .leading, spacing: Spacing.l) {
            slideHeader(
                eyebrow: "TU ESFUERZO",
                title: "\(data.cubetasFilled) cubetas",
                subtitle: "Lo separaste cubeta por cubeta. Cada una cuenta."
            )

            heroNumberCard(value: kgString(data.kgDiverted), unit: "kg", label: "que NO se fueron al relleno")

            HStack(spacing: Spacing.s) {
                badgeRow(icon: "calendar", text: "Tu mejor día: \(data.bestDay)")
                badgeRow(icon: "leaf.fill", text: "\(data.topCategoryPct)% \(data.topCategory)")
            }

            Spacer()
        }
    }

    // Slide 2: Impacto + equivalencias
    private var impactoSlide: some View {
        VStack(alignment: .leading, spacing: Spacing.l) {
            slideHeader(
                eyebrow: "TU IMPACTO",
                title: "Frenaste el cambio climático",
                subtitle: "Lo que NO se fue al relleno como metano"
            )

            heroNumberCard(value: kgString(data.co2KgAvoided), unit: "kg", label: "de CO₂ evitado")

            VStack(spacing: Spacing.s) {
                equivRow(icon: "car.fill", value: "\(data.co2EquivCarKm)", label: "km en auto")
                equivRow(icon: "lightbulb.fill", value: "\(data.co2EquivLedHours)", label: "horas de foco LED")
                equivRow(icon: "tree.fill", value: String(format: "%.1f", data.co2EquivTreesYear), label: "árboles capturando 1 año")
            }

            Spacer()
        }
    }

    // Slide 3: Tu cuadra
    private var cuadraSlide: some View {
        VStack(alignment: .leading, spacing: Spacing.l) {
            slideHeader(
                eyebrow: "TU CUADRA",
                title: "Top \(data.cuadraRankPercentile)%",
                subtitle: "En \(data.alcaldia) — entre \(data.cuadraNeighbors) vecinos"
            )

            HStack(spacing: Spacing.m) {
                ZStack {
                    Circle().fill(.white.opacity(0.20))
                    Image(systemName: "trophy.fill")
                        .foregroundStyle(.white)
                        .symbolEffect(.bounce, options: .repeat(.continuous))
                }
                .frame(width: 56, height: 56)
                VStack(alignment: .leading, spacing: 2) {
                    Text("ARRIBA DEL PROMEDIO")
                        .font(.appCaption.weight(.bold))
                        .foregroundStyle(.white.opacity(0.75))
                    Text("Tu cuadra desvió")
                        .font(.appCaption)
                        .foregroundStyle(.white.opacity(0.85))
                    Text("\(data.cuadraTotalKg) kg en \(data.monthName)")
                        .font(.appHeadline.weight(.bold))
                        .foregroundStyle(.white)
                }
                Spacer()
            }
            .padding(Spacing.l)
            .background {
                RoundedRectangle(cornerRadius: Radius.l).fill(.white.opacity(0.18))
            }

            LazyVGrid(columns: [GridItem(.flexible(), spacing: Spacing.m), GridItem(.flexible(), spacing: Spacing.m)], spacing: Spacing.m) {
                miniCard(value: "\(data.cuadraNeighbors)", unit: "", label: "Vecinos activos", icon: "person.3.fill")
                miniCard(value: "\(Int((data.kgDiverted / Double(data.cuadraTotalKg)) * 100))%", unit: "", label: "Tu aporte", icon: "chart.pie.fill")
            }

            Spacer()
        }
    }

    // Slide 4: Outro — abono recibido + share
    private var outroSlide: some View {
        VStack(alignment: .leading, spacing: Spacing.l) {
            slideHeader(
                eyebrow: "EL CICLO SE CIERRA",
                title: "Recibiste abono",
                subtitle: "Lo que separaste regresó como composta lista para tus plantas 🌱"
            )

            heroNumberCard(value: kgString(data.kgAbonoRecibido), unit: "kg", label: "de abono recibido")

            Spacer()

            Button {
                Haptics.confirm()
            } label: {
                HStack(spacing: Spacing.s) {
                    Image(systemName: "square.and.arrow.up")
                    Text("Compartir mi mes")
                        .font(.appHeadline.weight(.semibold))
                }
                .foregroundStyle(.brand)
                .frame(maxWidth: .infinity, minHeight: 52)
                .background(.white, in: .capsule)
                .shadow(color: .black.opacity(0.15), radius: 12, y: 6)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Reusable elements

    private func slideHeader(eyebrow: String, title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            Text(eyebrow)
                .font(.appCaption.weight(.bold))
                .foregroundStyle(.white.opacity(0.75))
            Text(title)
                .font(.system(size: 36, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            Text(subtitle)
                .font(.appCallout)
                .foregroundStyle(.white.opacity(0.85))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func heroNumberCard(value: String, unit: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            HStack(alignment: .firstTextBaseline) {
                Text(value)
                    .font(.system(size: 76, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
                Text(unit)
                    .font(.appLargeTitle)
                    .foregroundStyle(.white.opacity(0.85))
            }
            Text(label)
                .font(.appBody)
                .foregroundStyle(.white.opacity(0.85))
        }
        .padding(Spacing.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: Radius.xl).fill(.white.opacity(0.18))
        }
        .overlay {
            RoundedRectangle(cornerRadius: Radius.xl).stroke(.white.opacity(0.25), lineWidth: 1)
        }
    }

    private func miniCard(value: String, unit: String, label: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(.white.opacity(0.20), in: .circle)
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
                if !unit.isEmpty {
                    Text(unit)
                        .font(.appCallout)
                        .foregroundStyle(.white.opacity(0.75))
                }
            }
            Text(label)
                .font(.appCaption)
                .foregroundStyle(.white.opacity(0.75))
        }
        .padding(Spacing.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: Radius.l).fill(.white.opacity(0.15))
        }
    }

    private func badgeRow(icon: String, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.white)
            Text(text)
                .font(.appCaption.weight(.semibold))
                .foregroundStyle(.white)
                .lineLimit(1)
        }
        .padding(.horizontal, Spacing.m)
        .padding(.vertical, Spacing.s)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: Radius.l).fill(.white.opacity(0.15))
        }
    }

    private func equivRow(icon: String, value: String, label: String) -> some View {
        HStack(spacing: Spacing.s) {
            Image(systemName: icon)
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(.white.opacity(0.20), in: .circle)
            Text(value)
                .font(.appHeadline.weight(.bold))
                .foregroundStyle(.white)
            Text(label)
                .font(.appBody)
                .foregroundStyle(.white.opacity(0.85))
            Spacer()
        }
        .padding(.horizontal, Spacing.m)
        .padding(.vertical, Spacing.s)
        .background {
            RoundedRectangle(cornerRadius: Radius.l).fill(.white.opacity(0.15))
        }
    }

    private func kgString(_ value: Double) -> String {
        if value < 10 {
            return String(format: "%.1f", value)
        } else {
            return "\(Int(value))"
        }
    }

    // MARK: - Navigation & timers

    private func goToNext() {
        Haptics.tap()
        guard currentIndex < totalSlides - 1 else { return }
        withAnimation(.smooth(duration: 0.5)) {
            currentIndex += 1
        }
        restartProgress()
    }

    private func goToPrev() {
        Haptics.tap()
        guard currentIndex > 0 else { return }
        withAnimation(.smooth(duration: 0.5)) {
            currentIndex -= 1
        }
        restartProgress()
    }

    private func startTimers() {
        startProgress()
        advanceTimer = Timer.scheduledTimer(withTimeInterval: slideDuration, repeats: true) { _ in
            Task { @MainActor in
                if currentIndex < totalSlides - 1 {
                    withAnimation(.smooth(duration: 0.5)) {
                        currentIndex += 1
                    }
                    restartProgress()
                } else {
                    stopTimers()
                }
            }
        }
    }

    private func stopTimers() {
        advanceTimer?.invalidate(); advanceTimer = nil
        progressTimer?.invalidate(); progressTimer = nil
    }

    private func startProgress() {
        progress = 0
        let step: TimeInterval = 0.05
        let increment = CGFloat(step / slideDuration)
        progressTimer = Timer.scheduledTimer(withTimeInterval: step, repeats: true) { _ in
            Task { @MainActor in
                progress = min(1, progress + increment)
            }
        }
    }

    private func restartProgress() {
        progressTimer?.invalidate()
        startProgress()
    }
}

#Preview {
    RecolectorWrappedView(data: .mock)
}
