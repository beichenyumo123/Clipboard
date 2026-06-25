import SwiftUI

struct TabHandleView: View {
    let edge: ScreenEdge

    var body: some View {
        RoundedRectangle(cornerRadius: edge == .right ? 4 : 4)
            .fill(.ultraThinMaterial)
            .frame(width: 14, height: 64)
            .shadow(color: .black.opacity(0.08), radius: 2, x: 0, y: 0)
    }
}
