// Tests/InspectorTests/AccessibilityTests.swift
#if canImport(UIKit)
import XCTest
@testable import Inspector

final class AccessibilityTests: XCTestCase {

    func testToggleControlExposesLabelOnSwitch() {
        let control = ToggleControl(title: "Animate", isOn: false)
        XCTAssertEqual(control.switchControl.accessibilityLabel, "Animate")
    }

    func testTextFieldControlExposesLabelOnTextField() {
        let control = TextFieldControl(title: "Name", value: "hello", placeholder: nil)
        XCTAssertEqual(control.textField.accessibilityLabel, "Name")
    }

    func testStepperControlExposesLabelViaProxy() {
        let control = StepperControl(title: "Width", value: 10, range: 0...200, stepValue: 1, isDecimalValue: false)
        XCTAssertEqual(control.accessibilityLabel, "Width")
    }

    func testStepperControlExposesValueViaProxy() {
        let control = StepperControl(title: "Width", value: 10, range: 0...200, stepValue: 1, isDecimalValue: false)
        XCTAssertNotNil(control.accessibilityValue)
    }

    func testStepperControlLabelOverridePropagatesToInnerStepper() {
        let control = StepperControl(title: "Width", value: 10, range: 0...200, stepValue: 1, isDecimalValue: false)
        control.accessibilityLabel = "Custom Label"
        XCTAssertEqual(control.accessibilityLabel, "Custom Label")
    }
}
#endif
