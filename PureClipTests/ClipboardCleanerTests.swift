import XCTest
@testable import PureClip

final class ClipboardCleanerTests: XCTestCase {

    // MARK: - Line Ending Normalization Tests

    func testNormaliseConvertsWindowsLineEndings() {
        let input = "line1\r\nline2\r\nline3"
        let output = ClipboardCleaner.normalise(input, detab: false, tabWidth: 4)
        XCTAssertEqual(output, "line1\nline2\nline3")
    }

    func testNormaliseConvertsClassicMacLineEndings() {
        let input = "line1\rline2\rline3"
        let output = ClipboardCleaner.normalise(input, detab: false, tabWidth: 4)
        XCTAssertEqual(output, "line1\nline2\nline3")
    }

    func testNormaliseMixedLineEndings() {
        let input = "line1\r\nline2\rline3\nline4"
        let output = ClipboardCleaner.normalise(input, detab: false, tabWidth: 4)
        XCTAssertEqual(output, "line1\nline2\nline3\nline4")
    }

    func testNormalisePreservesUnixLineEndings() {
        let input = "line1\nline2\nline3"
        let output = ClipboardCleaner.normalise(input, detab: false, tabWidth: 4)
        XCTAssertEqual(output, "line1\nline2\nline3")
    }

    // MARK: - Invisible Character Tests

    func testNormaliseReplacesNBSP() {
        let input = "hello\u{00A0}world"
        let output = ClipboardCleaner.normalise(input, detab: false, tabWidth: 4)
        XCTAssertEqual(output, "hello world")
    }

    func testNormaliseRemovesZeroWidthSpace() {
        let input = "hello\u{200B}world"
        let output = ClipboardCleaner.normalise(input, detab: false, tabWidth: 4)
        XCTAssertEqual(output, "helloworld")
    }

    func testNormaliseRemovesZeroWidthNonJoiner() {
        let input = "hello\u{200C}world"
        let output = ClipboardCleaner.normalise(input, detab: false, tabWidth: 4)
        XCTAssertEqual(output, "helloworld")
    }

    func testNormaliseRemovesZeroWidthJoiner() {
        let input = "hello\u{200D}world"
        let output = ClipboardCleaner.normalise(input, detab: false, tabWidth: 4)
        XCTAssertEqual(output, "helloworld")
    }

    func testNormaliseHandlesMultipleInvisibleCharacters() {
        let input = "hello\u{00A0}\u{200B}world\u{200C}test\u{200D}end"
        let output = ClipboardCleaner.normalise(input, detab: false, tabWidth: 4)
        XCTAssertEqual(output, "hello worldtestend")
    }

    // MARK: - Tab Expansion Tests (Detab Off)

    func testDetabOffPreservesSingleTab() {
        let input = "\tindented"
        let output = ClipboardCleaner.normalise(input, detab: false, tabWidth: 4)
        XCTAssertEqual(output, "\tindented")
    }

    func testDetabOffPreservesMultipleTabs() {
        let input = "\t\t\tdeeply indented"
        let output = ClipboardCleaner.normalise(input, detab: false, tabWidth: 4)
        XCTAssertEqual(output, "\t\t\tdeeply indented")
    }

    func testDetabOffPreservesTabsInMiddle() {
        let input = "hello\tworld\ttest"
        let output = ClipboardCleaner.normalise(input, detab: false, tabWidth: 4)
        XCTAssertEqual(output, "hello\tworld\ttest")
    }

    // MARK: - Tab Expansion Tests (Detab On)

    func testDetabConvertsTabToTwoSpaces() {
        let input = "\tindented"
        let output = ClipboardCleaner.normalise(input, detab: true, tabWidth: 2)
        XCTAssertEqual(output, "  indented")
    }

    func testDetabConvertsTabToFourSpaces() {
        let input = "\tindented"
        let output = ClipboardCleaner.normalise(input, detab: true, tabWidth: 4)
        XCTAssertEqual(output, "    indented")
    }

    func testDetabConvertsTabToEightSpaces() {
        let input = "\tindented"
        let output = ClipboardCleaner.normalise(input, detab: true, tabWidth: 8)
        XCTAssertEqual(output, "        indented")
    }

    func testDetabConvertsMultipleTabs() {
        let input = "\t\t\tdeeply indented"
        let output = ClipboardCleaner.normalise(input, detab: true, tabWidth: 4)
        XCTAssertEqual(output, "            deeply indented")
    }

    func testDetabConvertsTabsInMiddleOfString() {
        let input = "hello\tworld\ttest"
        let output = ClipboardCleaner.normalise(input, detab: true, tabWidth: 4)
        XCTAssertEqual(output, "hello    world    test")
    }

    func testDetabHandlesMinimumWidth() {
        // Test that max(1, tabWidth) ensures at least one space
        let input = "\tindented"
        let output = ClipboardCleaner.normalise(input, detab: true, tabWidth: 0)
        XCTAssertEqual(output, " indented")
    }

    // MARK: - Combined Normalization Tests

    func testNormaliseHandlesAllTransformations() {
        // Windows line endings + NBSP + tabs
        let input = "line1\u{00A0}test\r\nline2\t\tindented\r\n"
        let output = ClipboardCleaner.normalise(input, detab: true, tabWidth: 4)
        XCTAssertEqual(output, "line1 test\nline2        indented\n")
    }

    func testNormalisePreservesEmptyString() {
        let input = ""
        let output = ClipboardCleaner.normalise(input, detab: false, tabWidth: 4)
        XCTAssertEqual(output, "")
    }

    func testNormaliseHandlesOnlyWhitespace() {
        let input = "   \t   \n   "
        let output = ClipboardCleaner.normalise(input, detab: true, tabWidth: 4)
        XCTAssertEqual(output, "          \n   ") // 3 spaces + 4 (tab) + 3 spaces = 10 spaces
    }

    func testNormalisePreservesRegularSpaces() {
        let input = "hello    world    with    spaces"
        let output = ClipboardCleaner.normalise(input, detab: false, tabWidth: 4)
        XCTAssertEqual(output, "hello    world    with    spaces")
    }

    // MARK: - Edge Cases

    func testNormaliseHandlesUnicodeCharacters() {
        let input = "Hello 世界 🌍 Привет"
        let output = ClipboardCleaner.normalise(input, detab: false, tabWidth: 4)
        XCTAssertEqual(output, "Hello 世界 🌍 Привет")
    }

    func testNormaliseHandlesVeryLongString() {
        let input = String(repeating: "test\t", count: 1000)
        let output = ClipboardCleaner.normalise(input, detab: true, tabWidth: 4)
        let expected = String(repeating: "test    ", count: 1000)
        XCTAssertEqual(output, expected)
    }

    func testNormaliseHandlesMultipleConsecutiveNBSP() {
        let input = "test\u{00A0}\u{00A0}\u{00A0}end"
        let output = ClipboardCleaner.normalise(input, detab: false, tabWidth: 4)
        XCTAssertEqual(output, "test   end")
    }
}
