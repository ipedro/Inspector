import Foundation

public struct InspectorPropertyDescriptor: Hashable, Sendable {
    public var id: String
    public var title: String
    public var kind: InspectorPropertyKind
    public var value: InspectorValueDescriptor
    public var editability: InspectorEditability
    public var presentation: InspectorPresentation?

    public init(
        id: String,
        title: String,
        kind: InspectorPropertyKind,
        value: InspectorValueDescriptor,
        editability: InspectorEditability,
        presentation: InspectorPresentation? = nil
    ) {
        self.id = id
        self.title = title
        self.kind = kind
        self.value = value
        self.editability = editability
        self.presentation = presentation
    }
}

public enum InspectorPropertyKind: Hashable, Sendable {
    case toggle
    case stepper
    case textField
    case textView
    case options
    case textButtons
    case imageButtons
    case color
    case group
    case separator
    case note
    case preview
    case subpanel
}

public enum InspectorValueDescriptor: Hashable, Sendable {
    case bool
    case number(NumberConstraints?)
    case string(StringConstraints?)
    case selection(SelectionConstraints)
    case color(allowsNil: Bool)
    case rect
    case point
    case size
    case offset
    case edgeInsets
    case directionalEdgeInsets
    case none
}

public struct NumberConstraints: Hashable, Sendable {
    public var min: Double?
    public var max: Double?
    public var step: Double?
    public var isDecimal: Bool

    public init(min: Double? = nil, max: Double? = nil, step: Double? = nil, isDecimal: Bool = false) {
        self.min = min
        self.max = max
        self.step = step
        self.isDecimal = isDecimal
    }
}

public struct StringConstraints: Hashable, Sendable {
    public var multiline: Bool
    public var placeholder: String?
    public var allowsNil: Bool

    public init(multiline: Bool, placeholder: String? = nil, allowsNil: Bool = false) {
        self.multiline = multiline
        self.placeholder = placeholder
        self.allowsNil = allowsNil
    }
}

public struct SelectionConstraints: Hashable, Sendable {
    public var options: [InspectorSelectionOption]
    public var allowsNil: Bool

    public init(options: [InspectorSelectionOption], allowsNil: Bool = false) {
        self.options = options
        self.allowsNil = allowsNil
    }
}

public enum InspectorEditability: Hashable, Sendable {
    case readOnly
    case editable
}

public struct InspectorPresentation: Hashable, Sendable {
    public var subtitle: String?
    public var axis: InspectorAxis?
    public var noteStyle: InspectorNoteStyle?

    public init(subtitle: String? = nil, axis: InspectorAxis? = nil, noteStyle: InspectorNoteStyle? = nil) {
        self.subtitle = subtitle
        self.axis = axis
        self.noteStyle = noteStyle
    }
}

public enum InspectorAxis: String, Hashable, Sendable {
    case horizontal
    case vertical
}

public enum InspectorNoteStyle: String, Hashable, Sendable {
    case info
    case warning
}
