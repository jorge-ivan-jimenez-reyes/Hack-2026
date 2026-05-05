import SwiftUI

/// Pantalla principal del Recolector. Compone el Home state-aware:
/// hero que cambia con la etapa, tracker 15:1, impacto, coach IA y cuadra.
/// FAB de Escanear flotando siempre.
///
/// **Cada card es tappable** — abre un InfoSheet explicando qué significa.
struct HomeView: View {
    /// Inicia en `.empty` — usuario nuevo recién acabó setup, todo en cero.
    /// Cambiar a `.mock` para demo con datos cargados.
    @State private var state: RecolectorState = .empty
    @State private var showScanner = false
    @State private var showCenterMap = false
    @State private var showSettings = false
    @State private var showWrapped = false
    @State private var showSchedule = false

    /// InfoSheet activo (uno a la vez). Nil = sin sheet.
    @State private var activeInfo: InfoKind?

    @AppStorage("recolector.serviceMode") private var serviceModeRaw = "drop_off"

    private var resolvedState: RecolectorState {
        var s = state
        s.serviceMode = serviceModeRaw == "pickup" ? .pickup : .dropOff
        return s
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(spacing: Spacing.l) {
                    HomeHeader(
                        name: state.name,
                        alcaldia: state.alcaldia,
                        streakDays: state.streakDays,
                        onTapProfile: { showSettings = true }
                    )

                    wrappedTeaser

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

                    Button {
                        Haptics.tap()
                        activeInfo = .impacto
                    } label: {
                        ImpactRow(
                            totalKg: resolvedState.totalKgDiverted,
                            co2Kg: resolvedState.co2SavedKg,
                            streakDays: resolvedState.streakDays
                        )
                    }
                    .buttonStyle(.plain)

                    CoachTipCard(tip: resolvedState.coachTip) {
                        Haptics.tap()
                        activeInfo = .coach
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
        .sheet(isPresented: $showSchedule) {
            ScheduleDeliverySheet(
                mode: resolvedState.serviceMode,
                nearestCenter: resolvedState.nearestCenter
            )
            .presentationDetents([.large])
        }
        .sheet(item: $activeInfo) { kind in
            kind.sheet
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .onAppear {
            WidgetState.sync(
                bucketProgress: resolvedState.currentBucketProgress,
                bucketsCompleted: resolvedState.bucketsCompleted,
                totalKgDiverted: resolvedState.totalKgDiverted
            )
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
        switch state.stage {
        case .bucketReady:
            showSchedule = true
        case .abonoReady:
            // TODO día del hack: pantalla "recibir abono". Por ahora reusa schedule.
            showSchedule = true
        default:
            break
        }
    }
}

/// Tipos de InfoSheet que se pueden mostrar en el Home.
enum InfoKind: Identifiable {
    case cubeta
    case tracker
    case impacto
    case coach
    case cuadra

    var id: String {
        switch self {
        case .cubeta: return "cubeta"
        case .tracker: return "tracker"
        case .impacto: return "impacto"
        case .coach: return "coach"
        case .cuadra: return "cuadra"
        }
    }

    @MainActor
    @ViewBuilder
    var sheet: some View {
        switch self {
        case .cubeta:  HomeInfoCatalog.cubeta
        case .tracker: HomeInfoCatalog.tracker
        case .impacto: HomeInfoCatalog.impacto
        case .coach:   HomeInfoCatalog.coach
        case .cuadra:  HomeInfoCatalog.cuadra
        }
    }
}

#Preview {
    HomeView()
}
