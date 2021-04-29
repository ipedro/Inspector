import XCTest

import InspectorTests

var tests = [XCTestCaseEntry]()
tests += InspectorTests.allTests()
XCTMain(tests)
