import XCTest
@testable import PureClip

final class DetabModeTests: XCTestCase {

    // MARK: - Tab Width Tests

    func testOffModeTabWidth() {
        XCTAssertEqual(DetabMode.off.tabWidth, 0)
    }

    func testTwoModeTabWidth() {
        XCTAssertEqual(DetabMode.two.tabWidth, 2)
    }

    func testFourModeTabWidth() {
        XCTAssertEqual(DetabMode.four.tabWidth, 4)
    }

    func testEightModeTabWidth() {
        XCTAssertEqual(DetabMode.eight.tabWidth, 8)
    }

    // MARK: - Label Tests

    func testOffModeLabel() {
        XCTAssertEqual(DetabMode.off.label, "Leave tabs as-is")
    }

    func testTwoModeLabel() {
        XCTAssertEqual(DetabMode.two.label, "Expand tabs to 2 spaces")
    }

    func testFourModeLabel() {
        XCTAssertEqual(DetabMode.four.label, "Expand tabs to 4 spaces")
    }

    func testEightModeLabel() {
        XCTAssertEqual(DetabMode.eight.label, "Expand tabs to 8 spaces")
    }

    // MARK: - Raw Value Tests

    func testOffModeRawValue() {
        XCTAssertEqual(DetabMode.off.rawValue, "off")
    }

    func testTwoModeRawValue() {
        XCTAssertEqual(DetabMode.two.rawValue, "two")
    }

    func testFourModeRawValue() {
        XCTAssertEqual(DetabMode.four.rawValue, "four")
    }

    func testEightModeRawValue() {
        XCTAssertEqual(DetabMode.eight.rawValue, "eight")
    }

    // MARK: - Initialization from Raw Value Tests

    func testInitFromRawValueOff() {
        let mode = DetabMode(rawValue: "off")
        XCTAssertEqual(mode, .off)
    }

    func testInitFromRawValueTwo() {
        let mode = DetabMode(rawValue: "two")
        XCTAssertEqual(mode, .two)
    }

    func testInitFromRawValueFour() {
        let mode = DetabMode(rawValue: "four")
        XCTAssertEqual(mode, .four)
    }

    func testInitFromRawValueEight() {
        let mode = DetabMode(rawValue: "eight")
        XCTAssertEqual(mode, .eight)
    }

    func testInitFromInvalidRawValue() {
        let mode = DetabMode(rawValue: "invalid")
        XCTAssertNil(mode)
    }

    // MARK: - Default Value Test

    func testDefaultMode() {
        XCTAssertEqual(DetabMode.default, .off)
    }

    // MARK: - Identifiable Protocol Tests

    func testIdentifiableId() {
        XCTAssertEqual(DetabMode.off.id, "off")
        XCTAssertEqual(DetabMode.two.id, "two")
        XCTAssertEqual(DetabMode.four.id, "four")
        XCTAssertEqual(DetabMode.eight.id, "eight")
    }

    // MARK: - CaseIterable Tests

    func testAllCases() {
        let allCases = DetabMode.allCases
        XCTAssertEqual(allCases.count, 4)
        XCTAssertTrue(allCases.contains(.off))
        XCTAssertTrue(allCases.contains(.two))
        XCTAssertTrue(allCases.contains(.four))
        XCTAssertTrue(allCases.contains(.eight))
    }

    func testAllCasesOrder() {
        let allCases = DetabMode.allCases
        XCTAssertEqual(allCases[0], .off)
        XCTAssertEqual(allCases[1], .two)
        XCTAssertEqual(allCases[2], .four)
        XCTAssertEqual(allCases[3], .eight)
    }

    // MARK: - Equality Tests

    func testEquality() {
        XCTAssertEqual(DetabMode.off, DetabMode.off)
        XCTAssertEqual(DetabMode.two, DetabMode.two)
        XCTAssertEqual(DetabMode.four, DetabMode.four)
        XCTAssertEqual(DetabMode.eight, DetabMode.eight)
    }

    func testInequality() {
        XCTAssertNotEqual(DetabMode.off, DetabMode.two)
        XCTAssertNotEqual(DetabMode.two, DetabMode.four)
        XCTAssertNotEqual(DetabMode.four, DetabMode.eight)
    }

    // MARK: - Integration Test with ClipboardCleaner

    func testDetabModeIntegrationOff() {
        let mode = DetabMode.off
        let input = "\ttest"
        let output = ClipboardCleaner.normalise(input, detab: mode != .off, tabWidth: mode.tabWidth)
        XCTAssertEqual(output, "\ttest")
    }

    func testDetabModeIntegrationTwo() {
        let mode = DetabMode.two
        let input = "\ttest"
        let output = ClipboardCleaner.normalise(input, detab: mode != .off, tabWidth: mode.tabWidth)
        XCTAssertEqual(output, "  test")
    }

    func testDetabModeIntegrationFour() {
        let mode = DetabMode.four
        let input = "\ttest"
        let output = ClipboardCleaner.normalise(input, detab: mode != .off, tabWidth: mode.tabWidth)
        XCTAssertEqual(output, "    test")
    }

    func testDetabModeIntegrationEight() {
        let mode = DetabMode.eight
        let input = "\ttest"
        let output = ClipboardCleaner.normalise(input, detab: mode != .off, tabWidth: mode.tabWidth)
        XCTAssertEqual(output, "        test")
    }
}
