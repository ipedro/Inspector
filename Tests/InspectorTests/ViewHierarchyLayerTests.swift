//  Copyright (c) 2021 Pedro Almeida
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

@testable import Inspector
import UIKit
import XCTest

final class ViewHierarchyLayerTests: XCTestCase {

    // MARK: - Name

    func testLayerHasNonEmptyName() {
        let builtIns: [Inspector.ViewHierarchyLayer] = [
            .buttons,
            .scrollViews,
            .images,
            .staticTexts,
            .switches,
            .controls,
            .stackViews,
            .tables,
            .wireframes
        ]

        for layer in builtIns {
            XCTAssertFalse(layer.name.isEmpty, "Layer name should not be empty for \(layer.name)")
        }
    }

    // MARK: - Hashable

    func testLayerIsHashable() {
        let layer1 = Inspector.ViewHierarchyLayer.buttons
        let layer2 = Inspector.ViewHierarchyLayer.scrollViews

        var set = Set<Inspector.ViewHierarchyLayer>()
        set.insert(layer1)
        set.insert(layer2)
        set.insert(layer1) // duplicate

        XCTAssertEqual(set.count, 2, "Set should deduplicate identical layers")
    }

    func testLayerIsUsableAsDictionaryKey() {
        let layer = Inspector.ViewHierarchyLayer.buttons
        var dict = [Inspector.ViewHierarchyLayer: Int]()
        dict[layer] = 42
        XCTAssertEqual(dict[layer], 42)
    }

    // MARK: - Comparable

    func testLayerIsComparableAlphabetically() {
        // "Buttons" < "Scroll Views" alphabetically
        let buttons = Inspector.ViewHierarchyLayer.buttons
        let scrollViews = Inspector.ViewHierarchyLayer.scrollViews
        XCTAssertLessThan(buttons, scrollViews)
    }

    func testLayerSortedByTitle() {
        let layers: [Inspector.ViewHierarchyLayer] = [.wireframes, .buttons, .images, .maps]
        let sorted = layers.sorted()
        // Verify ascending alphabetical order by description/title
        for i in 0 ..< sorted.count - 1 {
            XCTAssertLessThanOrEqual(
                sorted[i].description.localizedLowercase,
                sorted[i + 1].description.localizedLowercase
            )
        }
    }

    // MARK: - Built-in layers

    func testBuiltInLayersExist() {
        // Verify static members compile and return non-trivially named layers
        XCTAssertEqual(Inspector.ViewHierarchyLayer.buttons.name, "Buttons")
        XCTAssertEqual(Inspector.ViewHierarchyLayer.scrollViews.name, "Scroll Views")
        XCTAssertEqual(Inspector.ViewHierarchyLayer.images.name, "Images")
        XCTAssertEqual(Inspector.ViewHierarchyLayer.staticTexts.name, "Static Texts")
        XCTAssertEqual(Inspector.ViewHierarchyLayer.switches.name, "Switches")
        XCTAssertEqual(Inspector.ViewHierarchyLayer.tables.name, "Tables")
        XCTAssertEqual(Inspector.ViewHierarchyLayer.stackViews.name, "Stacks")
        XCTAssertEqual(Inspector.ViewHierarchyLayer.wireframes.name, "Wireframes")
    }

    // MARK: - Filter closure

    func testLayerFilterMatchesUIButton() {
        let layer = Inspector.ViewHierarchyLayer.buttons
        let button = UIButton()
        XCTAssertTrue(layer.filter(button), ".buttons filter should match UIButton")
    }

    func testLayerFilterRejectsUILabel() {
        let layer = Inspector.ViewHierarchyLayer.buttons
        let label = UILabel()
        XCTAssertFalse(layer.filter(label), ".buttons filter should reject UILabel")
    }

    func testLayerFilterMatchesUIScrollView() {
        let layer = Inspector.ViewHierarchyLayer.scrollViews
        let scrollView = UIScrollView()
        XCTAssertTrue(layer.filter(scrollView), ".scrollViews filter should match UIScrollView")
    }

    func testLayerFilterMatchesUIImageView() {
        let layer = Inspector.ViewHierarchyLayer.images
        let imageView = UIImageView()
        XCTAssertTrue(layer.filter(imageView), ".images filter should match UIImageView")
    }

    func testLayerFilterMatchesUILabel() {
        let layer = Inspector.ViewHierarchyLayer.staticTexts
        let label = UILabel()
        XCTAssertTrue(layer.filter(label), ".staticTexts filter should match UILabel")
    }

    func testLayerFilterMatchesUISwitch() {
        let layer = Inspector.ViewHierarchyLayer.switches
        let sw = UISwitch()
        XCTAssertTrue(layer.filter(sw), ".switches filter should match UISwitch")
    }

    func testLayerFilterRejectsUISwitchForButtons() {
        let layer = Inspector.ViewHierarchyLayer.buttons
        let sw = UISwitch()
        // UISwitch is a UIControl/UIView but NOT a UIButton
        XCTAssertFalse(layer.filter(sw), ".buttons filter should reject UISwitch")
    }

    // MARK: - Flags

    func testAllowsInternalViewsFlagDefaultsToFalse() {
        let layer = Inspector.ViewHierarchyLayer.scrollViews
        XCTAssertFalse(layer.allowsInternalViews)
    }

    func testAllowsInternalViewsFlagTrueForButtonsLayer() {
        // .buttons is defined with allowsInternalViews: true
        let layer = Inspector.ViewHierarchyLayer.buttons
        XCTAssertTrue(layer.allowsInternalViews)
    }

    func testAllowsSystemContainersFlagDefaultsToFalse() {
        let layer = Inspector.ViewHierarchyLayer.scrollViews
        XCTAssertFalse(layer.allowsSystemContainers)
    }

    func testAllowsSystemContainersFlagTrueForSystemContainersLayer() {
        // .systemContainers is defined with allowsSystemContainers: true
        let layer = Inspector.ViewHierarchyLayer.systemContainers
        XCTAssertTrue(layer.allowsSystemContainers)
    }

    func testCustomLayerFlagsDefaultToFalse() {
        let layer = Inspector.ViewHierarchyLayer.layer(name: "Custom") { _ in true }
        XCTAssertFalse(layer.allowsInternalViews)
        XCTAssertFalse(layer.allowsSystemContainers)
    }

    // MARK: - Custom layer factory

    func testLayerFactoryCreatesLayerWithCorrectName() {
        let layer = Inspector.ViewHierarchyLayer.layer(name: "My Layer") { _ in false }
        XCTAssertEqual(layer.name, "My Layer")
    }

    func testLayerFactoryFilterClosure() {
        let layer = Inspector.ViewHierarchyLayer.layer(name: "Labels Only") { $0 is UILabel }
        XCTAssertTrue(layer.filter(UILabel()))
        XCTAssertFalse(layer.filter(UIButton()))
    }
}
