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

public struct InspectorPropertyBinding {
    public let descriptor: InspectorContract.InspectorPropertyDescriptor
    public let read: @MainActor () -> InspectorValue
    public let write: (@MainActor (InspectorValue) -> Void)?
    public let refreshHint: InspectorRefreshHint

    public init(
        descriptor: InspectorContract.InspectorPropertyDescriptor,
        read: @escaping @MainActor () -> InspectorValue,
        write: (@MainActor (InspectorValue) -> Void)? = nil,
        refreshHint: InspectorRefreshHint = .reloadInspector
    ) {
        self.descriptor = descriptor
        self.read = read
        self.write = write
        self.refreshHint = refreshHint
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
        case .subpanel, .imageButtons:
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
}

public extension InspectorSectionBinding {
    func makeInspectorElementProperties(
        extraProperties: [String: () -> [InspectorElementProperty]] = [:]
    ) -> [InspectorElementProperty] {
        fields.flatMap { field in
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
