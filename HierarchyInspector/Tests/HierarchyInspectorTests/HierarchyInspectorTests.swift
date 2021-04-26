import XCTest
@testable import HierarchyInspector

final class HierarchyInspectorTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(HierarchyInspector().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
