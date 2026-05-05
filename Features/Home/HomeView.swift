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
        .sheet(item: $activeInfo) { kind in
            kind.sheet
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }

    private func handleHeroAction() {
        switch state.stage {
        case .bucketReady:
            break
        case .abonoReady:
            break
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
