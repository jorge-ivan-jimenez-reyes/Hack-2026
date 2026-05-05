import SwiftUI

/// Wrapped del Centro — slides estilo Spotify pero cada uno es un mini-dashboard
/// con varias cards de métricas en vez de un solo número gigante.
/// Auto-advance + tap zones (no cubren topBar) + close X funcional.
struct WrappedView: View {
    let data: CentroWrappedData

    @Environment(\.dismiss) private var dismiss
    @State private var currentIndex = 0
    @State private var progress: CGFloat = 0
    @State private var advanceTimer: Timer?
    @State private var progressTimer: Timer?

    private let slideDuration: TimeInterval = 6.0
    private let totalSlides = 5

    var body: some View {
        ZStack {
            // 1. Background gradient cambia por slide
            slideBackground
                .ignoresSafeArea()
                .animation(.smooth(duration: 0.8), value: currentIndex)

            // 2. Slide content
            currentSlide
                .id(currentIndex)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                .padding(.top, 90)
                .padding(.bottom, 40)
                .padding(.horizontal, Spacing.l)

            // 3. Tap zones — NO cubren los 90pt de arriba (donde está el topBar)
            VStack(spacing: 0) {
                Color.clear.frame(height: 90)   // espacio para topBar, sin tap
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

            // 4. TopBar siempre on TOP — close X funciona
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
            [.brand, .moss],                      // Slide 0 — Overview
            [.clay, .clay.opacity(0.7), .brand],  // Slide 1 — Kg / volumen
            [.moss, .brand, .limeSpark],          // Slide 2 — CO₂ / impacto
            [.brand, .limeSpark],                 // Slide 3 — Recolectores
            [.forestDeep, .brand]                 // Slide 4 — Outro
        ]
        let safe = max(0, min(gradients.count - 1, currentIndex))
        return LinearGradient(colors: gradients[safe], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    // MARK: - Top bar (progress + close)

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
                    Text(data.centroName)
                        .font(.appCallout.weight(.semibold))
                        .foregroundStyle(.white)
                    Text("Reporte mensual")
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
        case 1: volumeSlide
        case 2: impactSlide
        case 3: recolectoresSlide
        case 4: outroSlide
        default: EmptyView()
        }
    }

    // Slide 0: Overview — 4 stats clave
    private var overviewSlide: some View {
        VStack(alignment: .leading, spacing: Spacing.l) {
            slideHeader(eyebrow: "TU MES", title: "\(data.monthName) \(String(data.year))", subtitle: "Mira lo que lograste 👀")

            LazyVGrid(columns: [GridItem(.flexible(), spacing: Spacing.m), GridItem(.flexible(), spacing: Spacing.m)], spacing: Spacing.m) {
                miniCard(value: "\(data.kgProcessed)", unit: "kg", label: "Procesados", icon: "scalemass.fill")
                miniCard(value: "\(data.co2KgAvoided)", unit: "kg", label: "CO₂ evitado", icon: "leaf.fill")
                miniCard(value: "\(data.activeRecolectores)", unit: "", label: "Recolectores", icon: "person.3.fill")
                miniCard(value: "\(data.lotesCompleted)", unit: "", label: "Lotes terminados", icon: "checkmark.seal.fill")
            }

            Spacer()
        }
    }

    // Slide 1: Volumen (kg + cubetas + crecimiento)
    private var volumeSlide: some View {
        VStack(alignment: .leading, spacing: Spacing.l) {
            slideHeader(eyebrow: "VOLUMEN", title: "Procesaste mucho", subtitle: "El volumen del mes en cifras")

            heroNumberCard(value: "\(data.kgProcessed)", unit: "kg", label: "de orgánico desviado")

            LazyVGrid(columns: [GridItem(.flexible(), spacing: Spacing.m), GridItem(.flexible(), spacing: Spacing.m)], spacing: Spacing.m) {
                miniCard(value: "\(data.cubetasReceived)", unit: "", label: "Cubetas recibidas", icon: "circle.grid.3x3.fill")
                miniCard(value: "+\(data.kgGrowthPct)%", unit: "", label: "vs mes pasado", icon: "arrow.up.right")
            }

            Spacer()
        }
    }

    // Slide 2: Impacto (CO2 + equivalencias)
    private var impactSlide: some View {
        VStack(alignment: .leading, spacing: Spacing.l) {
            slideHeader(eyebrow: "IMPACTO", title: "Frenaste el cambio climático", subtitle: "Lo que NO se fue al relleno como metano")

            heroNumberCard(value: "\(data.co2KgAvoided)", unit: "kg", label: "de CO₂ evitado")

            VStack(spacing: Spacing.s) {
                equivRow(icon: "car.fill", value: "\(data.co2EquivCarKm)", label: "km en auto")
                equivRow(icon: "tree.fill", value: "\(data.co2EquivTreesYear)", label: "árboles capturando 1 año")
            }

            Spacer()
        }
    }

    // Slide 3: Recolectores + MVP + comparación
    private var recolectoresSlide: some View {
        VStack(alignment: .leading, spacing: Spacing.l) {
            slideHeader(eyebrow: "TU COMUNIDAD", title: "\(data.activeRecolectores) recolectores", subtitle: "Personas que confiaron en tu centro")

            // MVP card grande
            HStack(spacing: Spacing.m) {
                ZStack {
                    Circle().fill(.white.opacity(0.20))
                    Image(systemName: "trophy.fill")
                        .foregroundStyle(.white)
                        .symbolEffect(.bounce, options: .repeat(.continuous))
                }
                .frame(width: 56, height: 56)
                VStack(alignment: .leading, spacing: 2) {
                    Text("MVP DEL MES")
                        .font(.appCaption.weight(.bold))
                        .foregroundStyle(.white.opacity(0.75))
                    Text(data.topRecolectorName)
                        .font(.appHeadline.weight(.bold))
                        .foregroundStyle(.white)
                    Text("\(data.topRecolectorKg) kg entregados")
                        .font(.appCaption)
                        .foregroundStyle(.white.opacity(0.85))
                }
                Spacer()
            }
            .padding(Spacing.l)
            .background {
                RoundedRectangle(cornerRadius: Radius.l).fill(.white.opacity(0.18))
            }

            LazyVGrid(columns: [GridItem(.flexible(), spacing: Spacing.m), GridItem(.flexible(), spacing: Spacing.m)], spacing: Spacing.m) {
                miniCard(value: "+\(data.recolectorGrowthPct)%", unit: "", label: "Nuevos vs Abril", icon: "person.fill.badge.plus")
                miniCard(value: "\(data.cubetasReceived / data.activeRecolectores)", unit: "", label: "Cubetas/recolector", icon: "chart.bar.fill")
            }

            Spacer()
        }
    }

    // Slide 4: Outro — abono devuelto + share
    private var outroSlide: some View {
        VStack(alignment: .leading, spacing: Spacing.l) {
            slideHeader(eyebrow: "DEVOLVISTE A LA COMUNIDAD", title: "Cerramos el ciclo", subtitle: "Esto regresó a casas, jardines y huertos urbanos")

            heroNumberCard(value: "\(data.kgAbonoReturned)", unit: "kg", label: "de abono devueltos 🌳")

            Spacer()

            Button {
                Haptics.confirm()
            } label: {
                HStack(spacing: Spacing.s) {
                    Image(systemName: "square.and.arrow.up")
                    Text("Compartir reporte")
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
    WrappedView(data: .mock)
}
