// Sources/InspectorInterface/InspectorPanel.swift

// MARK: - @InspectorPanel

/// Attach to a UIView subclass to generate an InspectorElementSectionDataSource
/// and InspectorElementLibraryProtocol conformance for use with the Inspector debug library.
///
/// Example:
/// ```swift
/// @InspectorPanel(title: "My Card View")
/// class MyCardView: UIView {
///     @InspectorProperty(.colorPicker)
///     var borderColor: UIColor = .clear
/// }
/// ```
/// Generates `MyCardView.SectionDataSource` and `MyCardView.InspectorLibrary`
/// inside `#if INSPECTOR_ENABLED` guards.
@attached(member, names: named(SectionDataSource), named(InspectorLibrary))
public macro InspectorPanel(title: String) =
    #externalMacro(module: "InspectorMacros", type: "InspectorPanelMacro")

// MARK: - @InspectorProperty

/// Marks a stored property as inspectable. @InspectorPanel reads this annotation
/// during macro expansion — it generates no code on its own.
///
/// - Parameter descriptor: The inspector control to use. Omit for type-inferred default.
@attached(peer)
public macro InspectorProperty(
    _ descriptor: InspectorPropertyDescriptor = .auto
) = #externalMacro(module: "InspectorMacros", type: "InspectorPropertyMacro")

// MARK: - InspectorPropertyDescriptor

/// Describes which Inspector control to use for an @InspectorProperty-annotated property.
public enum InspectorPropertyDescriptor {
    // Interactive controls
    case `switch`
    case colorPicker
    case stepper(range: ClosedRange<Double> = 0...Double.infinity, step: Double = 1)
    case textField
    case textView
    case imagePicker
    case optionsList(options: [String])
    case textButtonGroup(texts: [String])

    // Struct controls
    case cgRect
    case cgPoint
    case cgSize
    case uiOffset
    case edgeInsets
    case directionalInsets

    // Non-interactive
    case group(title: String)
    case separator
    case infoNote(text: String)

    /// Inlines the properties of a nested component's inspector panel.
    /// The property's type must be annotated with @InspectorPanel.
    case subpanel

    /// Type-inferred: the macro chooses the control based on the property's declared type.
    case auto
}
