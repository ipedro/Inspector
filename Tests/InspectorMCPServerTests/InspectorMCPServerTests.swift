import Foundation
import InspectorMCPWire
@testable import InspectorMCPServer
import XCTest

final class InspectorMCPServerTests: XCTestCase {
    func testInitializeReturnsToolCapabilityAndServerInfo() async throws {
        let session = InspectorMCPServerSession(bridgeClient: MockBridgeClient())
        let responseData = try await session.handleMessage(
            jsonData(
                [
                    "jsonrpc": "2.0",
                    "id": 1,
                    "method": "initialize",
                    "params": [
                        "protocolVersion": "2025-11-25",
                        "capabilities": [:],
                        "clientInfo": [
                            "name": "Codex",
                            "version": "1.0"
                        ]
                    ]
                ]
            )
        )

        let response = try jsonObject(from: try XCTUnwrap(responseData))
        let result = try XCTUnwrap(response["result"] as? [String: Any])
        let capabilities = try XCTUnwrap(result["capabilities"] as? [String: Any])
        let tools = try XCTUnwrap(capabilities["tools"] as? [String: Any])
        let serverInfo = try XCTUnwrap(result["serverInfo"] as? [String: Any])

        XCTAssertEqual(result["protocolVersion"] as? String, "2025-11-25")
        XCTAssertEqual(tools["listChanged"] as? Bool, false)
        XCTAssertEqual(serverInfo["name"] as? String, "InspectorMCPServer")
    }

    func testToolsListReturnsOnlyFrozenReadOnlyTools() async throws {
        let session = InspectorMCPServerSession(bridgeClient: MockBridgeClient())
        let responseData = try await session.handleMessage(
            jsonData(
                [
                    "jsonrpc": "2.0",
                    "id": 2,
                    "method": "tools/list"
                ]
            )
        )

        let response = try jsonObject(from: try XCTUnwrap(responseData))
        let result = try XCTUnwrap(response["result"] as? [String: Any])
        let tools = try XCTUnwrap(result["tools"] as? [[String: Any]])

        XCTAssertEqual(tools.map { $0["name"] as? String }, ["query", "resolve", "snapshot"])
    }

    func testToolsCallQueryReturnsStructuredContentFromBridgeResult() async throws {
        let session = InspectorMCPServerSession(
            bridgeClient: MockBridgeClient(
                queryResult: .success(
                    InspectorMCPQueryResult(
                        expiresAt: Date(timeIntervalSince1970: 1_713_353_600),
                        nodes: [
                            .init(
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
                                childHandles: [],
                                childCount: 0
                            )
                        ]
                    )
                )
            )
        )

        let responseData = try await session.handleMessage(
            jsonData(
                [
                    "jsonrpc": "2.0",
                    "id": 3,
                    "method": "tools/call",
                    "params": [
                        "name": "query",
                        "arguments": [
                            "accessibilityIdentifierEquals": "Content Stack View"
                        ]
                    ]
                ]
            )
        )

        let response = try jsonObject(from: try XCTUnwrap(responseData))
        let result = try XCTUnwrap(response["result"] as? [String: Any])
        let content = try XCTUnwrap(result["content"] as? [[String: Any]])
        let structuredContent = try XCTUnwrap(result["structuredContent"] as? [String: Any])

        XCTAssertEqual(result["isError"] as? Bool, false)
        XCTAssertTrue((content.first?["text"] as? String ?? "").contains("Query matched"),
                      "text summary should describe the query outcome")
        XCTAssertNotNil(structuredContent["nodes"])
    }

    func testToolsCallMapsBridgeDomainErrorsToToolResults() async throws {
        let session = InspectorMCPServerSession(
            bridgeClient: MockBridgeClient(
                resolveResult: .failure(
                    .init(
                        code: .staleHandle,
                        message: "Handle has expired",
                        details: .empty
                    )
                )
            )
        )

        let responseData = try await session.handleMessage(
            jsonData(
                [
                    "jsonrpc": "2.0",
                    "id": 4,
                    "method": "tools/call",
                    "params": [
                        "name": "resolve",
                        "arguments": [
                            "handle": "old-handle"
                        ]
                    ]
                ]
            )
        )

        let response = try jsonObject(from: try XCTUnwrap(responseData))
        let result = try XCTUnwrap(response["result"] as? [String: Any])
        let structuredContent = try XCTUnwrap(result["structuredContent"] as? [String: Any])

        XCTAssertEqual(result["isError"] as? Bool, true)
        XCTAssertEqual(structuredContent["code"] as? String, "staleHandle")
    }

    func testInitializeResponseAdvertisesV2() async throws {
        let session = InspectorMCPServerSession(bridgeClient: MockBridgeClient())
        let responseData = try await session.handleMessage(
            jsonData(
                [
                    "jsonrpc": "2.0",
                    "id": 1,
                    "method": "initialize",
                    "params": [
                        "protocolVersion": "2025-11-25",
                        "capabilities": [:],
                        "clientInfo": [
                            "name": "test",
                            "version": "1"
                        ]
                    ]
                ]
            )
        )
        let response = try jsonObject(from: try XCTUnwrap(responseData))
        let result = try XCTUnwrap(response["result"] as? [String: Any])
        let serverInfo = try XCTUnwrap(result["serverInfo"] as? [String: Any])
        XCTAssertEqual(serverInfo["version"] as? String, "2.0.0")
    }

    func testSnapshotToolDescriptionMentionsPngPath() async throws {
        let session = InspectorMCPServerSession(bridgeClient: MockBridgeClient())
        let responseData = try await session.handleMessage(
            jsonData(
                [
                    "jsonrpc": "2.0",
                    "id": 2,
                    "method": "tools/list"
                ]
            )
        )
        let response = try jsonObject(from: try XCTUnwrap(responseData))
        let result = try XCTUnwrap(response["result"] as? [String: Any])
        let tools = try XCTUnwrap(result["tools"] as? [[String: Any]])
        let snapshotTool = try XCTUnwrap(tools.first { ($0["name"] as? String) == "snapshot" })

        let description = try XCTUnwrap(snapshotTool["description"] as? String)
        XCTAssertTrue(description.contains("pngPath"),
                      "description must mention pngPath so agents route to Read")

        let inputSchema = try XCTUnwrap(snapshotTool["inputSchema"] as? [String: Any])
        let properties = try XCTUnwrap(inputSchema["properties"] as? [String: Any])
        let handle = try XCTUnwrap(properties["handle"] as? [String: Any])
        let afterScreenUpdates = try XCTUnwrap(properties["afterScreenUpdates"] as? [String: Any])
        XCTAssertNotNil(handle["description"], "handle must have a description")
        XCTAssertNotNil(afterScreenUpdates["description"], "afterScreenUpdates must have a description")
    }

    private func jsonData(_ object: [String: Any]) -> Data {
        try! JSONSerialization.data(withJSONObject: object)
    }

    private func jsonObject(from data: Data) throws -> [String: Any] {
        let object = try JSONSerialization.jsonObject(with: data)
        return try XCTUnwrap(object as? [String: Any])
    }
}

private final class MockBridgeClient: InspectorMCPBridgeClient {
    var healthResult: InspectorMCPHealthResponse
    var queryResult: Result<InspectorMCPQueryResult, InspectorMCPTransportError>
    var resolveResult: Result<InspectorMCPNode, InspectorMCPTransportError>
    var snapshotResult: Result<InspectorMCPSnapshotResult, InspectorMCPTransportError>

    init(
        healthResult: InspectorMCPHealthResponse = .init(
            status: .active,
            bridgeEnabled: true,
            inspectorStarted: true,
            bundleIdentifier: "am.pedro.Inspector",
            operations: [.query, .resolve, .snapshot]
        ),
        queryResult: Result<InspectorMCPQueryResult, InspectorMCPTransportError> = .success(
            .init(expiresAt: .distantFuture, nodes: [])
        ),
        resolveResult: Result<InspectorMCPNode, InspectorMCPTransportError> = .success(
            .init(
                handle: "handle",
                nodeKind: .view,
                backingObjectType: "UIView",
                className: "UIView",
                displayName: "View",
                elementName: "View",
                accessibilityIdentifier: nil,
                frame: .init(x: 0, y: 0, width: 1, height: 1),
                isHidden: false,
                isUserInteractionEnabled: true,
                depth: 0,
                parentHandle: nil,
                childHandles: [],
                childCount: 0
            )
        ),
        snapshotResult: Result<InspectorMCPSnapshotResult, InspectorMCPTransportError> = .success(
            .init(
                handle: "MOCK-HANDLE",
                mimeType: "image/png",
                pngPath: "/tmp/inspector-snapshots/mock.png",
                size: .init(width: 10, height: 10),
                deviceScale: 2,
                createdAt: Date(timeIntervalSince1970: 0)
            )
        )
    ) {
        self.healthResult = healthResult
        self.queryResult = queryResult
        self.resolveResult = resolveResult
        self.snapshotResult = snapshotResult
    }

    func health() async throws -> InspectorMCPHealthResponse {
        healthResult
    }

    func query(_ request: InspectorMCPQueryRequest) async throws -> Result<InspectorMCPQueryResult, InspectorMCPTransportError> {
        queryResult
    }

    func resolve(_ request: InspectorMCPResolveRequest) async throws -> Result<InspectorMCPNode, InspectorMCPTransportError> {
        resolveResult
    }

    func snapshot(_ request: InspectorMCPSnapshotRequest) async throws -> Result<InspectorMCPSnapshotResult, InspectorMCPTransportError> {
        snapshotResult
    }
}
