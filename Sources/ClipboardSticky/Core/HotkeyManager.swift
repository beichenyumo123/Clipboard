import AppKit
import Carbon

/// Registers a global hotkey (Cmd+Shift+V) to toggle the clipboard panel.
/// Uses the legacy Carbon `RegisterEventHotKey` API, which still functions on macOS 14+.
final class HotkeyManager {
    private var hotkeyRef: EventHotKeyRef?
    private var eventHandlerRef: EventHandlerRef?
    private let panelWindow: PanelWindow

    init(panelWindow: PanelWindow) {
        self.panelWindow = panelWindow
    }

    func register() {
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: OSType(kEventHotKeyPressed)
        )

        let selfPtr = Unmanaged.passUnretained(self).toOpaque()

        InstallEventHandler(
            GetApplicationEventTarget(),
            { (_, event, userData) -> OSStatus in
                guard let userData else { return -1 }
                let manager = Unmanaged<HotkeyManager>.fromOpaque(userData).takeUnretainedValue()
                manager.handleHotkey()
                return noErr
            },
            1,
            &eventType,
            selfPtr,
            &eventHandlerRef
        )

        // Cmd+Shift+V => key code 9 = 'V'
        let hotkeyID = EventHotKeyID(signature: 0x43535048, id: 1)  // 'CSPH'
        let status = RegisterEventHotKey(
            UInt32(kVK_ANSI_V),
            UInt32(cmdKey | shiftKey),
            hotkeyID,
            GetApplicationEventTarget(),
            0,
            &hotkeyRef
        )

        if status != noErr {
            print("⚠️ Failed to register global hotkey Cmd+Shift+V (err: \(status))")
        }
    }

    func unregister() {
        if let ref = hotkeyRef {
            UnregisterEventHotKey(ref)
            hotkeyRef = nil
        }
        if let handler = eventHandlerRef {
            RemoveEventHandler(handler)
            eventHandlerRef = nil
        }
    }

    private func handleHotkey() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            PanelAnimator.toggle(self.panelWindow)
        }
    }
}
