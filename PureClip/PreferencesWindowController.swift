import AppKit
import SwiftUI

@MainActor
final class PreferencesWindowController {
    static let shared = PreferencesWindowController()
    static let preferredWindowSize = NSSize(width: 420, height: 300)

    private var windowController: NSWindowController?

    private init() {}

    func show() {
        if windowController == nil {
            windowController = makeWindowController()
        }

        guard let controller = windowController else { return }
        controller.showWindow(nil)
        controller.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func makeWindowController() -> NSWindowController {
        let hostingController = NSHostingController(rootView: SettingsView())
        let window = NSWindow(contentViewController: hostingController)
        window.title = NSLocalizedString("prefs.window_title", comment: "Preferences window title")
        window.styleMask = [.titled, .closable, .miniaturizable]
        window.setContentSize(Self.preferredWindowSize)
        window.center()
        window.isReleasedWhenClosed = false
        return NSWindowController(window: window)
    }
}
