import AppKit

final class StatusBarController {
    private static let menuIconSize = NSSize(width: 16, height: 16)

    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let menu = NSMenu()
    private let cleanMenuItem = NSMenuItem(title: NSLocalizedString("menu.clean_clipboard", comment: "Menu item to clean clipboard"), action: #selector(clean), keyEquivalent: "")
    private var hotKeyObserver: NSObjectProtocol?

    init() {
        if let button = statusItem.button, let image = NSImage(named: "MenuIcon") {
            image.isTemplate = true
            image.size = Self.menuIconSize
            button.image = image
            button.imagePosition = .imageOnly
            button.imageScaling = .scaleProportionallyDown
            button.imageHugsTitle = false
        }

        cleanMenuItem.target = self
        menu.addItem(cleanMenuItem)
        applyCurrentHotKey()

        let preferencesItem = NSMenuItem(title: NSLocalizedString("menu.preferences", comment: "Menu item to open preferences"), action: #selector(openPreferences), keyEquivalent: ",")
        preferencesItem.keyEquivalentModifierMask = [.command]
        preferencesItem.target = self
        menu.addItem(preferencesItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: NSLocalizedString("menu.quit", comment: "Menu item to quit application"), action: #selector(quit), keyEquivalent: "")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu

        hotKeyObserver = NotificationCenter.default.addObserver(forName: .hotKeyDidChange, object: nil, queue: .main) { [weak self] notification in
            guard let hotKey = notification.object as? HotKey else { return }
            self?.updateCleanMenuShortcut(with: hotKey)
        }
    }

    @objc private func clean() {
        ClipboardCoordinator.cleanUsingPreferences()
    }

    @objc private func openPreferences() {
        PreferencesWindowController.shared.show()
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }

    deinit {
        if let observer = hotKeyObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    private func applyCurrentHotKey() {
        updateCleanMenuShortcut(with: HotKeyStore.shared.currentHotKey)
    }

    private func updateCleanMenuShortcut(with hotKey: HotKey) {
        cleanMenuItem.keyEquivalent = hotKey.menuKeyEquivalent
        cleanMenuItem.keyEquivalentModifierMask = hotKey.menuModifierFlags
        cleanMenuItem.title = NSLocalizedString("menu.clean_clipboard", comment: "Menu item to clean clipboard")
    }
}
