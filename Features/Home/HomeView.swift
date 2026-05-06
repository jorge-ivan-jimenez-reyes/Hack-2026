import SwiftUI

/// Pantalla principal del Recolector. Compone el Home state-aware:
/// hero que cambia con la etapa, tracker 15:1, impacto, coach IA y cuadra.
/// FAB de Escanear flotando siempre.
///
/// **Cada card es tappable** — abre un InfoSheet explicando qué significa.
struct HomeView: View {
    /// Estado base — name, alcaldía, modalidad. El progreso real
    /// (cubeta, completed, kg) viene de `@AppStorage` para que el Scanner
    /// pueda actualizarlo y el Home reaccione automáticamente.
    @State private var state: RecolectorState = .empty
    @State private var showScanner = false
    @State private var showCenterMap = false
    @State private var showSettings = false
    @State private var showWrapped = false
    @State private var showSchedule = false
    @State private var showAbono = false
    @State private var fillBurstTrigger = 0
    @State private var fallingLeafTrigger = 0
    @State private var coachStarterPrompt: String?

    /// InfoSheet activo (uno a la vez). Nil = sin sheet.
    @State private var activeInfo: InfoKind?

    @AppStorage("recolector.serviceMode") private var serviceModeRaw = "drop_off"

    // Progreso persistido — único source of truth, escrito por ResultView.save()
    @AppStorage(RecolectorProgress.Keys.bucketProgress) private var storedBucketProgress: Double = 0
    @AppStorage(RecolectorProgress.Keys.bucketsCompleted) private var storedBucketsCompleted: Int = 0
    @AppStorage(RecolectorProgress.Keys.totalKg) private var storedTotalKg: Double = 0
    @AppStorage(RecolectorProgress.Keys.streakDays) private var storedStreakDays: Int = 0

    private var resolvedState: RecolectorState {
        var s = state
        s.serviceMode = serviceModeRaw == "pickup" ? .pickup : .dropOff
        s.currentBucketProgress = storedBucketProgress
        s.bucketsCompleted = storedBucketsCompleted
        s.totalKgDiverted = storedTotalKg
        s.co2SavedKg = storedTotalKg * 1.9    // factor metano evitado
        s.streakDays = max(s.streakDays, storedStreakDays)
        s.stage = derivedStage()
        s.coachTip = contextualTip.text
        return s
    }

    /// Tip contextual del Coach IA — derivado del progreso actual.
    /// Cambia con la cubeta, la racha y el ciclo 15:1.
    private var contextualTip: ContextualCoachTip {
        CoachTipEngine.tip(
            bucketProgress: storedBucketProgress,
            bucketsCompleted: storedBucketsCompleted,
            streakDays: max(state.streakDays, storedStreakDays)
        )
    }

    /// Deriva el stage del usuario a partir del progreso persistido.
    /// .abonoReady gana sobre todo: 15 cubetas → toca recibir abono.
    private func derivedStage() -> RecolectorJourneyStage {
        if storedBucketsCompleted >= RecolectorProgress.bucketsForAbono { return .abonoReady }
        if storedBucketProgress >= 1.0 { return .bucketReady }
        if storedBucketProgress > 0 || storedBucketsCompleted > 0 { return .filling }
        return .onboardingPending
    }

    /// Kg de abono que recibe el usuario al cerrar el ciclo.
    /// Aproximación: 1.5 kg por cubeta (15 cubetas ≈ 22.5 kg de composta).
    private var kgAbonoForCycle: Double {
        Double(RecolectorProgress.bucketsForAbono) * 1.5
    }

    /// El teaser del Wrapped solo aparece en los últimos 5 días del mes — fuera
    /// de eso es ruido (Simplicity: revelar features cuando son relevantes).
    private var shouldShowWrappedTeaser: Bool {
        let cal = Calendar.current
        let now = Date()
        guard let range = cal.range(of: .day, in: .month, for: now),
              let lastDay = range.last else { return false }
        let day = cal.component(.day, from: now)
        return day >= lastDay - 4
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Particle burst overlay — se dispara al cruzar a bucketReady.
            // Está arriba de todo lo demás pero `.allowsHitTesting(false)`
            // adentro del ConfettiView lo hace transparente al toque.
            ConfettiView(trigger: fillBurstTrigger, count: 36)
                .ignoresSafeArea()
                .zIndex(10)

            // Hoja cayendo — visualiza el "token tumbling" cuando un scan
            // hizo subir el progreso de la cubeta.
            FallingLeafToken(trigger: fallingLeafTrigger)
                .ignoresSafeArea()
                .zIndex(9)

            ScrollView {
                VStack(spacing: Spacing.l) {
                    HomeHeader(
                        name: state.name,
                        alcaldia: state.alcaldia,
                        streakDays: state.streakDays,
                        onTapProfile: { showSettings = true }
                    )

                    if shouldShowWrappedTeaser {
                        wrappedTeaser
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    Button {
                        Haptics.tap()
                        activeInfo = .cubeta
                    } label: {
                        HeroCubetaCard(
                            state: resolvedState,
                            onPrimaryAction: { handleHeroAction() },
                            onTapModalityChip: { showCenterMap = true }
                        )
                    }
                    .buttonStyle(.plain)

                    scheduleShortcut

                    Button {
                        Haptics.tap()
                        activeInfo = .tracker
                    } label: {
                        CubetaTracker(completed: resolvedState.bucketsCompleted)
                    }
                    .buttonStyle(.plain)

                    ImpactRow(
                        totalKg: resolvedState.totalKgDiverted,
                        co2Kg: resolvedState.co2SavedKg,
                        streakDays: resolvedState.streakDays,
                        onTap: { stat in
                            switch stat {
                            case .kg:    activeInfo = .impactoKg
                            case .co2:   activeInfo = .impactoCO2
                            case .racha: activeInfo = .impactoRacha
                            }
                        }
                    )

                    CoachTipCard(tip: resolvedState.coachTip) {
                        Haptics.tap()
                        // Abre el chat con la pregunta seed del tip cargada,
                        // así el coach arranca conversación con contexto real.
                        coachStarterPrompt = contextualTip.prompt
                    }

                    CuadraCard(
                        weeklyKg: resolvedState.cuadraKgWeek,
                        percentile: resolvedState.cuadraRankPercentile,
                        premioGoalKg: resolvedState.cuadraPremioGoalKg
                    ) {
                        Haptics.tap()
                        activeInfo = .cuadra
                    }

                    Color.clear.frame(height: 100) // espacio para el FAB
                }
                .padding(.vertical, Spacing.s)
            }
            .background(Color.surface)
            .scrollIndicators(.hidden)

            ScanFAB { showScanner = true }
                .padding(.trailing, Spacing.l)
                .padding(.bottom, Spacing.l)
        }
        .sheet(isPresented: $showScanner) {
            ScannerView()
        }
        .fullScreenCover(isPresented: $showCenterMap) {
            CenterMapView()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .fullScreenCover(isPresented: $showWrapped) {
            RecolectorWrappedView(data: .mock)
        }
        .fullScreenCover(isPresented: $showAbono) {
            AbonoReceivedView(kgAbono: kgAbonoForCycle)
        }
        .sheet(item: Binding(
            get: { coachStarterPrompt.map { CoachStarter(prompt: $0) } },
            set: { coachStarterPrompt = $0?.prompt }
        )) { starter in
            CoachView(starterPrompt: starter.prompt)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showSchedule) {
            ScheduleDeliverySheet(
                mode: resolvedState.serviceMode,
                nearestCenter: resolvedState.nearestCenter
            )
            // Progressive disclosure: arranca en medium para que se vean
            // las opciones esenciales; drag a large revela el form completo.
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .sheet(item: $activeInfo) { kind in
            kind.sheet
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .onAppear {
            // Seed primera vez: mete valores creíbles para que el Home no se
            // vea vacío al primer launch. Solo corre si nunca se sembró.
            RecolectorProgress.seedIfNeeded()
            WidgetState.sync(
                bucketProgress: resolvedState.currentBucketProgress,
                bucketsCompleted: resolvedState.bucketsCompleted,
                totalKgDiverted: resolvedState.totalKgDiverted
            )
        }
        // Family-style: burst de partículas cuando la cubeta cruza a 100%
        // (filling → bucketReady). Es el momento que recompensa la racha
        // de scans del usuario.
        .onChange(of: resolvedState.stage) { oldStage, newStage in
            if newStage == .bucketReady && oldStage != .bucketReady {
                Haptics.success()
                fillBurstTrigger += 1
            }
        }
        // Token tumbling: cada vez que el progreso o el contador suben,
        // animamos la hoja cayendo desde arriba al centro del Home.
        // Visualiza la conexión "scan guardado → cubeta avanzó".
        .onChange(of: storedBucketProgress) { oldValue, newValue in
            if newValue > oldValue {
                fallingLeafTrigger += 1
            }
        }
        .onChange(of: storedBucketsCompleted) { oldValue, newValue in
            if newValue > oldValue {
                fallingLeafTrigger += 1
            }
        }
    }

    /// Acceso rápido al flow de programar entrega — disponible sin importar la
    /// etapa, así el usuario siempre puede agendar (no solo cuando la cubeta
    /// está al 100%). Aparece como un botón sutil bajo el hero.
    private var scheduleShortcut: some View {
        Button {
            Haptics.tap()
            showSchedule = true
        } label: {
            HStack(spacing: Spacing.s) {
                Image(systemName: "calendar.badge.plus")
                    .font(.callout.weight(.semibold))
                Text(resolvedState.serviceMode == .pickup ? "Programar pickup" : "Programar entrega")
                    .font(.appCallout.weight(.semibold))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
            }
            .foregroundStyle(.brand)
            .padding(.horizontal, Spacing.l)
            .padding(.vertical, Spacing.m)
            .background {
                RoundedRectangle(cornerRadius: Radius.l)
                    .fill(.white)
                    .shadow(color: Color.inkCharcoal.opacity(0.05), radius: 8, y: 3)
            }
        }
        .buttonStyle(.plain)
        .padding(.horizontal, Spacing.l)
    }

    /// Card prominente que invita a ver el wrapped del mes del recolector.
    private var wrappedTeaser: some View {
        Button {
            Haptics.confirm()
            showWrapped = true
        } label: {
            HStack(spacing: Spacing.m) {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.20))
                    Image(systemName: "sparkles")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .symbolEffect(.variableColor.iterative.reversing, options: .repeat(.continuous))
                }
                .frame(width: 52, height: 52)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Tu mes en composta")
                        .font(.appHeadline.weight(.bold))
                        .foregroundStyle(.white)
                    Text("Mayo 2026 · Mira tu impacto")
                        .font(.appCaption)
                        .foregroundStyle(.white.opacity(0.85))
                }

                Spacer()

                Image(systemName: "play.fill")
                    .font(.title3)
                    .foregroundStyle(.white)
            }
            .padding(Spacing.l)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                LinearGradient(
                    colors: [.brand, .moss, .clay],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
            .clipShape(RoundedRectangle(cornerRadius: Radius.l))
            .shadow(color: Color.brand.opacity(0.30), radius: 18, y: 6)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, Spacing.l)
    }

    private func handleHeroAction() {
        switch resolvedState.stage {
        case .bucketReady:
            showSchedule = true
        case .abonoReady:
            showAbono = true
        default:
            break
        }
    }
}

/// Wrapper Identifiable para presentar el Coach con un prompt seed.
/// Necesario porque `.sheet(item:)` requiere Identifiable.
struct CoachStarter: Identifiable, Hashable {
    var id: String { prompt }
    let prompt: String
}

/// Tipos de InfoSheet que se pueden mostrar en el Home.
enum InfoKind: Identifiable {
    case cubeta
    case tracker
    case impactoKg
    case impactoCO2
    case impactoRacha
    case coach
    case cuadra

    var id: String {
        switch self {
        case .cubeta:        return "cubeta"
        case .tracker:       return "tracker"
        case .impactoKg:     return "impactoKg"
        case .impactoCO2:    return "impactoCO2"
        case .impactoRacha:  return "impactoRacha"
        case .coach:         return "coach"
        case .cuadra:        return "cuadra"
        }
    }

    @MainActor
    @ViewBuilder
    var sheet: some View {
        switch self {
        case .cubeta:        HomeInfoCatalog.cubeta
        case .tracker:       HomeInfoCatalog.tracker
        case .impactoKg:     HomeInfoCatalog.impactoKg
        case .impactoCO2:    HomeInfoCatalog.impactoCO2
        case .impactoRacha:  HomeInfoCatalog.impactoRacha
        case .coach:         HomeInfoCatalog.coach
        case .cuadra:        HomeInfoCatalog.cuadra
        }
    }
}

#Preview {
    HomeView()
}
