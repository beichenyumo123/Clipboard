import SwiftUI
import ServiceManagement

/// Preferences/settings window.
struct SettingsView: View {
    @AppStorage("maxHistoryCount") private var maxHistoryCount: Int = 500
    @AppStorage("panelPosition") private var panelPosition: String = ScreenEdge.right.rawValue
    @AppStorage("expandMode") private var expandMode: String = "hover"  // "hover" or "click"
    @AppStorage("panelHeightRatio") private var panelHeightRatio: Double = 0.7
    @AppStorage("panelWidth") private var panelWidth: Double = 320
    @AppStorage("launchAtLogin") private var launchAtLogin: Bool = false

    var body: some View {
        TabView {
            generalTab
                .tabItem {
                    Label("通用", systemImage: "gearshape")
                }
                .padding()

            aboutTab
                .tabItem {
                    Label("关于", systemImage: "info.circle")
                }
                .padding()
        }
    }

    // MARK: - General Tab

    private var generalTab: some View {
        Form {
            Section("面板位置") {
                Picker("屏幕边缘", selection: $panelPosition) {
                    Text("左侧").tag(ScreenEdge.left.rawValue)
                    Text("右侧").tag(ScreenEdge.right.rawValue)
                }
                .pickerStyle(.segmented)
                .frame(width: 200)
            }

            Section("面板外观") {
                HStack {
                    Text("高度占比:")
                    Slider(value: $panelHeightRatio, in: 0.4...0.9, step: 0.05)
                    Text("\(Int(panelHeightRatio * 100))%")
                        .monospacedDigit()
                        .frame(width: 36)
                }

                HStack {
                    Text("宽度:")
                    Slider(value: $panelWidth, in: 250...500, step: 10)
                    Text("\(Int(panelWidth))pt")
                        .monospacedDigit()
                        .frame(width: 36)
                }
            }

            Section("展开方式") {
                Picker("触发方式", selection: $expandMode) {
                    Text("悬停展开").tag("hover")
                    Text("点击展开").tag("click")
                }
                .pickerStyle(.radioGroup)
            }

            Section("历史记录") {
                Picker("最大条数", selection: $maxHistoryCount) {
                    Text("100").tag(100)
                    Text("200").tag(200)
                    Text("500").tag(500)
                    Text("1000").tag(1000)
                }
                .pickerStyle(.segmented)
            }

            Section("系统") {
                Toggle("开机自动启动", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { _, newValue in
                        toggleLaunchAtLogin(newValue)
                    }
            }
        }
        .formStyle(.grouped)
    }

    // MARK: - About Tab

    private var aboutTab: some View {
        VStack(spacing: 16) {
            Image(systemName: "clipboard")
                .font(.system(size: 48))
                .foregroundColor(.accentColor)

            Text("ClipboardSticky")
                .font(.title2)
                .fontWeight(.medium)

            Text("版本 1.0.0")
                .font(.caption)
                .foregroundColor(.secondary)

            Text("一个轻量的 macOS 剪贴板便利贴工具。\n在屏幕边缘驻留，随时记录和调用剪贴板历史。")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Helpers

    private func toggleLaunchAtLogin(_ enable: Bool) {
        do {
            if enable {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("Failed to toggle launch at login: \(error)")
        }
    }
}
