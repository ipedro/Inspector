import SwiftSyntax
import SwiftSyntaxMacros

/// A marker-only peer macro. Generates nothing.
/// @InspectorPanel reads @InspectorProperty annotations during its member scan.
public struct InspectorPropertyMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        return []
    }
}
