import SwiftUI
import AppKit

// MARK: - Code Detection

private let codeIndicators: Set<String> = [
    "function", "const", "let", "var", "if", "for", "while", "return",
    "import", "export", "class", "struct", "enum", "def", "async", "await",
    "try", "catch", "throw", "new", "this", "self", "static", "public",
    "private", "protected", "extends", "implements", "interface", "type",
    "fn", "=>", "&&", "||", "===", "!==", "use", "mod", "pub", "impl",
]
private let codeSymbols = CharacterSet(charactersIn: "{}()[];=:<>+-*/%&|!^~?.,\\\"'`@#$")

func looksLikeCode(_ text: String) -> Bool {
    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
    guard trimmed.count > 8 else { return false }

    let lines = trimmed.components(separatedBy: "\n")
    let nonEmpty = lines.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }

    // Multi-line with consistent indentation → code
    if nonEmpty.count >= 3 {
        let indented = nonEmpty.filter { $0.hasPrefix("    ") || $0.hasPrefix("\t") }
        if Double(indented.count) / Double(nonEmpty.count) > 0.5 { return true }
    }

    // High symbol ratio
    let symbolCount = trimmed.unicodeScalars.filter { codeSymbols.contains($0) }.count
    let totalCount = trimmed.unicodeScalars.count
    let symbolRatio = Double(symbolCount) / Double(totalCount)
    if symbolRatio > 0.06 { return true }

    // Contains programming keywords
    let words = trimmed.lowercased().components(separatedBy: .whitespacesAndNewlines)
    let keywordHits = words.filter { codeIndicators.contains($0) }.count
    if keywordHits >= 2 { return true }

    // Very high ASCII ratio with structural characters
    let asciiCount = trimmed.unicodeScalars.filter { $0.value < 128 }.count
    let asciiRatio = Double(asciiCount) / Double(totalCount)
    if asciiRatio > 0.85 && (trimmed.contains("{") || trimmed.contains(";") || trimmed.contains("=>")) {
        return true
    }

    return false
}

// MARK: - Type Badge

struct ClipboardTypeBadge: View {
    let type: ClipboardContentType
    let isCode: Bool

    private var color: Color {
        if isCode { return .cpBlue }
        switch type {
        case .text:  return .cpSubtext0
        case .rtf:   return .cpGreen
        case .html:  return .cpTeal
        case .image: return .cpPink
        case .file:  return .cpPeach
        }
    }

    private var bg: Color { color.opacity(0.10) }
    private var fg: Color { color }

    var body: some View {
        Text(isCode ? "代码" : type.displayName)
            .font(.system(size: 9, weight: .semibold))
            .foregroundColor(fg)
            .padding(.horizontal, 7)
            .padding(.vertical, 2.5)
            .background(RoundedRectangle(cornerRadius: 5).fill(bg))
    }
}

// MARK: - Row

struct ClipboardItemRow: View {
    let item: ClipboardItem
    let isSelected: Bool

    @State private var appIcon: NSImage?
    @State private var isHovered: Bool = false

    private var isCode: Bool {
        guard item.contentType == .text,
              let text = item.textContent else { return false }
        return looksLikeCode(text)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                // App icon
                iconView
                Spacer().frame(width: 10)

                // Main content
                VStack(alignment: .leading, spacing: 4) {
                    // Badge row
                    HStack(spacing: 5) {
                        ClipboardTypeBadge(type: item.contentType, isCode: isCode)
                        if isSelected {
                            Image(systemName: "checkmark")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.stickyAccent)
                        }
                    }

                    // Text preview
                    contentPreview
                        .lineLimit(3)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer().frame(width: 8)

                // Right column: pin + time
                VStack(alignment: .trailing, spacing: 4) {
                    if item.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.system(size: 9))
                            .foregroundColor(.stickyAccent)
                    }
                    Spacer()
                    Text(item.timestamp.relativeDescription)
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(.stickyTextTertiary)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
        }
        .background(cardBg)
        .overlay(cardBorderOverlay)
        .scaleEffect(isHovered ? 1.015 : 1.0)
        .offset(y: isHovered ? -2 : 0)
        .shadow(color: isHovered
            ? Color.stickyAccent.opacity(0.10) : .clear,
            radius: isHovered ? 12 : 0, x: 0, y: isHovered ? 4 : 0)
        .shadow(color: isHovered
            ? .black.opacity(0.08) : .clear,
            radius: isHovered ? 6 : 0, x: 0, y: isHovered ? 2 : 0)
        .onHover { hovering in
            withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) {
                isHovered = hovering
            }
        }
        .onAppear { loadAppIcon() }
    }

    // MARK: - Icon

    @ViewBuilder
    private var iconView: some View {
        if let icon = appIcon {
            Image(nsImage: icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 22, height: 22)
                .opacity(0.8)
        } else {
            Image(systemName: defaultIcon)
                .font(.system(size: 14))
                .foregroundColor(.stickyTextTertiary)
                .frame(width: 22, height: 22)
        }
    }

    private var defaultIcon: String {
        switch item.contentType {
        case .image: return "photo"
        case .file:  return "doc"
        default:     return "doc.on.doc"
        }
    }

    // MARK: - Content Preview

    @ViewBuilder
    private var contentPreview: some View {
        switch item.contentType {
        case .text:
            let txt = item.textContent?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if isCode {
                Text(txt)
                    .font(.system(size: 11.5, design: .monospaced))
                    .foregroundColor(.stickyTextPrimary)
                    .tracking(-0.2)
            } else {
                Text(txt)
                    .font(.system(size: 12.5))
                    .foregroundColor(.stickyTextPrimary)
                    .tracking(0.15)
            }

        case .rtf:
            // RTF is already plain text extracted from attributed string
            Text(item.textContent ?? "")
                .font(.system(size: 12))
                .foregroundColor(.stickyTextPrimary)
                .tracking(0.15)

        case .html:
            // Strip HTML tags for preview, keep raw HTML for copy-back
            let plain = stripHTML(item.textContent ?? "")
            Text(plain)
                .font(.system(size: 12))
                .foregroundColor(.stickyTextPrimary)
                .tracking(0.15)

        case .image:
            HStack(spacing: 6) {
                if let thumb = item.imageThumbnailData ?? item.imageData,
                   let nsImg = NSImage(data: thumb) {
                    Image(nsImage: nsImg)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 44, height: 32)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("图片")
                        .font(.system(size: 12.5))
                        .foregroundColor(.stickyTextPrimary)
                    if let count = item.characterCount, count > 0 {
                        Text("\(count) 字")
                            .font(.system(size: 9))
                            .foregroundColor(.stickyTextTertiary)
                    }
                }
            }

        case .file:
            VStack(alignment: .leading, spacing: 2) {
                Text(item.fileURLs?.first?.lastPathComponent ?? "文件")
                    .font(.system(size: 12.5))
                    .foregroundColor(.stickyTextPrimary)
                if let urls = item.fileURLs {
                    if urls.count > 1 {
                        Text("等 \(urls.count) 个文件")
                            .font(.system(size: 10))
                            .foregroundColor(.stickyTextTertiary)
                    } else {
                        Text("1 个文件")
                            .font(.system(size: 10))
                            .foregroundColor(.stickyTextTertiary)
                    }
                }
            }
        }
    }

    // MARK: - Card Styling

    private var cardBg: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(isSelected ? Color.stickyCardActive
                : isHovered ? Color.stickyCardHover
                : Color.stickyCard)
    }

    @ViewBuilder
    private var cardBorderOverlay: some View {
        let isActive = isSelected || isHovered
        RoundedRectangle(cornerRadius: 8)
            .stroke(isActive ? Color.stickyAccent.opacity(0.35) : Color.stickyCardBorder,
                    lineWidth: isActive ? 1.0 : 0.5)
            .overlay(
                // Glow ring on hover
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.stickyAccent.opacity(isHovered ? 0.15 : 0),
                            lineWidth: 3)
                    .blur(radius: isHovered ? 2 : 0)
                    .opacity(isHovered ? 1 : 0)
            )
    }

    private func loadAppIcon() {
        guard let id = item.sourceAppBundleID,
              let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: id)
        else { return }
        appIcon = NSWorkspace.shared.icon(forFile: url.path)
    }
}

/// Strip HTML tags, decode entities, collapse whitespace.
private func stripHTML(_ html: String) -> String {
    guard let data = html.data(using: .utf8) else { return html }
    if let attr = try? NSAttributedString(
        data: data,
        options: [.documentType: NSAttributedString.DocumentType.html,
                  .characterEncoding: String.Encoding.utf8.rawValue],
        documentAttributes: nil
    ) {
        let text = attr.string
            .replacingOccurrences(of: "\n\n+", with: "\n", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return html }
        return text
    }
    // Fallback: regex strip
    return html
        .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        .trimmingCharacters(in: .whitespacesAndNewlines)
}
