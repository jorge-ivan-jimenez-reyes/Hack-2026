import UIKit

struct MockWasteClassifier: WasteClassifier {
    var deterministic: WasteCategory? = nil

    func classify(image: UIImage) async throws -> Classification {
        try await Task.sleep(for: .milliseconds(450))
        let pool = WasteCategory.allCases.filter { $0 != .unknown }
        let category = deterministic ?? pool.randomElement()!
        let alternatives = pool
            .filter { $0 != category }
            .shuffled()
            .prefix(2)
            .map { Classification.Alternative(category: $0, confidence: Double.random(in: 0.05...0.25)) }

        return Classification(
            category: category,
            confidence: Double.random(in: 0.74...0.96),
            alternatives: Array(alternatives)
        )
    }
}
