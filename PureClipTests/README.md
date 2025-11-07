# PureClip Unit Tests

This directory contains comprehensive unit tests for PureClip's core functionality.

## Test Coverage

### ClipboardCleanerTests.swift
Tests the core text normalization logic:
- ✅ Line ending conversion (Windows `\r\n`, Classic Mac `\r`, Unix `\n`)
- ✅ Invisible character handling (NBSP, zero-width spaces)
- ✅ Tab expansion with various widths (2, 4, 8 spaces)
- ✅ Combined transformations
- ✅ Edge cases (empty strings, Unicode, very long strings)

**29 tests** covering all normalization scenarios

### HotKeyTests.swift
Tests hotkey model and display formatting:
- ✅ HotKey initialization and equality
- ✅ Display string formatting (⌘⌥⇧⌃ symbols)
- ✅ Special key handling (Space, Escape)
- ✅ Menu key equivalent conversion
- ✅ Modifier flag mapping
- ✅ Codable serialization

**24 tests** covering hotkey functionality

### DetabModeTests.swift
Tests the detab mode enumeration:
- ✅ Tab width calculations
- ✅ Display labels
- ✅ Raw value conversions
- ✅ Protocol conformance (Identifiable, CaseIterable)
- ✅ Integration with ClipboardCleaner

**21 tests** covering all enum cases

### HotKeyCharacterValidatorTests.swift
Tests keyboard shortcut character validation:
- ✅ Printable ASCII support (letters, numbers, symbols)
- ✅ Special keys (Escape, Space)
- ✅ Modifier combinations
- ✅ Unsupported characters (Unicode, control chars)
- ✅ Real-world shortcut examples

**22 tests** covering validation logic

## Total Test Count

**96 unit tests** providing comprehensive coverage of core functionality.

## Adding Tests to Xcode

The test files have been created but need to be added to your Xcode project:

### Step 1: Create Test Target

1. Open `PureClip.xcodeproj` in Xcode
2. Select the project in the navigator
3. Click the **+** button at the bottom of the Targets list
4. Choose **Unit Testing Bundle**
5. Name it: `PureClipTests`
6. Set **Product Name**: `PureClipTests`
7. Set **Team**: Your Apple ID
8. Click **Finish**

### Step 2: Add Test Files

1. In Xcode's Project Navigator, right-click the `PureClipTests` group
2. Select **Add Files to "PureClip"...**
3. Navigate to `PureClip/PureClipTests/`
4. Select all `.swift` test files:
   - `ClipboardCleanerTests.swift`
   - `HotKeyTests.swift`
   - `DetabModeTests.swift`
   - `HotKeyCharacterValidatorTests.swift`
5. **Important**: Check **Add to targets:** `PureClipTests`
6. Click **Add**

### Step 3: Configure Test Target

1. Select the `PureClipTests` target
2. Go to **Build Phases** tab
3. Expand **Compile Sources** - verify all test files are listed
4. Go to **General** tab
5. Under **Frameworks and Libraries**, ensure the test target can access `PureClip.app`

### Step 4: Make Code Testable

For tests to access internal code, you need to enable testability:

1. Select the **PureClip** target (main app)
2. Go to **Build Settings** tab
3. Search for "testability"
4. Set **Enable Testability** to **Yes** for both Debug and Release

This allows `@testable import PureClip` to access internal types.

### Step 5: Run Tests

Run all tests:
```
⌘U (Command-U)
```

Or via menu:
```
Product → Test
```

Run individual test files:
- Click the diamond icon next to the test class
- Or click diamonds next to individual test methods

## Running Tests from Command Line

```bash
# Run all tests
xcodebuild test \
  -project PureClip.xcodeproj \
  -scheme PureClip \
  -destination 'platform=macOS'

# Run specific test class
xcodebuild test \
  -project PureClip.xcodeproj \
  -scheme PureClip \
  -destination 'platform=macOS' \
  -only-testing:PureClipTests/ClipboardCleanerTests

# Run specific test method
xcodebuild test \
  -project PureClip.xcodeproj \
  -scheme PureClip \
  -destination 'platform=macOS' \
  -only-testing:PureClipTests/ClipboardCleanerTests/testNormaliseConvertsWindowsLineEndings
```

## Test Organization

Tests are organized to match the structure of the main codebase:

```
PureClipTests/
├── ClipboardCleanerTests.swift    # Tests ClipboardCleaner.swift
├── HotKeyTests.swift              # Tests HotKey.swift + HotKeyFormatter
├── DetabModeTests.swift           # Tests DetabMode.swift
└── HotKeyCharacterValidatorTests.swift  # Tests validation in ShortcutCaptureView.swift
```

## Writing New Tests

When adding new functionality to PureClip:

1. **Add tests first** (TDD approach) or alongside implementation
2. **Follow naming conventions**: `test[MethodName][Scenario][ExpectedResult]`
3. **Test edge cases**: empty strings, nil values, boundary conditions
4. **Test error handling**: ensure errors are properly handled
5. **Keep tests focused**: one assertion per test when possible

Example:
```swift
func testNormaliseConvertsWindowsLineEndings() {
    // Arrange
    let input = "line1\r\nline2"

    // Act
    let output = ClipboardCleaner.normalise(input, detab: false, tabWidth: 4)

    // Assert
    XCTAssertEqual(output, "line1\nline2")
}
```

## CI/CD Integration

To run tests in GitHub Actions, add to `.github/workflows/test.yml`:

```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run tests
        run: |
          xcodebuild test \
            -project PureClip.xcodeproj \
            -scheme PureClip \
            -destination 'platform=macOS'
```

## Notes

- **ClipboardCleaner.normalise()** is `private` but tests can access it via `@testable import`
- Tests cover **pure functions** which are easiest to test
- UI components (StatusBarController, PreferencesWindowController) are not tested yet
- Future: Add integration tests for full clipboard workflow
- Future: Add UI tests using XCUITest

## Troubleshooting

**"Use of unresolved identifier 'PureClip'"**
- Ensure **Enable Testability** is set to **Yes** in PureClip target Build Settings
- Verify `@testable import PureClip` is at the top of test files

**Tests not running**
- Verify test files are added to `PureClipTests` target (not `PureClip` target)
- Check **Build Phases** → **Compile Sources** in test target

**"No such module 'PureClip'"**
- Build the main app first (⌘B)
- Clean build folder (⌘⇧K) and rebuild

**Carbon imports not found**
- The tests import Carbon for hotkey constants
- This is expected and matches the main app's dependencies
