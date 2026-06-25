import AppKit
import SwiftUI
import SwiftData
import Combine

final class PanelWindowController: NSWindowController {
    private let modelContainer: ModelContainer
    private var hostingView: NSHostingView<AnyView>!
    private var panelWindow: PanelWindow { window as! PanelWindow }
    private var cancellables = Set<AnyCancellable>()

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        let window = PanelWindow()
        super.init(window: window)
        setupHostingView()
        observeEdgeChanges()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupHostingView() {
        let rootView = PanelRootView()
            .environmentObject(panelWindow.stateModel)
            .environmentObject(panelWindow)
            .modelContainer(modelContainer)
            .frame(width: PanelWindow.Metrics.panelWidth)

        hostingView = NSHostingView(rootView: AnyView(rootView))
        hostingView.wantsLayer = true
        hostingView.layer?.cornerRadius = PanelWindow.Metrics.cornerRadius
        hostingView.layer?.masksToBounds = true

        panelWindow.contentView = hostingView
        updateCornerMask()
    }

    private func observeEdgeChanges() {
        panelWindow.stateModel.$edge
            .dropFirst()
            .sink { [weak self] _ in
                self?.updateCornerMask()
            }
            .store(in: &cancellables)
    }

    private func updateCornerMask() {
        let edge = panelWindow.preferredEdge
        // Only round the INNER corners — screen-edge corners stay square
        hostingView.layer?.maskedCorners = edge == .right
            ? [.layerMinXMinYCorner, .layerMinXMaxYCorner]  // left (inner) corners
            : [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]  // right (inner) corners
    }

    func reposition() {
        panelWindow.updateFrame()
    }

    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        panelWindow.makeKeyAndOrderFront(nil)
    }
}
