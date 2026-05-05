import SwiftUI
import SwiftData

@main
struct HackNacional2026App: App {
    init() {
        #if DEBUG
        // En builds DEBUG, cada cold launch arranca desde cero.
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
