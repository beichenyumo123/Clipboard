import AppKit

/// Resolves the currently active (frontmost) application info.
enum SourceAppResolver {

    struct AppInfo {
        let bundleID: String?
        let name: String?
    }

    /// Get the bundle ID and name of the frontmost application.
    static func resolve() -> AppInfo {
        guard let frontApp = NSWorkspace.shared.frontmostApplication else {
            return AppInfo(bundleID: nil, name: nil)
        }

        return AppInfo(
            bundleID: frontApp.bundleIdentifier,
            name: frontApp.localizedName
        )
    }

    /// Get the icon for a given bundle ID.
    static func icon(for bundleID: String?) -> NSImage? {
        guard let bundleID else { return nil }
        guard let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) else {
            return nil
        }
        return NSWorkspace.shared.icon(forFile: appURL.path)
    }
}
