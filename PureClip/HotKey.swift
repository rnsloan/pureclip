import Carbon.HIToolbox
#if canImport(AppKit)
import AppKit
#endif

struct HotKey: Codable, Equatable {
    var keyCode: UInt32
    var modifiers: UInt32
    var keyEquivalent: String

    init(keyCode: UInt32, modifiers: UInt32, keyEquivalent: String) {
        self.keyCode = keyCode
        self.modifiers = modifiers
        self.keyEquivalent = keyEquivalent.uppercased()
    }

    static let `default` = HotKey(keyCode: UInt32(kVK_ANSI_V),
                                  modifiers: UInt32(cmdKey | optionKey),
                                  keyEquivalent: "V")

    var displayString: String {
        HotKeyFormatter.string(from: self)
    }

#if canImport(AppKit)
    var menuKeyEquivalent: String {
        if let scalar = keyEquivalent.unicodeScalars.first, scalar.value == 0x1B {
            return String(scalar)
        }
        return keyEquivalent.lowercased()
    }

    var menuModifierFlags: NSEvent.ModifierFlags {
        var flags: NSEvent.ModifierFlags = []
        if modifiers & UInt32(cmdKey) != 0 { flags.insert(.command) }
        if modifiers & UInt32(optionKey) != 0 { flags.insert(.option) }
        if modifiers & UInt32(shiftKey) != 0 { flags.insert(.shift) }
        if modifiers & UInt32(controlKey) != 0 { flags.insert(.control) }
        return flags
    }
#endif
}

enum HotKeyFormatter {
    static func string(from hotKey: HotKey) -> String {
        var components: [String] = []

        if hotKey.modifiers & UInt32(cmdKey) != 0 { components.append("⌘") }
        if hotKey.modifiers & UInt32(optionKey) != 0 { components.append("⌥") }
        if hotKey.modifiers & UInt32(shiftKey) != 0 { components.append("⇧") }
        if hotKey.modifiers & UInt32(controlKey) != 0 { components.append("⌃") }

        components.append(DisplayStrings.display(for: hotKey.keyEquivalent))

        return components.joined()
    }
}

enum DisplayStrings {
    static func display(for keyEquivalent: String) -> String {
        guard let scalar = keyEquivalent.unicodeScalars.first else { return keyEquivalent }
        switch scalar.value {
        case 0x20: return NSLocalizedString("key.space", comment: "Space key name")
        case 0x1B: return NSLocalizedString("key.esc", comment: "Escape key name")
        default:
            return keyEquivalent.uppercased()
        }
    }
}
