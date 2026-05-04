import SwiftUI

/// Tipografía semántica. Siempre usar estos en lugar de Font.system con tamaños literales,
/// para que Dynamic Type funcione correctamente en TODA la app.
extension Font {
    static let appLargeTitle = Font.system(.largeTitle, design: .rounded).weight(.bold)
    static let appTitle      = Font.system(.title, design: .rounded).weight(.semibold)
    static let appTitle2     = Font.system(.title2, design: .rounded).weight(.semibold)
    static let appHeadline   = Font.system(.headline)
    static let appBody       = Font.system(.body)
    static let appCallout    = Font.system(.callout)
    static let appCaption    = Font.system(.caption)
}
