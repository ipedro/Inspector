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

#if canImport(UIKit)
@testable import Inspector
import XCTest

final class InspectorConfigurationTests: XCTestCase {
    // MARK: - Defaults

    func testDefaultConfigurationExists() {
        // .default must be reachable without crashing.
        let config = InspectorConfiguration.default
        _ = config
    }

    func testDefaultLayersAreNonEmpty() {
        let config = InspectorConfiguration.default
        XCTAssertFalse(config.defaultLayers.isEmpty, "defaultLayers should contain at least one layer")
    }

    func testSnapshotExpirationIsPositive() {
        let config = InspectorConfiguration.default
        XCTAssertGreaterThan(config.snapshotExpirationTimeInterval, 0,
                             "snapshotExpirationTimeInterval should be > 0")
    }

    func testSnapshotMaxCountIsPositive() {
        let config = InspectorConfiguration.default
        XCTAssertGreaterThanOrEqual(config.snapshotMaxCount, 1,
                                   "snapshotMaxCount should be >= 1")
    }

    func testVerboseDefaultsToFalse() {
        let config = InspectorConfiguration.default
        XCTAssertFalse(config.verbose, "verbose should default to false")
    }

    func testEnableLayoutSubviewsSwizzlingDefaultsToFalse() {
        let config = InspectorConfiguration.default
        XCTAssertFalse(config.enableLayoutSubviewsSwizzling,
                       "enableLayoutSubviewsSwizzling should default to false")
    }

    // MARK: - Builder Pattern

    func testConfigBuilderSetsValues() {
        let expiration: TimeInterval = 5
        let nonInspectable = ["SomePrivateClass"]
        let searchQuery = "myQuery"

        let config = InspectorConfiguration.config(
            enableLayoutSubviewsSwizzling: true,
            nonInspectableClassNames: nonInspectable,
            showAllViewSearchQuery: searchQuery,
            snapshotExpiration: expiration,
            showFullApplicationHierarchy: true,
            verbose: true
        )

        XCTAssertTrue(config.enableLayoutSubviewsSwizzling)
        XCTAssertEqual(config.nonInspectableClassNames, nonInspectable)
        XCTAssertEqual(config.showAllViewSearchQuery, searchQuery)
        XCTAssertEqual(config.snapshotExpirationTimeInterval, expiration)
        XCTAssertTrue(config.showFullApplicationHierarchy)
        XCTAssertTrue(config.verbose)
    }
}
#endif
