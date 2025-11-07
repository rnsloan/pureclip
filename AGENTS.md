# PureClip – Agent Guide

This document is for contributors/agents who may need to troubleshoot or extend the project. The app is considered feature-complete; use this as a quick reference for architecture, build steps, and future considerations.

## Overview
- **Type:** macOS menu-bar utility (LSUIElement = YES)
- **Target:** macOS 13+ (Ventura) on Apple Silicon
- **Goal:** Convert the clipboard to plain text on demand while preserving indentation/newlines
- **Dependencies:** None beyond the standard macOS SDK (SwiftUI + AppKit + Carbon + UserNotifications)

## Project layout
```
PureClip/
├─ AppDelegate.swift           # Bootstraps status bar + hotkey, routes to cleaner
├─ StatusBarController.swift   # Menu bar UI, menu actions, menu icon wiring
├─ PreferencesWindowController.swift
├─ PlainClipApp.swift          # SwiftUI entry point + Settings view
├─ HotKeyStore.swift           # Carbon registration + persistence of hotkey
├─ HotKey.swift                # Codable hotkey model + formatting helpers
├─ ShortcutCaptureView.swift   # SwiftUI sheet for recording shortcuts
├─ ClipboardCleaner.swift      # Pasteboard inspection + text normalisation
├─ DetabMode.swift             # Preferences enum (Off / 2 / 4 / 8 spaces)
├─ NotificationDispatcher.swift# UserNotifications wrapper
├─ UserDefaults+Keys.swift     # Namespaced keys
├─ Assets.xcassets             # Menu icon (`MenuIcon`), App icon placeholders
└─ Config/Info.plist           # Minimal agent app plist (LSUIElement, etc.)
```

## Build & run
- Open `PureClip.xcodeproj` in Xcode 15+ and run the `PureClip` scheme (`⌘R`).
- Command-line build (no signing required for local use):
  ```bash
  xcodebuild -project PureClip.xcodeproj -scheme PureClip -configuration Debug build
  ```
- Output is an unsigned `.app` targeting arm64. Catalyst or Intel builds are not configured.
- The app is distributed directly (not through Mac App Store) and is not sandboxed.

## Runtime behaviour
- Menu bar icon loads `MenuIcon` (template PDF) and defaults to a size of 16×16.
- Menu items: **Clean Clipboard**, **Preferences…**, **Quit**.
- Global hotkey defaults to ⌥⌘V. Users can capture any modifier-based shortcut via the Preferences sheet. The combination is stored in `UserDefaults.Keys.hotKeyData` and registered through Carbon (`HotKeyStore.registerHotKey`).
- Clipboard cleaning runs synchronously on the main actor: prefers `.string`, falls back to `.rtf` / `.html` via `NSAttributedString`. It normalises line endings and removes NBSP/zero-width characters.
- Detab preference (`DetabMode`) expands tabs to 2/4/8 spaces when enabled. Stored in `UserDefaults.Keys.detabMode`.
- Notifications use `UNUserNotificationCenter`; authorisation is requested only when the toggle is turned on.
- Hotkey updates post `.hotKeyDidChange` notifications so the menu item shortcut stays in sync.
- Non-text content is ignored — cleaner returns `false` and the pasteboard remains unchanged.

## Testing checklist
Use these scenarios after making changes:
- Rich text → clean → paste into Word/TextEdit (should be plain text with indentation intact).
- Plain text → clean (no alteration except newline normalisation).
- Tabs with detab off/on (verify tab expansion matches selected width).
- Non-text clipboard (images/files) → clean (clipboard untouched, no notification).
- Change shortcut to unusual combos (e.g., ⇧⌘V) and ensure Carbon registration succeeds/falls back gracefully.
- Notifications enabled → confirm first-run permission and that failure resets the toggle.

## Maintenance tips
- Keep the project dependency-free; prefer native frameworks. Any new persistence settings should use `UserDefaults+Keys`.
- When adjusting the menu icon, update `Assets.xcassets/MenuIcon.imageset`; the code already expects a template image named `MenuIcon`.
- `HotKeyStore` uses Carbon APIs which require modifier masks as `UInt32`. Validate new combinations before registering.
- `ClipboardCleaner.normalise` is the core text pipeline. Extend it with caution and add unit coverage if practical (currently invoked directly).
- Preferences window is SwiftUI-only; `PreferencesWindowController` hosts it inside an `NSWindow` to remain LSUIElement-friendly.

## Known technical debt: Carbon APIs

### Why Carbon?
PureClip relies on **deprecated Carbon APIs** for global hotkey registration. This is **unavoidable** — Apple has never provided a modern replacement in AppKit, SwiftUI, or Cocoa for system-wide keyboard shortcuts.

### Where Carbon is used
- **HotKeyStore.swift**: `RegisterEventHotKey()`, `UnregisterEventHotKey()`, `InstallEventHandler()`, `GetApplicationEventTarget()`
- **HotKey.swift**: Carbon modifier constants (`cmdKey`, `optionKey`, `shiftKey`, `controlKey`) and virtual key codes (`kVK_ANSI_*`)
- **ShortcutCaptureView.swift**: Carbon modifier masks for event handling

### Why this is acceptable
- **No alternative exists**: Local shortcuts can use `NSEvent.addLocalMonitorForEvents`, but global hotkeys (that work when the app is in the background) require Carbon's `RegisterEventHotKey()`
- **Industry standard**: Popular Mac utilities (Alfred, Raycast, Rectangle, Magnet, etc.) all use the same Carbon APIs for global hotkeys
- **Stable**: These APIs have been "deprecated" for over a decade but remain functional and are unlikely to be removed due to widespread usage
- **Tested**: The implementation is proven to work in both sandboxed (Mac App Store) and unsandboxed (direct distribution) environments

### Implications for future development
- **Do not attempt to "modernize" this code** — there is no modern equivalent
- Xcode will show deprecation warnings; these can be safely ignored
- If Apple ever provides a replacement API, it will require a significant rewrite of `HotKeyStore.swift`
- When troubleshooting hotkey issues, focus on Carbon registration logic, not trying to replace the Carbon calls

### References
- Similar implementations: [KeyboardShortcuts package](https://github.com/sindresorhus/KeyboardShortcuts) (also uses Carbon, Mac App Store compatible)
- Apple has not announced any replacement API as of 2025

## Future ideas (optional)
- Auto-clean mode driven by `NSPasteboard.changeCount`
- AppKit/SwiftUI localisation (currently English only)
- Universal binary support if Intel is required later
- Distribution workflow (Archive → Notarise → DMG) if shipping outside source builds

## Support artifacts
- `README.md` – end-user instructions
- `LICENSE` – MIT
- App icon source acknowledged in README (“App icon by https://fonts.google.com/icons”)

If you encounter unexpected behaviours or need to add features, update this guide accordingly to keep future agents productive.
