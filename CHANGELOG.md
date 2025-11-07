# Changelog

All notable changes to PureClip will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2025-11-08

### Added
- Initial release
- Menu bar application for converting clipboard to plain text
- Global keyboard shortcut (default: ⌥⌘V) for cleaning clipboard
- Preferences window with customizable settings:
  - Toggle notifications when clipboard is cleaned
  - Detab mode: expand tabs to 2/4/8 spaces or leave as-is
  - Custom keyboard shortcut assignment
- Preserves indentation, line breaks, and tabs while removing rich text formatting
- Normalizes line endings and removes invisible characters (NBSP, zero-width characters)
- Full localization support for 6 languages:
  - English (base language)
  - Spanish (Español)
  - French (Français)
  - German (Deutsch)
  - Japanese (日本語)
  - Chinese Simplified (简体中文)
- Comprehensive test coverage with 102 unit tests across 4 test suites
- Version display in preferences window footer
- macOS 13.5 or newer support (tests require macOS 14.0+)
- Zero external dependencies

[Unreleased]: https://github.com/rnsloan/pureclip/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/rnsloan/pureclip/releases/tag/v1.0.0
