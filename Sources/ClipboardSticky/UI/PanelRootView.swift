import SwiftUI

struct PanelRootView: View {
    @EnvironmentObject var stateModel: PanelStateModel
    @EnvironmentObject var panelWindow: PanelWindow

    private var isExpanded: Bool {
        stateModel.state == .expanded || stateModel.state == .locked
    }
    private var isRight: Bool { stateModel.edge == .right }

    var body: some View {
        ZStack {
            if isExpanded {
                // Background + content as one unit — animate together
                expandedPanel
                    .transition(.move(edge: isRight ? .trailing : .leading)
                        .combined(with: .opacity))
            }
            if !isExpanded {
                HStack(spacing: 0) {
                    if isRight { Spacer(minLength: 0) }
                    collapsedTab
                    if !isRight { Spacer(minLength: 0) }
                }
                .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.spring(response: 0.28, dampingFraction: 0.78), value: isExpanded)
    }

    private var expandedPanel: some View {
        ZStack {
            VisualEffectView(material: .menu, blendingMode: .behindWindow)
                .ignoresSafeArea()
                .overlay(
                    RoundedRectangle(cornerRadius: PanelWindow.Metrics.cornerRadius)
                        .stroke(Color.primary.opacity(0.08), lineWidth: 0.5)
                        .ignoresSafeArea()
                )

            PanelContentView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var collapsedTab: some View {
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
}
