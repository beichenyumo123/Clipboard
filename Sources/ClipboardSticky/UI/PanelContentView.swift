import SwiftUI
import SwiftData

/// The main expanded panel content: search bar + clipboard list + toolbar.
struct PanelContentView: View {
    @EnvironmentObject var stateModel: PanelStateModel
    @EnvironmentObject var panelWindow: PanelWindow
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openSettings) private var openSettings
    @State private var searchText: String = ""
    @State private var selectedItemID: UUID?

    var body: some View {
        VStack(spacing: 0) {
            headerView

            Divider()
                .opacity(0.3)

            SearchField(text: $searchText)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)

            Divider()
                .opacity(0.3)

            ClipboardListView(
                searchText: searchText,
                selectedItemID: $selectedItemID
            )
            .id(searchText)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Divider()
                .opacity(0.3)

            bottomToolbar
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            Text("剪贴板")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.secondary)

            Spacer()

            Button(action: { panelWindow.toggleLock() }) {
                Image(systemName: stateModel.state == .locked ? "pin.fill" : "pin")
                    .font(.system(size: 11))
                    .foregroundColor(stateModel.state == .locked ? .accentColor : .secondary)
            }
            .buttonStyle(.plain)
            .help("固定面板")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }

    // MARK: - Bottom Toolbar

    private var bottomToolbar: some View {
        HStack(spacing: 14) {
            Button(action: { openSettings() }) {
                Image(systemName: "gear")
                    .font(.system(size: 12))
            }
            .buttonStyle(.plain)
            .help("设置")

            Spacer()

            Button(action: { clearAllItems() }) {
                Text("清空")
                    .font(.system(size: 10))
            }
            .buttonStyle(.plain)
            .help("清空未固定的历史")

            Button(action: { PanelAnimator.toggleEdge(panelWindow) }) {
                Image(systemName: "arrow.left.arrow.right")
                    .font(.system(size: 12))
            }
            .buttonStyle(.plain)
            .help("切换左右")

            Button(action: { PanelAnimator.collapse(panelWindow) }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
            }
            .buttonStyle(.plain)
            .help("收起面板")

            Button(action: { quitApp() }) {
                Image(systemName: "xmark.square")
                    .font(.system(size: 12))
            }
            .buttonStyle(.plain)
            .help("退出程序")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    // MARK: - Actions

    private func clearAllItems() {
        let descriptor = FetchDescriptor<ClipboardItem>(
            predicate: #Predicate { !$0.isPinned }
        )
        guard let items = try? modelContext.fetch(descriptor) else { return }
        for item in items {
            modelContext.delete(item)
        }
        try? modelContext.save()
    }

    private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
