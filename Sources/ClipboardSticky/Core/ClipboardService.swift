import AppKit

/// Content read from the clipboard, ready for storage.
struct ClipboardContent {
    let type: ClipboardContentType
    let textContent: String?
    let imageData: Data?
    let imageThumbnailData: Data?
    let fileURLs: [URL]?
    let sourceAppBundleID: String?
    let sourceAppName: String?
}

/// Reads content from NSPasteboard and converts it to storable ClipboardContent.
final class ClipboardService {

    /// Read the current contents of the general pasteboard.
    /// Returns nil if there's nothing new or supported.
    func readClipboard() -> ClipboardContent? {
        let pasteboard = NSPasteboard.general
        let sourceInfo = SourceAppResolver.resolve()

        // Try to read in priority order: text → image → file

        // 1. Plain text
        if let text = pasteboard.string(forType: .string), !text.isEmpty {
            return ClipboardContent(
                type: .text,
                textContent: text,
                imageData: nil,
                imageThumbnailData: nil,
                fileURLs: nil,
                sourceAppBundleID: sourceInfo.bundleID,
                sourceAppName: sourceInfo.name
            )
        }

        // 2. RTF
        if let rtfData = pasteboard.data(forType: .rtf) {
            let attributed = NSAttributedString(rtf: rtfData, documentAttributes: nil)
            if let text = attributed?.string, !text.isEmpty {
                return ClipboardContent(
                    type: .rtf,
                    textContent: text,
                    imageData: rtfData,  // store original RTF for re-copy
                    imageThumbnailData: nil,
                    fileURLs: nil,
                    sourceAppBundleID: sourceInfo.bundleID,
                    sourceAppName: sourceInfo.name
                )
            }
        }

        // 3. HTML
        if let htmlData = pasteboard.data(forType: .html),
           let htmlString = String(data: htmlData, encoding: .utf8), !htmlString.isEmpty {
            return ClipboardContent(
                type: .html,
                textContent: htmlString,
                imageData: nil,
                imageThumbnailData: nil,
                fileURLs: nil,
                sourceAppBundleID: sourceInfo.bundleID,
                sourceAppName: sourceInfo.name
            )
        }

        // 4. Image (PNG preferred, fallback to TIFF)
        if let imageData = pasteboard.data(forType: .png) ?? pasteboard.data(forType: .tiff) {
            let thumbnail = generateThumbnail(from: imageData, maxSize: 200)
            return ClipboardContent(
                type: .image,
                textContent: nil,
                imageData: imageData,
                imageThumbnailData: thumbnail,
                fileURLs: nil,
                sourceAppBundleID: sourceInfo.bundleID,
                sourceAppName: sourceInfo.name
            )
        }

        // 5. File URLs
        if let fileURLs = pasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL],
           !fileURLs.isEmpty {
            return ClipboardContent(
                type: .file,
                textContent: nil,
                imageData: nil,
                imageThumbnailData: nil,
                fileURLs: fileURLs,
                sourceAppBundleID: sourceInfo.bundleID,
                sourceAppName: sourceInfo.name
            )
        }

        return nil
    }

    /// Generate a small thumbnail from image data to reduce memory pressure.
    private func generateThumbnail(from imageData: Data, maxSize: CGFloat) -> Data? {
        guard let image = NSImage(data: imageData) else { return nil }

        let size = image.size
        let scale = min(maxSize / max(size.width, size.height), 1.0)

        guard scale < 1.0 else { return imageData }  // already small enough

        let newSize = NSSize(width: size.width * scale, height: size.height * scale)
        let thumbnail = NSImage(size: newSize)

        thumbnail.lockFocus()
        image.draw(in: NSRect(origin: .zero, size: newSize),
                   from: .zero, operation: .copy, fraction: 1.0)
        thumbnail.unlockFocus()

        guard let tiff = thumbnail.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiff) else { return nil }

        return bitmap.representation(using: .png, properties: [:])
    }
}

extension ClipboardItem {
    /// Check if a newly-read clipboard content is a duplicate of this item.
    func isDuplicate(of content: ClipboardContent) -> Bool {
        guard contentTypeRaw == content.type.rawValue else { return false }

        switch content.type {
        case .text, .rtf, .html:
            return textContent == content.textContent
        case .image:
            return imageData == content.imageData
        case .file:
            return fileURLsString == content.fileURLs?.map(\.absoluteString).joined(separator: "\n")
        }
    }
}
