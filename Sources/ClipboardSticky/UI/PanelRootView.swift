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
                expandedPanel
                    .transition(.move(edge: isRight ? .trailing : .leading)
                        .combined(with: .opacity))
            }
            if !isExpanded {
                HStack(spacing: 0) {
                    if isRight { Spacer(minLength: 0) }
                    TabHandleView(edge: stateModel.edge)
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

            PanelContentView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
