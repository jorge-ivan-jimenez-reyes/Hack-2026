import SwiftUI

// MARK: - Semantic Colors
//
// Cada nombre apunta a un Color set en Assets.xcassets/Colors/<name>.colorset
// con variantes Light/Dark. NUNCA usar hex inline en views — siempre por aquí.

extension Color {
    // Surfaces
    static let surface         = Color("surface")
    static let surfaceElevated = Color("surfaceElevated")
    static let surfaceMuted    = Color("surfaceMuted")

    // Text
    static let textPrimary   = Color("textPrimary")
    static let textSecondary = Color("textSecondary")
    static let textTertiary  = Color("textTertiary")

    // Brand
    static let brand     = Color("brand")
    static let brandSoft = Color("brandSoft")

    // Waste categories
    static let wasteOrganic    = Color("wasteOrganic")
    static let wastePET        = Color("wastePET")
    static let wasteGlass      = Color("wasteGlass")
    static let wastePaper      = Color("wastePaper")
    static let wasteMetal      = Color("wasteMetal")
    static let wasteElectronic = Color("wasteElectronic")

    // State
    static let success = Color("success")
    static let warning = Color("warning")
    static let danger  = Color("danger")
    static let info    = Color("info")
}

// MARK: - Spacing tokens (escala 4-pt)

enum Spacing {
    static let xs: CGFloat  = 4
    static let s: CGFloat   = 8
    static let m: CGFloat   = 12
    static let l: CGFloat   = 16
    static let xl: CGFloat  = 24
    static let xxl: CGFloat = 32
}

// MARK: - Corner radii

enum Radius {
    static let s: CGFloat    = 8
    static let m: CGFloat    = 12
    static let l: CGFloat    = 16
    static let xl: CGFloat   = 24
    static let pill: CGFloat = 999
}
