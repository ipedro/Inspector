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
    }

    func testHealthResponseRoundTripsThroughJSON() throws {
        let response = InspectorMCPHealthResponse(
            status: .active,
            bridgeEnabled: true,
            inspectorStarted: true,
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

    private func roundTrip<T: Codable & Equatable>(_ value: T) throws -> T {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return try decoder.decode(T.self, from: encoder.encode(value))
    }
}
