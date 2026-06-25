import AppKit
import SwiftUI
import SwiftData

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var panelController: PanelWindowController?
    private var clipboardMonitor: ClipboardMonitor?
    private var hotkeyManager: HotkeyManager?
    private var modelContainer: ModelContainer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize SwiftData container with explicit store URL
        do {
            let schema = Schema([ClipboardItem.self])
            let storeURL = URL.applicationSupportDirectory
                .appending(path: "ClipboardSticky")
                .appending(path: "clipboard.store")
            // Ensure directory exists
            try FileManager.default.createDirectory(
                at: storeURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            let config = ModelConfiguration(schema: schema, url: storeURL)
            modelContainer = try ModelContainer(for: schema, configurations: [config])
            print("[ClipboardSticky] Store at: \(storeURL.path())")
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }

        // Hide from Dock
        NSApp.setActivationPolicy(.accessory)

        // Set up the panel window
        panelController = PanelWindowController(modelContainer: modelContainer!)
        panelController?.showWindow(nil)

        guard let panelWindow = panelController?.window as? PanelWindow else {
            fatalError("Expected PanelWindow")
        }

        // Register global hotkey: Cmd+Shift+V to toggle panel
        hotkeyManager = HotkeyManager(panelWindow: panelWindow)
        hotkeyManager?.register()

        // Start clipboard monitoring
        clipboardMonitor = ClipboardMonitor(modelContainer: modelContainer!)
        clipboardMonitor?.start()

        // Wire the monitor to PasteboardWriter so writes don't self-trigger
        PasteboardWriter.monitor = clipboardMonitor

        // Listen for screen parameter changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenParametersChanged),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )

        // Set up a minimal main menu (required for keyboard shortcuts and settings)
        setupMainMenu()
    }

    func applicationWillTerminate(_ notification: Notification) {
        clipboardMonitor?.stop()
        hotkeyManager?.unregister()
    }

    @objc private func screenParametersChanged() {
        panelController?.reposition()
    }

    // MARK: - Main Menu

    private func setupMainMenu() {
        let mainMenu = NSMenu()

        // App menu
        let appMenuItem = NSMenuItem()
        let appMenu = NSMenu()
        appMenu.addItem(
            withTitle: "关于 ClipboardSticky",
            action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)),
            keyEquivalent: ""
        )
        appMenu.addItem(.separator())
        appMenu.addItem(
            withTitle: "设置...",
            action: Selector(("showSettingsWindow:")),
            keyEquivalent: ","
        )
        appMenu.addItem(.separator())
        appMenu.addItem(
            withTitle: "退出",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        )
        appMenuItem.submenu = appMenu
        mainMenu.addItem(appMenuItem)

        NSApp.mainMenu = mainMenu
    }
}
