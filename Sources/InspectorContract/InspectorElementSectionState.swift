import Foundation

/// Constants describing the possible states of an element inspector section.
public enum InspectorElementSectionState: Hashable, Sendable {
    case expanded
    case collapsed

    public mutating func toggle() {
        switch self {
        case .collapsed:
            self = .expanded
        case .expanded:
            self = .collapsed
        }
    }
}
