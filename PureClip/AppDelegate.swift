import AppKit
import Carbon.HIToolbox

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBarController: StatusBarController!

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusBarController = StatusBarController()

        HotKeyStore.shared.load()
        HotKeyStore.shared.registerHotKey { [weak self] in
            self?.cleanClipboard()
        }
    }

    private func cleanClipboard() {
        ClipboardCoordinator.cleanUsingPreferences()
    }
}
