import XCTest
import Carbon.HIToolbox
@testable import PureClip

final class HotKeyTests: XCTestCase {

    // MARK: - HotKey Initialization Tests

    func testHotKeyInitializationUppercasesKeyEquivalent() {
        let hotKey = HotKey(keyCode: UInt32(kVK_ANSI_V),
                           modifiers: UInt32(cmdKey),
                           keyEquivalent: "v")
        XCTAssertEqual(hotKey.keyEquivalent, "V")
    }

    func testHotKeyInitializationPreservesUppercase() {
        let hotKey = HotKey(keyCode: UInt32(kVK_ANSI_V),
                           modifiers: UInt32(cmdKey),
                           keyEquivalent: "V")
        XCTAssertEqual(hotKey.keyEquivalent, "V")
    }

    // MARK: - HotKey Equality Tests

    func testHotKeyEquality() {
        let hotKey1 = HotKey(keyCode: UInt32(kVK_ANSI_V),
                            modifiers: UInt32(cmdKey | optionKey),
                            keyEquivalent: "V")
        let hotKey2 = HotKey(keyCode: UInt32(kVK_ANSI_V),
                            modifiers: UInt32(cmdKey | optionKey),
                            keyEquivalent: "V")
        XCTAssertEqual(hotKey1, hotKey2)
    }

    func testHotKeyInequalityDifferentKey() {
        let hotKey1 = HotKey(keyCode: UInt32(kVK_ANSI_V),
                            modifiers: UInt32(cmdKey),
                            keyEquivalent: "V")
        let hotKey2 = HotKey(keyCode: UInt32(kVK_ANSI_C),
                            modifiers: UInt32(cmdKey),
                            keyEquivalent: "C")
        XCTAssertNotEqual(hotKey1, hotKey2)
    }

    func testHotKeyInequalityDifferentModifiers() {
        let hotKey1 = HotKey(keyCode: UInt32(kVK_ANSI_V),
                            modifiers: UInt32(cmdKey),
                            keyEquivalent: "V")
        let hotKey2 = HotKey(keyCode: UInt32(kVK_ANSI_V),
                            modifiers: UInt32(cmdKey | shiftKey),
                            keyEquivalent: "V")
        XCTAssertNotEqual(hotKey1, hotKey2)
    }

    // MARK: - HotKey Default Tests

    func testDefaultHotKey() {
        let defaultHotKey = HotKey.default
        XCTAssertEqual(defaultHotKey.keyCode, UInt32(kVK_ANSI_V))
        XCTAssertEqual(defaultHotKey.modifiers, UInt32(cmdKey | optionKey))
        XCTAssertEqual(defaultHotKey.keyEquivalent, "V")
    }

    // MARK: - HotKeyFormatter Display String Tests

    func testDisplayStringCommandOnly() {
        let hotKey = HotKey(keyCode: UInt32(kVK_ANSI_V),
                           modifiers: UInt32(cmdKey),
                           keyEquivalent: "V")
        XCTAssertEqual(hotKey.displayString, "⌘V")
    }

    func testDisplayStringOptionOnly() {
        let hotKey = HotKey(keyCode: UInt32(kVK_ANSI_V),
                           modifiers: UInt32(optionKey),
                           keyEquivalent: "V")
        XCTAssertEqual(hotKey.displayString, "⌥V")
    }

    func testDisplayStringShiftOnly() {
        let hotKey = HotKey(keyCode: UInt32(kVK_ANSI_V),
                           modifiers: UInt32(shiftKey),
                           keyEquivalent: "V")
        XCTAssertEqual(hotKey.displayString, "⇧V")
    }

    func testDisplayStringControlOnly() {
        let hotKey = HotKey(keyCode: UInt32(kVK_ANSI_V),
                           modifiers: UInt32(controlKey),
                           keyEquivalent: "V")
        XCTAssertEqual(hotKey.displayString, "⌃V")
    }

    func testDisplayStringCommandOption() {
        let hotKey = HotKey(keyCode: UInt32(kVK_ANSI_V),
                           modifiers: UInt32(cmdKey | optionKey),
                           keyEquivalent: "V")
        XCTAssertEqual(hotKey.displayString, "⌘⌥V")
    }

    func testDisplayStringCommandShift() {
        let hotKey = HotKey(keyCode: UInt32(kVK_ANSI_V),
                           modifiers: UInt32(cmdKey | shiftKey),
                           keyEquivalent: "V")
        XCTAssertEqual(hotKey.displayString, "⌘⇧V")
    }

    func testDisplayStringCommandControl() {
        let hotKey = HotKey(keyCode: UInt32(kVK_ANSI_V),
                           modifiers: UInt32(cmdKey | controlKey),
                           keyEquivalent: "V")
        XCTAssertEqual(hotKey.displayString, "⌘⌃V")
    }

    func testDisplayStringAllModifiers() {
        let hotKey = HotKey(keyCode: UInt32(kVK_ANSI_V),
                           modifiers: UInt32(cmdKey | optionKey | shiftKey | controlKey),
                           keyEquivalent: "V")
        XCTAssertEqual(hotKey.displayString, "⌘⌥⇧⌃V")
    }

    func testDisplayStringOptionShift() {
        let hotKey = HotKey(keyCode: UInt32(kVK_ANSI_V),
                           modifiers: UInt32(optionKey | shiftKey),
                           keyEquivalent: "V")
        XCTAssertEqual(hotKey.displayString, "⌥⇧V")
    }

    // MARK: - DisplayStrings Special Keys Tests

    func testDisplayStringSpace() {
        let hotKey = HotKey(keyCode: 49, // Space key code
                           modifiers: UInt32(cmdKey),
                           keyEquivalent: String(UnicodeScalar(0x20)!))
        XCTAssertEqual(hotKey.displayString, "⌘Space")
    }

    func testDisplayStringEscape() {
        let hotKey = HotKey(keyCode: 53, // Escape key code
                           modifiers: UInt32(cmdKey),
                           keyEquivalent: String(UnicodeScalar(0x1B)!))
        XCTAssertEqual(hotKey.displayString, "⌘Esc")
    }

    func testDisplayStringRegularLetter() {
        let hotKey = HotKey(keyCode: UInt32(kVK_ANSI_A),
                           modifiers: UInt32(cmdKey),
                           keyEquivalent: "A")
        XCTAssertEqual(hotKey.displayString, "⌘A")
    }

    func testDisplayStringNumber() {
        let hotKey = HotKey(keyCode: UInt32(kVK_ANSI_1),
                           modifiers: UInt32(cmdKey),
                           keyEquivalent: "1")
        XCTAssertEqual(hotKey.displayString, "⌘1")
    }

    // MARK: - Menu Key Equivalent Tests

#if canImport(AppKit)
    func testMenuKeyEquivalentLowercase() {
        let hotKey = HotKey(keyCode: UInt32(kVK_ANSI_V),
                           modifiers: UInt32(cmdKey),
                           keyEquivalent: "V")
        XCTAssertEqual(hotKey.menuKeyEquivalent, "v")
    }

    func testMenuKeyEquivalentEscape() {
        let hotKey = HotKey(keyCode: 53,
                           modifiers: UInt32(cmdKey),
                           keyEquivalent: String(UnicodeScalar(0x1B)!))
        XCTAssertEqual(hotKey.menuKeyEquivalent, String(UnicodeScalar(0x1B)!))
    }

    func testMenuModifierFlagsCommandOnly() {
        let hotKey = HotKey(keyCode: UInt32(kVK_ANSI_V),
                           modifiers: UInt32(cmdKey),
                           keyEquivalent: "V")
        XCTAssertTrue(hotKey.menuModifierFlags.contains(.command))
        XCTAssertFalse(hotKey.menuModifierFlags.contains(.option))
        XCTAssertFalse(hotKey.menuModifierFlags.contains(.shift))
        XCTAssertFalse(hotKey.menuModifierFlags.contains(.control))
    }

    func testMenuModifierFlagsAllModifiers() {
        let hotKey = HotKey(keyCode: UInt32(kVK_ANSI_V),
                           modifiers: UInt32(cmdKey | optionKey | shiftKey | controlKey),
                           keyEquivalent: "V")
        XCTAssertTrue(hotKey.menuModifierFlags.contains(.command))
        XCTAssertTrue(hotKey.menuModifierFlags.contains(.option))
        XCTAssertTrue(hotKey.menuModifierFlags.contains(.shift))
        XCTAssertTrue(hotKey.menuModifierFlags.contains(.control))
    }

    func testMenuModifierFlagsNoModifiers() {
        let hotKey = HotKey(keyCode: UInt32(kVK_ANSI_V),
                           modifiers: 0,
                           keyEquivalent: "V")
        XCTAssertFalse(hotKey.menuModifierFlags.contains(.command))
        XCTAssertFalse(hotKey.menuModifierFlags.contains(.option))
        XCTAssertFalse(hotKey.menuModifierFlags.contains(.shift))
        XCTAssertFalse(hotKey.menuModifierFlags.contains(.control))
    }
#endif

    // MARK: - HotKey Codable Tests

    func testHotKeyCodableRoundTrip() throws {
        let original = HotKey(keyCode: UInt32(kVK_ANSI_V),
                             modifiers: UInt32(cmdKey | optionKey),
                             keyEquivalent: "V")

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(HotKey.self, from: data)

        XCTAssertEqual(original, decoded)
    }

    func testHotKeyEncodedFormat() throws {
        let hotKey = HotKey(keyCode: UInt32(kVK_ANSI_V),
                           modifiers: UInt32(cmdKey | optionKey),
                           keyEquivalent: "V")

        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let data = try encoder.encode(hotKey)
        let jsonString = String(data: data, encoding: .utf8)

        XCTAssertNotNil(jsonString)
        XCTAssertTrue(jsonString!.contains("keyCode"))
        XCTAssertTrue(jsonString!.contains("modifiers"))
        XCTAssertTrue(jsonString!.contains("keyEquivalent"))
    }
}
