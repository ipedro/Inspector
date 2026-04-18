import InspectorContract
import UIKit

public enum InspectorValue {
    case bool(Bool)
    case number(Double)
    case string(String?)
    case selection(Int?)
    case color(UIColor?)
    case image(UIImage?)
    case preview(UIView)
    case rect(CGRect)
    case point(CGPoint)
    case size(CGSize)
    case offset(UIOffset)
    case edgeInsets(UIEdgeInsets)
    case directionalEdgeInsets(NSDirectionalEdgeInsets)
    case none
}

public enum InspectorRefreshHint: Hashable {
    case none
    case reloadSection
    case reloadInspector
}

public struct InspectorPropertyRuntimePresentation {
    public var emptyTitle: String?
    public var selectionOptionIcons: [UIImage?]?
    public var selectionImages: [UIImage]?

    public init(
        emptyTitle: String? = nil,
        selectionOptionIcons: [UIImage?]? = nil,
        selectionImages: [UIImage]? = nil
    ) {
        self.emptyTitle = emptyTitle
        self.selectionOptionIcons = selectionOptionIcons
        self.selectionImages = selectionImages
    }
}

public struct InspectorPropertyBinding {
    public let descriptor: InspectorContract.InspectorPropertyDescriptor
    public let read: @MainActor () -> InspectorValue
    public let write: (@MainActor (InspectorValue) -> Void)?
    public let refreshHint: InspectorRefreshHint
    public let runtimePresentation: InspectorPropertyRuntimePresentation?

    public init(
        descriptor: InspectorContract.InspectorPropertyDescriptor,
        read: @escaping @MainActor () -> InspectorValue,
        write: (@MainActor (InspectorValue) -> Void)? = nil,
        refreshHint: InspectorRefreshHint = .reloadInspector,
        runtimePresentation: InspectorPropertyRuntimePresentation? = nil
    ) {
        self.descriptor = descriptor
        self.read = read
        self.write = write
        self.refreshHint = refreshHint
        self.runtimePresentation = runtimePresentation
    }
}

public struct InspectorSectionBinding {
    public let descriptor: InspectorContract.InspectorSectionDescriptor
    public let fields: [InspectorPropertyBinding]

    public init(
        descriptor: InspectorContract.InspectorSectionDescriptor,
        fields: [InspectorPropertyBinding]
    ) {
        self.descriptor = descriptor
        self.fields = fields
    }
}

public extension InspectorPropertyBinding {
    func currentValue() -> InspectorValue {
        readValue()
    }

    func apply(_ value: InspectorValue) {
        writeValue(value)
    }

@available(*, deprecated, message: "Compatibility bridge only; prefer binding-native rendering")
    func makeInspectorElementProperty() -> InspectorElementProperty? {
        switch descriptor.kind {
        case .toggle:
            return .switch(
                title: descriptor.title,
                isOn: {
                    guard case let .bool(value) = self.readValue() else { return false }
                    return value
                },
                handler: write.map { _ in
                    { self.writeValue(.bool($0)) }
                }
            )
        case .stepper:
            let constraints: InspectorContract.NumberConstraints?
            if case let .number(value) = descriptor.value {
                constraints = value
            } else {
                constraints = nil
            }

            return .stepper(
                title: descriptor.title,
                value: {
                    guard case let .number(value) = self.readValue() else { return 0 }
                    return value
                },
                range: {
                    let min = constraints?.min ?? 0
                    let max = constraints?.max ?? Double.infinity
                    return min...max
                },
                stepValue: { constraints?.step ?? 1 },
                isDecimalValue: constraints?.isDecimal ?? false,
                handler: write.map { _ in
                    { self.writeValue(.number($0)) }
                }
            )
        case .textField:
            let stringConstraints: InspectorContract.StringConstraints?
            if case let .string(value) = descriptor.value {
                stringConstraints = value
            } else {
                stringConstraints = nil
            }
            return .textField(
                title: descriptor.title,
                placeholder: stringConstraints?.placeholder,
                axis: axis,
                value: {
                    guard case let .string(value) = self.readValue() else { return nil }
                    return value
                },
                handler: write.map { _ in
                    { self.writeValue(.string($0)) }
                }
            )
        case .textView:
            let stringConstraints: InspectorContract.StringConstraints?
            if case let .string(value) = descriptor.value {
                stringConstraints = value
            } else {
                stringConstraints = nil
            }
            return .textView(
                title: descriptor.title,
                placeholder: stringConstraints?.placeholder,
                value: {
                    guard case let .string(value) = self.readValue() else { return nil }
                    return value
                },
                handler: write.map { _ in
                    { self.writeValue(.string($0)) }
                }
            )
        case .options, .textButtons:
            let selectionConstraints: InspectorContract.SelectionConstraints?
            if case let .selection(value) = descriptor.value {
                selectionConstraints = value
            } else {
                selectionConstraints = nil
            }
            let options = selectionConstraints?.options.map(\.title) ?? []
            if descriptor.kind == .options {
                return .optionsList(
                    title: descriptor.title,
                    emptyTitle: runtimePresentation?.emptyTitle ?? "Unspecified",
                    axis: axis,
                    options: options,
                    selectedIndex: {
                        guard case let .selection(index) = self.readValue() else { return nil }
                        return index
                    },
                    handler: write.map { _ in
                        { self.writeValue(.selection($0)) }
                    }
                )
            }
            return .textButtonGroup(
                title: descriptor.title,
                axis: axis,
                texts: options,
                selectedIndex: {
                    guard case let .selection(index) = self.readValue() else { return nil }
                    return index
                },
                handler: write.map { _ in
                    { self.writeValue(.selection($0)) }
                }
            )
        case .color:
            return .colorPicker(
                title: descriptor.title,
                emptyTitle: runtimePresentation?.emptyTitle ?? "No color",
                color: {
                    guard case let .color(value) = self.readValue() else { return nil }
                    return value
                },
                handler: write.map { _ in
                    { self.writeValue(.color($0)) }
                }
            )
        case .group:
            return .group(title: descriptor.title, subtitle: descriptor.presentation?.subtitle)
        case .separator:
            return .separator
        case .note:
            return .infoNote(
                text: descriptor.presentation?.subtitle ?? descriptor.title
            )
        case .preview:
            switch readValue() {
            case let .preview(view):
                return .preview(target: .init(view: view))
            case let .rect(value):
                return .cgRect(
                    title: descriptor.title,
                    rect: { value },
                    handler: write.map { _ in
                        { self.writeValue(.rect($0 ?? .zero)) }
                    }
                )
            case let .point(value):
                return .cgPoint(
                    title: descriptor.title,
                    point: { value },
                    handler: write.map { _ in
                        { self.writeValue(.point($0 ?? .zero)) }
                    }
                )
            case let .size(value):
                return .cgSize(
                    title: descriptor.title,
                    size: { value },
                    handler: write.map { _ in
                        { self.writeValue(.size($0 ?? .zero)) }
                    }
                )
            case let .offset(value):
                return .uiOffset(
                    title: descriptor.title,
                    offset: { value },
                    handler: write.map { _ in
                        { self.writeValue(.offset($0)) }
                    }
                )
            case let .edgeInsets(value):
                return .edgeInsets(
                    title: descriptor.title,
                    insets: { value },
                    handler: write.map { _ in
                        { self.writeValue(.edgeInsets($0)) }
                    }
                )
            case let .directionalEdgeInsets(value):
                return .directionalInsets(
                    title: descriptor.title,
                    insets: { value },
                    handler: write.map { _ in
                        { self.writeValue(.directionalEdgeInsets($0)) }
                    }
                )
            case let .image(value):
                return .imagePicker(
                    title: descriptor.title,
                    image: { value },
                    handler: write.map { _ in
                        { self.writeValue(.image($0)) }
                    }
                )
            case .none, .bool, .number, .string, .selection, .color:
                return nil
            }
        case .imageButtons:
            guard let images = runtimePresentation?.selectionImages else {
                return nil
            }
            return .imageButtonGroup(
                title: descriptor.title,
                axis: axis,
                images: images,
                selectedIndex: {
                    guard case let .selection(index) = self.readValue() else { return nil }
                    return index
                },
                handler: write.map { _ in
                    { self.writeValue(.selection($0)) }
                }
            )
        case .subpanel:
            return nil
        }
    }


    private func writeValue(_ value: InspectorValue) {
        guard let write else { return }

        if Thread.isMainThread {
            MainActor.assumeIsolated { write(value) }
            return
        }

        DispatchQueue.main.sync {
            MainActor.assumeIsolated { write(value) }
        }
    }

    private func readValue() -> InspectorValue {
        if Thread.isMainThread {
            return MainActor.assumeIsolated { read() }
        }

        return DispatchQueue.main.sync {
            MainActor.assumeIsolated { read() }
        }
    }

    private var axis: NSLayoutConstraint.Axis {
        switch descriptor.presentation?.axis {
        case .horizontal:
            .horizontal
        case .vertical:
            .vertical
        case .none:
            .vertical
        }
    }
}

public extension InspectorSectionBinding {
    func makeInspectorElementProperties(
        extraBindings: [String: () -> [InspectorPropertyBinding]] = [:],
        extraProperties: [String: () -> [InspectorElementProperty]] = [:]
    ) -> [InspectorElementProperty] {
        fields.flatMap { field in
            if let extra = extraBindings[field.descriptor.id] {
                return extra().compactMap { $0.makeInspectorElementProperty() }
            }
            if let extra = extraProperties[field.descriptor.id] {
                return extra()
            }
            guard let property = field.makeInspectorElementProperty() else {
                return []
            }
            return [property]
        }
    }
}

public extension InspectorElementProperty {
    @available(*, deprecated, message: "Compatibility bridge only; prefer constructing InspectorPropertyBinding directly")
    func makeBinding(id: String) -> InspectorPropertyBinding? {
        switch self {
        case let .switch(title, isOn, handler):
            return .init(
                descriptor: .init(id: id, title: title, kind: .toggle, value: .bool, editability: handler == nil ? .readOnly : .editable),
                read: { .bool(isOn()) },
                write: handler.map { writer in { value in guard case let .bool(updated) = value else { return }; writer(updated) } }
            )
        case let .stepper(title, value, range, stepValue, isDecimalValue, handler):
            let resolvedRange = range()
            return .init(
                descriptor: .init(
                    id: id,
                    title: title,
                    kind: .stepper,
                    value: .number(.init(min: resolvedRange.lowerBound, max: resolvedRange.upperBound, step: stepValue(), isDecimal: isDecimalValue)),
                    editability: handler == nil ? .readOnly : .editable
                ),
                read: { .number(value()) },
                write: handler.map { writer in { newValue in guard case let .number(updated) = newValue else { return }; writer(updated) } }
            )
        case let .textField(title, placeholder, axis, value, handler):
            return .init(
                descriptor: .init(
                    id: id,
                    title: title,
                    kind: .textField,
                    value: .string(.init(multiline: false, placeholder: placeholder, allowsNil: true)),
                    editability: handler == nil ? .readOnly : .editable,
                    presentation: .init(axis: axis.inspectorAxis)
                ),
                read: { .string(value()) },
                write: handler.map { writer in { newValue in guard case let .string(updated) = newValue else { return }; writer(updated) } }
            )
        case let .textView(title, placeholder, value, handler):
            return .init(
                descriptor: .init(id: id, title: title, kind: .textView, value: .string(.init(multiline: true, placeholder: placeholder, allowsNil: true)), editability: handler == nil ? .readOnly : .editable),
                read: { .string(value()) },
                write: handler.map { writer in { newValue in guard case let .string(updated) = newValue else { return }; writer(updated) } }
            )
        case let .optionsList(title, emptyTitle, axis, options, selectedIndex, handler):
            return .init(
                descriptor: .init(
                    id: id,
                    title: title,
                    kind: .options,
                    value: .selection(.init(options: options.enumerated().map { .init(id: "\($0.offset)", title: String(describing: $0.element.title)) }, allowsNil: true)),
                    editability: handler == nil ? .readOnly : .editable,
                    presentation: .init(axis: axis.inspectorAxis)
                ),
                read: { .selection(selectedIndex()) },
                write: handler.map { writer in { newValue in guard case let .selection(updated) = newValue else { return }; writer(updated) } },
                runtimePresentation: .init(
                    emptyTitle: emptyTitle,
                    selectionOptionIcons: options.map(\.icon)
                )
            )
        case let .textButtonGroup(title, axis, texts, selectedIndex, handler):
            return .init(
                descriptor: .init(
                    id: id,
                    title: title,
                    kind: .textButtons,
                    value: .selection(.init(options: texts.enumerated().map { .init(id: "\($0.offset)", title: $0.element) }, allowsNil: true)),
                    editability: handler == nil ? .readOnly : .editable,
                    presentation: .init(axis: axis.inspectorAxis)
                ),
                read: { .selection(selectedIndex()) },
                write: handler.map { writer in { newValue in guard case let .selection(updated) = newValue else { return }; writer(updated) } }
            )
        case let .imageButtonGroup(title, axis, images, selectedIndex, handler):
            return .init(
                descriptor: .init(
                    id: id,
                    title: title,
                    kind: .imageButtons,
                    value: .selection(.init(options: images.enumerated().map { .init(id: "\($0.offset)", title: "\($0.offset)") }, allowsNil: true)),
                    editability: handler == nil ? .readOnly : .editable,
                    presentation: .init(axis: axis.inspectorAxis)
                ),
                read: { .selection(selectedIndex()) },
                write: handler.map { writer in { newValue in guard case let .selection(updated) = newValue else { return }; writer(updated) } },
                runtimePresentation: .init(selectionImages: images)
            )
        case let .colorPicker(title, emptyTitle, color, handler):
            return .init(
                descriptor: .init(id: id, title: title, kind: .color, value: .color(allowsNil: true), editability: handler == nil ? .readOnly : .editable),
                read: { .color(color()) },
                write: handler.map { writer in { newValue in guard case let .color(updated) = newValue else { return }; writer(updated) } },
                runtimePresentation: .init(emptyTitle: emptyTitle)
            )
        case let .cgRect(title, rect, handler):
            return .init(
                descriptor: .init(id: id, title: title, kind: .preview, value: .rect, editability: handler == nil ? .readOnly : .editable),
                read: { .rect(rect()) },
                write: handler.map { writer in { newValue in guard case let .rect(updated) = newValue else { return }; writer(updated) } }
            )
        case let .cgPoint(title, point, handler):
            return .init(
                descriptor: .init(id: id, title: title, kind: .preview, value: .point, editability: handler == nil ? .readOnly : .editable),
                read: { .point(point()) },
                write: handler.map { writer in { newValue in guard case let .point(updated) = newValue else { return }; writer(updated) } }
            )
        case let .cgSize(title, size, handler):
            return .init(
                descriptor: .init(id: id, title: title, kind: .preview, value: .size, editability: handler == nil ? .readOnly : .editable),
                read: { .size(size()) },
                write: handler.map { writer in { newValue in guard case let .size(updated) = newValue else { return }; writer(updated) } }
            )
        case let .uiOffset(title, offset, handler):
            return .init(
                descriptor: .init(id: id, title: title, kind: .preview, value: .offset, editability: handler == nil ? .readOnly : .editable),
                read: { .offset(offset()) },
                write: handler.map { writer in { newValue in guard case let .offset(updated) = newValue else { return }; writer(updated) } }
            )
        case let .edgeInsets(title, insets, handler):
            return .init(
                descriptor: .init(id: id, title: title, kind: .preview, value: .edgeInsets, editability: handler == nil ? .readOnly : .editable),
                read: { .edgeInsets(insets()) },
                write: handler.map { writer in { newValue in guard case let .edgeInsets(updated) = newValue else { return }; writer(updated) } }
            )
        case let .directionalInsets(title, insets, handler):
            return .init(
                descriptor: .init(id: id, title: title, kind: .preview, value: .directionalEdgeInsets, editability: handler == nil ? .readOnly : .editable),
                read: { .directionalEdgeInsets(insets()) },
                write: handler.map { writer in { newValue in guard case let .directionalEdgeInsets(updated) = newValue else { return }; writer(updated) } }
            )
        case let .preview(target):
            return .init(
                descriptor: .init(id: id, title: "Preview", kind: .preview, value: .none, editability: .readOnly),
                read: {
                    if let view = target.reference._underlyingView {
                        return .preview(view)
                    }
                    return .none
                },
                write: nil,
                refreshHint: .reloadSection
            )
        case let .group(title, subtitle):
            return .init(
                descriptor: .init(id: id, title: title, kind: .group, value: .none, editability: .readOnly, presentation: .init(subtitle: subtitle)),
                read: { .none },
                write: nil,
                refreshHint: .none
            )
        case .separator:
            return .init(
                descriptor: .init(id: id, title: "", kind: .separator, value: .none, editability: .readOnly),
                read: { .none },
                write: nil,
                refreshHint: .none
            )
        case let .infoNote(icon, title, text):
            let style: InspectorContract.InspectorNoteStyle = icon == .warning ? .warning : .info
            return .init(
                descriptor: .init(id: id, title: title ?? "", kind: .note, value: .none, editability: .readOnly, presentation: .init(subtitle: text, noteStyle: style)),
                read: { .none },
                write: nil,
                refreshHint: .none
            )
        case let .imagePicker(title, axis, image, handler):
            return .init(
                descriptor: .init(
                    id: id,
                    title: title,
                    kind: .preview,
                    value: .none,
                    editability: handler == nil ? .readOnly : .editable,
                    presentation: .init(axis: axis.inspectorAxis)
                ),
                read: { .image(image()) },
                write: handler.map { writer in { newValue in guard case let .image(updated) = newValue else { return }; writer(updated) } }
            )
        }
    }
}

private extension NSLayoutConstraint.Axis {
    var inspectorAxis: InspectorContract.InspectorAxis {
        switch self {
        case .horizontal:
            .horizontal
        case .vertical:
            .vertical
        @unknown default:
            .vertical
        }
    }
}
