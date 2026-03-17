// Tests/InspectorMacrosTests/InspectorPanelMacroTests.swift

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
@testable import InspectorMacros

private let testMacros: [String: any Macro.Type] = [
    "InspectorPanel": InspectorPanelMacro.self,
    "InspectorProperty": InspectorPropertyMacro.self
]

final class InspectorPanelMacroTests: XCTestCase {

    func testBasicColorPickerExpansion() {
        assertMacroExpansion(
            """
            @InspectorPanel(title: "My Card View")
            class MyCardView: UIView {
                @InspectorProperty(.colorPicker)
                var borderColor: UIColor = .clear
            }
            """,
            expandedSource: """
            class MyCardView: UIView {
                var borderColor: UIColor = .clear
            }
            """,
            macros: testMacros
        )
    }
}
