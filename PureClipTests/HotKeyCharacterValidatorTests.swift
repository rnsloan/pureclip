import XCTest
import Carbon.HIToolbox
@testable import PureClip

final class HotKeyCharacterValidatorTests: XCTestCase {

    // MARK: - Escape Key Tests

    func testEscapeWithModifiers() {
        let escapeScalar = UnicodeScalar(0x1B)!
        XCTAssertTrue(HotKeyCharacterValidator.isSupported(escapeScalar, modifiers: UInt32(cmdKey)))
    }

    func testEscapeWithMultipleModifiers() {
        let escapeScalar = UnicodeScalar(0x1B)!
        XCTAssertTrue(HotKeyCharacterValidator.isSupported(escapeScalar, modifiers: UInt32(cmdKey | optionKey)))
    }

    // MARK: - Space Key Tests

    func testSpaceIsSupported() {
        let spaceScalar = UnicodeScalar(0x20)!
        XCTAssertTrue(HotKeyCharacterValidator.isSupported(spaceScalar, modifiers: UInt32(cmdKey)))
    }

    func testSpaceWithNoModifiers() {
        let spaceScalar = UnicodeScalar(0x20)!
        XCTAssertTrue(HotKeyCharacterValidator.isSupported(spaceScalar, modifiers: 0))
    }

    // MARK: - Printable ASCII Tests

    func testLettersAreSupported() {
        // Test lowercase
        for char in "abcdefghijklmnopqrstuvwxyz" {
            let scalar = char.unicodeScalars.first!
            XCTAssertTrue(HotKeyCharacterValidator.isSupported(scalar, modifiers: UInt32(cmdKey)),
                         "Lowercase letter '\(char)' should be supported")
        }

        // Test uppercase
        for char in "ABCDEFGHIJKLMNOPQRSTUVWXYZ" {
            let scalar = char.unicodeScalars.first!
            XCTAssertTrue(HotKeyCharacterValidator.isSupported(scalar, modifiers: UInt32(cmdKey)),
                         "Uppercase letter '\(char)' should be supported")
        }
    }

    func testNumbersAreSupported() {
        for char in "0123456789" {
            let scalar = char.unicodeScalars.first!
            XCTAssertTrue(HotKeyCharacterValidator.isSupported(scalar, modifiers: UInt32(cmdKey)),
                         "Number '\(char)' should be supported")
        }
    }

    func testCommonSymbolsAreSupported() {
        let symbols = "!@#$%^&*()-=_+[]{}\\|;:'\",.<>/?`~"
        for char in symbols {
            let scalar = char.unicodeScalars.first!
            XCTAssertTrue(HotKeyCharacterValidator.isSupported(scalar, modifiers: UInt32(cmdKey)),
                         "Symbol '\(char)' should be supported")
        }
    }

    // MARK: - ASCII Boundary Tests

    func testFirstPrintableASCII() {
        // 0x21 is '!'
        let scalar = UnicodeScalar(0x21)!
        XCTAssertTrue(HotKeyCharacterValidator.isSupported(scalar, modifiers: UInt32(cmdKey)))
    }

    func testLastPrintableASCII() {
        // 0x7E is '~'
        let scalar = UnicodeScalar(0x7E)!
        XCTAssertTrue(HotKeyCharacterValidator.isSupported(scalar, modifiers: UInt32(cmdKey)))
    }

    func testJustBeforePrintableRange() {
        // 0x20 is space, which is explicitly supported
        let scalar = UnicodeScalar(0x20)!
        XCTAssertTrue(HotKeyCharacterValidator.isSupported(scalar, modifiers: UInt32(cmdKey)))
    }

    func testJustAfterPrintableRange() {
        // 0x7F is DEL (not supported)
        let scalar = UnicodeScalar(0x7F)!
        XCTAssertFalse(HotKeyCharacterValidator.isSupported(scalar, modifiers: UInt32(cmdKey)))
    }

    // MARK: - Unsupported Character Tests

    func testNonPrintableASCII() {
        // Control characters (0x00-0x1F except escape)
        for value in 0x00...0x1F where value != 0x1B {
            if let scalar = UnicodeScalar(value) {
                XCTAssertFalse(HotKeyCharacterValidator.isSupported(scalar, modifiers: UInt32(cmdKey)),
                              "Control character \\u{\(String(format:"%02X", value))} should not be supported")
            }
        }
    }

    func testUnicodeCharactersNotSupported() {
        let unicodeChars = "é中文🌍"
        for char in unicodeChars {
            let scalar = char.unicodeScalars.first!
            XCTAssertFalse(HotKeyCharacterValidator.isSupported(scalar, modifiers: UInt32(cmdKey)),
                          "Unicode character '\(char)' should not be supported")
        }
    }

    func testExtendedASCIINotSupported() {
        // Characters beyond basic ASCII (>0x7F)
        for value in [0x80, 0x90, 0xA0, 0xFF] {
            if let scalar = UnicodeScalar(value) {
                XCTAssertFalse(HotKeyCharacterValidator.isSupported(scalar, modifiers: UInt32(cmdKey)),
                              "Extended ASCII character \\u{\(String(format:"%02X", value))} should not be supported")
            }
        }
    }

    // MARK: - Modifier Combinations Tests

    func testSupportedWithDifferentModifiers() {
        let vScalar = UnicodeScalar("V")

        XCTAssertTrue(HotKeyCharacterValidator.isSupported(vScalar, modifiers: UInt32(cmdKey)))
        XCTAssertTrue(HotKeyCharacterValidator.isSupported(vScalar, modifiers: UInt32(optionKey)))
        XCTAssertTrue(HotKeyCharacterValidator.isSupported(vScalar, modifiers: UInt32(shiftKey)))
        XCTAssertTrue(HotKeyCharacterValidator.isSupported(vScalar, modifiers: UInt32(controlKey)))
        XCTAssertTrue(HotKeyCharacterValidator.isSupported(vScalar, modifiers: UInt32(cmdKey | optionKey)))
        XCTAssertTrue(HotKeyCharacterValidator.isSupported(vScalar, modifiers: UInt32(cmdKey | shiftKey)))
    }

    func testNoModifiersStillSupportsASCII() {
        let aScalar = UnicodeScalar("A")
        // With no modifiers, regular ASCII is still valid
        XCTAssertTrue(HotKeyCharacterValidator.isSupported(aScalar, modifiers: 0))
    }

    // MARK: - Edge Cases

    func testEmptyModifiers() {
        let vScalar = UnicodeScalar("V")
        XCTAssertTrue(HotKeyCharacterValidator.isSupported(vScalar, modifiers: 0))
    }

    func testAllModifiersCombined() {
        let vScalar = UnicodeScalar("V")
        let allModifiers = UInt32(cmdKey | optionKey | shiftKey | controlKey)
        XCTAssertTrue(HotKeyCharacterValidator.isSupported(vScalar, modifiers: allModifiers))
    }

    // MARK: - Real-World Shortcut Examples

    func testCommandV() {
        let vScalar = UnicodeScalar("V")
        XCTAssertTrue(HotKeyCharacterValidator.isSupported(vScalar, modifiers: UInt32(cmdKey)))
    }

    func testCommandOptionV() {
        let vScalar = UnicodeScalar("V")
        XCTAssertTrue(HotKeyCharacterValidator.isSupported(vScalar, modifiers: UInt32(cmdKey | optionKey)))
    }

    func testShiftCommandV() {
        let vScalar = UnicodeScalar("V")
        XCTAssertTrue(HotKeyCharacterValidator.isSupported(vScalar, modifiers: UInt32(shiftKey | cmdKey)))
    }

    func testControlOptionCommandC() {
        let cScalar = UnicodeScalar("C")
        XCTAssertTrue(HotKeyCharacterValidator.isSupported(cScalar, modifiers: UInt32(controlKey | optionKey | cmdKey)))
    }

    func testCommandComma() {
        let commaScalar = UnicodeScalar(",")
        XCTAssertTrue(HotKeyCharacterValidator.isSupported(commaScalar, modifiers: UInt32(cmdKey)))
    }

    func testCommandNumber() {
        let oneScalar = UnicodeScalar("1")
        XCTAssertTrue(HotKeyCharacterValidator.isSupported(oneScalar, modifiers: UInt32(cmdKey)))
    }
}
