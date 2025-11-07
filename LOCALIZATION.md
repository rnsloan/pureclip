# Localization

## Overview

PureClip has full localization support with English as the base language. All user-facing strings are externalized to `Localizable.strings`, making it easy to add translations for other languages in the future.

## Supported Languages

English, Spanish (Español), French (Français), German (Deutsch), Japanese (日本語), Chinese Simplified (简体中文).

## Adding a New Language

To add support for another language:

### 1. In Xcode:
1. Select the **PureClip** project in the navigator
2. Go to the **Info** tab
3. Under **Localizations**, click **+**
4. Select the language (e.g., "Spanish")
5. Make sure `Localizable.strings` is checked
6. Click **Finish**

### 2. Translate Strings:
Xcode will create `PureClip/es.lproj/Localizable.strings` (for Spanish). Open it and translate each string:

```
/* Menu Bar Items */
"menu.clean_clipboard" = "Limpiar Portapapeles";
"menu.preferences" = "Preferencias…";
"menu.quit" = "Salir de PureClip";
```

### 3. Test:
- Change your Mac's system language to test
- Or use Xcode's scheme editor to test specific localizations


## Key Implementation Details

### NSLocalizedString Pattern

All strings use this pattern:
```swift
NSLocalizedString("key.name", comment: "Description for translators")
```

Example:
```swift
Button(NSLocalizedString("prefs.shortcut.change", comment: "Change shortcut button"))
```

### String Format with Variables

For strings with variables (like version):
```swift
String(format: NSLocalizedString("prefs.version", comment: "Version display format"), version)
```

In `Localizable.strings`:
```
"prefs.version" = "PureClip v%@";
```

## Modified Files

### Swift Files Updated:
- `StatusBarController.swift` - Menu items
- `PlainClipApp.swift` - Preferences UI
- `PreferencesWindowController.swift` - Window title
- `ShortcutCaptureView.swift` - Capture UI and errors
- `DetabMode.swift` - Mode labels
- `HotKey.swift` - Special key names
- `NotificationDispatcher.swift` - Notification content

### Project Configuration:
- Already configured for localization (`developmentRegion = en`, `knownRegions = (en, Base)`)
- Uses `PBXFileSystemSynchronizedRootGroup` - automatically discovers `.lproj` folders

## String Key Naming Convention

Keys follow a hierarchical dot-notation:

- `menu.*` - Menu bar items
- `prefs.*` - Preferences window
  - `prefs.section.*` - Section headers
  - `prefs.notifications.*` - Notifications section
  - `prefs.shortcut.*` - Keyboard shortcut section
  - `prefs.whitespace.*` - Whitespace section
- `shortcut_capture.*` - Shortcut capture view
  - `shortcut_capture.error.*` - Error messages
- `detab.*` - Tab expansion modes
- `key.*` - Special key names
- `notification.*` - System notifications

## Testing Localization

### Manual Testing:
1. Change Mac system language in System Settings
2. Launch app and verify all text displays correctly
3. Test all UI interactions

### Export/Import for Translation:
```bash
# Export strings for translation (generates XLIFF file)
xcodebuild -exportLocalizations -project PureClip.xcodeproj -localizationPath ./Localizations

# Import translated strings
xcodebuild -importLocalizations -project PureClip.xcodeproj -localizationPath ./Localizations/es.xliff
```
---

[Apple Localization Guide](https://developer.apple.com/localization/)
