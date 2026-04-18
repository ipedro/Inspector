// Sources/InspectorMacros/InspectorPanelMacro.swift

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

// MARK: - String escaping

/// Escapes a user-supplied string for safe interpolation into a Swift string literal.
/// Without this, a title like `He said "Hello"` would produce malformed Swift.
private func escapedStringLiteral(_ s: String) -> String {
    s.replacingOccurrences(of: "\\", with: "\\\\")
     .replacingOccurrences(of: "\"", with: "\\\"")
}

// MARK: - Supporting types

struct InspectableProperty {
    let name: String
    let typeName: String
    let isOptional: Bool
    let displayName: String
    let descriptor: ResolvedDescriptor
}

// MARK: - InspectorPanelMacro

public struct InspectorPanelMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {

        // 1. Must be applied to a class
        guard let classDecl = declaration.as(ClassDeclSyntax.self) else {
            context.diagnose(Diagnostic(node: Syntax(node), message: InspectorMacroDiagnostic.notAClass))
            return []
        }

        let className = classDecl.name.text

        // 2. Get the title argument
        guard let labeledArgs = node.arguments?.as(LabeledExprListSyntax.self),
              let firstArg = labeledArgs.first,
              let titleLiteral = firstArg.expression.as(StringLiteralExprSyntax.self),
              let titleSegment = titleLiteral.segments.first?.as(StringSegmentSyntax.self),
              !titleSegment.content.text.isEmpty else {
            context.diagnose(Diagnostic(node: Syntax(node), message: InspectorMacroDiagnostic.missingTitle))
            return []
        }
        let title = titleSegment.content.text

        // 3. Collect @InspectorProperty-annotated stored properties
        let properties: [InspectableProperty] = classDecl.memberBlock.members.compactMap { member in
            guard let varDecl = member.decl.as(VariableDeclSyntax.self),
                  varDecl.bindingSpecifier.text == "var",
                  let binding = varDecl.bindings.first,
                  !binding.hasComputedAccessors, // stored property only (allow didSet/willSet)
                  let pattern = binding.pattern.as(IdentifierPatternSyntax.self),
                  let typeAnnotation = binding.typeAnnotation?.type else { return nil }

            // Find @InspectorProperty attribute
            guard varDecl.attributes.contains(where: { attr in
                attr.as(AttributeSyntax.self)?
                    .attributeName.as(IdentifierTypeSyntax.self)?
                    .name.text == "InspectorProperty"
            }) else { return nil }

            let inspectorAttr = varDecl.attributes.compactMap { $0.as(AttributeSyntax.self) }.first {
                $0.attributeName.as(IdentifierTypeSyntax.self)?.name.text == "InspectorProperty"
            }

            let rawTypeName = typeAnnotation.trimmedDescription
            let isOptional = rawTypeName.hasSuffix("?")
            let typeName = rawTypeName

            // Resolve descriptor: explicit → auto-inferred → error
            let resolvedDescriptor: ResolvedDescriptor
            if let explicit = inspectorAttr.flatMap({ PropertyDescriptorParser.parseDescriptor(from: $0) }) {
                resolvedDescriptor = explicit
            } else if let inferred = PropertyDescriptorParser.inferDescriptor(forTypeName: rawTypeName) {
                resolvedDescriptor = inferred
            } else {
                context.diagnose(Diagnostic(
                    node: Syntax(typeAnnotation),
                    message: InspectorMacroDiagnostic.unsupportedTypeForAutoDescriptor(typeName: rawTypeName)
                ))
                return nil
            }

            return InspectableProperty(
                name: pattern.identifier.text,
                typeName: typeName,
                isOptional: isOptional,
                displayName: CamelCaseConverter.toDisplayName(pattern.identifier.text),
                descriptor: resolvedDescriptor
            )
        }

        if properties.isEmpty {
            context.diagnose(Diagnostic(node: Syntax(node), message: InspectorMacroDiagnostic.noInspectableProperties))
        }

        // 4. Generate the two nested types as source strings
        let sectionDataSourceSource = generateSectionDataSourceSource(
            className: className,
            title: title,
            properties: properties
        )
        let sectionDescriptorSource = generateSectionDescriptorSource(
            className: className,
            title: title,
            properties: properties
        )
        let inspectorLibrarySource = generateInspectorLibrarySource(className: className)

        // 5. Wrap both in #if INSPECTOR_DEBUGGING using IfConfigDeclSyntax
        // NOTE: use .poundIfToken() — string literal will crash the compiler.
        let ifConfigDecl = IfConfigDeclSyntax(
            clauses: IfConfigClauseListSyntax([
                IfConfigClauseSyntax(
                    poundKeyword: .poundIfToken(trailingTrivia: .space),
                    condition: ExprSyntax(
                        DeclReferenceExprSyntax(baseName: .identifier("INSPECTOR_DEBUGGING"))
                    ),
                    elements: .decls(MemberBlockItemListSyntax([
                        MemberBlockItemSyntax(decl: DeclSyntax(stringLiteral: sectionDescriptorSource)),
                        MemberBlockItemSyntax(decl: DeclSyntax(stringLiteral: sectionDataSourceSource)),
                        MemberBlockItemSyntax(decl: DeclSyntax(stringLiteral: inspectorLibrarySource))
                    ]))
                )
            ])
        )

        return [DeclSyntax(ifConfigDecl)]
    }

    // MARK: - Source string generators

    private static func generateSectionDataSourceSource(
        className: String,
        title: String,
        properties: [InspectableProperty]
    ) -> String {
        let extraBindings = generateExtraBindingsSource(properties: properties)
        let sectionBindingSource = generateSectionBindingSource(className: className, properties: properties)

        return """
        final class SectionDataSource: InspectorElementSectionDataSource {
            var state: InspectorContract.InspectorElementSectionState = .collapsed
            let title = "\(escapedStringLiteral(title))"
            private weak var element: \(className)?
            init?(with object: NSObject) {
                guard let element = object as? \(className) else { return nil }
                self.element = element
            }
        \(sectionBindingSource)
            var sectionBinding: InspectorSectionBinding? {
                guard element != nil else { return nil }
                return makeInspectorSectionBinding()
            }
        \(extraBindings)
        }
        """
    }

    private static func generateExtraBindingsSource(properties: [InspectableProperty]) -> String {
        let entries = properties.compactMap { prop -> String? in
            guard case .subpanel = prop.descriptor else { return nil }
            let title = escapedStringLiteral(prop.displayName)
            let name = prop.name
            let type = prop.typeName.replacingOccurrences(of: "!", with: "")
            return """
                    "\(name)": {
                        guard let element = self.element, let child = element.\(name), let section = \(type).SectionDataSource(with: child) else { return [] }
                        return [
                            .init(
                                descriptor: .init(
                                    id: "group-\(name)",
                                    title: "\(title)",
                                    kind: .group,
                                    value: .none,
                                    editability: .readOnly
                                ),
                                read: { .none },
                                write: nil,
                                refreshHint: .none
                            )
                        ] + section.propertyBindings
                    }
            """
        }.joined(separator: ",\n")

        if entries.isEmpty {
            return "            var sectionBindingExtraBindings: [String: () -> [InspectorPropertyBinding]] { [:] }"
        }

        return """
            var sectionBindingExtraBindings: [String: () -> [InspectorPropertyBinding]] {
                [
        \(entries)
                ]
            }
        """
    }

    private static func generateSectionDescriptorSource(
        className _: String,
        title: String,
        properties: [InspectableProperty]
    ) -> String {
        let fieldLines = properties.map(generateDescriptorField).joined(separator: ",\n")

        return """
        static let inspectorSectionDescriptor: InspectorContract.InspectorSectionDescriptor = .init(
            id: "\(escapedStringLiteral(title))",
            title: "\(escapedStringLiteral(title))",
            defaultState: .collapsed,
            fields: [
        \(fieldLines)
            ]
        )
        """
    }

    private static func generateSectionBindingSource(className: String, properties: [InspectableProperty]) -> String {
        let lines = properties.enumerated().map { index, prop in
            generateBindingField(className: className, index: index, prop: prop)
        }.joined(separator: ",\n")

        return """
            func makeInspectorSectionBinding() -> InspectorSectionBinding {
                guard let element else {
                    return InspectorSectionBinding(
                        descriptor: \(className).inspectorSectionDescriptor,
                        fields: []
                    )
                }
                return InspectorSectionBinding(
                descriptor: \(className).inspectorSectionDescriptor,
                fields: [
        \(lines)
                ]
            )
            }
        """
    }

    private static func generateInspectorLibrarySource(className: String) -> String {
        return """
        struct InspectorLibrary: InspectorElementLibraryProtocol {
            var targetClass: AnyClass { \(className).self }
            func sections(for object: NSObject) -> InspectorElementSections {
                .init(with: SectionDataSource(with: object))
            }
        }
        """
    }

    private static func generateSwitchCase(prop: InspectableProperty) -> String {
        let body = generatePropertyBuilder(prop: prop)
        return """
                    case .\(prop.name):
        \(body)
        """
    }

    private static func generateDescriptorField(prop: InspectableProperty) -> String {
        let id = escapedStringLiteral(prop.name)
        let title = escapedStringLiteral(prop.displayName)
        let descriptor = contractDescriptor(for: prop)

        return """
                .init(
                    id: "\(id)",
                    title: "\(title)",
                    kind: \(descriptor.kind),
                    value: \(descriptor.value),
                    editability: \(descriptor.editability),
                    presentation: \(descriptor.presentation)
                )
        """
    }

    private static func generateBindingField(className: String, index: Int, prop: InspectableProperty) -> String {
        let n = prop.name
        let descriptorRef = "\(className).inspectorSectionDescriptor.fields[\(index)]"

        switch prop.descriptor {
        case .switch:
            return """
                .init(
                    descriptor: \(descriptorRef),
                    read: { .bool(element.\(n)) },
                    write: { value in
                        guard case let .bool(newValue) = value else { return }
                        element.\(n) = newValue
                    },
                    refreshHint: .reloadInspector
                )
            """
        case .colorPicker:
            if prop.isOptional {
                return """
                .init(
                    descriptor: \(descriptorRef),
                    read: { .color(element.\(n)) },
                    write: { value in
                        guard case let .color(newValue) = value else { return }
                        element.\(n) = newValue
                    },
                    refreshHint: .reloadInspector
                )
            """
            } else {
                return """
                .init(
                    descriptor: \(descriptorRef),
                    read: { .color(element.\(n)) },
                    write: { value in
                        guard case let .color(newValue) = value, let newValue else { return }
                        element.\(n) = newValue
                    },
                    refreshHint: .reloadInspector
                )
            """
            }
        case .stepper:
            let readExpr = prop.typeName == "CGFloat" ? ".number(Double(element.\(n)))" : ".number(element.\(n))"
            let writeExpr = prop.typeName == "CGFloat"
                ? "element.\(n) = CGFloat(newValue)"
                : "element.\(n) = newValue"
            return """
                .init(
                    descriptor: \(descriptorRef),
                    read: { \(readExpr) },
                    write: { value in
                        guard case let .number(newValue) = value else { return }
                        \(writeExpr)
                    },
                    refreshHint: .reloadInspector
                )
            """
        case .textField, .textView:
            return """
                .init(
                    descriptor: \(descriptorRef),
                    read: { .string(element.\(n)) },
                    write: { value in
                        guard case let .string(newValue) = value else { return }
                        element.\(n) = newValue ?? ""
                    },
                    refreshHint: .reloadInspector
                )
            """
        case .cgRect:
            return """
                .init(
                    descriptor: \(descriptorRef),
                    read: { .rect(element.\(n)) },
                    write: { value in
                        guard case let .rect(newValue) = value else { return }
                        element.\(n) = newValue
                    },
                    refreshHint: .reloadInspector
                )
            """
        case .cgPoint:
            return """
                .init(
                    descriptor: \(descriptorRef),
                    read: { .point(element.\(n)) },
                    write: { value in
                        guard case let .point(newValue) = value else { return }
                        element.\(n) = newValue
                    },
                    refreshHint: .reloadInspector
                )
            """
        case .cgSize:
            return """
                .init(
                    descriptor: \(descriptorRef),
                    read: { .size(element.\(n)) },
                    write: { value in
                        guard case let .size(newValue) = value else { return }
                        element.\(n) = newValue
                    },
                    refreshHint: .reloadInspector
                )
            """
        case .uiOffset:
            return """
                .init(
                    descriptor: \(descriptorRef),
                    read: { .offset(element.\(n)) },
                    write: { value in
                        guard case let .offset(newValue) = value else { return }
                        element.\(n) = newValue
                    },
                    refreshHint: .reloadInspector
                )
            """
        case .edgeInsets:
            return """
                .init(
                    descriptor: \(descriptorRef),
                    read: { .edgeInsets(element.\(n)) },
                    write: { value in
                        guard case let .edgeInsets(newValue) = value else { return }
                        element.\(n) = newValue
                    },
                    refreshHint: .reloadInspector
                )
            """
        case .directionalInsets:
            return """
                .init(
                    descriptor: \(descriptorRef),
                    read: { .directionalEdgeInsets(element.\(n)) },
                    write: { value in
                        guard case let .directionalEdgeInsets(newValue) = value else { return }
                        element.\(n) = newValue
                    },
                    refreshHint: .reloadInspector
                )
            """
        case .optionsList, .textButtonGroup:
            return """
                .init(
                    descriptor: \(descriptorRef),
                    read: { .selection(element.\(n)) },
                    write: { value in
                        guard case let .selection(newValue) = value else { return }
                        element.\(n) = newValue
                    },
                    refreshHint: .reloadInspector
                )
            """
        case .imagePicker:
            return """
                .init(
                    descriptor: \(descriptorRef),
                    read: { .image(element.\(n)) },
                    write: { value in
                        guard case let .image(newValue) = value else { return }
                        element.\(n) = newValue
                    },
                    refreshHint: .reloadInspector
                )
            """
        case .group, .separator, .infoNote, .subpanel:
            return """
                .init(
                    descriptor: \(descriptorRef),
                    read: { .none },
                    write: nil,
                    refreshHint: .none
                )
            """
        }
    }

    private static func contractDescriptor(for prop: InspectableProperty) -> (kind: String, value: String, editability: String, presentation: String) {
        let editable = ".editable"
        let readOnly = ".readOnly"

        switch prop.descriptor {
        case .switch:
            return (".toggle", ".bool", editable, "nil")
        case .colorPicker:
            return (".color", ".color(allowsNil: \(prop.isOptional ? "true" : "false"))", editable, "nil")
        case .stepper(let range, let step):
            let lo = range.lowerBound == 0 ? "0.0" : "\(range.lowerBound)"
            let hi = range.upperBound == Double.infinity ? "Double.infinity" : "\(range.upperBound)"
            let stepStr = step == 1.0 ? "1.0" : "\(step)"
            let isDecimal = (prop.typeName == "CGFloat" || prop.typeName == "Double" || prop.typeName == "Float") ? "true" : "false"
            return (
                ".stepper",
                ".number(.init(min: \(lo), max: \(hi), step: \(stepStr), isDecimal: \(isDecimal)))",
                editable,
                "nil"
            )
        case .textField:
            return (".textField", ".string(.init(multiline: false, placeholder: nil, allowsNil: false))", editable, "nil")
        case .textView:
            return (".textView", ".string(.init(multiline: true, placeholder: nil, allowsNil: false))", editable, "nil")
        case .imagePicker:
            return (".preview", ".none", editable, "nil")
        case .optionsList(let options):
            let rendered = options.enumerated().map { index, option in
                ".init(id: \"\(index)\", title: \"\(escapedStringLiteral(option))\")"
            }.joined(separator: ", ")
            return (".options", ".selection(.init(options: [\(rendered)], allowsNil: true))", editable, "nil")
        case .textButtonGroup(let texts):
            let rendered = texts.enumerated().map { index, option in
                ".init(id: \"\(index)\", title: \"\(escapedStringLiteral(option))\")"
            }.joined(separator: ", ")
            return (".textButtons", ".selection(.init(options: [\(rendered)], allowsNil: true))", editable, "nil")
        case .cgRect:
            return (".preview", ".rect", editable, "nil")
        case .cgPoint:
            return (".preview", ".point", editable, "nil")
        case .cgSize:
            return (".preview", ".size", editable, "nil")
        case .uiOffset:
            return (".preview", ".offset", editable, "nil")
        case .edgeInsets:
            return (".preview", ".edgeInsets", editable, "nil")
        case .directionalInsets:
            return (".preview", ".directionalEdgeInsets", editable, "nil")
        case .group(let groupTitle):
            return (".group", ".none", readOnly, ".init(subtitle: \"\(escapedStringLiteral(groupTitle))\")")
        case .separator:
            return (".separator", ".none", readOnly, "nil")
        case .infoNote(let text):
            return (".note", ".none", readOnly, ".init(subtitle: \"\(escapedStringLiteral(text))\", noteStyle: .info)")
        case .subpanel:
            return (".subpanel", ".none", readOnly, "nil")
        }
    }

    private static func generatePropertyBuilder(prop: InspectableProperty) -> String {
        let name = prop.name
        let displayName = "property.rawValue"

        let n = name
        let dn = displayName

        switch prop.descriptor {
        case .switch:
            return """
            return [.switch(
                title: \(dn),
                isOn: { element.\(n) },
                handler: { element.\(n) = $0 }
            )]
            """
        case .colorPicker:
            if prop.isOptional {
                return """
                return [.colorPicker(
                    title: \(dn),
                    color: { element.\(n) },
                    handler: { element.\(n) = $0 }
                )]
                """
            } else {
                return """
                return [.colorPicker(
                    title: \(dn),
                    color: { element.\(n) },
                    handler: { newColor in
                        if let newColor { element.\(n) = newColor }
                    }
                )]
                """
            }
        case .stepper(let range, let step):
            let lo = range.lowerBound == 0 ? "0.0" : "\(range.lowerBound)"
            let hi = range.upperBound == Double.infinity ? "Double.infinity" : "\(range.upperBound)"
            let stepStr = step == 1.0 ? "1.0" : "\(step)"
            let isDecimal = (prop.typeName == "CGFloat" || prop.typeName == "Double" || prop.typeName == "Float")
            let valueExpr = prop.typeName == "CGFloat" ? "Double(element.\(n))" : "element.\(n)"
            let handlerExpr = prop.typeName == "CGFloat" ? "element.\(n) = CGFloat($0)" : "element.\(n) = $0"
            return """
            return [.stepper(
                title: \(dn),
                value: { \(valueExpr) },
                range: { \(lo)...\(hi) },
                stepValue: { \(stepStr) },
                isDecimalValue: \(isDecimal),
                handler: { \(handlerExpr) }
            )]
            """
        case .textField:
            return """
            return [.textField(
                title: \(dn),
                placeholder: nil,
                value: { element.\(n) },
                handler: { element.\(n) = $0 ?? "" }
            )]
            """
        case .textView:
            return """
            return [.textView(
                title: \(dn),
                placeholder: nil,
                value: { element.\(n) },
                handler: { element.\(n) = $0 ?? "" }
            )]
            """
        case .cgRect:
            return """
            return [.cgRect(
                title: \(dn),
                rect: { element.\(n) },
                handler: { element.\(n) = $0 ?? .zero }
            )]
            """
        case .cgPoint:
            return """
            return [.cgPoint(
                title: \(dn),
                point: { element.\(n) },
                handler: { element.\(n) = $0 ?? .zero }
            )]
            """
        case .cgSize:
            return """
            return [.cgSize(
                title: \(dn),
                size: { element.\(n) },
                handler: { element.\(n) = $0 ?? .zero }
            )]
            """
        case .uiOffset:
            return """
            return [.uiOffset(
                title: \(dn),
                offset: { element.\(n) },
                handler: { element.\(n) = $0 }
            )]
            """
        case .edgeInsets:
            return """
            return [.edgeInsets(
                title: \(dn),
                insets: { element.\(n) },
                handler: { element.\(n) = $0 }
            )]
            """
        case .directionalInsets:
            return """
            return [.directionalInsets(
                title: \(dn),
                insets: { element.\(n) },
                handler: { element.\(n) = $0 }
            )]
            """
        case .optionsList(let options):
            let optionsList = options.map { "\"\(escapedStringLiteral($0))\"" }.joined(separator: ", ")
            return """
            return [.optionsList(
                title: \(dn),
                options: [\(optionsList)],
                selectedIndex: { element.\(n) },
                handler: { element.\(n) = $0 }
            )]
            """
        case .textButtonGroup(let texts):
            let textsList = texts.map { "\"\(escapedStringLiteral($0))\"" }.joined(separator: ", ")
            return """
            return [.textButtonGroup(
                title: \(dn),
                texts: [\(textsList)],
                selectedIndex: { element.\(n) },
                handler: { element.\(n) = $0 }
            )]
            """
        case .group(let groupTitle):
            return "return [.group(title: \"\(escapedStringLiteral(groupTitle))\")]"
        case .separator:
            return "return [.separator]"
        case .infoNote(let text):
            return "return [.infoNote(text: \"\(escapedStringLiteral(text))\")]"
        case .imagePicker:
            return """
            return [.imagePicker(
                title: \(dn),
                image: { element.\(n) },
                handler: { element.\(n) = $0 }
            )]
            """
        case .subpanel:
            let baseType = prop.typeName.trimmingCharacters(in: .init(charactersIn: "!?"))
            return """
            guard let child = element.\(n) else { return [] }
            return [.group(title: \(dn))] + (\(baseType).SectionDataSource(with: child)?.properties ?? [])
            """
        }
    }
}

extension PatternBindingSyntax {
    var hasComputedAccessors: Bool {
        guard let block = accessorBlock else { return false }

        switch block.accessors {
        case .accessors(let list):
            return list.contains { accessor in
                accessor.accessorSpecifier.text == "get" || accessor.accessorSpecifier.text == "set"
            }
        case .getter:
            return true
        @unknown default:
            return true
        }
    }
}
