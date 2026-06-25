import SwiftData
import Foundation

@Model
final class ClipboardItem {
    @Attribute(.unique) var id: UUID
    var timestamp: Date
    var contentTypeRaw: String
    var textContent: String?
    @Attribute(.externalStorage) var imageData: Data?
    @Attribute(.externalStorage) var imageThumbnailData: Data?
    // Stored as comma-separated string since SwiftData doesn't support [URL] directly
    var fileURLsString: String?
    var sourceAppBundleID: String?
    var sourceAppName: String?
    var isPinned: Bool
    var characterCount: Int?
    var searchText: String?

    var contentType: ClipboardContentType {
        get { ClipboardContentType(rawValue: contentTypeRaw) ?? .text }
        set { contentTypeRaw = newValue.rawValue }
    }

    var fileURLs: [URL]? {
        get {
            fileURLsString?.components(separatedBy: "\n").compactMap { URL(string: $0) }
        }
        set {
            fileURLsString = newValue?.map(\.absoluteString).joined(separator: "\n")
        }
    }

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        contentType: ClipboardContentType = .text,
        textContent: String? = nil,
        imageData: Data? = nil,
        imageThumbnailData: Data? = nil,
        fileURLs: [URL]? = nil,
        sourceAppBundleID: String? = nil,
        sourceAppName: String? = nil,
        isPinned: Bool = false,
        characterCount: Int? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.contentTypeRaw = contentType.rawValue
        self.textContent = textContent
        self.imageData = imageData
        self.imageThumbnailData = imageThumbnailData
        self.fileURLsString = fileURLs?.map(\.absoluteString).joined(separator: "\n")
        self.sourceAppBundleID = sourceAppBundleID
        self.sourceAppName = sourceAppName
        self.isPinned = isPinned
        self.characterCount = characterCount
        self.searchText = textContent?.lowercased()
    }
}

enum ClipboardContentType: String, CaseIterable {
    case text = "text"
    case rtf = "rtf"
    case html = "html"
    case image = "image"
    case file = "file"

    var displayName: String {
        switch self {
        case .text: return "文本"
        case .rtf: return "RTF"
        case .html: return "HTML"
        case .image: return "图片"
        case .file: return "文件"
        }
    }
}
