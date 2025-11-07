import SwiftUI

@main
struct PlainClipApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        Settings {
            SettingsView()
        }
    }
}

struct SettingsView: View {
    @AppStorage(UserDefaults.Keys.showNotification) private var showNotificationOnClean = false
    @State private var hotKey = HotKeyStore.shared.currentHotKey
    @State private var showingShortcutSheet = false
    @AppStorage(UserDefaults.Keys.detabMode) private var detabSelection = DetabMode.default.rawValue

    init() {
        HotKeyStore.shared.load()
        _hotKey = State(initialValue: HotKeyStore.shared.currentHotKey)
        if UserDefaults.standard.string(forKey: UserDefaults.Keys.detabMode) == nil {
            UserDefaults.standard.set(DetabMode.default.rawValue, forKey: UserDefaults.Keys.detabMode)
        }
    }

    private var appVersion: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        return String(format: NSLocalizedString("prefs.version", comment: "Version display format"), version)
    }

    var body: some View {
        Form {
            Section(NSLocalizedString("prefs.section.notifications", comment: "Notifications section header")) {
                Toggle(NSLocalizedString("prefs.notifications.toggle", comment: "Show notifications toggle"), isOn: $showNotificationOnClean)
                    .notificationAuthorization(on: $showNotificationOnClean)
            }

            Section(NSLocalizedString("prefs.section.keyboard_shortcut", comment: "Keyboard shortcut section header")) {
                HStack {
                    Text(NSLocalizedString("prefs.shortcut.current", comment: "Current shortcut label"))
                    Text(hotKey.displayString)
                        .font(.system(size: 14, weight: .semibold))
                    Spacer()
                    Button(NSLocalizedString("prefs.shortcut.reset", comment: "Reset shortcut button")) {
                        switch HotKeyStore.shared.updateHotKey(to: .default) {
                        case .success(let restored):
                            hotKey = restored
                        case .failure:
                            // Reset to default should always succeed, but guard just in case.
                            hotKey = HotKey.default
                        }
                    }
                    .keyboardShortcut("r", modifiers: [.command])
                    Button(NSLocalizedString("prefs.shortcut.change", comment: "Change shortcut button")) {
                        showingShortcutSheet = true
                    }
                }
                .controlSize(.small)
            }

            Section(NSLocalizedString("prefs.section.whitespace", comment: "Whitespace section header")) {
                Picker(NSLocalizedString("prefs.whitespace.tabs", comment: "Tabs picker label"), selection: $detabSelection) {
                    ForEach(DetabMode.allCases) { mode in
                        Text(mode.label).tag(mode.rawValue)
                    }
                }
                .pickerStyle(.radioGroup)
            }
        }
        .formStyle(.grouped)
        .frame(width: PreferencesWindowController.preferredWindowSize.width,
               height: PreferencesWindowController.preferredWindowSize.height)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .sheet(isPresented: $showingShortcutSheet) {
            ShortcutCaptureView(isPresented: $showingShortcutSheet) { newHotKey in
                hotKey = newHotKey
            }
        }
        .safeAreaInset(edge: .bottom) {
            Text(appVersion)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 8)
        }
    }
}

private extension View {
    func notificationAuthorization(on binding: Binding<Bool>) -> some View {
        modifier(NotificationAuthorizationModifier(isEnabled: binding))
    }
}

private struct NotificationAuthorizationModifier: ViewModifier {
    @Binding var isEnabled: Bool

    func body(content: Content) -> some View {
        if #available(macOS 14, *) {
            content.onChange(of: isEnabled, initial: false) { _, newValue in
                handleChange(newValue)
            }
        } else {
            content.onChange(of: isEnabled) { newValue in
                handleChange(newValue)
            }
        }
    }

    private func handleChange(_ newValue: Bool) {
        guard newValue else { return }

        NotificationDispatcher.requestAuthorization { granted in
            if !granted {
                DispatchQueue.main.async {
                    isEnabled = false
                }
            }
        }
    }
}
