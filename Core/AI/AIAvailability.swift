import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif

enum AIAvailability {
    enum Status: Equatable {
        case ready
        case unavailable(reason: String)
    }

    static var foundationModels: Status {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            // TODO día del hack: validar el shape exacto de
            // SystemLanguageModel.default.availability con la versión actual de Xcode 26.
            // Aproximación:
            // switch SystemLanguageModel.default.availability {
            // case .available: return .ready
            // case .unavailable(.appleIntelligenceNotEnabled): return .unavailable(reason: "...")
            // ...
            // }
            return .ready
        }
        #endif
        return .unavailable(reason: "Requiere iOS 26 o superior con Apple Intelligence.")
    }
}
