import SwiftUI

struct RootView: View {
    @AppStorage("didOnboard") private var didOnboard = false

    var body: some View {
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

#Preview {
    RootView()
}
