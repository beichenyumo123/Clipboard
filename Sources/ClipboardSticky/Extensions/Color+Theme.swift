import SwiftUI

// MARK: - Catppuccin Latte Palette

extension Color {
    // Accent
    static let cpMauve     = Color(hex: "#8839ef")
    static let cpPink      = Color(hex: "#ea76cb")
    static let cpSapphire  = Color(hex: "#209fb5")
    static let cpBlue      = Color(hex: "#1e66f5")
    static let cpLavender  = Color(hex: "#7287fd")
    static let cpTeal      = Color(hex: "#179299")
    static let cpGreen     = Color(hex: "#40a02b")
    static let cpPeach     = Color(hex: "#fe640b")
    static let cpRed       = Color(hex: "#d20f39")

    // Surfaces
    static let cpBase      = Color(hex: "#eff1f5")
    static let cpMantle    = Color(hex: "#e6e9ef")
    static let cpCrust     = Color(hex: "#dce0e8")
    static let cpSurface0  = Color(hex: "#ccd0da")
    static let cpSurface1  = Color(hex: "#bcc0cc")
    static let cpSurface2  = Color(hex: "#acb0be")

    // Text
    static let cpText      = Color(hex: "#4c4f69")
    static let cpSubtext0  = Color(hex: "#6c6f85")
    static let cpSubtext1  = Color(hex: "#5c5f77")
    static let cpOverlay0  = Color(hex: "#9ca0b0")
    static let cpOverlay1  = Color(hex: "#8c8fa1")
}

// Hex initializer
private extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255.0
        let g = Double((int >> 8)  & 0xFF) / 255.0
        let b = Double((int >> 0)  & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Semantic Tokens

extension Color {
    /// Primary accent — Mauve
    static let stickyAccent     = Color.cpMauve

    /// Card & panel backgrounds
    static let stickyBg         = Color.cpBase
    static let stickyCard       = Color.cpSurface0.opacity(0.45)
    static let stickyCardHover  = Color.cpSurface1.opacity(0.55)
    static let stickyCardActive = Color.cpMauve.opacity(0.12)
    static let stickyCardBorder = Color.cpOverlay0.opacity(0.25)
    static let stickyCardBorderHover = Color.cpOverlay0.opacity(0.45)
    static let stickyCardBorderActive = Color.cpMauve.opacity(0.35)

    /// Frosted glass tint overlay
    static let stickyGlassTint  = Color.cpBase.opacity(0.55)

    /// Text
    static let stickyTextPrimary   = Color.cpText
    static let stickyTextSecondary = Color.cpSubtext0
    static let stickyTextTertiary  = Color.cpOverlay0

    /// Search field
    static let stickySearchBg      = Color.cpSurface0.opacity(0.50)
    static let stickySearchBorder   = Color.cpOverlay0.opacity(0.18)
}
