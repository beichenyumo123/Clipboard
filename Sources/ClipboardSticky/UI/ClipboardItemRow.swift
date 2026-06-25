import SwiftUI
import AppKit

/// A single row in the clipboard list showing a preview of the content.
struct ClipboardItemRow: View {
    let item: ClipboardItem
    let isSelected: Bool

    @State private var appIcon: NSImage?

    var body: some View {
        HStack(spacing: 8) {
            // Content preview
            contentPreview
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(2)

            // Source app icon
            if let icon = appIcon {
                Image(nsImage: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 14, height: 14)
                    .opacity(0.6)
            }

            // Time
            Text(item.timestamp, style: .relative)
                .font(.system(size: 9))
                .foregroundColor(.tertiaryLabel)
                .fixedSize()

            // Pin indicator
            if item.isPinned {
                Image(systemName: "pin.fill")
                    .font(.system(size: 8))
                    .foregroundColor(.accentColor)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isSelected ? Color.accentColor.opacity(0.15) : Color.clear)
        )
        .onAppear {
            loadAppIcon()
        }
    }

    @ViewBuilder
    private var contentPreview: some View {
        switch item.contentType {
        case .text:
            Text(item.textContent ?? "")
                .font(.system(size: 11))
                .foregroundColor(.primary)
                .truncationMode(.tail)

        case .rtf, .html:
            Text(item.textContent ?? "")
                .font(.system(size: 11))
                .foregroundColor(.primary)
                .truncationMode(.tail)

        case .image:
            HStack(spacing: 4) {
                if let thumbnailData = item.imageThumbnailData ?? item.imageData,
                   let nsImage = NSImage(data: thumbnailData) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 36)
                        .cornerRadius(4)
                }
                Text("图片")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }

        case .file:
            HStack(spacing: 4) {
                Image(systemName: "doc")
                    .font(.system(size: 11))
                Text(item.fileURLs?.first?.lastPathComponent ?? "文件")
                    .font(.system(size: 11))
                    .foregroundColor(.primary)
                if let count = item.fileURLs?.count, count > 1 {
                    Text("等 \(count) 个")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    private func loadAppIcon() {
        guard let bundleID = item.sourceAppBundleID else { return }
        guard let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) else { return }
        appIcon = NSWorkspace.shared.icon(forFile: appURL.path)
    }
}
