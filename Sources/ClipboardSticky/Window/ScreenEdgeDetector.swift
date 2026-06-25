import AppKit

/// Detects available screens and computes panel positions for left/right edge placement.
struct ScreenEdgeDetector {

    /// The primary screen (screen with menu bar)
    static var primaryScreen: NSScreen? {
        NSScreen.main
    }

    /// All available screens
    static var availableScreens: [NSScreen] {
        NSScreen.screens
    }

    /// Get the screen that contains the mouse cursor
    static func screenAtMouseLocation() -> NSScreen? {
        let mouseLocation = NSEvent.mouseLocation
        return NSScreen.screens.first { $0.frame.contains(mouseLocation) }
    }

    /// Compute the collapsed (tab-only) frame for a given screen and edge.
    static func collapsedFrame(
        for screen: NSScreen,
        edge: ScreenEdge
    ) -> NSRect {
        let screenFrame = screen.visibleFrame
        let width = PanelWindow.Metrics.tabWidth
        let height = PanelWindow.Metrics.tabHeight
        let inset = PanelWindow.Metrics.edgeInset

        let x: CGFloat = edge == .right
            ? screenFrame.maxX - width - inset
            : screenFrame.minX + inset

        let y = screenFrame.midY - height / 2

        return NSRect(x: x, y: y, width: width, height: height)
    }

    /// Compute the expanded (full panel) frame for a given screen and edge.
    /// - Parameters:
    ///   - screen: The target screen
    ///   - edge: Left or right edge
    ///   - heightRatio: Fraction of screen height (0.0–1.0), default 0.7
    ///   - width: Panel width in points
    static func expandedFrame(
        for screen: NSScreen,
        edge: ScreenEdge,
        heightRatio: CGFloat = 0.7,
        width: CGFloat = PanelWindow.Metrics.panelWidth
    ) -> NSRect {
        let screenFrame = screen.visibleFrame
        let inset = PanelWindow.Metrics.edgeInset
        let height = screenFrame.height * heightRatio

        let x: CGFloat = edge == .right
            ? screenFrame.maxX - width - inset
            : screenFrame.minX + inset

        let y = screenFrame.midY - height / 2

        return NSRect(x: x, y: y, width: width, height: height)
    }
}
