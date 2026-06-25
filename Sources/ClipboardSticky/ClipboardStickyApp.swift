import SwiftUI
import AppKit

@main
struct ClipboardStickyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            SettingsView()
                .frame(width: 520, height: 420)
        }
        .windowResizability(.contentSize)
    }
}
