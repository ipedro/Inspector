import UIKit

struct InspectorAutobuiltPanelBuilder {
    static func sections(
        for object: NSObject,
        panel: ElementInspectorPanel,
        libraries: [InspectorElementLibraryProtocol]
    ) -> InspectorElementSections {
        let curatedSections = libraries.curatedFormItems(for: object)

        guard panel == .attributes else { return curatedSections }
        guard shouldAutobuild(for: object, libraries: libraries) else { return curatedSections }

        let autobuiltRows = autobuiltRows(for: object)
        guard autobuiltRows.isEmpty == false else { return curatedSections }

        return curatedSections + [
            InspectorElementSection(
                title: "Autobuilt",
                rows: autobuiltRows
            )
        ]
    }

    private static func shouldAutobuild(
        for object: NSObject,
        libraries: [InspectorElementLibraryProtocol]
    ) -> Bool {
        guard libraries.contains(where: { $0.targetClass == object.classForCoder }) == false else {
            return false
        }

        let bundleIdentifier = Bundle(for: object.classForCoder).bundleIdentifier ?? ""
        return bundleIdentifier.hasPrefix("com.apple.") == false
    }

    private static func autobuiltRows(for object: NSObject) -> [InspectorElementSectionDataSource] {
        let dataSource = InspectorAutobuiltAttributesSectionDataSource(object: object)
        return dataSource.autobuiltFieldCount > 0 ? [dataSource] : []
    }
}

private final class InspectorAutobuiltAttributesSectionDataSource: InspectorElementSectionDataSource {
    var state: InspectorElementSectionState = .expanded
    let title = "Runtime Fields"
    let subtitle: String?
    let propertyBindings: [InspectorPropertyBinding]
    let autobuiltFieldCount: Int

    init(object: NSObject) {
        let className = String(describing: object.classForCoder)
        subtitle = className

        let fields = Self.makeFieldBindings(for: object)
        autobuiltFieldCount = fields.count

        let note = InspectorPropertyBinding(
            descriptor: .init(
                id: "autobuilt-note",
                title: "Generated at runtime",
                kind: .note,
                value: .none,
                editability: .readOnly,
                presentation: .init(
                    subtitle: "Inspector generated these fields from stored properties on \(className). Inherited curated sections are shown above."
                )
            ),
            read: { .none },
            write: nil,
            refreshHint: .none
        )

        propertyBindings = [note] + fields
    }

    private static func makeFieldBindings(for object: NSObject) -> [InspectorPropertyBinding] {
        var seenLabels = Set<String>()
        return mirroredChildren(for: object).compactMap { child in
            guard let label = child.label?.trimmed else { return nil }
            guard label.hasPrefix("_") == false else { return nil }
            guard seenLabels.insert(label).inserted else { return nil }
            return makeBinding(label: label, sampleValue: child.value, object: object)
        }
    }

    private static func makeBinding(
        label: String,
        sampleValue: Any,
        object: NSObject
    ) -> InspectorPropertyBinding? {
        let title = label.camelCaseToWords().capitalized
        let reflectedKind = ReflectedFieldKind(sampleValue: sampleValue)

        switch reflectedKind {
        case let .toggle(fallback):
            return .init(
                descriptor: .init(
                    id: label,
                    title: title,
                    kind: .toggle,
                    value: .bool,
                    editability: .readOnly
                ),
                read: { .bool(Self.currentBoolValue(for: label, on: object) ?? fallback) },
                write: nil,
                refreshHint: .reloadSection
            )
        case let .number(fallback, isDecimal):
            return .init(
                descriptor: .init(
                    id: label,
                    title: title,
                    kind: .stepper,
                    value: .number(.init(step: isDecimal ? 0.1 : 1, isDecimal: isDecimal)),
                    editability: .readOnly
                ),
                read: { .number(Self.currentNumberValue(for: label, on: object) ?? fallback) },
                write: nil,
                refreshHint: .reloadSection
            )
        case let .string(fallback):
            return .init(
                descriptor: .init(
                    id: label,
                    title: title,
                    kind: .textField,
                    value: .string(.init(multiline: false, allowsNil: true)),
                    editability: .readOnly
                ),
                read: { .string(Self.currentStringValue(for: label, on: object) ?? fallback) },
                write: nil,
                refreshHint: .reloadSection
            )
        case let .color(fallback):
            return .init(
                descriptor: .init(
                    id: label,
                    title: title,
                    kind: .color,
                    value: .color(allowsNil: true),
                    editability: .readOnly
                ),
                read: { .color(Self.currentColorValue(for: label, on: object) ?? fallback) },
                write: nil,
                refreshHint: .reloadSection,
                runtimePresentation: .init(emptyTitle: "nil")
            )
        case let .image(fallback):
            return .init(
                descriptor: .init(
                    id: label,
                    title: title,
                    kind: .preview,
                    value: .none,
                    editability: .readOnly
                ),
                read: { .image(Self.currentImageValue(for: label, on: object) ?? fallback) },
                write: nil,
                refreshHint: .reloadSection
            )
        case let .rect(fallback):
            return .init(
                descriptor: .init(id: label, title: title, kind: .preview, value: .rect, editability: .readOnly),
                read: { .rect(Self.currentRectValue(for: label, on: object) ?? fallback) },
                write: nil,
                refreshHint: .reloadSection
            )
        case let .point(fallback):
            return .init(
                descriptor: .init(id: label, title: title, kind: .preview, value: .point, editability: .readOnly),
                read: { .point(Self.currentPointValue(for: label, on: object) ?? fallback) },
                write: nil,
                refreshHint: .reloadSection
            )
        case let .size(fallback):
            return .init(
                descriptor: .init(id: label, title: title, kind: .preview, value: .size, editability: .readOnly),
                read: { .size(Self.currentSizeValue(for: label, on: object) ?? fallback) },
                write: nil,
                refreshHint: .reloadSection
            )
        case let .offset(fallback):
            return .init(
                descriptor: .init(id: label, title: title, kind: .preview, value: .offset, editability: .readOnly),
                read: { .offset(Self.currentOffsetValue(for: label, on: object) ?? fallback) },
                write: nil,
                refreshHint: .reloadSection
            )
        case let .edgeInsets(fallback):
            return .init(
                descriptor: .init(id: label, title: title, kind: .preview, value: .edgeInsets, editability: .readOnly),
                read: { .edgeInsets(Self.currentEdgeInsetsValue(for: label, on: object) ?? fallback) },
                write: nil,
                refreshHint: .reloadSection
            )
        case let .directionalEdgeInsets(fallback):
            return .init(
                descriptor: .init(id: label, title: title, kind: .preview, value: .directionalEdgeInsets, editability: .readOnly),
                read: { .directionalEdgeInsets(Self.currentDirectionalEdgeInsetsValue(for: label, on: object) ?? fallback) },
                write: nil,
                refreshHint: .reloadSection
            )
        case .unsupported:
            return nil
        }
    }

    private static func currentValue(for label: String, on object: NSObject) -> Any? {
        mirroredChildren(for: object).first(where: { $0.label == label }).map(\.value)
    }

    private static func mirroredChildren(for object: NSObject) -> [Mirror.Child] {
        var children: [Mirror.Child] = []
        var mirror: Mirror? = Mirror(reflecting: object)
        while let current = mirror {
            children.append(contentsOf: current.children)
            mirror = current.superclassMirror
        }
        return children
    }

    private static func unwrap(_ value: Any) -> Any? {
        let mirror = Mirror(reflecting: value)
        guard mirror.displayStyle == .optional else { return value }
        return mirror.children.first?.value
    }

    private static func currentBoolValue(for label: String, on object: NSObject) -> Bool? {
        guard let value = currentValue(for: label, on: object).flatMap(unwrap) else { return nil }
        return value as? Bool
    }

    private static func currentNumberValue(for label: String, on object: NSObject) -> Double? {
        guard let value = currentValue(for: label, on: object).flatMap(unwrap) else { return nil }
        return numberValue(from: value)
    }

    private static func currentStringValue(for label: String, on object: NSObject) -> String? {
        guard let value = currentValue(for: label, on: object).flatMap(unwrap) else { return nil }
        if let string = value as? String { return string }
        if let string = value as? NSString { return string as String }
        return nil
    }

    private static func currentColorValue(for label: String, on object: NSObject) -> UIColor? {
        guard let value = currentValue(for: label, on: object).flatMap(unwrap) else { return nil }
        return value as? UIColor
    }

    private static func currentImageValue(for label: String, on object: NSObject) -> UIImage? {
        guard let value = currentValue(for: label, on: object).flatMap(unwrap) else { return nil }
        return value as? UIImage
    }

    private static func currentRectValue(for label: String, on object: NSObject) -> CGRect? {
        guard let value = currentValue(for: label, on: object).flatMap(unwrap) else { return nil }
        return value as? CGRect
    }

    private static func currentPointValue(for label: String, on object: NSObject) -> CGPoint? {
        guard let value = currentValue(for: label, on: object).flatMap(unwrap) else { return nil }
        return value as? CGPoint
    }

    private static func currentSizeValue(for label: String, on object: NSObject) -> CGSize? {
        guard let value = currentValue(for: label, on: object).flatMap(unwrap) else { return nil }
        return value as? CGSize
    }

    private static func currentOffsetValue(for label: String, on object: NSObject) -> UIOffset? {
        guard let value = currentValue(for: label, on: object).flatMap(unwrap) else { return nil }
        return value as? UIOffset
    }

    private static func currentEdgeInsetsValue(for label: String, on object: NSObject) -> UIEdgeInsets? {
        guard let value = currentValue(for: label, on: object).flatMap(unwrap) else { return nil }
        return value as? UIEdgeInsets
    }

    private static func currentDirectionalEdgeInsetsValue(for label: String, on object: NSObject) -> NSDirectionalEdgeInsets? {
        guard let value = currentValue(for: label, on: object).flatMap(unwrap) else { return nil }
        return value as? NSDirectionalEdgeInsets
    }

    private static func numberValue(from value: Any) -> Double? {
        switch value {
        case let int as Int: return Double(int)
        case let int as Int8: return Double(int)
        case let int as Int16: return Double(int)
        case let int as Int32: return Double(int)
        case let int as Int64: return Double(int)
        case let uint as UInt: return Double(uint)
        case let uint as UInt8: return Double(uint)
        case let uint as UInt16: return Double(uint)
        case let uint as UInt32: return Double(uint)
        case let uint as UInt64: return Double(uint)
        case let double as Double: return double
        case let float as Float: return Double(float)
        case let cgFloat as CGFloat: return Double(cgFloat)
        case let number as NSNumber:
            return CFGetTypeID(number) == CFBooleanGetTypeID() ? nil : number.doubleValue
        default:
            return nil
        }
    }

    private enum ReflectedFieldKind {
        case toggle(Bool)
        case number(Double, isDecimal: Bool)
        case string(String?)
        case color(UIColor?)
        case image(UIImage?)
        case rect(CGRect)
        case point(CGPoint)
        case size(CGSize)
        case offset(UIOffset)
        case edgeInsets(UIEdgeInsets)
        case directionalEdgeInsets(NSDirectionalEdgeInsets)
        case unsupported

        init(sampleValue: Any) {
            let mirror = Mirror(reflecting: sampleValue)
            let unwrapped: Any? = mirror.displayStyle == .optional ? mirror.children.first?.value : sampleValue

            if let value = unwrapped {
                switch value {
                case let value as Bool:
                    self = .toggle(value)
                case let value as String:
                    self = .string(value)
                case let value as NSString:
                    self = .string(value as String)
                case let value as UIColor:
                    self = .color(value)
                case let value as UIImage:
                    self = .image(value)
                case let value as CGRect:
                    self = .rect(value)
                case let value as CGPoint:
                    self = .point(value)
                case let value as CGSize:
                    self = .size(value)
                case let value as UIOffset:
                    self = .offset(value)
                case let value as UIEdgeInsets:
                    self = .edgeInsets(value)
                case let value as NSDirectionalEdgeInsets:
                    self = .directionalEdgeInsets(value)
                default:
                    if let number = Self.makeNumber(from: value) {
                        self = .number(number.value, isDecimal: number.isDecimal)
                    } else {
                        self = .unsupported
                    }
                }
            } else {
                let typeName = String(describing: Swift.type(of: sampleValue))
                if typeName.contains("String") {
                    self = .string(nil)
                } else if typeName.contains("UIColor") {
                    self = .color(nil)
                } else if typeName.contains("UIImage") {
                    self = .image(nil)
                } else {
                    self = .unsupported
                }
            }
        }

        private static func makeNumber(from value: Any) -> (value: Double, isDecimal: Bool)? {
            switch value {
            case is Int, is Int8, is Int16, is Int32, is Int64,
                 is UInt, is UInt8, is UInt16, is UInt32, is UInt64:
                return (InspectorAutobuiltAttributesSectionDataSource.numberValue(from: value) ?? 0, false)
            case is Float, is Double, is CGFloat:
                return (InspectorAutobuiltAttributesSectionDataSource.numberValue(from: value) ?? 0, true)
            case let number as NSNumber:
                guard CFGetTypeID(number) != CFBooleanGetTypeID() else { return nil }
                return (number.doubleValue, true)
            default:
                return nil
            }
        }
    }
}
