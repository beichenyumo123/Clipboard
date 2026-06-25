import AppKit
import SwiftUI

// MARK: - State Model (pure Swift → reliable @Published)

final class PanelStateModel: ObservableObject {
    @Published var state: PanelState = .collapsed
    @Published var edge: ScreenEdge = .right
}

enum PanelState: Equatable {
    case collapsed
    case expanded
    case locked
}

// MARK: - Panel Window

final class PanelWindow: NSPanel, ObservableObject {

    enum Metrics {
        static let tabWidth: CGFloat = 14
        static let tabHeight: CGFloat = 80
        static let panelWidth: CGFloat = 360
        static let cornerRadius: CGFloat = 14
        static let edgeInset: CGFloat = 0
    }

    let stateModel = PanelStateModel()

    var panelState: PanelState {
        get { stateModel.state }
        set {
            stateModel.state = newValue
            // Click-through: when collapsed, pass clicks through to windows below.
            // The timer-based hover still works since NSEvent.mouseLocation is global.
            ignoresMouseEvents = (newValue == .collapsed)
        }
    }

    var preferredEdge: ScreenEdge {
        get { stateModel.edge }
        set {
            stateModel.edge = newValue
            updateFrame()
        }
    }

    var onStateChange: ((PanelState) -> Void)?

    private weak var targetScreen: NSScreen? = NSScreen.main
    private var mouseCheckTimer: Timer?
    private var hoverEnterTime: Date?
    private var wasMouseInside: Bool = false

    // MARK: - Init

    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: backing, defer: flag)
    }

    convenience init() {
        self.init(
            contentRect: .zero,
            styleMask: [.borderless, .nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        configureWindow()
        updateFrame()
        startMouseTracking()
    }

    private func configureWindow() {
        isOpaque = false
        backgroundColor = .clear
        hasShadow = true
        level = .floating
        isMovableByWindowBackground = false
        isMovable = false
        becomesKeyOnlyIfNeeded = true
        animationBehavior = .none
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        ignoresMouseEvents = true  // start collapsed → click-through
    }

    deinit {
        mouseCheckTimer?.invalidate()
    }

    // MARK: - Frame

    func updateFrame() {
        guard let screen = targetScreen ?? NSScreen.main else { return }
        targetScreen = screen

        // Use screen.frame (full bounds) for horizontal positioning to ensure flush edge.
        // visibleFrame excludes areas like the menu bar notch which is vertical only,
        // but some configs (Stage Manager, side Dock) may inset horizontal edges too.
        let fullFrame = screen.frame
        let visibleFrame = screen.visibleFrame
        let h = visibleFrame.height * 0.52
        let y = visibleFrame.midY - h / 2
        let size = NSSize(width: Metrics.panelWidth, height: h)
        let x = preferredEdge == .right
            ? fullFrame.maxX - Metrics.panelWidth - Metrics.edgeInset
            : fullFrame.minX + Metrics.edgeInset

        let winFrame = NSRect(origin: NSPoint(x: x, y: y), size: size)
        setFrame(winFrame, display: true, animate: false)
    }

    var tabScreenRect: NSRect {
        let tw = Metrics.tabWidth
        let th = Metrics.tabHeight
        let tx = preferredEdge == .right
            ? frame.maxX - tw
            : frame.minX
        let ty = frame.midY - th / 2
        return NSRect(x: tx, y: ty, width: tw, height: th)
    }

    // MARK: - Mouse Tracking

    private func startMouseTracking() {
        mouseCheckTimer = Timer.scheduledTimer(withTimeInterval: 0.20, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    private func tick() {
        let mouse = NSEvent.mouseLocation

        switch panelState {
        case .collapsed:
            let near = tabScreenRect.insetBy(dx: -14, dy: -10)
            let inside = near.contains(mouse)

            if inside && !wasMouseInside {
                wasMouseInside = true
                hoverEnterTime = Date()
            } else if inside && wasMouseInside {
                if let t = hoverEnterTime, Date().timeIntervalSince(t) > 0.2 {
                    setExpanded()
                }
            } else if !inside {
                wasMouseInside = false
                hoverEnterTime = nil
            }

        case .expanded:
            let area = frame.insetBy(dx: -8, dy: -4)
            let outside = !area.contains(mouse)

            if outside && wasMouseInside {
                wasMouseInside = false
                hoverEnterTime = Date()
            } else if outside && !wasMouseInside {
                if let t = hoverEnterTime, Date().timeIntervalSince(t) > 0.35 {
                    setCollapsed()
                }
            } else if !outside {
                wasMouseInside = true
                hoverEnterTime = nil
            }

        case .locked:
            break
        }
    }

    // MARK: - State

    func setExpanded() {
        guard panelState == .collapsed else { return }
        panelState = .expanded
        wasMouseInside = true
        hoverEnterTime = nil
        onStateChange?(.expanded)
    }

    func setCollapsed() {
        guard panelState == .expanded else { return }
        panelState = .collapsed
        wasMouseInside = false
        hoverEnterTime = nil
        onStateChange?(.collapsed)
    }

    func toggleLock() {
        switch panelState {
        case .locked: panelState = .expanded
        case .expanded, .collapsed: panelState = .locked
        }
        wasMouseInside = true
        hoverEnterTime = nil
        onStateChange?(panelState)
    }

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}

enum ScreenEdge: String, CaseIterable {
    case left, right
    var displayName: String { self == .left ? "左侧" : "右侧" }
}
