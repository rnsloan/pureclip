import SwiftUI
import Carbon.HIToolbox

struct ShortcutCaptureView: View {
    @Binding var isPresented: Bool
    var onCommit: (HotKey) -> Void

    @State private var capturedHotKey: HotKey? = nil
    @State private var captureError: String?

    var body: some View {
        VStack(spacing: 16) {
            Text(NSLocalizedString("shortcut_capture.title", comment: "Shortcut capture instruction"))
                .font(.headline)

            Text(capturedHotKey?.displayString ?? NSLocalizedString("shortcut_capture.waiting", comment: "Waiting for shortcut"))
                .font(.system(size: 24, weight: .semibold))

            if let captureError {
                Text(captureError)
                    .font(.footnote)
                    .foregroundColor(.red)
            }

            HStack {
                Button(NSLocalizedString("shortcut_capture.cancel", comment: "Cancel button")) {
                    isPresented = false
                }
                .keyboardShortcut(.cancelAction)

                Button(NSLocalizedString("shortcut_capture.save", comment: "Save button")) {
                    guard let capturedHotKey else {
                        captureError = NSLocalizedString("shortcut_capture.error.no_shortcut", comment: "Error when no shortcut pressed")
                        return
                    }
                    switch HotKeyStore.shared.updateHotKey(to: capturedHotKey) {
                    case .success(let applied):
                        onCommit(applied)
                        isPresented = false
                    case .failure:
                        captureError = NSLocalizedString("shortcut_capture.error.registration_failed", comment: "Error when shortcut registration fails")
                    }
                }
                .keyboardShortcut(.defaultAction)
                .disabled(capturedHotKey == nil)
            }
        }
        .padding(24)
        .frame(minWidth: 320)
        .background(ShortcutCaptureRepresentable(capturedHotKey: $capturedHotKey, captureError: $captureError))
    }
}

private struct ShortcutCaptureRepresentable: NSViewRepresentable {
    @Binding var capturedHotKey: HotKey?
    @Binding var captureError: String?

    func makeNSView(context: Context) -> ShortcutCaptureViewHost {
        let host = ShortcutCaptureViewHost()
        host.onHotKeyCaptured = { hotKey in
            capturedHotKey = hotKey
            captureError = nil
        }
        host.onCaptureError = { message in
            captureError = message
        }
        host.startCapture()
        return host
    }

    func updateNSView(_ nsView: ShortcutCaptureViewHost, context: Context) {}
}

final class ShortcutCaptureViewHost: NSView {
    var onHotKeyCaptured: ((HotKey) -> Void)?
    var onCaptureError: ((String) -> Void)?

    private var monitor: Any?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func startCapture() {
        window?.makeFirstResponder(self)
        monitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { [weak self] event in
            self?.handle(event: event)
            return nil
        }
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        window?.makeFirstResponder(self)
    }

    override func keyDown(with event: NSEvent) {
        handle(event: event)
    }

    override func removeFromSuperview() {
        super.removeFromSuperview()
        if let monitor {
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
        }
    }

    deinit {
        if let monitor {
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
        }
    }

    private func handle(event: NSEvent) {
        guard let charactersIgnoring = event.charactersIgnoringModifiers, !charactersIgnoring.isEmpty else {
            onCaptureError?(NSLocalizedString("shortcut_capture.error.unsupported_key", comment: "Error for unsupported key"))
            return
        }

        let modifiers = mapModifiers(from: event.modifierFlags)

        guard modifiers != 0 else {
            onCaptureError?(NSLocalizedString("shortcut_capture.error.needs_modifier", comment: "Error when no modifier key pressed"))
            return
        }

        guard charactersIgnoring.count == 1,
              let scalar = charactersIgnoring.unicodeScalars.first,
              HotKeyCharacterValidator.isSupported(scalar, modifiers: modifiers) else {
            onCaptureError?(NSLocalizedString("shortcut_capture.error.invalid_character", comment: "Error for invalid character"))
            return
        }

        let keyCode = UInt32(event.keyCode)
        let keyEquivalent = charactersIgnoring.uppercased()
        onHotKeyCaptured?(HotKey(keyCode: keyCode, modifiers: modifiers, keyEquivalent: keyEquivalent))
    }

    private func mapModifiers(from flags: NSEvent.ModifierFlags) -> UInt32 {
        var carbonModifiers: UInt32 = 0

        if flags.contains(.command) { carbonModifiers |= UInt32(cmdKey) }
        if flags.contains(.option) { carbonModifiers |= UInt32(optionKey) }
        if flags.contains(.shift) { carbonModifiers |= UInt32(shiftKey) }
        if flags.contains(.control) { carbonModifiers |= UInt32(controlKey) }

        return carbonModifiers
    }
}

enum HotKeyCharacterValidator {
    static func isSupported(_ scalar: UnicodeScalar, modifiers: UInt32) -> Bool {
        switch scalar.value {
        case 0x1B: // Escape
            return modifiers != 0
        case 0x20: return true // space
        case 0x21...0x7E: return true // printable ASCII
        default:
            return false
        }
    }
}
