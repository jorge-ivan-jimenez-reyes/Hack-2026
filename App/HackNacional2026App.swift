import SwiftUI
import SwiftData

@main
struct HackNacional2026App: App {
    init() {
        #if DEBUG
        // En builds DEBUG, cada cold launch arranca desde cero.
        // Reset del flow completo: educational onboarding + rol + setup.
        UserDefaults.standard.set(false, forKey: "didOnboard")
        UserDefaults.standard.set("", forKey: "userRole")
        UserDefaults.standard.set(false, forKey: "didCompleteRoleSetup")
        #endif
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: ScanRecord.self)
    }
}
