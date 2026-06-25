import SwiftUI
import SwiftData

struct PanelContentView: View {
    @EnvironmentObject var stateModel: PanelStateModel
    @EnvironmentObject var panelWindow: PanelWindow
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openSettings) private var openSettings
    @State private var searchText: String = ""
    @State private var selectedItemID: UUID?

    var body: some View {
        VStack(spacing: 0) {
            // Search
            SearchField(text: $searchText)
                .padding(.horizontal, 14)
                .padding(.top, 12)
                .padding(.bottom, 10)

            // List
            ClipboardListView(searchText: searchText, selectedItemID: $selectedItemID)
                .id(searchText)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Toolbar
            bottomToolbar
                .padding(.top, 4)
        }
    }

    // MARK: - Toolbar

    private var bottomToolbar: some View {
        HStack(spacing: 0) {
            toolbarButton("pin", active: stateModel.state == .locked,
                          help: "固定面板") { panelWindow.toggleLock() }

            Spacer()

            toolbarButton("arrow.left.arrow.right", active: false,
                          help: "切换左右") { PanelAnimator.toggleEdge(panelWindow) }

            toolbarButton("gearshape", active: false,
                          help: "设置") { openSettings() }

            toolbarButton("xmark.square", active: false,
                          help: "退出") { NSApplication.shared.terminate(nil) }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    private func toolbarButton(_ icon: String, active: Bool, help: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: active ? "\(icon).fill" : icon)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(active ? .accentColor : .secondary)
                .frame(width: 28, height: 28)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(help)
    }
}
