import SwiftUI

/// The small pill-shaped tab that sits at the screen edge when the panel is collapsed.
struct TabHandleView: View {
    let edge: ScreenEdge

    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: "clipboard")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)

            Text("剪贴")
                .font(.system(size: 8))
                .foregroundColor(.tertiaryLabel)
        }
        .frame(width: 24, height: 72)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.primary.opacity(0.1), lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
        .scaleEffect(x: edge == .left ? -1 : 1, y: 1)
    }
}
