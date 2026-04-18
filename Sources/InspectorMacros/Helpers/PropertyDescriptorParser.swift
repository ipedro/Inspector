// Sources/InspectorMacros/Helpers/PropertyDescriptorParser.swift

import SwiftSyntax

// MARK: - ResolvedDescriptor

/// The parsed/inferred descriptor for a single @InspectorProperty.
enum ResolvedDescriptor: Equatable {
    case `switch`
    case colorPicker
    case stepper(range: ClosedRange<Double>, step: Double)
    case textField
    case textView
    case imagePicker
    case optionsList(options: [String])
    case textButtonGroup(texts: [String])
    case cgRect
    case cgPoint
    case cgSize
    case uiOffset
    case edgeInsets
    case directionalInsets
    case group(title: String)
    case separator
    case infoNote(text: String)
    case subpanel
}

// MARK: - PropertyDescriptorParser

enum PropertyDescriptorParser {

    // MARK: Type inference

    /// Returns the default ResolvedDescriptor for a Swift type name, or nil if unsupported.
    static func inferDescriptor(forTypeName typeName: String) -> ResolvedDescriptor? {
        // Strip optional suffix
        let base = typeName.hasSuffix("?") ? String(typeName.dropLast()) : typeName
        switch base {
        case "Bool":                        return .switch
        case "UIColor":                     return .colorPicker
        case "CGFloat", "Double", "Float":  return .stepper(range: 0...Double.infinity, step: 1)
        case "String":                      return .textField
        case "CGRect":                      return .cgRect
        case "CGPoint":                     return .cgPoint
        case "CGSize":                      return .cgSize
        case "UIOffset":                    return .uiOffset
        case "UIEdgeInsets":                return .edgeInsets
        case "NSDirectionalEdgeInsets":     return .directionalInsets
        default:                            return nil
        }
    }

    // MARK: Attribute syntax parsing

    /// Parses the argument of an @InspectorProperty(...) attribute.
    /// Returns nil if the argument is `.auto` or absent (both mean "infer from type").
    static func parseDescriptor(from attribute: AttributeSyntax) -> ResolvedDescriptor? {
        // @InspectorProperty with no argument → auto
        guard let args = attribute.arguments?.as(LabeledExprListSyntax.self),
              let firstArg = args.first else {
            return nil // auto
        }

        let expr = firstArg.expression

        // Handle member access: .switch, .colorPicker, .cgRect, etc.
        if let memberAccess = expr.as(MemberAccessExprSyntax.self) {
            return parseSimpleCase(memberAccess.declName.baseName.text)
        }

        // Handle function calls: .stepper(range:step:), .optionsList(options:), etc.
        if let funcCall = expr.as(FunctionCallExprSyntax.self),
           let base = funcCall.calledExpression.as(MemberAccessExprSyntax.self) {
            return parseFunctionCase(base.declName.baseName.text, args: funcCall.arguments)
        }

        return nil // unknown syntax — treated as auto, error emitted by caller
    }

    // MARK: - Private

    private static func parseSimpleCase(_ name: String) -> ResolvedDescriptor? {
        switch name {
        case "switch":           return .switch
        case "colorPicker":      return .colorPicker
        case "textField":        return .textField
        case "textView":         return .textView
        case "imagePicker":      return .imagePicker
        case "cgRect":           return .cgRect
        case "cgPoint":          return .cgPoint
        case "cgSize":           return .cgSize
        case "uiOffset":         return .uiOffset
        case "edgeInsets":       return .edgeInsets
        case "directionalInsets": return .directionalInsets
        case "separator":        return .separator
        case "subpanel":         return .subpanel
        case "auto":             return nil // caller handles auto
        default:                 return nil
        }
    }

    private static func parseFunctionCase(
        _ name: String,
        args: LabeledExprListSyntax
    ) -> ResolvedDescriptor? {
        switch name {
        case "stepper":
            let range = extractDoubleClosedRange(from: args, label: "range") ?? 0...Double.infinity
            let step = extractDouble(from: args, label: "step") ?? 1.0
            return .stepper(range: range, step: step)

        case "optionsList":
            let options = extractStringArray(from: args, label: "options") ?? []
            return .optionsList(options: options)

        case "textButtonGroup":
            let texts = extractStringArray(from: args, label: "texts") ?? []
            return .textButtonGroup(texts: texts)

        case "group":
            let title = extractString(from: args, label: "title") ?? ""
            return .group(title: title)

        case "infoNote":
            let text = extractString(from: args, label: "text") ?? ""
            return .infoNote(text: text)

        default:
            return nil
        }
    }

    // MARK: Literal extractors

    private static func extractDouble(from args: LabeledExprListSyntax, label: String) -> Double? {
        guard let arg = args.first(where: { $0.label?.text == label }) else { return nil }
        let expr = arg.expression
        if let floatLit = expr.as(FloatLiteralExprSyntax.self) {
            return Double(floatLit.literal.text)
        }
        if let intLit = expr.as(IntegerLiteralExprSyntax.self) {
            return Double(intLit.literal.text)
        }
        return nil
    }

    private static func extractDoubleClosedRange(
        from args: LabeledExprListSyntax,
        label: String
    ) -> ClosedRange<Double>? {
        guard let arg = args.first(where: { $0.label?.text == label }) else { return nil }

        let raw = arg.expression.trimmedDescription
        let parts = raw.components(separatedBy: "...")
        guard parts.count == 2 else { return nil }

        func toDouble(_ raw: String) -> Double? {
            let value = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            if value == "Double.infinity" || value == ".infinity" || value == "infinity" {
                return Double.infinity
            }
            return Double(value)
        }

        guard let lo = toDouble(parts[0]),
              let hi = toDouble(parts[1]) else { return nil }
        return lo...hi
    }

    private static func extractString(from args: LabeledExprListSyntax, label: String) -> String? {
        guard let arg = args.first(where: { $0.label?.text == label }),
              let lit = arg.expression.as(StringLiteralExprSyntax.self),
              let seg = lit.segments.first?.as(StringSegmentSyntax.self) else { return nil }
        return seg.content.text
    }

    private static func extractStringArray(
        from args: LabeledExprListSyntax,
        label: String
    ) -> [String]? {
        guard let arg = args.first(where: { $0.label?.text == label }),
              let array = arg.expression.as(ArrayExprSyntax.self) else { return nil }
        return array.elements.compactMap { element in
            guard let lit = element.expression.as(StringLiteralExprSyntax.self),
                  let seg = lit.segments.first?.as(StringSegmentSyntax.self) else { return nil }
            return seg.content.text
        }
    }
}
