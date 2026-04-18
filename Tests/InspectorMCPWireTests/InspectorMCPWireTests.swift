import Foundation
import InspectorMCPWire
import XCTest

final class InspectorMCPWireTests: XCTestCase {
    func testEndpointConstantsFreezeLocalhostContract() {
        XCTAssertEqual(InspectorMCPBridgeEndpoint.host, "127.0.0.1")
        XCTAssertEqual(InspectorMCPBridgeEndpoint.port, 49_321)
        XCTAssertEqual(InspectorMCPBridgeEndpoint.baseURL.absoluteString, "http://127.0.0.1:49321")
        XCTAssertEqual(InspectorMCPBridgeEndpoint.healthPath, "/health")
        XCTAssertEqual(InspectorMCPBridgeEndpoint.queryPath, "/query")
        XCTAssertEqual(InspectorMCPBridgeEndpoint.resolvePath, "/resolve")
        XCTAssertEqual(InspectorMCPBridgeEndpoint.snapshotPath, "/snapshot")
        XCTAssertEqual(InspectorMCPBridgeEndpoint.tapPath, "/tap")
        XCTAssertEqual(InspectorMCPBridgeEndpoint.actionsPath, "/actions")
        XCTAssertEqual(InspectorMCPBridgeEndpoint.performActionPath, "/perform-action")
        XCTAssertEqual(InspectorMCPBridgeEndpoint.assertPropertyPath, "/assert-property")
        XCTAssertEqual(InspectorMCPBridgeEndpoint.assertVisiblePath, "/assert-visible")
        XCTAssertEqual(InspectorMCPBridgeEndpoint.assertHierarchyContainsPath, "/assert-hierarchy-contains")
        XCTAssertEqual(InspectorMCPBridgeEndpoint.captureStatePath, "/capture-state")
        XCTAssertEqual(InspectorMCPBridgeEndpoint.diffStatesPath, "/diff-states")
        XCTAssertEqual(InspectorMCPBridgeEndpoint.propertiesPath, "/properties")
        XCTAssertEqual(InspectorMCPBridgeEndpoint.setPropertyPath, "/set-property")
    }

    func testHealthResponseRoundTripsThroughJSON() throws {
        let response = InspectorMCPHealthResponse(
            status: .active,
            bridgeEnabled: true,
            inspectorStarted: true,
            keyboardWindowsFiltered: false,
            bundleIdentifier: "am.pedro.Inspector",
            operations: [.query, .resolve, .snapshot]
        )

        let decoded = try roundTrip(response)

        XCTAssertEqual(decoded, response)
    }

    func testQuerySuccessEnvelopeRoundTripsFrozenNodeShape() throws {
        let node = InspectorMCPNode(
            handle: "handle-1",
            nodeKind: .view,
            backingObjectType: "UIStackView",
            className: "UIStackView",
            displayName: "Content Stack View",
            elementName: "Content Stack View",
            accessibilityIdentifier: "Content Stack View",
            frame: .init(x: 10, y: 20, width: 30, height: 40),
            isHidden: false,
            isUserInteractionEnabled: true,
            isInternalView: false,
            isSystemContainer: false,
            depth: 3,
            parentHandle: "parent-handle",
            childHandles: ["child-1", "child-2"],
            childCount: 2
        )
        let result = InspectorMCPQueryResult(
            expiresAt: Date(timeIntervalSince1970: 1_713_353_600),
            nodes: [node]
        )
        let envelope = InspectorMCPSuccessEnvelope(result: result)

        let decoded = try roundTrip(envelope)

        XCTAssertEqual(decoded, envelope)
    }

    func testTransportErrorEnvelopeCarriesFrozenCodesAndDetails() throws {
        let envelope = InspectorMCPFailureEnvelope(
            error: .init(
                code: .snapshotUnavailable,
                message: "Snapshot failed",
                details: .snapshotUnavailable(reason: .captureFailed)
            )
        )

        let decoded = try roundTrip(envelope)

        XCTAssertEqual(decoded, envelope)
    }

    func testHealthResponseRoundTripsApiVersion() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        let response = InspectorMCPHealthResponse(
            status: .active,
            bridgeEnabled: true,
            inspectorStarted: true,
            keyboardWindowsFiltered: true,
            bundleIdentifier: "com.example",
            operations: [.query, .resolve, .snapshot],
            apiVersion: 2
        )

        let data = try encoder.encode(response)
        let decoded = try decoder.decode(InspectorMCPHealthResponse.self, from: data)

        XCTAssertEqual(decoded.apiVersion, 2)
    }

    func testHealthResponseDecodesWithoutApiVersionField() throws {
        let legacy = #"{"status":"active","bridgeEnabled":true,"inspectorStarted":true,"bundleIdentifier":"com.example","operations":["query","resolve","snapshot"]}"#
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(InspectorMCPHealthResponse.self, from: Data(legacy.utf8))

        XCTAssertNil(decoded.apiVersion)
    }

    func testSnapshotResultRoundTripsNewShape() throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let createdAt = ISO8601DateFormatter().date(from: "2026-04-17T10:00:00Z")!
        let result = InspectorMCPSnapshotResult(
            handle: "HANDLE",
            mimeType: "image/png",
            pngPath: "/tmp/inspector-snapshots/abc.png",
            size: .init(width: 402, height: 874),
            deviceScale: 3,
            createdAt: createdAt
        )

        let data = try encoder.encode(result)
        let decoded = try decoder.decode(InspectorMCPSnapshotResult.self, from: data)

        XCTAssertEqual(decoded.pngPath, "/tmp/inspector-snapshots/abc.png")
        XCTAssertEqual(decoded.deviceScale, 3)
        XCTAssertEqual(decoded.createdAt, createdAt)
        XCTAssertEqual(decoded.mimeType, "image/png")
    }

    func testInspectOperationIsInAllCases() {
        XCTAssertTrue(InspectorMCPOperation.allCases.contains(.inspect),
                      "InspectorMCPOperation.inspect must be a declared case")
    }

    func testInspectRequestRoundTrips() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        let request = InspectorMCPInspectRequest(handle: "HANDLE-1")

        let data = try encoder.encode(request)
        let decoded = try decoder.decode(InspectorMCPInspectRequest.self, from: data)

        XCTAssertEqual(decoded.handle, "HANDLE-1")
    }

    func testInspectResultRoundTrips() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        let result = InspectorMCPInspectResult(handle: "HANDLE-2", presented: true)

        let data = try encoder.encode(result)
        let decoded = try decoder.decode(InspectorMCPInspectResult.self, from: data)

        XCTAssertEqual(decoded.handle, "HANDLE-2")
        XCTAssertTrue(decoded.presented)
    }

    func testInspectPathMatchesRouteConstant() {
        XCTAssertEqual(InspectorMCPBridgeEndpoint.inspectPath, "/inspect")
    }

    func testTapOperationIsInAllCases() {
        XCTAssertTrue(InspectorMCPOperation.allCases.contains(.tap),
                      "InspectorMCPOperation.tap must be a declared case")
    }

    func testTapRequestRoundTrips() throws {
        let request = InspectorMCPTapRequest(handle: "HANDLE-3")

        let decoded = try roundTrip(request)

        XCTAssertEqual(decoded.handle, "HANDLE-3")
    }

    func testTapResultRoundTrips() throws {
        let result = InspectorMCPTapResult(handle: "HANDLE-4", dispatched: true)

        let decoded = try roundTrip(result)

        XCTAssertEqual(decoded.handle, "HANDLE-4")
        XCTAssertTrue(decoded.dispatched)
    }

    func testTapPathMatchesRouteConstant() {
        XCTAssertEqual(InspectorMCPBridgeEndpoint.tapPath, "/tap")
    }

    func testListActionsOperationIsInAllCases() {
        XCTAssertTrue(InspectorMCPOperation.allCases.contains(.listActions))
    }

    func testPerformActionOperationIsInAllCases() {
        XCTAssertTrue(InspectorMCPOperation.allCases.contains(.performAction))
    }

    func testActionListRequestRoundTrips() throws {
        let request = InspectorMCPActionListRequest(handle: "HANDLE-A")
        let decoded = try roundTrip(request)
        XCTAssertEqual(decoded, request)
    }

    func testPerformActionRequestRoundTrips() throws {
        let request = InspectorMCPPerformActionRequest(actionRef: "ACTION-1")
        let decoded = try roundTrip(request)
        XCTAssertEqual(decoded, request)
    }

    func testActionListResultRoundTrips() throws {
        let result = InspectorMCPActionListResult(
            handle: "HANDLE-A",
            expiresAt: Date(timeIntervalSince1970: 1_713_353_600),
            actions: [
                .init(actionRef: "ACTION-1", title: "Inspect Attributes", kind: .inspect),
                .init(actionRef: "ACTION-2", title: "Highlight Views", kind: .showHighlight)
            ]
        )
        let decoded = try roundTrip(result)
        XCTAssertEqual(decoded, result)
    }

    func testPerformActionResultRoundTrips() throws {
        let result = InspectorMCPPerformActionResult(actionRef: "ACTION-3", performed: true, refreshRecommended: true)
        let decoded = try roundTrip(result)
        XCTAssertEqual(decoded, result)
    }

    func testAssertPropertyOperationIsInAllCases() {
        XCTAssertTrue(InspectorMCPOperation.allCases.contains(.assertProperty))
    }

    func testAssertVisibleOperationIsInAllCases() {
        XCTAssertTrue(InspectorMCPOperation.allCases.contains(.assertVisible))
    }

    func testAssertHierarchyContainsOperationIsInAllCases() {
        XCTAssertTrue(InspectorMCPOperation.allCases.contains(.assertHierarchyContains))
    }

    func testAssertPropertyRequestRoundTrips() throws {
        let request = InspectorMCPAssertPropertyRequest(handle: "HANDLE-ASSERT", property: .isHidden, boolValue: false)
        XCTAssertEqual(try roundTrip(request), request)
    }

    func testAssertVisibleRequestRoundTrips() throws {
        let request = InspectorMCPAssertVisibleRequest(handle: "HANDLE-VISIBLE")
        XCTAssertEqual(try roundTrip(request), request)
    }

    func testAssertHierarchyContainsRequestRoundTrips() throws {
        let request = InspectorMCPAssertHierarchyContainsRequest(classNameContains: "UIButton", minimumCount: 2)
        XCTAssertEqual(try roundTrip(request), request)
    }

    func testAssertPropertyResultRoundTrips() throws {
        let result = InspectorMCPAssertPropertyResult(handle: "HANDLE", property: .className, passed: true, actualString: "UIButton", message: "className is UIButton")
        XCTAssertEqual(try roundTrip(result), result)
    }

    func testAssertVisibleResultRoundTrips() throws {
        let result = InspectorMCPAssertVisibleResult(handle: "HANDLE", passed: true, isHidden: false, message: "node is visible")
        XCTAssertEqual(try roundTrip(result), result)
    }

    func testAssertHierarchyContainsResultRoundTrips() throws {
        let result = InspectorMCPAssertHierarchyContainsResult(passed: true, matchCount: 2, minimumCount: 1, message: "hierarchy matched 2 node(s)")
        XCTAssertEqual(try roundTrip(result), result)
    }

    func testCaptureStateOperationIsInAllCases() {
        XCTAssertTrue(InspectorMCPOperation.allCases.contains(.captureState))
    }

    func testDiffStatesOperationIsInAllCases() {
        XCTAssertTrue(InspectorMCPOperation.allCases.contains(.diffStates))
    }

    func testCaptureStateRequestRoundTrips() throws {
        XCTAssertEqual(try roundTrip(InspectorMCPCaptureStateRequest()), InspectorMCPCaptureStateRequest())
    }

    func testDiffStatesRequestRoundTrips() throws {
        let request = InspectorMCPDiffStatesRequest(beforeRef: "A", afterRef: "B")
        XCTAssertEqual(try roundTrip(request), request)
    }

    func testCapturedStateRoundTrips() throws {
        let result = InspectorMCPCapturedState(stateRef: "STATE", createdAt: Date(timeIntervalSince1970: 1_713_353_600), nodeCount: 42)
        XCTAssertEqual(try roundTrip(result), result)
    }

    func testStateDiffRoundTrips() throws {
        let result = InspectorMCPStateDiff(
            beforeRef: "A",
            afterRef: "B",
            addedCount: 1,
            removedCount: 2,
            changedCount: 3,
            entries: [
                .init(signature: "sig", kind: .changed, className: "UIButton", elementName: "Button", accessibilityIdentifier: "cta")
            ]
        )
        XCTAssertEqual(try roundTrip(result), result)
    }

    func testListPropertiesOperationIsInAllCases() {
        XCTAssertTrue(InspectorMCPOperation.allCases.contains(.listProperties))
    }

    func testSetPropertyOperationIsInAllCases() {
        XCTAssertTrue(InspectorMCPOperation.allCases.contains(.setProperty))
    }

    func testPropertyListRequestRoundTrips() throws {
        let request = InspectorMCPPropertyListRequest(handle: "HANDLE-5", panel: .attributes, includeReadOnly: false)
        let decoded = try roundTrip(request)
        XCTAssertEqual(decoded, request)
    }

    func testSetPropertyRequestRoundTrips() throws {
        let request = InspectorMCPSetPropertyRequest(propertyRef: "PROP-1", boolValue: true)
        let decoded = try roundTrip(request)
        XCTAssertEqual(decoded, request)
    }

    func testPropertyListResultRoundTrips() throws {
        let result = InspectorMCPPropertyListResult(
            handle: "HANDLE-6",
            expiresAt: Date(timeIntervalSince1970: 1_713_353_600),
            panel: .attributes,
            sections: [
                .init(
                    title: "View",
                    rows: [
                        .init(
                            title: "View",
                            properties: [
                                .init(
                                    propertyRef: "PROP-2",
                                    path: .init(panel: .attributes, section: 0, row: 0, slot: .property, index: 0),
                                    title: "Hidden",
                                    kind: .toggle,
                                    editable: true,
                                    boolValue: false,
                                    nullable: false
                                )
                            ]
                        )
                    ]
                )
            ]
        )

        let decoded = try roundTrip(result)
        XCTAssertEqual(decoded, result)
    }

    func testSetPropertyResultRoundTrips() throws {
        let result = InspectorMCPSetPropertyResult(propertyRef: "PROP-3", applied: true, refreshRecommended: true)
        let decoded = try roundTrip(result)
        XCTAssertEqual(decoded, result)
    }

    func testLayersOperationIsInAllCases() {
        XCTAssertTrue(InspectorMCPOperation.allCases.contains(.layers),
                      "InspectorMCPOperation.layers must be a declared case")
    }

    func testToggleLayerOperationIsInAllCases() {
        XCTAssertTrue(InspectorMCPOperation.allCases.contains(.toggleLayer),
                      "InspectorMCPOperation.toggleLayer must be a declared case")
    }

    func testLayersPathMatchesRouteConstant() {
        XCTAssertEqual(InspectorMCPBridgeEndpoint.layersPath, "/layers")
    }

    func testToggleLayerPathMatchesRouteConstant() {
        XCTAssertEqual(InspectorMCPBridgeEndpoint.toggleLayerPath, "/toggle-layer")
    }

    func testLayerStateRoundTrips() throws {
        let state = InspectorMCPLayerState(name: "wireframes", displayName: "Wireframes", active: true)

        let decoded = try roundTrip(state)

        XCTAssertEqual(decoded.name, "wireframes")
        XCTAssertEqual(decoded.displayName, "Wireframes")
        XCTAssertTrue(decoded.active)
    }

    func testLayersResultRoundTrips() throws {
        let result = InspectorMCPLayersResult(layers: [
            .init(name: "wireframes", displayName: "Wireframes", active: false),
            .init(name: "controls", displayName: "Controls", active: true),
        ])

        let decoded = try roundTrip(result)

        XCTAssertEqual(decoded.layers.count, 2)
        XCTAssertEqual(decoded.layers[0].name, "wireframes")
        XCTAssertTrue(decoded.layers[1].active)
    }

    func testToggleLayerRequestRoundTrips() throws {
        let request = InspectorMCPToggleLayerRequest(name: "wireframes")

        let decoded = try roundTrip(request)

        XCTAssertEqual(decoded.name, "wireframes")
    }

    func testToggleLayerResultRoundTrips() throws {
        let result = InspectorMCPToggleLayerResult(name: "wireframes", active: true)

        let decoded = try roundTrip(result)

        XCTAssertEqual(decoded.name, "wireframes")
        XCTAssertTrue(decoded.active)
    }

    private func roundTrip<T: Codable & Equatable>(_ value: T) throws -> T {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return try decoder.decode(T.self, from: encoder.encode(value))
    }
}
