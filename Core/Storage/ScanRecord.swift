import Foundation
import SwiftData

@Model
final class ScanRecord {
    @Attribute(.unique) var id: UUID
    var categoryRaw: String
    var confidence: Double
    var summary: String
    var detail: String
    var tip: String?
    var imageData: Data?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        category: WasteCategory,
        confidence: Double,
        summary: String,
        detail: String,
        tip: String? = nil,
        imageData: Data? = nil,
        createdAt: Date = .now
    ) {
        self.id = id
        self.categoryRaw = category.rawValue
        self.confidence = confidence
        self.summary = summary
        self.detail = detail
        self.tip = tip
        self.imageData = imageData
        self.createdAt = createdAt
    }

    var category: WasteCategory {
        WasteCategory(rawValue: categoryRaw) ?? .unknown
    }
}
