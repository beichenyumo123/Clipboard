import SwiftUI

extension View {
    /// Conditionally apply a modifier.
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    /// Apply a rounded border with the given color and width.
    func roundedBorder(
        color: Color = .primary.opacity(0.1),
        radius: CGFloat = 8,
        lineWidth: CGFloat = 0.5
    ) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: radius)
                .stroke(color, lineWidth: lineWidth)
        )
    }
}

extension Int {
    /// Returns self if non-zero, otherwise nil. Useful for UserDefaults values.
    var nonZero: Int? {
        self == 0 ? nil : self
    }
}
