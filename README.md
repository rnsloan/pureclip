# PureClip

![PureClip logo](https://github.com/user-attachments/assets/bfb929d4-a228-4c63-9d7d-5c16a155e13d)

PureClip is a lightweight macOS menu-bar utility that converts the clipboard to plain text.

It keeps indentation intact, strips rich-text styling, and gives you a single hotkey to clean the clipboard before pasting into editors like Word or Outlook.

## Features
- Runs as a menu-bar app on macOS 13 Ventura or newer
- Cleans the clipboard to plain text while preserving line breaks and tabs
- Configurable global shortcut, Notifications, and detab mode: expand tabs to 2/4/8 spaces for code-friendly pastes
- Multiple language support: English, Spanish (Español), French (Français), German (Deutsch), Japanese (日本語), Chinese Simplified (简体中文)
- Zero external dependencies — built entirely with SwiftUI + AppKit

![Demo video](https://github.com/user-attachments/assets/805d94ed-1bb4-4a56-9d1b-4f68ede0ca7c)

## Installation

### Download Pre-built Release
1. Download the latest `PureClip.dmg` from [Releases](https://github.com/yourusername/PureClip/releases)
2. Open the DMG and drag PureClip to your Applications folder
3. **First launch**: Right-click PureClip and select "Open" (required due to unsigned app)
4. Click "Open" when prompted about an app from an unidentified developer

## Usage
- Access the app via the menu-bar icon
- Default hotkey: ⌥⌘V (change in Preferences…)
- Preferences allow you to:
  - Toggle notifications when the clipboard is cleaned
  - Choose whether to expand tabs (Off / 2 / 4 / 8 spaces)
  - Reassign the global shortcut or reset to default

## Build from Source

### For Development (GUI)
1. Ensure you have Xcode 15 (or newer) with Swift 5.9+
2. Clone this repository
3. Open `PureClip.xcodeproj` in Xcode
4. Select your Apple ID in Signing & Capabilities (Team dropdown)
5. Build and run (`⌘R`)

### For Distribution (Command Line)
```bash
# Build to a local directory
xcodebuild -project PureClip.xcodeproj -scheme PureClip -configuration Release \
  -derivedDataPath ./build clean build

# The app will be in: ./build/Build/Products/Release/PureClip.app
```

You can then drag `PureClip.app` to `/Applications` to install.

### Why "Unidentified Developer"?
PureClip is open-source and distributed without Apple Developer Program enrollment. macOS will show a warning on first launch. This is normal for unsigned apps. After the first "right-click → Open", the app will launch normally.

## Running Tests

The test target requires **macOS 14.0+** (while the app itself supports macOS 13.5+). This is because Xcode's XCTest framework requires macOS 14.

### In Xcode
```
⌘U (Command-U) to run all tests
```

### From Command Line
```bash
xcodebuild test \
  -project PureClip.xcodeproj \
  -scheme PureClip \
  -destination 'platform=macOS'
```

## Creating a Release DMG

1. **Update the version number**:
   - Open `PureClip.xcodeproj` in Xcode
   - Select the **PureClip** project in the navigator
   - Select the **PureClip** target
   - Go to the **General** tab → **Identity** section
   - Update **Version** (e.g., from `1.0` to `1.1`)
   - Update `CHANGELOG.md` with the new version and changes

2. **Install create-dmg** (one-time setup):
   ```bash
   brew install create-dmg
   ```

3. **Build the Release version**:
   ```bash
   xcodebuild -project PureClip.xcodeproj -scheme PureClip -configuration Release \
     -derivedDataPath ./build clean build
   ```

4. **Prepare a clean staging directory** (excludes debug symbols and build artifacts):
   ```bash
   rm -rf ./dmg-staging
   mkdir -p ./dmg-staging
   cp -R ./build/Build/Products/Release/PureClip.app ./dmg-staging/
   ```

5. **Create a DMG**:
   ```bash
   create-dmg \
     --volname "PureClip" \
     --volicon "Resources/AppIcon.icns" \
     --window-pos 200 120 \
     --window-size 600 400 \
     --icon-size 100 \
     --icon "PureClip.app" 175 190 \
     --hide-extension "PureClip.app" \
     --app-drop-link 425 190 \
     --no-internet-enable \
     "PureClip.dmg" \
     "./dmg-staging/"
   ```

6. **Clean up**:
   ```bash
   rm -rf ./dmg-staging
   ```

7. **Upload to GitHub Releases**:
   - Go to the repository's Releases page
   - Click "Draft a new release"
   - Tag version (e.g., `v1.0.0`)
   - Upload the `PureClip.dmg` file
   - Publish release

## Credits
- App icon by [Google Fonts Icons](https://fonts.google.com/icons) & [IconKitchen](https://icon.kitchen/)
- Created with [OpenAI Codex](https://openai.com/codex/) & [Claude Code](https://www.claude.com/product/claude-code)

## License
This project is released under the MIT License. See `LICENSE` for details.
