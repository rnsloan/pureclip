import Carbon.HIToolbox
import OSLog

final class HotKeyStore {
    static let shared = HotKeyStore()

    private(set) var currentHotKey: HotKey = .default
    private let logger = Logger(subsystem: "com.rnsloan.PureClip", category: "HotKeyStore")

    private var hotKeyRef: EventHotKeyRef?
    private var hotKeyID = EventHotKeyID(signature: OSType(0x50434C50), id: UInt32(1))
    private var action: (() -> Void)?
    private var eventHandler: EventHandlerRef?

    private init() {}

    func load() {
        guard let data = UserDefaults.standard.data(forKey: UserDefaults.Keys.hotKeyData) else {
            currentHotKey = .default
            return
        }

        if let decoded = try? JSONDecoder().decode(HotKey.self, from: data) {
            currentHotKey = decoded
        } else if let legacy = try? JSONDecoder().decode(LegacyHotKey.self, from: data) {
            currentHotKey = HotKey(keyCode: legacy.keyCode,
                                    modifiers: legacy.modifiers,
                                    keyEquivalent: legacy.keyEquivalent)
            persistCurrentHotKey()
            logger.debug("Migrated legacy hotkey data to current format")
        } else {
            logger.warning("Failed to decode stored hotkey data; resetting to default")
            currentHotKey = .default
            persistCurrentHotKey()
        }
    }

    func registerHotKey(action: @escaping () -> Void) {
        self.action = action
        installHandlerIfNeeded()

        if registerCarbonHotKey(currentHotKey) == false {
            logger.error("Failed to register stored shortcut; reverting to default")
            currentHotKey = .default
            persistCurrentHotKey()
            _ = registerCarbonHotKey(currentHotKey)
        }

        notifyChange()
    }

    @discardableResult
    func updateHotKey(to hotKey: HotKey) -> Result<HotKey, HotKeyStoreError> {
        let previous = currentHotKey

        guard registerCarbonHotKey(hotKey) else {
            logger.error("Carbon rejected shortcut: \(hotKey.displayString)")
            _ = registerCarbonHotKey(previous)
            return .failure(.registrationFailed)
        }

        currentHotKey = hotKey
        persistCurrentHotKey()
        notifyChange()
        return .success(hotKey)
    }

    private func registerCarbonHotKey(_ hotKey: HotKey) -> Bool {
        if let ref = hotKeyRef {
            UnregisterEventHotKey(ref)
            hotKeyRef = nil
        }

        let status = RegisterEventHotKey(hotKey.keyCode,
                                         hotKey.modifiers,
                                         hotKeyID,
                                         GetApplicationEventTarget(),
                                         0,
                                         &hotKeyRef)

        if status != noErr {
            hotKeyRef = nil
            return false
        }

        return true
    }

    private func installHandlerIfNeeded() {
        guard eventHandler == nil else { return }

        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard),
                                      eventKind: UInt32(kEventHotKeyPressed))

        let callback: EventHandlerUPP = { _, _, _ in
            HotKeyStore.shared.action?()
            return noErr
        }

        InstallEventHandler(GetApplicationEventTarget(), callback, 1, &eventType, nil, &eventHandler)
    }

    private func persistCurrentHotKey() {
        let data = try? JSONEncoder().encode(currentHotKey)
        UserDefaults.standard.set(data, forKey: UserDefaults.Keys.hotKeyData)
    }

    private func notifyChange() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .hotKeyDidChange, object: self.currentHotKey)
        }
    }
}

private extension HotKeyStore {
    struct LegacyHotKey: Codable {
        var keyCode: UInt32
        var modifiers: UInt32
        var keyEquivalent: String
    }
}

enum HotKeyStoreError: Error {
    case registrationFailed
}

extension Notification.Name {
    static let hotKeyDidChange = Notification.Name("com.rnsloan.PureClip.hotKeyDidChange")
}
