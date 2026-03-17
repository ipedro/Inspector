// Tests/InspectorMacrosTests/CamelCaseConverterTests.swift

import XCTest
@testable import InspectorMacros

final class CamelCaseConverterTests: XCTestCase {

    func testSingleWord() {
        XCTAssertEqual(CamelCaseConverter.toDisplayName("color"), "Color")
    }

    func testTwoWords() {
        XCTAssertEqual(CamelCaseConverter.toDisplayName("borderColor"), "Border Color")
    }

    func testThreeWords() {
        XCTAssertEqual(CamelCaseConverter.toDisplayName("cornerRadius"), "Corner Radius")
    }

    func testAcronymHandling() {
        XCTAssertEqual(CamelCaseConverter.toDisplayName("isHidden"), "Is Hidden")
    }

    func testAlreadyCapitalized() {
        XCTAssertEqual(CamelCaseConverter.toDisplayName("showsBorder"), "Shows Border")
    }

    func testSingleCharacterSegments() {
        XCTAssertEqual(CamelCaseConverter.toDisplayName("xPosition"), "X Position")
    }

    func testConsecutiveUppercaseAcronym() {
        // Acronym run: space inserted before the last uppercase that starts a new word
        XCTAssertEqual(CamelCaseConverter.toDisplayName("URLString"), "URL String")
    }
}
