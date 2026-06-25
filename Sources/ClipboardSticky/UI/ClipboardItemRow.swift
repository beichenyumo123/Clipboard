import SwiftUI
import AppKit

struct ClipboardItemRow: View {
    let item: ClipboardItem
    let isSelected: Bool

    @State private var appIcon: NSImage?
    @State private var isHovered: Bool = false

    var body: some View {
        HStack(spacing: 0) {
            // App icon
            if let icon = appIcon {
                Image(nsImage: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 22, height: 22)
                    .opacity(0.8)
            } else {
                Image(systemName: "doc.on.doc")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .frame(width: 22, height: 22)
            }

            Spacer().frame(width: 10)

            // Content
            VStack(alignment: .leading, spacing: 3) {
                contentText
                    .font(.system(size: 12.5))
                    .foregroundColor(.primary)
                    .lineLimit(2)

                HStack(spacing: 6) {
                    // Type badge
                    if item.contentType != .text {
                        typeBadge
                    }
                    // Char count
                    if let count = item.characterCount, count > 0 {
                        Text("\(count) 字")
                            .font(.system(size: 9))
                            .foregroundColor(.tertiaryLabel)
                    }
                    // Time
                    Text(item.timestamp.relativeDescription)
                        .font(.system(size: 9))
                        .foregroundColor(.tertiaryLabel)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer().frame(width: 8)

            // Pin badge
            if item.isPinned {
                Image(systemName: "pin.fill")
                    .font(.system(size: 9))
                    .foregroundColor(.accentColor)
                    .help("已固定")
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(cardBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(cardBorderColor, lineWidth: 0.5)
        )
        .scaleEffect(isHovered ? 1.01 : 1.0)
        .shadow(color: isHovered ? .black.opacity(0.06) : .clear, radius: 4, y: 1)
        .onHover { hovering in
            withAnimation(.easeOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
        .onAppear { loadAppIcon() }
    }

    @ViewBuilder
    private var contentText: some View {
        switch item.contentType {
        case .text, .rtf, .html:
            Text(item.textContent?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
                .lineLimit(2)

        case .image:
            HStack(spacing: 6) {
                if let thumb = item.imageThumbnailData ?? item.imageData,
                   let nsImg = NSImage(data: thumb) {
                    Image(nsImage: nsImg)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 40, height: 28)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                Text("图片")
                    .foregroundColor(.secondary)
            }

        case .file:
            HStack(spacing: 6) {
                Image(systemName: "doc.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.blue)
                Text(item.fileURLs?.first?.lastPathComponent ?? "文件")
                if let count = item.fileURLs?.count, count > 1 {
                    Text("+\(count - 1)")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    private var typeBadge: some View {
        Text(item.contentType.displayName)
            .font(.system(size: 8, weight: .medium))
            .foregroundColor(.secondary)
            .padding(.horizontal, 5)
            .padding(.vertical, 1)
            .background(
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.primary.opacity(0.08))
            )
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(cardFillColor)
    }

    private var cardFillColor: Color {
        if isSelected {
            return .accentColor.opacity(0.12)
        }
        if isHovered {
            return .primary.opacity(0.08)
        }
        return .primary.opacity(0.04)
    }

    private var cardBorderColor: Color {
        if isSelected {
            return .accentColor.opacity(0.3)
        }
        if isHovered {
            return .primary.opacity(0.12)
        }
        return .primary.opacity(0.06)
    }

    private func loadAppIcon() {
        guard let bundleID = item.sourceAppBundleID,
              let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID)
        else { return }
        appIcon = NSWorkspace.shared.icon(forFile: url.path)
    }
}
