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
        ZStack(alignment: .topLeading) {
            mainContent

            #if DEBUG
            DebugResetOnboardingButton(
                didOnboard: $didOnboard,
                userRoleRaw: $userRoleRaw,
                didCompleteRoleSetup: $didCompleteRoleSetup
            )
            .padding(Spacing.m)
            #endif
        }
    }

    @ViewBuilder
    private var mainContent: some View {
        if !didOnboard {
            OnboardingView { didOnboard = true }
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
            Tab("Escanear", systemImage: "camera.viewfinder") {
                ScannerView()
            }
            Tab("Guía", systemImage: "book.closed.fill") {
                RecyclingGuideView()
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

/// Tab bar del Centro de acopio — Dashboard, Recolectores, Reportes.
struct CentroTabView: View {
    var body: some View {
        TabView {
            Tab("Dashboard", systemImage: "square.grid.2x2.fill") {
                CentroHomeView()
            }
            Tab("Recolectores", systemImage: "person.3.fill") {
                RecolectoresListView()
            }
            Tab("Reportes", systemImage: "exclamationmark.bubble.fill") {
                ReportesListView()
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
        .tint(.brand)
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

#if DEBUG
/// Solo en DEBUG. Resetea TODOS los flags del onboarding flow.
private struct DebugResetOnboardingButton: View {
    @Binding var didOnboard: Bool
    @Binding var userRoleRaw: String
    @Binding var didCompleteRoleSetup: Bool
    @State private var showConfirm = false

    var body: some View {
        Button {
            showConfirm = true
        } label: {
            Image(systemName: "arrow.counterclockwise.circle.fill")
                .font(.title3)
                .foregroundStyle(.red)
                .padding(8)
                .background(.ultraThinMaterial, in: .circle)
        }
        .accessibilityLabel("Restablecer todo (debug)")
        .confirmationDialog(
            "¿Restablecer flow completo?",
            isPresented: $showConfirm,
            titleVisibility: .visible
        ) {
            Button("Restablecer", role: .destructive) {
                didOnboard = false
                userRoleRaw = ""
                didCompleteRoleSetup = false
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Reinicia onboarding + selección de rol + setup.")
        }
    }
}
#endif

#Preview {
    RootView()
}
