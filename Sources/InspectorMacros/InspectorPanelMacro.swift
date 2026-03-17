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
                  binding.accessorBlock == nil, // stored property only
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
        let inspectorLibrarySource = generateInspectorLibrarySource(className: className)

        // 5. Wrap both in #if INSPECTOR_ENABLED using IfConfigDeclSyntax
        // NOTE: use .poundIfToken() — string literal will crash the compiler.
        let ifConfigDecl = IfConfigDeclSyntax(
            clauses: IfConfigClauseListSyntax([
                IfConfigClauseSyntax(
                    poundKeyword: .poundIfToken(trailingTrivia: .space),
                    condition: ExprSyntax(
                        DeclReferenceExprSyntax(baseName: .identifier("INSPECTOR_ENABLED"))
                    ),
                    elements: .decls(MemberBlockItemListSyntax([
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
        let enumCases = properties.map { prop in
            "        case \(prop.name) = \"\(escapedStringLiteral(prop.displayName))\""
        }.joined(separator: "\n")

        let switchCases = properties.map { prop in
            generateSwitchCase(prop: prop)
        }.joined(separator: "\n")

        return """
        final class SectionDataSource: InspectorElementSectionDataSource {
            var state: InspectorElementSectionState = .collapsed
            let title = "\(escapedStringLiteral(title))"
            private weak var element: \(className)?
            init?(with object: NSObject) {
                guard let element = object as? \(className) else { return nil }
                self.element = element
            }
            private enum Property: String, Swift.CaseIterable {
        \(enumCases)
            }
            var properties: [InspectorElementProperty] {
                guard let element else { return [] }
                return Property.allCases.flatMap { property -> [InspectorElementProperty] in
                    switch property {
        \(switchCases)
                    }
                }
            }
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
