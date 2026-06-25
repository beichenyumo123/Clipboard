import AppKit

enum PasteboardWriter {

    static weak var monitor: ClipboardMonitor?

    static func copyToClipboard(_ item: ClipboardItem) {
        let pb = NSPasteboard.general
        pb.clearContents()

        switch item.contentType {
        case .text:
            if let text = item.textContent {
                pb.setString(text, forType: .string)
            }

        case .rtf:
            if let rtf = item.imageData {  // RTF stored in imageData
                pb.setData(rtf, forType: .rtf)
            }
            if let text = item.textContent {
                pb.setString(text, forType: .string)
            }

        case .html:
            if let html = item.textContent {
                pb.setString(html, forType: .html)
                pb.setString(stripHTML(html), forType: .string)
            }

        case .image:
            if let data = item.imageData {
                pb.setData(data, forType: .png)
                // Also provide TIFF for apps that prefer it
                if let image = NSImage(data: data),
                   let tiff = image.tiffRepresentation {
                    pb.setData(tiff, forType: .tiff)
                }
            }

        case .file:
            if let urls = item.fileURLs {
                pb.writeObjects(urls.map { $0 as NSURL })
            }
        }

        monitor?.syncChangeCount()
    }

    static func copyAndPaste(_ item: ClipboardItem) {
        copyToClipboard(item)
        let src = CGEventSource(stateID: .combinedSessionState)
        let down = CGEvent(keyboardEventSource: src, virtualKey: 0x09, keyDown: true)
        down?.flags = .maskCommand
        let up = CGEvent(keyboardEventSource: src, virtualKey: 0x09, keyDown: false)
        up?.flags = .maskCommand
        down?.post(tap: .cghidEventTap)
        up?.post(tap: .cghidEventTap)
    }

    private static func stripHTML(_ html: String) -> String {
        guard let data = html.data(using: .utf8) else { return html }
        let opts: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        if let attr = try? NSAttributedString(data: data, options: opts, documentAttributes: nil) {
            return attr.string
        }
        return html.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
    }
}
