import SwiftUI

struct RootView: View {
    @AppStorage("didOnboard") private var didOnboard = false

    var body: some View {
        ZStack(alignment: .topLeading) {
            mainContent

            #if DEBUG
            DebugResetOnboardingButton(didOnboard: $didOnboard)
                .padding(Spacing.m)
            #endif
        }
    }

    @ViewBuilder
    private var mainContent: some View {
        if didOnboard {
            MainTabView()
        } else {
            OnboardingView { didOnboard = true }
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
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

#if DEBUG
/// Solo aparece en builds DEBUG. Resetea `didOnboard` para volver a ver el flujo.
private struct DebugResetOnboardingButton: View {
    @Binding var didOnboard: Bool
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
        .accessibilityLabel("Restablecer onboarding (debug)")
        .confirmationDialog(
            "¿Restablecer onboarding?",
            isPresented: $showConfirm,
            titleVisibility: .visible
        ) {
            Button("Restablecer", role: .destructive) {
                didOnboard = false
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Solo aparece en builds de DEBUG.")
        }
    }
}
#endif

#Preview {
    RootView()
}
