// Tests/InspectorMacrosTests/PropertyDescriptorParserTests.swift

import XCTest
@testable import InspectorMacros

final class PropertyDescriptorParserTests: XCTestCase {

    // MARK: - Type inference

    func testBoolInfersSwitch() {
        XCTAssertEqual(PropertyDescriptorParser.inferDescriptor(forTypeName: "Bool"), .switch)
    }

    func testUIColorInfersColorPicker() {
        XCTAssertEqual(PropertyDescriptorParser.inferDescriptor(forTypeName: "UIColor"), .colorPicker)
    }

    func testOptionalUIColorInfersColorPicker() {
        XCTAssertEqual(PropertyDescriptorParser.inferDescriptor(forTypeName: "UIColor?"), .colorPicker)
    }

    func testCGFloatInfersStepper() {
        XCTAssertEqual(PropertyDescriptorParser.inferDescriptor(forTypeName: "CGFloat"), .stepper(range: 0...Double.infinity, step: 1))
    }

    func testStringInfersTextField() {
        XCTAssertEqual(PropertyDescriptorParser.inferDescriptor(forTypeName: "String"), .textField)
    }

    func testUnknownTypeReturnsNil() {
        XCTAssertNil(PropertyDescriptorParser.inferDescriptor(forTypeName: "MyCustomEnum"))
    }

    func testCGRectInfersCGRect() {
        XCTAssertEqual(PropertyDescriptorParser.inferDescriptor(forTypeName: "CGRect"), .cgRect)
    }
}
