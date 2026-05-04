import SwiftUI
import SwiftData

@main
struct HackNacional2026App: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: ScanRecord.self)
    }
}
