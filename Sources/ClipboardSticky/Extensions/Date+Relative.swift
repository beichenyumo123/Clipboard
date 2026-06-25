import Foundation

extension Date {
    /// Returns a relative time string like "3分钟前", "刚刚", etc.
    var relativeDescription: String {
        let now = Date()
        let interval = now.timeIntervalSince(self)

        switch interval {
        case ..<0:
            return "未来"
        case 0..<10:
            return "刚刚"
        case 10..<60:
            return "\(Int(interval))秒前"
        case 60..<3600:
            return "\(Int(interval / 60))分钟前"
        case 3600..<86400:
            return "\(Int(interval / 3600))小时前"
        case 86400..<604800:
            return "\(Int(interval / 86400))天前"
        default:
            let formatter = DateFormatter()
            formatter.dateFormat = "MM-dd"
            return formatter.string(from: self)
        }
    }
}
