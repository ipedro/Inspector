import Foundation

/// Constants describing the possible states of an element inspector section.
public enum InspectorElementSectionState: Hashable {
    case expanded, collapsed

    public mutating func toggle() {
        switch self {
        case .collapsed:
            self = .expanded
        case .expanded:
            self = .collapsed
        }
    }
}
