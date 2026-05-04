import Foundation

struct Classification: Equatable, Sendable, Identifiable {
    let id: UUID
    let category: WasteCategory
    let confidence: Double
    let alternatives: [Alternative]
    let timestamp: Date

    struct Alternative: Equatable, Sendable, Hashable {
        let category: WasteCategory
        let confidence: Double
    }

    init(
        id: UUID = UUID(),
        category: WasteCategory,
        confidence: Double,
        alternatives: [Alternative] = [],
        timestamp: Date = .now
    ) {
        self.id = id
        self.category = category
        self.confidence = confidence
        self.alternatives = alternatives
        self.timestamp = timestamp
    }

    var isConfident: Bool { confidence >= 0.7 }
    var confidencePercentage: Int { Int(confidence * 100) }
}
