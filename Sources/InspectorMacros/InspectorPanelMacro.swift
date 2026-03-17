import SwiftSyntax
import SwiftSyntaxMacros

public struct InspectorPanelMacro: MemberMacro {
    // Use the 3-parameter form — the 4-parameter form (with `conformingTo:`) is only
    // called for macros declared with `@attached(member, conformances:...)`.
    // Using the wrong overload compiles but is silently never called.
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // TODO: full implementation in Tasks 4-6
        return []
    }
}
