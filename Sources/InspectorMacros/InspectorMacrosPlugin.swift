import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct InspectorMacrosPlugin: CompilerPlugin {
    let providingMacros: [any Macro.Type] = [
        InspectorPanelMacro.self,
        InspectorPropertyMacro.self,
    ]
}
