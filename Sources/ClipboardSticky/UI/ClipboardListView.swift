import SwiftUI
import SwiftData

/// Scrollable list of clipboard items with lazy loading.
struct ClipboardListView: View {
    @Environment(\.modelContext) private var modelContext
    let searchText: String
    @Binding var selectedItemID: UUID?

    @Query private var items: [ClipboardItem]

    init(searchText: String, selectedItemID: Binding<UUID?>) {
        self.searchText = searchText
        self._selectedItemID = selectedItemID

        let term = searchText.lowercased()
        if term.isEmpty {
            _items = Query(
                sort: \ClipboardItem.timestamp, order: .reverse,
                animation: .default
            )
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
                LazyVStack(spacing: 2) {
                    ForEach(items) { item in
                        ClipboardItemRow(
                            item: item,
                            isSelected: selectedItemID == item.id
                        )
                        .onTapGesture {
                            selectedItemID = item.id
                            PasteboardWriter.copyToClipboard(item)

                            // Brief visual feedback then deselect
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                if selectedItemID == item.id {
                                    selectedItemID = nil
                                }
                            }
                        }
                        .contextMenu {
                            Button("复制") {
                                PasteboardWriter.copyToClipboard(item)
                            }
                            Button("复制并粘贴") {
                                PasteboardWriter.copyAndPaste(item)
                            }
                            Divider()
                            if item.isPinned {
                                Button("取消固定") {
                                    item.isPinned = false
                                    try? modelContext.save()
                                }
                            } else {
                                Button("固定") {
                                    item.isPinned = true
                                    try? modelContext.save()
                                }
                            }
                            Divider()
                            Button("删除", role: .destructive) {
                                deleteItem(item)
                            }
                        }
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
            }
        }
    }

    private func deleteItem(_ item: ClipboardItem) {
        modelContext.delete(item)
        try? modelContext.save()
    }
}
