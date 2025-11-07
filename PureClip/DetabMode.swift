import Foundation

enum DetabMode: String, CaseIterable, Identifiable {
    case off
    case two
    case four
    case eight

    var id: String { rawValue }

    var label: String {
        switch self {
        case .off: return NSLocalizedString("detab.off", comment: "Leave tabs unchanged")
        case .two: return NSLocalizedString("detab.two", comment: "Expand tabs to 2 spaces")
        case .four: return NSLocalizedString("detab.four", comment: "Expand tabs to 4 spaces")
        case .eight: return NSLocalizedString("detab.eight", comment: "Expand tabs to 8 spaces")
        }
    }

    var tabWidth: Int {
        switch self {
        case .off: return 0
        case .two: return 2
        case .four: return 4
        case .eight: return 8
        }
    }

    static let `default`: DetabMode = .off
}
