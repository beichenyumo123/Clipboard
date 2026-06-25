import AppKit
import SwiftData

/// Polls NSPasteboard.general for changes and records new clipboard content.
/// Uses a "skip count" mechanism: call `skipNext()` before programmatic writes
/// to avoid capturing our own pasteboard modifications.
final class ClipboardMonitor {
    private let modelContainer: ModelContainer
    private var timer: Timer?
    private var lastChangeCount: Int = 0
    private let pollingInterval: TimeInterval = 0.5
    private let service = ClipboardService()

    private var maxHistoryCount: Int {
        UserDefaults.standard.integer(forKey: "maxHistoryCount").nonZero ?? 500
    }

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        lastChangeCount = NSPasteboard.general.changeCount
    }

    func start() {
        timer = Timer.scheduledTimer(
            withTimeInterval: pollingInterval,
            repeats: true
        ) { [weak self] _ in
            self?.pollPasteboard()
        }
        timer?.tolerance = 0.1
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    /// Call AFTER writing to the pasteboard programmatically to prevent re-capture.
    /// Updates the internal changeCount so our own writes are invisible to the next poll.
    func syncChangeCount() {
        lastChangeCount = NSPasteboard.general.changeCount
    }

    private func pollPasteboard() {
        let pasteboard = NSPasteboard.general
        let currentChangeCount = pasteboard.changeCount

        guard currentChangeCount != lastChangeCount else { return }
        lastChangeCount = currentChangeCount

        // Read clipboard content
        guard let content = service.readClipboard() else { return }

        // Check deduplication
        if let latestItem = fetchLatestItem(),
           latestItem.isDuplicate(of: content) {
            return
        }

        // Save to SwiftData
        saveItem(content)

        // Enforce max history limit
        enforceHistoryLimit()
    }

    private func fetchLatestItem() -> ClipboardItem? {
        let context = ModelContext(modelContainer)
        var descriptor = FetchDescriptor<ClipboardItem>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        return try? context.fetch(descriptor).first
    }

    private func saveItem(_ content: ClipboardContent) {
        let context = ModelContext(modelContainer)

        let item = ClipboardItem(
            timestamp: Date(),
            contentType: content.type,
            textContent: content.textContent,
            imageData: content.imageData,
            imageThumbnailData: content.imageThumbnailData,
            fileURLs: content.fileURLs,
            sourceAppBundleID: content.sourceAppBundleID,
            sourceAppName: content.sourceAppName,
            characterCount: content.textContent?.count
        )

        context.insert(item)
        try? context.save()
    }

    private func enforceHistoryLimit() {
        let context = ModelContext(modelContainer)
        let descriptor = FetchDescriptor<ClipboardItem>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        guard let totalCount = try? context.fetchCount(descriptor),
              totalCount > maxHistoryCount else { return }

        var cleanupDescriptor = FetchDescriptor<ClipboardItem>(
            predicate: #Predicate { !$0.isPinned },
            sortBy: [SortDescriptor(\.timestamp, order: .forward)]
        )
        let excess = totalCount - maxHistoryCount
        cleanupDescriptor.fetchLimit = max(0, excess)

        if let toDelete = try? context.fetch(cleanupDescriptor) {
            for item in toDelete {
                context.delete(item)
            }
            try? context.save()
        }
    }
}
