import SwiftUI
import AppKit

/// Frosted glass with a Catppuccin-tinted overlay.
struct VisualEffectView: View {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode

    var body: some View {
        ZStack {
            _VisualEffectView(material: material, blendingMode: blendingMode)
            Rectangle().fill(Color.stickyGlassTint)
        }
    }
}

private struct _VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
