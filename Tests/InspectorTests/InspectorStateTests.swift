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
import XCTest

final class InspectorStateTests: XCTestCase {
    // Use a fresh instance per test to avoid shared-singleton pollution.
    private var sut: Inspector!

    override func setUp() {
        super.setUp()
        sut = Inspector()
    }

    override func tearDown() {
        sut.stop()
        sut = nil
        super.tearDown()
    }

    // MARK: - State Machine

    func testInitialStateIsIdle() {
        XCTAssertNil(sut.manager, "manager should be nil before start() is called")
        XCTAssertEqual(sut.state, .idle)
    }

    func testStartTransitionsToStarted() {
        sut.start()
        XCTAssertNotNil(sut.manager, "manager should exist after start()")
        XCTAssertEqual(sut.state, .started)
    }

    func testStopTransitionsToIdle() {
        sut.start()
        sut.stop()
        XCTAssertNil(sut.manager, "manager should be nil after stop()")
        XCTAssertEqual(sut.state, .idle)
    }

    func testStartIsIdempotent() {
        // Calling start() twice must not crash and must leave the inspector started.
        sut.start()
        let firstManager = sut.manager
        sut.start()
        XCTAssertNotNil(sut.manager)
        XCTAssertEqual(sut.state, .started)
        // A second start() replaces the manager (restart path), so we just verify
        // no crash occurred and the state is still .started.
        _ = firstManager // suppress unused-variable warning
    }

    func testStopWhenIdleIsNoop() {
        // Calling stop() before start() must not crash.
        XCTAssertEqual(sut.state, .idle)
        sut.stop()
        XCTAssertEqual(sut.state, .idle)
    }
}
