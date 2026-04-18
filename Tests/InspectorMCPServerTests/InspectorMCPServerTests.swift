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

        XCTAssertEqual(tools.map { $0["name"] as? String }, ["query", "resolve", "snapshot", "inspect", "tap", "list_actions", "perform_action", "assert_property", "assert_visible", "assert_hierarchy_contains", "capture_state", "diff_states", "list_properties", "set_property", "list_layers", "toggle_layer"])
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
                                isInternalView: false,
                                isSystemContainer: false,
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

    func testToolsListIncludesInspectToolWithNonReadOnlyAnnotations() async throws {
        let session = InspectorMCPServerSession(bridgeClient: MockBridgeClient())
        let request = #"{"jsonrpc":"2.0","id":1,"method":"tools/list"}"#
        let responseData = try await session.handleMessage(Data(request.utf8))
        let response = try XCTUnwrap(responseData)
        let object = try JSONSerialization.jsonObject(with: response) as? [String: Any]
        let result = try XCTUnwrap(object?["result"] as? [String: Any])
        let tools = try XCTUnwrap(result["tools"] as? [[String: Any]])
        let inspectTool = try XCTUnwrap(tools.first { ($0["name"] as? String) == "inspect" })

        let description = try XCTUnwrap(inspectTool["description"] as? String)
        XCTAssertTrue(description.contains("Inspector UI"),
                      "description should explain the tool drives Inspector UI")

        let annotations = try XCTUnwrap(inspectTool["annotations"] as? [String: Any])
        XCTAssertEqual(annotations["readOnlyHint"] as? Bool, false,
                       "inspect drives UI state, must not claim readOnly")
        XCTAssertEqual(annotations["idempotentHint"] as? Bool, false,
                       "consecutive inspect calls stack modals, must not claim idempotent")
        XCTAssertEqual(annotations["destructiveHint"] as? Bool, false)

        let schema = try XCTUnwrap(inspectTool["inputSchema"] as? [String: Any])
        let properties = try XCTUnwrap(schema["properties"] as? [String: Any])
        XCTAssertNotNil(properties["handle"])
        let required = try XCTUnwrap(schema["required"] as? [String])
        XCTAssertEqual(required, ["handle"])
    }

    func testToolsCallInspectForwardsToBridgeClient() async throws {
        let mock = MockBridgeClient(
            inspectResult: .success(InspectorMCPInspectResult(handle: "HANDLE", presented: true))
        )
        let session = InspectorMCPServerSession(bridgeClient: mock)
        let request = #"{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"inspect","arguments":{"handle":"HANDLE"}}}"#

        let responseData = try await session.handleMessage(Data(request.utf8))
        let response = try XCTUnwrap(responseData)
        let object = try JSONSerialization.jsonObject(with: response) as? [String: Any]
        let result = try XCTUnwrap(object?["result"] as? [String: Any])

        XCTAssertEqual(result["isError"] as? Bool, false)
        let structured = try XCTUnwrap(result["structuredContent"] as? [String: Any])
        XCTAssertEqual(structured["handle"] as? String, "HANDLE")
        XCTAssertEqual(structured["presented"] as? Bool, true)
    }

    func testToolsCallInspectSurfacesStaleHandleError() async throws {
        let mock = MockBridgeClient(
            inspectResult: .failure(.init(code: .staleHandle, message: "Handle has expired", details: .empty))
        )
        let session = InspectorMCPServerSession(bridgeClient: mock)
        let request = #"{"jsonrpc":"2.0","id":4,"method":"tools/call","params":{"name":"inspect","arguments":{"handle":"STALE"}}}"#

        let responseData = try await session.handleMessage(Data(request.utf8))
        let response = try XCTUnwrap(responseData)
        let object = try JSONSerialization.jsonObject(with: response) as? [String: Any]
        let result = try XCTUnwrap(object?["result"] as? [String: Any])

        XCTAssertEqual(result["isError"] as? Bool, true)
        let structured = try XCTUnwrap(result["structuredContent"] as? [String: Any])
        XCTAssertEqual(structured["code"] as? String, "staleHandle")
    }

    func testToolsListIncludesTapToolWithNonReadOnlyAnnotations() async throws {
        let session = InspectorMCPServerSession(bridgeClient: MockBridgeClient())
        let request = #"{"jsonrpc":"2.0","id":9,"method":"tools/list"}"#
        let responseData = try await session.handleMessage(Data(request.utf8))
        let response = try XCTUnwrap(responseData)
        let object = try JSONSerialization.jsonObject(with: response) as? [String: Any]
        let result = try XCTUnwrap(object?["result"] as? [String: Any])
        let tools = try XCTUnwrap(result["tools"] as? [[String: Any]])
        let tapTool = try XCTUnwrap(tools.first { ($0["name"] as? String) == "tap" })

        let description = try XCTUnwrap(tapTool["description"] as? String)
        XCTAssertTrue(description.contains("UIControl"),
                      "tap docs should explain the MVP target shape")

        let annotations = try XCTUnwrap(tapTool["annotations"] as? [String: Any])
        XCTAssertEqual(annotations["readOnlyHint"] as? Bool, false)
        XCTAssertEqual(annotations["idempotentHint"] as? Bool, false)
        XCTAssertEqual(annotations["destructiveHint"] as? Bool, false)

        let schema = try XCTUnwrap(tapTool["inputSchema"] as? [String: Any])
        let properties = try XCTUnwrap(schema["properties"] as? [String: Any])
        XCTAssertNotNil(properties["handle"])
        XCTAssertEqual(schema["required"] as? [String], ["handle"])
    }

    func testToolsCallTapForwardsToBridgeClient() async throws {
        let mock = MockBridgeClient(
            tapResult: .success(InspectorMCPTapResult(handle: "HANDLE", dispatched: true))
        )
        let session = InspectorMCPServerSession(bridgeClient: mock)
        let request = #"{"jsonrpc":"2.0","id":10,"method":"tools/call","params":{"name":"tap","arguments":{"handle":"HANDLE"}}}"#

        let responseData = try await session.handleMessage(Data(request.utf8))
        let response = try XCTUnwrap(responseData)
        let object = try JSONSerialization.jsonObject(with: response) as? [String: Any]
        let result = try XCTUnwrap(object?["result"] as? [String: Any])

        XCTAssertEqual(result["isError"] as? Bool, false)
        let structured = try XCTUnwrap(result["structuredContent"] as? [String: Any])
        XCTAssertEqual(structured["handle"] as? String, "HANDLE")
        XCTAssertEqual(structured["dispatched"] as? Bool, true)
        XCTAssertEqual(mock.lastTapRequest?.handle, "HANDLE")
    }

    func testToolsCallTapSurfacesUntappableTargetError() async throws {
        let mock = MockBridgeClient(
            tapResult: .failure(
                .init(
                    code: .internalFailure,
                    message: "Inspector bridge failed internally",
                    details: .internalFailure(message: "handle is not tappable")
                )
            )
        )
        let session = InspectorMCPServerSession(bridgeClient: mock)
        let request = #"{"jsonrpc":"2.0","id":11,"method":"tools/call","params":{"name":"tap","arguments":{"handle":"NOPE"}}}"#

        let responseData = try await session.handleMessage(Data(request.utf8))
        let response = try XCTUnwrap(responseData)
        let object = try JSONSerialization.jsonObject(with: response) as? [String: Any]
        let result = try XCTUnwrap(object?["result"] as? [String: Any])

        XCTAssertEqual(result["isError"] as? Bool, true)
        let structured = try XCTUnwrap(result["structuredContent"] as? [String: Any])
        XCTAssertEqual(structured["code"] as? String, "internalFailure")
    }

    func testToolsListIncludesPropertyMutationTools() async throws {
        let session = InspectorMCPServerSession(bridgeClient: MockBridgeClient())
        let request = #"{"jsonrpc":"2.0","id":12,"method":"tools/list"}"#
        let responseData = try await session.handleMessage(Data(request.utf8))
        let response = try XCTUnwrap(responseData)
        let object = try JSONSerialization.jsonObject(with: response) as? [String: Any]
        let result = try XCTUnwrap(object?["result"] as? [String: Any])
        let tools = try XCTUnwrap(result["tools"] as? [[String: Any]])

        let listProperties = try XCTUnwrap(tools.first { ($0["name"] as? String) == "list_properties" })
        let listAnnotations = try XCTUnwrap(listProperties["annotations"] as? [String: Any])
        XCTAssertEqual(listAnnotations["readOnlyHint"] as? Bool, true)

        let listSchema = try XCTUnwrap(listProperties["inputSchema"] as? [String: Any])
        XCTAssertEqual(listSchema["required"] as? [String], ["handle", "panel", "includeReadOnly"])

        let setProperty = try XCTUnwrap(tools.first { ($0["name"] as? String) == "set_property" })
        let setAnnotations = try XCTUnwrap(setProperty["annotations"] as? [String: Any])
        XCTAssertEqual(setAnnotations["readOnlyHint"] as? Bool, false)
        XCTAssertEqual(setAnnotations["idempotentHint"] as? Bool, false)
    }

    func testToolsListIncludesActionTools() async throws {
        let session = InspectorMCPServerSession(bridgeClient: MockBridgeClient())
        let request = #"{"jsonrpc":"2.0","id":16,"method":"tools/list"}"#
        let responseData = try await session.handleMessage(Data(request.utf8))
        let response = try XCTUnwrap(responseData)
        let object = try JSONSerialization.jsonObject(with: response) as? [String: Any]
        let result = try XCTUnwrap(object?["result"] as? [String: Any])
        let tools = try XCTUnwrap(result["tools"] as? [[String: Any]])

        let listActions = try XCTUnwrap(tools.first { ($0["name"] as? String) == "list_actions" })
        let listAnnotations = try XCTUnwrap(listActions["annotations"] as? [String: Any])
        XCTAssertEqual(listAnnotations["readOnlyHint"] as? Bool, true)

        let performAction = try XCTUnwrap(tools.first { ($0["name"] as? String) == "perform_action" })
        let performAnnotations = try XCTUnwrap(performAction["annotations"] as? [String: Any])
        XCTAssertEqual(performAnnotations["readOnlyHint"] as? Bool, false)
        XCTAssertEqual(performAnnotations["idempotentHint"] as? Bool, false)
    }

    func testToolsCallListActionsForwardsToBridgeClient() async throws {
        let mock = MockBridgeClient(
            actionListResult: .success(
                .init(
                    handle: "HANDLE",
                    expiresAt: .distantFuture,
                    actions: [
                        .init(actionRef: "ACTION-1", title: "Inspect Attributes", kind: .inspect),
                        .init(actionRef: "ACTION-2", title: "Highlight Views", kind: .showHighlight)
                    ]
                )
            )
        )
        let session = InspectorMCPServerSession(bridgeClient: mock)
        let request = #"{"jsonrpc":"2.0","id":17,"method":"tools/call","params":{"name":"list_actions","arguments":{"handle":"HANDLE"}}}"#

        let responseData = try await session.handleMessage(Data(request.utf8))
        let response = try XCTUnwrap(responseData)
        let object = try JSONSerialization.jsonObject(with: response) as? [String: Any]
        let result = try XCTUnwrap(object?["result"] as? [String: Any])
        XCTAssertEqual(result["isError"] as? Bool, false)
        XCTAssertEqual(mock.lastActionListRequest?.handle, "HANDLE")
    }

    func testToolsCallPerformActionForwardsToBridgeClient() async throws {
        let mock = MockBridgeClient(
            performActionResult: .success(.init(actionRef: "ACTION-1", performed: true, refreshRecommended: true))
        )
        let session = InspectorMCPServerSession(bridgeClient: mock)
        let request = #"{"jsonrpc":"2.0","id":18,"method":"tools/call","params":{"name":"perform_action","arguments":{"actionRef":"ACTION-1"}}}"#

        let responseData = try await session.handleMessage(Data(request.utf8))
        let response = try XCTUnwrap(responseData)
        let object = try JSONSerialization.jsonObject(with: response) as? [String: Any]
        let result = try XCTUnwrap(object?["result"] as? [String: Any])
        XCTAssertEqual(result["isError"] as? Bool, false)
        XCTAssertEqual(mock.lastPerformActionRequest?.actionRef, "ACTION-1")
    }

    func testToolsCallPerformActionSurfacesStaleActionRef() async throws {
        let mock = MockBridgeClient(
            performActionResult: .failure(.init(code: .staleActionReference, message: "Action reference is stale; list actions again", details: .empty))
        )
        let session = InspectorMCPServerSession(bridgeClient: mock)
        let request = #"{"jsonrpc":"2.0","id":19,"method":"tools/call","params":{"name":"perform_action","arguments":{"actionRef":"STALE"}}}"#

        let responseData = try await session.handleMessage(Data(request.utf8))
        let response = try XCTUnwrap(responseData)
        let object = try JSONSerialization.jsonObject(with: response) as? [String: Any]
        let result = try XCTUnwrap(object?["result"] as? [String: Any])
        XCTAssertEqual(result["isError"] as? Bool, true)
        let structured = try XCTUnwrap(result["structuredContent"] as? [String: Any])
        XCTAssertEqual(structured["code"] as? String, "staleActionReference")
    }

    func testToolsListIncludesAssertionTools() async throws {
        let session = InspectorMCPServerSession(bridgeClient: MockBridgeClient())
        let request = #"{"jsonrpc":"2.0","id":20,"method":"tools/list"}"#
        let responseData = try await session.handleMessage(Data(request.utf8))
        let response = try XCTUnwrap(responseData)
        let object = try JSONSerialization.jsonObject(with: response) as? [String: Any]
        let result = try XCTUnwrap(object?["result"] as? [String: Any])
        let tools = try XCTUnwrap(result["tools"] as? [[String: Any]])

        XCTAssertNotNil(tools.first { ($0["name"] as? String) == "assert_property" })
        XCTAssertNotNil(tools.first { ($0["name"] as? String) == "assert_visible" })
        XCTAssertNotNil(tools.first { ($0["name"] as? String) == "assert_hierarchy_contains" })
    }

    func testToolsListIncludesStateTools() async throws {
        let session = InspectorMCPServerSession(bridgeClient: MockBridgeClient())
        let request = #"{"jsonrpc":"2.0","id":24,"method":"tools/list"}"#
        let responseData = try await session.handleMessage(Data(request.utf8))
        let response = try XCTUnwrap(responseData)
        let object = try JSONSerialization.jsonObject(with: response) as? [String: Any]
        let result = try XCTUnwrap(object?["result"] as? [String: Any])
        let tools = try XCTUnwrap(result["tools"] as? [[String: Any]])
        XCTAssertNotNil(tools.first { ($0["name"] as? String) == "capture_state" })
        XCTAssertNotNil(tools.first { ($0["name"] as? String) == "diff_states" })
    }

    func testToolsCallAssertPropertyForwardsToBridgeClient() async throws {
        let mock = MockBridgeClient(
            assertPropertyResult: .success(.init(handle: "HANDLE", property: .className, passed: true, actualString: "UIButton", message: "className is UIButton"))
        )
        let session = InspectorMCPServerSession(bridgeClient: mock)
        let request = #"{"jsonrpc":"2.0","id":21,"method":"tools/call","params":{"name":"assert_property","arguments":{"handle":"HANDLE","property":"className","stringValue":"UIButton"}}}"#
        let responseData = try await session.handleMessage(Data(request.utf8))
        let response = try XCTUnwrap(responseData)
        let object = try JSONSerialization.jsonObject(with: response) as? [String: Any]
        let result = try XCTUnwrap(object?["result"] as? [String: Any])
        XCTAssertEqual(result["isError"] as? Bool, false)
        XCTAssertEqual(mock.lastAssertPropertyRequest?.property, .className)
    }

    func testToolsCallAssertVisibleForwardsToBridgeClient() async throws {
        let mock = MockBridgeClient(
            assertVisibleResult: .success(.init(handle: "HANDLE", passed: true, isHidden: false, message: "node is visible"))
        )
        let session = InspectorMCPServerSession(bridgeClient: mock)
        let request = #"{"jsonrpc":"2.0","id":22,"method":"tools/call","params":{"name":"assert_visible","arguments":{"handle":"HANDLE"}}}"#
        let responseData = try await session.handleMessage(Data(request.utf8))
        let response = try XCTUnwrap(responseData)
        let object = try JSONSerialization.jsonObject(with: response) as? [String: Any]
        let result = try XCTUnwrap(object?["result"] as? [String: Any])
        XCTAssertEqual(result["isError"] as? Bool, false)
        XCTAssertEqual(mock.lastAssertVisibleRequest?.handle, "HANDLE")
    }

    func testToolsCallAssertHierarchyContainsForwardsToBridgeClient() async throws {
        let mock = MockBridgeClient(
            assertHierarchyContainsResult: .success(.init(passed: true, matchCount: 1, minimumCount: 1, message: "hierarchy matched 1 node(s)"))
        )
        let session = InspectorMCPServerSession(bridgeClient: mock)
        let request = #"{"jsonrpc":"2.0","id":23,"method":"tools/call","params":{"name":"assert_hierarchy_contains","arguments":{"accessibilityIdentifierEquals":"MCP Tap Smoke Button","minimumCount":1}}}"#
        let responseData = try await session.handleMessage(Data(request.utf8))
        let response = try XCTUnwrap(responseData)
        let object = try JSONSerialization.jsonObject(with: response) as? [String: Any]
        let result = try XCTUnwrap(object?["result"] as? [String: Any])
        XCTAssertEqual(result["isError"] as? Bool, false)
        XCTAssertEqual(mock.lastAssertHierarchyContainsRequest?.accessibilityIdentifierEquals, "MCP Tap Smoke Button")
    }

    func testToolsCallCaptureStateForwardsToBridgeClient() async throws {
        let mock = MockBridgeClient(
            captureStateResult: .success(.init(stateRef: "STATE-A", createdAt: .distantPast, nodeCount: 10))
        )
        let session = InspectorMCPServerSession(bridgeClient: mock)
        let request = #"{"jsonrpc":"2.0","id":25,"method":"tools/call","params":{"name":"capture_state","arguments":{}}}"#
        let responseData = try await session.handleMessage(Data(request.utf8))
        let response = try XCTUnwrap(responseData)
        let object = try JSONSerialization.jsonObject(with: response) as? [String: Any]
        let result = try XCTUnwrap(object?["result"] as? [String: Any])
        XCTAssertEqual(result["isError"] as? Bool, false)
    }

    func testToolsCallDiffStatesForwardsToBridgeClient() async throws {
        let mock = MockBridgeClient(
            diffStatesResult: .success(.init(beforeRef: "A", afterRef: "B", addedCount: 0, removedCount: 0, changedCount: 1, entries: []))
        )
        let session = InspectorMCPServerSession(bridgeClient: mock)
        let request = #"{"jsonrpc":"2.0","id":26,"method":"tools/call","params":{"name":"diff_states","arguments":{"beforeRef":"A","afterRef":"B"}}}"#
        let responseData = try await session.handleMessage(Data(request.utf8))
        let response = try XCTUnwrap(responseData)
        let object = try JSONSerialization.jsonObject(with: response) as? [String: Any]
        let result = try XCTUnwrap(object?["result"] as? [String: Any])
        XCTAssertEqual(result["isError"] as? Bool, false)
        XCTAssertEqual(mock.lastDiffStatesRequest?.beforeRef, "A")
    }

    func testToolsCallListPropertiesForwardsToBridgeClient() async throws {
        let mock = MockBridgeClient(
            propertyListResult: .success(
                .init(
                    handle: "HANDLE",
                    expiresAt: .distantFuture,
                    panel: .attributes,
                    sections: [
                        .init(title: "View", rows: [
                            .init(title: "View", properties: [
                                .init(
                                    propertyRef: "PROP-1",
                                    path: .init(panel: .attributes, section: 0, row: 0, slot: .property, index: 0),
                                    title: "Hidden",
                                    kind: .toggle,
                                    editable: true,
                                    boolValue: false,
                                    nullable: false
                                )
                            ])
                        ])
                    ]
                )
            )
        )
        let session = InspectorMCPServerSession(bridgeClient: mock)
        let request = #"{"jsonrpc":"2.0","id":13,"method":"tools/call","params":{"name":"list_properties","arguments":{"handle":"HANDLE","panel":"attributes","includeReadOnly":false}}}"#

        let responseData = try await session.handleMessage(Data(request.utf8))
        let response = try XCTUnwrap(responseData)
        let object = try JSONSerialization.jsonObject(with: response) as? [String: Any]
        let result = try XCTUnwrap(object?["result"] as? [String: Any])
        XCTAssertEqual(result["isError"] as? Bool, false)

        let structured = try XCTUnwrap(result["structuredContent"] as? [String: Any])
        XCTAssertEqual(structured["handle"] as? String, "HANDLE")
        XCTAssertEqual(mock.lastPropertyListRequest?.panel, .attributes)
    }

    func testToolsCallSetPropertyForwardsToBridgeClient() async throws {
        let mock = MockBridgeClient(
            setPropertyResult: .success(.init(propertyRef: "PROP-1", applied: true, refreshRecommended: true))
        )
        let session = InspectorMCPServerSession(bridgeClient: mock)
        let request = #"{"jsonrpc":"2.0","id":14,"method":"tools/call","params":{"name":"set_property","arguments":{"propertyRef":"PROP-1","boolValue":true}}}"#

        let responseData = try await session.handleMessage(Data(request.utf8))
        let response = try XCTUnwrap(responseData)
        let object = try JSONSerialization.jsonObject(with: response) as? [String: Any]
        let result = try XCTUnwrap(object?["result"] as? [String: Any])
        XCTAssertEqual(result["isError"] as? Bool, false)
        XCTAssertEqual(mock.lastSetPropertyRequest?.propertyRef, "PROP-1")
    }

    func testToolsCallSetPropertySurfacesInvalidPropertyValue() async throws {
        let mock = MockBridgeClient(
            setPropertyResult: .failure(.init(code: .invalidPropertyValue, message: "Property value is invalid", details: .internalFailure(message: "bad value")))
        )
        let session = InspectorMCPServerSession(bridgeClient: mock)
        let request = #"{"jsonrpc":"2.0","id":15,"method":"tools/call","params":{"name":"set_property","arguments":{"propertyRef":"PROP-1","numberValue":999}}}"#

        let responseData = try await session.handleMessage(Data(request.utf8))
        let response = try XCTUnwrap(responseData)
        let object = try JSONSerialization.jsonObject(with: response) as? [String: Any]
        let result = try XCTUnwrap(object?["result"] as? [String: Any])
        XCTAssertEqual(result["isError"] as? Bool, true)
        let structured = try XCTUnwrap(result["structuredContent"] as? [String: Any])
        XCTAssertEqual(structured["code"] as? String, "invalidPropertyValue")
    }

    func testToolsListAdvertisesLayerTools() async throws {
        let mock = MockBridgeClient()
        let session = InspectorMCPServerSession(bridgeClient: mock)
        let request = #"{"jsonrpc":"2.0","id":5,"method":"tools/list"}"#

        let responseData = try await session.handleMessage(Data(request.utf8))
        let response = try XCTUnwrap(responseData)
        let object = try JSONSerialization.jsonObject(with: response) as? [String: Any]
        let result = try XCTUnwrap(object?["result"] as? [String: Any])
        let tools = try XCTUnwrap(result["tools"] as? [[String: Any]])

        let listLayers = try XCTUnwrap(tools.first { $0["name"] as? String == "list_layers" })
        let listAnnotations = try XCTUnwrap(listLayers["annotations"] as? [String: Any])
        XCTAssertEqual(listAnnotations["readOnlyHint"] as? Bool, true,
                       "list_layers must be read-only — no state mutation")

        let listSchema = try XCTUnwrap(listLayers["inputSchema"] as? [String: Any])
        let listProperties = try XCTUnwrap(listSchema["properties"] as? [String: Any])
        XCTAssertTrue(listProperties.isEmpty,
                      "list_layers takes no arguments")

        let toggle = try XCTUnwrap(tools.first { $0["name"] as? String == "toggle_layer" })
        let toggleAnnotations = try XCTUnwrap(toggle["annotations"] as? [String: Any])
        XCTAssertEqual(toggleAnnotations["readOnlyHint"] as? Bool, false,
                       "toggle_layer mutates Inspector UI state")
        XCTAssertEqual(toggleAnnotations["idempotentHint"] as? Bool, false,
                       "consecutive toggles flip the layer, not idempotent")

        let toggleSchema = try XCTUnwrap(toggle["inputSchema"] as? [String: Any])
        let toggleProperties = try XCTUnwrap(toggleSchema["properties"] as? [String: Any])
        XCTAssertNotNil(toggleProperties["name"])
        XCTAssertEqual(toggleSchema["required"] as? [String], ["name"])
    }

    func testToolsCallListLayersForwardsToBridgeClient() async throws {
        let mock = MockBridgeClient(
            layersResult: .success(
                InspectorMCPLayersResult(layers: [
                    .init(name: "Wireframes", displayName: "Wireframes", active: true),
                    .init(name: "Controls", displayName: "Controls", active: false),
                ])
            )
        )
        let session = InspectorMCPServerSession(bridgeClient: mock)
        let request = #"{"jsonrpc":"2.0","id":6,"method":"tools/call","params":{"name":"list_layers","arguments":{}}}"#

        let responseData = try await session.handleMessage(Data(request.utf8))
        let response = try XCTUnwrap(responseData)
        let object = try JSONSerialization.jsonObject(with: response) as? [String: Any]
        let result = try XCTUnwrap(object?["result"] as? [String: Any])

        XCTAssertEqual(result["isError"] as? Bool, false)
        let structured = try XCTUnwrap(result["structuredContent"] as? [String: Any])
        let layers = try XCTUnwrap(structured["layers"] as? [[String: Any]])
        XCTAssertEqual(layers.count, 2)
        XCTAssertEqual(layers.first?["name"] as? String, "Wireframes")
        XCTAssertEqual(layers.first?["active"] as? Bool, true)

        let content = try XCTUnwrap(result["content"] as? [[String: Any]])
        let text = try XCTUnwrap(content.first?["text"] as? String)
        XCTAssertTrue(text.contains("Listed 2"))
    }

    func testToolsCallToggleLayerForwardsNameToBridgeClient() async throws {
        let mock = MockBridgeClient(
            toggleLayerResult: .success(
                InspectorMCPToggleLayerResult(name: "Wireframes", active: true)
            )
        )
        let session = InspectorMCPServerSession(bridgeClient: mock)
        let request = #"{"jsonrpc":"2.0","id":7,"method":"tools/call","params":{"name":"toggle_layer","arguments":{"name":"Wireframes"}}}"#

        let responseData = try await session.handleMessage(Data(request.utf8))
        let response = try XCTUnwrap(responseData)
        let object = try JSONSerialization.jsonObject(with: response) as? [String: Any]
        let result = try XCTUnwrap(object?["result"] as? [String: Any])

        XCTAssertEqual(result["isError"] as? Bool, false)
        XCTAssertEqual(mock.lastToggleLayerRequest?.name, "Wireframes")

        let structured = try XCTUnwrap(result["structuredContent"] as? [String: Any])
        XCTAssertEqual(structured["name"] as? String, "Wireframes")
        XCTAssertEqual(structured["active"] as? Bool, true)
    }

    func testToolsCallToggleLayerSurfacesUnknownLayerError() async throws {
        let mock = MockBridgeClient(
            toggleLayerResult: .failure(
                .init(
                    code: .internalFailure,
                    message: "Inspector bridge failed internally",
                    details: .internalFailure(message: "unknown layer: nope")
                )
            )
        )
        let session = InspectorMCPServerSession(bridgeClient: mock)
        let request = #"{"jsonrpc":"2.0","id":8,"method":"tools/call","params":{"name":"toggle_layer","arguments":{"name":"nope"}}}"#

        let responseData = try await session.handleMessage(Data(request.utf8))
        let response = try XCTUnwrap(responseData)
        let object = try JSONSerialization.jsonObject(with: response) as? [String: Any]
        let result = try XCTUnwrap(object?["result"] as? [String: Any])

        XCTAssertEqual(result["isError"] as? Bool, true)
        let structured = try XCTUnwrap(result["structuredContent"] as? [String: Any])
        XCTAssertEqual(structured["code"] as? String, "internalFailure")
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
    var inspectResult: Result<InspectorMCPInspectResult, InspectorMCPTransportError>
    var tapResult: Result<InspectorMCPTapResult, InspectorMCPTransportError>
    var actionListResult: Result<InspectorMCPActionListResult, InspectorMCPTransportError>
    var performActionResult: Result<InspectorMCPPerformActionResult, InspectorMCPTransportError>
    var assertPropertyResult: Result<InspectorMCPAssertPropertyResult, InspectorMCPTransportError>
    var assertVisibleResult: Result<InspectorMCPAssertVisibleResult, InspectorMCPTransportError>
    var assertHierarchyContainsResult: Result<InspectorMCPAssertHierarchyContainsResult, InspectorMCPTransportError>
    var captureStateResult: Result<InspectorMCPCapturedState, InspectorMCPTransportError>
    var diffStatesResult: Result<InspectorMCPStateDiff, InspectorMCPTransportError>
    var propertyListResult: Result<InspectorMCPPropertyListResult, InspectorMCPTransportError>
    var setPropertyResult: Result<InspectorMCPSetPropertyResult, InspectorMCPTransportError>
    var layersResult: Result<InspectorMCPLayersResult, InspectorMCPTransportError>
    var toggleLayerResult: Result<InspectorMCPToggleLayerResult, InspectorMCPTransportError>
    private(set) var lastTapRequest: InspectorMCPTapRequest?
    private(set) var lastActionListRequest: InspectorMCPActionListRequest?
    private(set) var lastPerformActionRequest: InspectorMCPPerformActionRequest?
    private(set) var lastAssertPropertyRequest: InspectorMCPAssertPropertyRequest?
    private(set) var lastAssertVisibleRequest: InspectorMCPAssertVisibleRequest?
    private(set) var lastAssertHierarchyContainsRequest: InspectorMCPAssertHierarchyContainsRequest?
    private(set) var lastDiffStatesRequest: InspectorMCPDiffStatesRequest?
    private(set) var lastPropertyListRequest: InspectorMCPPropertyListRequest?
    private(set) var lastSetPropertyRequest: InspectorMCPSetPropertyRequest?
    private(set) var lastToggleLayerRequest: InspectorMCPToggleLayerRequest?

    init(
        healthResult: InspectorMCPHealthResponse = .init(
            status: .active,
            bridgeEnabled: true,
            inspectorStarted: true,
            keyboardWindowsFiltered: false,
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
                isInternalView: false,
                isSystemContainer: false,
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
        ),
        inspectResult: Result<InspectorMCPInspectResult, InspectorMCPTransportError> = .success(
            .init(handle: "MOCK-HANDLE", presented: true)
        ),
        tapResult: Result<InspectorMCPTapResult, InspectorMCPTransportError> = .success(
            .init(handle: "MOCK-HANDLE", dispatched: true)
        ),
        actionListResult: Result<InspectorMCPActionListResult, InspectorMCPTransportError> = .success(
            .init(handle: "MOCK-HANDLE", expiresAt: .distantFuture, actions: [])
        ),
        performActionResult: Result<InspectorMCPPerformActionResult, InspectorMCPTransportError> = .success(
            .init(actionRef: "ACTION", performed: true, refreshRecommended: true)
        ),
        assertPropertyResult: Result<InspectorMCPAssertPropertyResult, InspectorMCPTransportError> = .success(
            .init(handle: "MOCK-HANDLE", property: .className, passed: true, actualString: "UIView", message: "className is UIView")
        ),
        assertVisibleResult: Result<InspectorMCPAssertVisibleResult, InspectorMCPTransportError> = .success(
            .init(handle: "MOCK-HANDLE", passed: true, isHidden: false, message: "node is visible")
        ),
        assertHierarchyContainsResult: Result<InspectorMCPAssertHierarchyContainsResult, InspectorMCPTransportError> = .success(
            .init(passed: true, matchCount: 1, minimumCount: 1, message: "hierarchy matched 1 node(s)")
        ),
        captureStateResult: Result<InspectorMCPCapturedState, InspectorMCPTransportError> = .success(
            .init(stateRef: "STATE", createdAt: .distantPast, nodeCount: 1)
        ),
        diffStatesResult: Result<InspectorMCPStateDiff, InspectorMCPTransportError> = .success(
            .init(beforeRef: "A", afterRef: "B", addedCount: 0, removedCount: 0, changedCount: 0, entries: [])
        ),
        propertyListResult: Result<InspectorMCPPropertyListResult, InspectorMCPTransportError> = .success(
            .init(handle: "MOCK-HANDLE", expiresAt: .distantFuture, panel: .attributes, sections: [])
        ),
        setPropertyResult: Result<InspectorMCPSetPropertyResult, InspectorMCPTransportError> = .success(
            .init(propertyRef: "PROP", applied: true, refreshRecommended: true)
        ),
        layersResult: Result<InspectorMCPLayersResult, InspectorMCPTransportError> = .success(
            .init(layers: [])
        ),
        toggleLayerResult: Result<InspectorMCPToggleLayerResult, InspectorMCPTransportError> = .success(
            .init(name: "Wireframes", active: true)
        )
    ) {
        self.healthResult = healthResult
        self.queryResult = queryResult
        self.resolveResult = resolveResult
        self.snapshotResult = snapshotResult
        self.inspectResult = inspectResult
        self.tapResult = tapResult
        self.actionListResult = actionListResult
        self.performActionResult = performActionResult
        self.assertPropertyResult = assertPropertyResult
        self.assertVisibleResult = assertVisibleResult
        self.assertHierarchyContainsResult = assertHierarchyContainsResult
        self.captureStateResult = captureStateResult
        self.diffStatesResult = diffStatesResult
        self.propertyListResult = propertyListResult
        self.setPropertyResult = setPropertyResult
        self.layersResult = layersResult
        self.toggleLayerResult = toggleLayerResult
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

    func inspect(_ request: InspectorMCPInspectRequest) async throws -> Result<InspectorMCPInspectResult, InspectorMCPTransportError> {
        inspectResult
    }

    func tap(_ request: InspectorMCPTapRequest) async throws -> Result<InspectorMCPTapResult, InspectorMCPTransportError> {
        lastTapRequest = request
        return tapResult
    }

    func listActions(_ request: InspectorMCPActionListRequest) async throws -> Result<InspectorMCPActionListResult, InspectorMCPTransportError> {
        lastActionListRequest = request
        return actionListResult
    }

    func performAction(_ request: InspectorMCPPerformActionRequest) async throws -> Result<InspectorMCPPerformActionResult, InspectorMCPTransportError> {
        lastPerformActionRequest = request
        return performActionResult
    }

    func assertProperty(_ request: InspectorMCPAssertPropertyRequest) async throws -> Result<InspectorMCPAssertPropertyResult, InspectorMCPTransportError> {
        lastAssertPropertyRequest = request
        return assertPropertyResult
    }

    func assertVisible(_ request: InspectorMCPAssertVisibleRequest) async throws -> Result<InspectorMCPAssertVisibleResult, InspectorMCPTransportError> {
        lastAssertVisibleRequest = request
        return assertVisibleResult
    }

    func assertHierarchyContains(_ request: InspectorMCPAssertHierarchyContainsRequest) async throws -> Result<InspectorMCPAssertHierarchyContainsResult, InspectorMCPTransportError> {
        lastAssertHierarchyContainsRequest = request
        return assertHierarchyContainsResult
    }

    func captureState(_ request: InspectorMCPCaptureStateRequest) async throws -> Result<InspectorMCPCapturedState, InspectorMCPTransportError> {
        captureStateResult
    }

    func diffStates(_ request: InspectorMCPDiffStatesRequest) async throws -> Result<InspectorMCPStateDiff, InspectorMCPTransportError> {
        lastDiffStatesRequest = request
        return diffStatesResult
    }

    func listProperties(_ request: InspectorMCPPropertyListRequest) async throws -> Result<InspectorMCPPropertyListResult, InspectorMCPTransportError> {
        lastPropertyListRequest = request
        return propertyListResult
    }

    func setProperty(_ request: InspectorMCPSetPropertyRequest) async throws -> Result<InspectorMCPSetPropertyResult, InspectorMCPTransportError> {
        lastSetPropertyRequest = request
        return setPropertyResult
    }

    func layers() async throws -> Result<InspectorMCPLayersResult, InspectorMCPTransportError> {
        layersResult
    }

    func toggleLayer(_ request: InspectorMCPToggleLayerRequest) async throws -> Result<InspectorMCPToggleLayerResult, InspectorMCPTransportError> {
        lastToggleLayerRequest = request
        return toggleLayerResult
    }
}
