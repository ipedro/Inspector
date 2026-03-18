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
}
#endif
