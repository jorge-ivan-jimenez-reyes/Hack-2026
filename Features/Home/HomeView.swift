import SwiftUI

/// Pantalla principal del Recolector. Compone el Home state-aware:
/// hero que cambia con la etapa, tracker 15:1, impacto, coach IA y cuadra.
/// FAB de Escanear flotando siempre.
struct HomeView: View {
    @State private var state: RecolectorState = .mock
    @State private var showScanner = false
    @State private var showCenterMap = false
    @State private var showSettings = false

    /// Modalidad seleccionada en RecolectorSetup (Q5). Controla qué muestra
    /// el Hero card: pickup en casa vs centro más cercano.
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

                    HeroCubetaCard(
                        state: resolvedState,
                        onPrimaryAction: { handleHeroAction() },
                        onTapModalityChip: { showCenterMap = true }
                    )

                    CubetaTracker(completed: resolvedState.bucketsCompleted)

                    ImpactRow(
                        totalKg: resolvedState.totalKgDiverted,
                        co2Kg: resolvedState.co2SavedKg,
                        streakDays: resolvedState.streakDays
                    )

                    CoachTipCard(tip: resolvedState.coachTip) {
                        // TODO: abrir Coach
                    }

                    CuadraCard(
                        weeklyKg: resolvedState.cuadraKgWeek,
                        percentile: resolvedState.cuadraRankPercentile,
                        premioGoalKg: resolvedState.cuadraPremioGoalKg
                    ) {
                        // TODO: abrir leaderboard
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
    }

    private func handleHeroAction() {
        switch state.stage {
        case .bucketReady:
            // TODO: navegar a programar entrega
            break
        case .abonoReady:
            // TODO: navegar a recibir abono
            break
        default:
            break
        }
    }
}

#Preview {
    HomeView()
}
