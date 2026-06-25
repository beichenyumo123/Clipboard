import SwiftUI

/// Root view. Observes `PanelStateModel` (pure Swift ObservableObject — reliable @Published)
/// for reactive state, and uses `PanelWindow` for actions.
struct PanelRootView: View {
    @EnvironmentObject var stateModel: PanelStateModel
    @EnvironmentObject var panelWindow: PanelWindow

    private var isExpanded: Bool {
        stateModel.state == .expanded || stateModel.state == .locked
    }

    var body: some View {
        ZStack(alignment: stateModel.edge == .right ? .trailing : .leading) {
            if isExpanded {
                panelContent
                    .transition(.opacity)
            }
            if !isExpanded {
                tabHandle
                    .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .background(backgroundView)
        .animation(.spring(response: 0.28, dampingFraction: 0.8), value: isExpanded)
    }

    // MARK: - Tab Handle

    private var tabHandle: some View {
        VStack(spacing: 3) {
            Image(systemName: "list.clipboard")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)

            Text("剪贴")
                .font(.system(size: 8))
                .foregroundColor(.tertiaryLabel)
        }
        .frame(width: PanelWindow.Metrics.tabWidth, height: PanelWindow.Metrics.tabHeight)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.12), radius: 3, y: 1)
        )
        .padding(.vertical, 8)
    }

    // MARK: - Panel Content

    private var panelContent: some View {
        PanelContentView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Background

    @ViewBuilder
    private var backgroundView: some View {
        if isExpanded {
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
                .ignoresSafeArea()
        } else {
            Color.clear.ignoresSafeArea()
        }
    }
}
