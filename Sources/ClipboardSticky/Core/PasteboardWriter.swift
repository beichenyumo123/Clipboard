import AppKit

/// Writes content back to the general pasteboard. Notifies the monitor
/// to skip the next change to avoid recording our own writes.
enum PasteboardWriter {

    /// The monitor instance. Set by AppDelegate after initialization.
    static weak var monitor: ClipboardMonitor?

    /// Copy a ClipboardItem's content to the general pasteboard.
    static func copyToClipboard(_ item: ClipboardItem) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()

        switch item.contentType {
        case .text:
            if let text = item.textContent {
                pasteboard.setString(text, forType: .string)
            }

        case .rtf:
            if let rtfData = item.imageData {
                pasteboard.setData(rtfData, forType: .rtf)
            }
            if let text = item.textContent {
                pasteboard.setString(text, forType: .string)
            }

        case .html:
            if let text = item.textContent {
                pasteboard.setString(text, forType: .html)
                let plainText = stripHTML(text)
                pasteboard.setString(plainText, forType: .string)
            }

        case .image:
            if let imageData = item.imageData {
                pasteboard.setData(imageData, forType: .png)
            }

        case .file:
            if let urls = item.fileURLs {
                pasteboard.writeObjects(urls as [NSURL])
            }
        }

        // Sync changeCount so our own writes don't get re-captured
        monitor?.syncChangeCount()
    }

    /// Copy and simulate Cmd+V to paste into the previously active app.
    static func copyAndPaste(_ item: ClipboardItem) {
        copyToClipboard(item)

        let source = CGEventSource(stateID: .combinedSessionState)
        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: true)
        keyDown?.flags = .maskCommand
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: false)
        keyUp?.flags = .maskCommand

        keyDown?.post(tap: .cghidEventTap)
        keyUp?.post(tap: .cghidEventTap)
    }

    private static func stripHTML(_ html: String) -> String {
        guard let data = html.data(using: .utf8) else { return html }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        if let attributed = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
            return attributed.string
        }
        return html.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
    }
}
