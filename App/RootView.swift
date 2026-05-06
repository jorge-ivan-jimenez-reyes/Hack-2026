import SwiftUI

/// Coordinador del flow de arranque:
/// 1. !didOnboard           → Educational onboarding (4 páginas + cubeta 3D)
/// 2. !userRole             → Profile selection (Recolector / Centro)
/// 3. !didCompleteRoleSetup → Setup específico del rol (preguntas calibrar)
/// 4. todo completo         → MainTabView del rol
struct RootView: View {
    @AppStorage("didOnboard") private var didOnboard = false
    @AppStorage("userRole") private var userRoleRaw = ""
    @AppStorage("didCompleteRoleSetup") private var didCompleteRoleSetup = false

    private var role: UserRole? { UserRole(rawValue: userRoleRaw) }

    var body: some View {
        Group {
            if didCompleteRoleSetup {
                // Solo durante el uso real de la app (post-onboarding) montamos el host
                // de reminders. Durante onboarding/setup NO molestamos.
                mainContent.reminderHost()
            } else {
                mainContent
            }
        }
    }

    /// Feature flag: si `useJourneyOnboarding` true, usamos el journey 3D
    /// con camioncito; si false, el OnboardingView educativo de páginas.
    /// Cambiar aquí para alternar entre ambos durante demos.
    private let useJourneyOnboarding = true

    @ViewBuilder
    private var mainContent: some View {
        if !didOnboard {
            if useJourneyOnboarding {
                JourneyView { didOnboard = true }
            } else {
                OnboardingView { didOnboard = true }
            }
        } else if role == nil {
            ProfileSelectionView { selected in
                userRoleRaw = selected.rawValue
            }
        } else if !didCompleteRoleSetup {
            roleSetupView
        } else {
            roleMainTabView
        }
    }

    @ViewBuilder
    private var roleSetupView: some View {
        switch role {
        case .recolector:
            RecolectorSetupView { didCompleteRoleSetup = true }
        case .centro:
            CentroSetupView { didCompleteRoleSetup = true }
        case .none:
            EmptyView()
        }
    }

    @ViewBuilder
    private var roleMainTabView: some View {
        switch role {
        case .recolector: RecolectorTabView()
        case .centro:     CentroTabView()
        case .none:       EmptyView()
        }
    }
}

/// Tab bar del Recolector — Home, Escanear, Guía, Historial, Coach.
struct RecolectorTabView: View {
    var body: some View {
        TabView {
            Tab("Inicio", systemImage: "house.fill") {
                HomeView()
            }
            Tab("Guía", systemImage: "book.closed.fill") {
                RecyclingGuideView()
            }
            Tab("Escanear", systemImage: "camera.viewfinder") {
                ScannerView()
            }
            Tab("Historial", systemImage: "clock") {
                HistoryView()
            }
            Tab("Coach", systemImage: "sparkles") {
                CoachView()
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
        .tint(.brand)
    }
}

/// Tab bar del Centro de acopio — Dashboard, Insights, Recolectores, Lotes, Reportes.
/// **Insights** es el diferenciador del rol Centro: inteligencia operacional
/// (tendencias, heatmap, predicciones, alertas auto-generadas) que la libreta
/// de papel jamás daría.
struct CentroTabView: View {
    var body: some View {
        TabView {
            Tab("Dashboard", systemImage: "square.grid.2x2.fill") {
                CentroHomeView()
            }
            Tab("Insights", systemImage: "chart.line.uptrend.xyaxis") {
                CentroInsightsView()
            }
            Tab("Recolectores", systemImage: "person.3.fill") {
                RecolectoresListView()
            }
            Tab("Lotes", systemImage: "leaf.arrow.circlepath") {
                BatchListView()
            }
            Tab("Reportes", systemImage: "exclamationmark.bubble.fill") {
                ReportesListView()
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
        .tint(.forestDeep)
    }
}

/// Stub para tabs que aún no implementamos.
private struct PlaceholderView: View {
    let title: String
    let subtitle: String

    var body: some View {
        ZStack {
            Color.cream.ignoresSafeArea()
            VStack(spacing: Spacing.m) {
                Image(systemName: "hammer.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.brand.opacity(0.45))
                Text(title)
                    .font(.appTitle.weight(.semibold))
                    .foregroundStyle(.inkCharcoal)
                Text(subtitle)
                    .font(.appBody)
                    .foregroundStyle(.inkCharcoal.opacity(0.65))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.xl)
            }
        }
    }
}

#Preview {
    RootView()
}
