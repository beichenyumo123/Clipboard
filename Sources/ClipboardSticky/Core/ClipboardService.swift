import AppKit

struct ClipboardContent {
    let type: ClipboardContentType
    let textContent: String?
    let imageData: Data?
    let imageThumbnailData: Data?
    let fileURLs: [URL]?
    let sourceAppBundleID: String?
    let sourceAppName: String?
}

final class ClipboardService {

    func readClipboard() -> ClipboardContent? {
        let pb = NSPasteboard.general
        let sourceInfo = SourceAppResolver.resolve()

        // Read all available types from the pasteboard
        let types = pb.types ?? []

        // 1. File URLs — check BEFORE text, because Finder puts file paths as text too
        if types.contains(.fileURL) {
            if let urls = readFileURLs(from: pb), !urls.isEmpty {
                return ClipboardContent(
                    type: .file,
                    textContent: urls.map(\.lastPathComponent).joined(separator: ", "),
                    imageData: nil,
                    imageThumbnailData: nil,
                    fileURLs: urls,
                    sourceAppBundleID: sourceInfo.bundleID,
                    sourceAppName: sourceInfo.name
                )
            }
        }

        // 2. Image — check multiple formats
        if types.contains(.png) || types.contains(.tiff) || types.contains(where: { $0.rawValue == "public.jpeg" }) {
            let imageData = pb.data(forType: .png)
                ?? pb.data(forType: .tiff)
                ?? pb.data(forType: NSPasteboard.PasteboardType("public.jpeg"))
            if let imageData {
                let thumb = generateThumbnail(from: imageData, maxSize: 200)
                return ClipboardContent(
                    type: .image,
                    textContent: nil,
                    imageData: imageData,
                    imageThumbnailData: thumb,
                    fileURLs: nil,
                    sourceAppBundleID: sourceInfo.bundleID,
                    sourceAppName: sourceInfo.name
                )
            }
        }

        // 3. RTF
        if let rtfData = pb.data(forType: .rtf) {
            let text = NSAttributedString(rtf: rtfData, documentAttributes: nil)?.string
            if let text, !text.isEmpty {
                return ClipboardContent(
                    type: .rtf,
                    textContent: text,
                    imageData: rtfData,   // store RTF for re-copy
                    imageThumbnailData: nil,
                    fileURLs: nil,
                    sourceAppBundleID: sourceInfo.bundleID,
                    sourceAppName: sourceInfo.name
                )
            }
        }

        // 4. HTML
        if let htmlData = pb.data(forType: .html),
           let htmlStr = String(data: htmlData, encoding: .utf8), !htmlStr.isEmpty {
            return ClipboardContent(
                type: .html,
                textContent: htmlStr,
                imageData: nil,
                imageThumbnailData: nil,
                fileURLs: nil,
                sourceAppBundleID: sourceInfo.bundleID,
                sourceAppName: sourceInfo.name
            )
        }

        // 5. Plain text (lowest priority — avoids mistaking file paths for text)
        if let text = pb.string(forType: .string), !text.isEmpty {
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

        return nil
    }

    /// Read file URLs using NSPasteboard's dedicated file URL reading.
    private func readFileURLs(from pb: NSPasteboard) -> [URL]? {
        // Try standard file URL reading first
        if let urls = pb.readObjects(forClasses: [NSURL.self], options: [
            .urlReadingFileURLsOnly: true,
            .urlReadingContentsConformToTypes: []
        ]) as? [URL], !urls.isEmpty {
            return urls
        }
        // Fallback: read raw string and parse
        if let str = pb.string(forType: .fileURL),
           let url = URL(string: str) {
            return [url]
        }
        return nil
    }

    private func generateThumbnail(from imageData: Data, maxSize: CGFloat) -> Data? {
        guard let image = NSImage(data: imageData) else { return nil }
        let size = image.size
        let scale = min(maxSize / max(size.width, size.height), 1.0)
        guard scale < 1.0 else { return imageData }

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
