import AppKit

/// Coordinates panel state transitions. Window is always at expanded frame size;
/// only the SwiftUI content and hitTest behavior change — no window resize needed.
enum PanelAnimator {

    static func expand(_ window: PanelWindow) {
        window.setExpanded()
    }

    static func collapse(_ window: PanelWindow) {
        window.setCollapsed()
    }

    static func toggle(_ window: PanelWindow) {
        switch window.panelState {
        case .collapsed:
            expand(window)
        case .expanded:
            collapse(window)
        case .locked:
            collapse(window)
        }
    }

    /// Move the panel to the opposite screen edge.
    static func toggleEdge(_ window: PanelWindow) {
        window.preferredEdge = window.preferredEdge == .right ? .left : .right
    }
}
