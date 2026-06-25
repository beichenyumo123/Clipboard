import SwiftUI
import SwiftData

struct ClipboardListView: View {
    @EnvironmentObject var panelWindow: PanelWindow
    @Environment(\.modelContext) private var modelContext
    let searchText: String
    @Binding var selectedItemID: UUID?

    @Query private var items: [ClipboardItem]

    init(searchText: String, selectedItemID: Binding<UUID?>) {
        self.searchText = searchText
        self._selectedItemID = selectedItemID

        let term = searchText.lowercased()
        if term.isEmpty {
            _items = Query(sort: \ClipboardItem.timestamp, order: .reverse, animation: .default)
        } else {
            _items = Query(
                filter: #Predicate { $0.searchText?.contains(term) ?? false },
                sort: \ClipboardItem.timestamp, order: .reverse,
                animation: .default
            )
        }
    }

    var body: some View {
        if items.isEmpty {
            EmptyStateView()
        } else {
            ScrollView {
                LazyVStack(spacing: 6) {
                    ForEach(items) { item in
                        ClipboardItemRow(item: item, isSelected: selectedItemID == item.id)
                            .onTapGesture {
                                bumpAndCopy(item)
                            }
                            .contextMenu {
                                Button("复制") { bumpAndCopy(item) }
                                Button("复制并粘贴") { PasteboardWriter.copyAndPaste(item); bumpTimestamp(item) }
                                Divider()
                                Button(item.isPinned ? "取消固定" : "固定") {
                                    item.isPinned.toggle()
                                    try? modelContext.save()
                                }
                                Divider()
                                Button("删除", role: .destructive) { deleteItem(item) }
                            }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
            }
        }
    }

    private func bumpAndCopy(_ item: ClipboardItem) {
        selectedItemID = item.id
        item.timestamp = Date()
        try? modelContext.save()
        PasteboardWriter.copyToClipboard(item)
        // Collapse the panel after copying
        PanelAnimator.collapse(panelWindow)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            if selectedItemID == item.id { selectedItemID = nil }
        }
    }

    private func bumpTimestamp(_ item: ClipboardItem) {
        item.timestamp = Date()
        try? modelContext.save()
    }

    private func deleteItem(_ item: ClipboardItem) {
        modelContext.delete(item)
        try? modelContext.save()
    }
}
