import AppKit

enum ClipboardCleaner {
    /// Converts clipboard to *plain text only*, preserving indentation and newlines.
    /// Returns false if no text could be recovered.
    static func clean(detab: Bool = false, tabWidth: Int = 4) -> Bool {
        let pb = NSPasteboard.general

        // 1) Best case: plain text is already on the pasteboard.
        if let s = pb.string(forType: .string), !s.isEmpty {
            writePlain(normalise(s, detab: detab, tabWidth: tabWidth))
            return true
        }

        // 2) Try to derive from RTF or HTML while preserving code-like whitespace.
        if let derived = derivePlainTextPreservingWhitespace(from: pb) {
            writePlain(normalise(derived, detab: detab, tabWidth: tabWidth))
            return true
        }

        return false
    }

    private static func writePlain(_ s: String) {
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(s, forType: .string)
    }

    /// Attempts to reconstruct plain text from rich flavours without losing indentation.
    private static func derivePlainTextPreservingWhitespace(from pb: NSPasteboard) -> String? {
        // RTF path preserves whitespace and newlines well.
        if let rtf = pb.data(forType: .rtf),
           let attr = try? NSAttributedString(
                data: rtf,
                options: [.documentType: NSAttributedString.DocumentType.rtf],
                documentAttributes: nil) {
            return attr.string
        }

        // HTML path: handle <pre>/<code> correctly and preserve line breaks.
        if let html = pb.data(forType: .html),
           let attr = try? NSAttributedString(
                data: html,
                options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ],
                documentAttributes: nil) {
            return attr.string
        }

        return nil
    }

    /// Normalise line endings and invisible spaces; optionally expand tabs.
    static func normalise(_ s: String, detab: Bool, tabWidth: Int) -> String {
        var out = s

        // Unify endings to \n (macOS friendly for plain text)
        out = out.replacingOccurrences(of: "\r\n", with: "\n")
                 .replacingOccurrences(of: "\r", with: "\n")

        // Replace NBSP with regular space (works with replacingOccurrences)
        out = out.replacingOccurrences(of: "\u{00A0}", with: " ")

        // Remove zero-width characters at unicode scalar level
        // (they form extended grapheme clusters, so replacingOccurrences doesn't work)
        let zeroWidthScalars: Set<UInt32> = [
            0x200B,  // zero-width space
            0x200C,  // zero-width non-joiner
            0x200D   // zero-width joiner
        ]
        out = String(out.unicodeScalars.filter { !zeroWidthScalars.contains($0.value) })

        // Optionally convert tabs to spaces (keeps visual alignment in Word)
        if detab {
            let spaces = String(repeating: " ", count: max(1, tabWidth))
            out = out.replacingOccurrences(of: "\t", with: spaces)
        }

        return out
    }
}

enum ClipboardCoordinator {
    @discardableResult
    static func cleanUsingPreferences() -> Bool {
        let mode = DetabMode(rawValue: UserDefaults.standard.string(forKey: UserDefaults.Keys.detabMode) ?? DetabMode.default.rawValue) ?? .default
        let cleaned = ClipboardCleaner.clean(detab: mode != .off, tabWidth: mode.tabWidth)
        if cleaned {
            NotificationDispatcher.postCleanSuccessNotification()
        }
        return cleaned
    }
}
