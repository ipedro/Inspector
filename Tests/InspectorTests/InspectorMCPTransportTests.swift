#if INSPECTOR_DEBUGGING && canImport(UIKit) && targetEnvironment(simulator)
import Foundation
import XCTest
@testable import Inspector

final class InspectorMCPTransportTests: XCTestCase {
    private let baseURL = URL(string: "http://127.0.0.1:49321")!
    private lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    func testHealthEventuallyReportsActiveBridge() async throws {
        let health = try await pollHealth(timeout: 5) { payload in
            payload["status"] as? String == "active"
        }

        XCTAssertEqual(health["status"] as? String, "active")
        XCTAssertEqual(health["bridgeEnabled"] as? Bool, true)
        XCTAssertEqual(health["inspectorStarted"] as? Bool, true)
        XCTAssertEqual(health["keyboardWindowsFiltered"] as? Bool, false)
        XCTAssertEqual(health["operations"] as? [String], ["query", "resolve", "refreshHandle", "snapshot", "subtree", "inspect", "tap", "listActions", "performAction", "assertProperty", "assertVisible", "assertHierarchyContains", "captureState", "diffStates", "saveScenario", "listScenarios", "deleteScenario", "diffScenario", "listProperties", "setProperty", "registerInjectedPanel", "removeInjectedPanel", "layers", "toggleLayer"])
        XCTAssertEqual(health["apiVersion"] as? Int, 2)
    }

    func testQueryReturnsFrozenNodeShapeForExampleHierarchy() async throws {
        _ = try await pollHealth(timeout: 5) { payload in
            payload["status"] as? String == "active"
        }

        let response = try await postJSON(
            path: "/query",
            body: ["accessibilityIdentifierEquals": "Content Stack View"]
        )

        XCTAssertEqual(response.statusCode, 200)

        let payload = try unpackSuccessEnvelope(from: response.body)
        let expiresAt = payload["expiresAt"] as? String
        let nodes = payload["nodes"] as? [[String: Any]]

        XCTAssertFalse((expiresAt ?? "").isEmpty)
        XCTAssertEqual(nodes?.count, 1, "unexpected nodes: \(String(describing: nodes))")

        let node = try XCTUnwrap(nodes?.first)
        XCTAssertEqual(node["nodeKind"] as? String, "view")
        XCTAssertEqual(node["accessibilityIdentifier"] as? String, "Content Stack View")
        XCTAssertFalse((node["handle"] as? String ?? "").isEmpty)

        let expectedKeys = [
            "handle",
            "semanticReference",
            "nodeKind",
            "backingObjectType",
            "className",
            "displayName",
            "elementName",
            "accessibilityIdentifier",
            "frame",
            "isHidden",
            "isUserInteractionEnabled",
            "isInternalView",
            "isSystemContainer",
            "depth",
            "parentHandle",
            "childHandles",
            "childCount"
        ]

        XCTAssertEqual(Set(node.keys), Set(expectedKeys))
    }

    func testSnapshotReturnsPNGFilePathEnvelope() async throws {
        let result = try await snapshotResult()

        let path = try XCTUnwrap(result["pngPath"] as? String)
        XCTAssertTrue(path.hasPrefix("/"), "pngPath must be absolute")
        XCTAssertTrue(FileManager.default.fileExists(atPath: path),
                      "pngPath must resolve to an existing file")

        let magic = try Data(contentsOf: URL(fileURLWithPath: path)).prefix(8)
        XCTAssertEqual(Array(magic), [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A],
                       "artifact must be a valid PNG")

        XCTAssertEqual(result["mimeType"] as? String, "image/png")
        XCTAssertEqual(result["deviceScale"] as? Double, Double(UIScreen.main.scale))

        let createdAtString = try XCTUnwrap(result["createdAt"] as? String)
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let createdAtWithFractional = formatter.date(from: createdAtString)
        let createdAtPlain = ISO8601DateFormatter().date(from: createdAtString)
        let createdAt = try XCTUnwrap(createdAtWithFractional ?? createdAtPlain)
        XCTAssertLessThan(Date().timeIntervalSince(createdAt), 10,
                          "createdAt must be recent")
    }

    func testSnapshotRingBufferEvictsOldestViaTransport() async throws {
        Inspector.sharedInstance.configuration.snapshotArtifactMaxCount = 3

        let fileManager = FileManager.default
        let directory = inspectorSnapshotsDirectoryURL()
        try? fileManager.removeItem(at: directory)

        var paths: [String] = []
        for _ in 0..<4 {
            let result = try await snapshotResult()
            let path = try XCTUnwrap(result["pngPath"] as? String)
            paths.append(path)
            try await Task.sleep(nanoseconds: 50_000_000)
        }

        let remaining = try fileManager.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: nil
        )
        XCTAssertEqual(remaining.count, 3)
        XCTAssertFalse(fileManager.fileExists(atPath: paths[0]),
                       "oldest snapshot must have been pruned")

        addTeardownBlock {
            Inspector.sharedInstance.configuration.snapshotArtifactMaxCount = 32
            try? fileManager.removeItem(at: directory)
        }
    }

    func testSnapshotCleanupOnInspectorStop() async throws {
        _ = try await snapshotResult()
        _ = try await snapshotResult()

        let directory = inspectorSnapshotsDirectoryURL()
        XCTAssertTrue(FileManager.default.fileExists(atPath: directory.path))

        await MainActor.run {
            Inspector.sharedInstance.stop()
        }

        XCTAssertFalse(FileManager.default.fileExists(atPath: directory.path),
                       "snapshots directory must be gone after Inspector.stop()")

        addTeardownBlock {
            await MainActor.run {
                Inspector.sharedInstance.start()
            }
        }
    }

    func testHealthAdvertisesInspectOperation() async throws {
        let health = try await pollHealth(timeout: 5) { payload in
            payload["status"] as? String == "active"
        }
        let operations = try XCTUnwrap(health["operations"] as? [String])
        XCTAssertTrue(operations.contains("inspect"),
                      "/health must advertise the inspect operation")
    }

    func testInspectReturnsPresentedEnvelopeForLiveHandle() async throws {
        _ = try await pollHealth(timeout: 5) { payload in
            payload["status"] as? String == "active"
        }

        let queryResponse = try await postJSON(
            path: "/query",
            body: ["accessibilityIdentifierEquals": "Content Stack View"]
        )
        let queryPayload = try unpackSuccessEnvelope(from: queryResponse.body)
        let nodes = try XCTUnwrap(queryPayload["nodes"] as? [[String: Any]])
        let handle = try XCTUnwrap(nodes.first?["handle"] as? String)

        let inspectResponse = try await postJSON(path: "/inspect", body: ["handle": handle])
        XCTAssertEqual(inspectResponse.statusCode, 200)
        let rawPayload = try jsonObject(from: inspectResponse.body)
        XCTAssertEqual(rawPayload["ok"] as? Bool, true,
                       "inspect failed: \(rawPayload)")

        let result = try XCTUnwrap(rawPayload["result"] as? [String: Any])
        XCTAssertEqual(result["handle"] as? String, handle)
        XCTAssertEqual(result["presented"] as? Bool, true)

        // The bridge actually presents the Inspector UI as a modal over
        // the key window. Inspector.stop() releases the manager but does
        // not dismiss modals UIKit still owns, so the Inspector UI's
        // navigation bar (whose accessibility identifier mirrors the
        // inspected element) survives into subsequent tests and breaks
        // `nodes?.count == 1` assertions. The `inspect` dispatch itself
        // is async, so we wait briefly for UIKit to finish presenting
        // before walking the presented-VC chain and dismissing it.
        addTeardownBlock {
            try? await Task.sleep(nanoseconds: 300_000_000)
            await MainActor.run {
                for window in UIApplication.shared
                    .connectedScenes
                    .compactMap({ $0 as? UIWindowScene })
                    .flatMap(\.windows)
                {
                    var top = window.rootViewController
                    while let next = top?.presentedViewController {
                        top = next
                    }
                    top?.dismiss(animated: false)
                }
                Inspector.sharedInstance.stop()
                Inspector.sharedInstance.start()
            }
            try? await Task.sleep(nanoseconds: 500_000_000)
        }
    }

    func testHealthAdvertisesTapOperation() async throws {
        let health = try await pollHealth(timeout: 5) { payload in
            payload["status"] as? String == "active"
        }
        let operations = try XCTUnwrap(health["operations"] as? [String])
        XCTAssertTrue(operations.contains("tap"),
                      "/health must advertise the tap operation")
    }

    func testHealthAdvertisesActionOperations() async throws {
        let health = try await pollHealth(timeout: 5) { payload in
            payload["status"] as? String == "active"
        }
        let operations = try XCTUnwrap(health["operations"] as? [String])
        XCTAssertTrue(operations.contains("listActions"))
        XCTAssertTrue(operations.contains("performAction"))
    }

    func testHealthAdvertisesRefreshAndSubtreeOperations() async throws {
        let health = try await pollHealth(timeout: 5) { payload in
            payload["status"] as? String == "active"
        }
        let operations = try XCTUnwrap(health["operations"] as? [String])
        XCTAssertTrue(operations.contains("refreshHandle"))
        XCTAssertTrue(operations.contains("subtree"))
    }

    func testTapReturnsDispatchedEnvelopeForLiveButtonHandle() async throws {
        _ = try await pollHealth(timeout: 5) { payload in
            payload["status"] as? String == "active"
        }

        let queryResponse = try await postJSON(
            path: "/query",
            body: ["accessibilityIdentifierEquals": "MCP Tap Smoke Button"]
        )
        let queryPayload = try unpackSuccessEnvelope(from: queryResponse.body)
        let nodes = try XCTUnwrap(queryPayload["nodes"] as? [[String: Any]])
        let handle = try XCTUnwrap(nodes.first?["handle"] as? String)

        let tapResponse = try await postJSON(path: "/tap", body: ["handle": handle])
        XCTAssertEqual(tapResponse.statusCode, 200)
        let rawPayload = try jsonObject(from: tapResponse.body)
        XCTAssertEqual(rawPayload["ok"] as? Bool, true,
                       "tap failed: \(rawPayload)")

        let result = try XCTUnwrap(rawPayload["result"] as? [String: Any])
        XCTAssertEqual(result["handle"] as? String, handle)
        XCTAssertEqual(result["dispatched"] as? Bool, true)

    }

    func testHealthAdvertisesPropertyMutationOperations() async throws {
        let health = try await pollHealth(timeout: 5) { payload in
            payload["status"] as? String == "active"
        }
        let operations = try XCTUnwrap(health["operations"] as? [String])
        XCTAssertTrue(operations.contains("listProperties"))
        XCTAssertTrue(operations.contains("setProperty"))
    }

    func testListPropertiesAndSetPropertyMutateExampleView() async throws {
        _ = try await pollHealth(timeout: 5) { payload in
            payload["status"] as? String == "active"
        }

        let handle = try await queryHandle(accessibilityIdentifier: "MCP Tap Smoke Button")
        let listResponse = try await postJSON(
            path: "/properties",
            body: ["handle": handle, "panel": "attributes", "includeReadOnly": false]
        )
        XCTAssertEqual(listResponse.statusCode, 200)
        let listPayload = try unpackSuccessEnvelope(from: listResponse.body)
        let sections = try XCTUnwrap(listPayload["sections"] as? [[String: Any]])
        let propertyRef = try XCTUnwrap(findPropertyRef(in: sections, titled: "Hidden"))

        let setResponse = try await postJSON(
            path: "/set-property",
            body: ["propertyRef": propertyRef, "boolValue": true]
        )
        XCTAssertEqual(setResponse.statusCode, 200)
        let setPayload = try unpackSuccessEnvelope(from: setResponse.body)
        XCTAssertEqual(setPayload["propertyRef"] as? String, propertyRef)
        XCTAssertEqual(setPayload["applied"] as? Bool, true)
        XCTAssertEqual(setPayload["refreshRecommended"] as? Bool, true)

        let mutatedHandle = try await queryHandle(accessibilityIdentifier: "MCP Tap Smoke Button")
        let mutatedNodeResponse = try await postJSON(path: "/resolve", body: ["handle": mutatedHandle])
        let mutatedNode = try unpackSuccessEnvelope(from: mutatedNodeResponse.body)
        XCTAssertEqual(mutatedNode["isHidden"] as? Bool, true)

        addTeardownBlock {
            try? await self.restoreHidden(accessibilityIdentifier: "MCP Tap Smoke Button")
        }
    }

    func testListActionsAndPerformActionToggleHighlightAvailability() async throws {
        _ = try await pollHealth(timeout: 5) { payload in
            payload["status"] as? String == "active"
        }

        let handle = try await queryHandle(accessibilityIdentifier: "MCP Tap Smoke Button")
        let actionsResponse = try await postJSON(
            path: "/actions",
            body: ["handle": handle]
        )
        XCTAssertEqual(actionsResponse.statusCode, 200)
        let actionsPayload = try unpackSuccessEnvelope(from: actionsResponse.body)
        let actions = try XCTUnwrap(actionsPayload["actions"] as? [[String: Any]])
        let showHighlight = try XCTUnwrap(actions.first { $0["kind"] as? String == "showHighlight" })
        let actionRef = try XCTUnwrap(showHighlight["actionRef"] as? String)

        let performResponse = try await postJSON(
            path: "/perform-action",
            body: ["actionRef": actionRef]
        )
        XCTAssertEqual(performResponse.statusCode, 200)
        let performPayload = try unpackSuccessEnvelope(from: performResponse.body)
        XCTAssertEqual(performPayload["actionRef"] as? String, actionRef)
        XCTAssertEqual(performPayload["performed"] as? Bool, true)
        XCTAssertEqual(performPayload["refreshRecommended"] as? Bool, true)

        let refreshedHandle = try await queryHandle(accessibilityIdentifier: "MCP Tap Smoke Button")
        let refreshedActionsResponse = try await postJSON(
            path: "/actions",
            body: ["handle": refreshedHandle]
        )
        let refreshedPayload = try unpackSuccessEnvelope(from: refreshedActionsResponse.body)
        let refreshedActions = try XCTUnwrap(refreshedPayload["actions"] as? [[String: Any]])
        XCTAssertTrue(refreshedActions.contains { $0["kind"] as? String == "hideHighlight" })
    }

    func testHealthAdvertisesAssertionOperations() async throws {
        let health = try await pollHealth(timeout: 5) { payload in
            payload["status"] as? String == "active"
        }
        let operations = try XCTUnwrap(health["operations"] as? [String])
        XCTAssertTrue(operations.contains("assertProperty"))
        XCTAssertTrue(operations.contains("assertVisible"))
        XCTAssertTrue(operations.contains("assertHierarchyContains"))
    }

    func testHealthAdvertisesStateOperations() async throws {
        let health = try await pollHealth(timeout: 5) { payload in
            payload["status"] as? String == "active"
        }
        let operations = try XCTUnwrap(health["operations"] as? [String])
        XCTAssertTrue(operations.contains("captureState"))
        XCTAssertTrue(operations.contains("diffStates"))
    }

    func testAssertionToolsWorkOnLiveHierarchy() async throws {
        _ = try await pollHealth(timeout: 5) { payload in
            payload["status"] as? String == "active"
        }

        let handle = try await queryHandle(accessibilityIdentifier: "MCP Tap Smoke Button")

        let visibleResponse = try await postJSON(path: "/assert-visible", body: ["handle": handle])
        let visiblePayload = try unpackSuccessEnvelope(from: visibleResponse.body)
        XCTAssertEqual(visiblePayload["passed"] as? Bool, true)

        let propertyResponse = try await postJSON(
            path: "/assert-property",
            body: ["handle": handle, "property": "className", "stringValue": "UIButton"]
        )
        let propertyPayload = try unpackSuccessEnvelope(from: propertyResponse.body)
        XCTAssertEqual(propertyPayload["passed"] as? Bool, true)

        let hierarchyResponse = try await postJSON(
            path: "/assert-hierarchy-contains",
            body: ["accessibilityIdentifierEquals": "MCP Tap Smoke Button", "minimumCount": 1]
        )
        let hierarchyPayload = try unpackSuccessEnvelope(from: hierarchyResponse.body)
        XCTAssertEqual(hierarchyPayload["passed"] as? Bool, true)
        XCTAssertEqual(hierarchyPayload["matchCount"] as? Int, 1)
    }

    func testQueryCanFilterInternalViews() async throws {
        _ = try await pollHealth(timeout: 5) { payload in
            payload["status"] as? String == "active"
        }

        let response = try await postJSON(
            path: "/query",
            body: [
                "accessibilityIdentifierEquals": "MCP Internal Discoverability View",
                "isInternalView": true
            ]
        )
        XCTAssertEqual(response.statusCode, 200)
        let payload = try unpackSuccessEnvelope(from: response.body)
        let nodes = try XCTUnwrap(payload["nodes"] as? [[String: Any]])
        XCTAssertEqual(nodes.count, 1)
        XCTAssertEqual(nodes.first?["isInternalView"] as? Bool, true)
    }

    func testQueryCanFilterSystemContainers() async throws {
        _ = try await pollHealth(timeout: 5) { payload in
            payload["status"] as? String == "active"
        }

        let response = try await postJSON(
            path: "/query",
            body: [
                "nodeKind": "window",
                "isSystemContainer": true
            ]
        )
        XCTAssertEqual(response.statusCode, 200)
        let payload = try unpackSuccessEnvelope(from: response.body)
        let nodes = try XCTUnwrap(payload["nodes"] as? [[String: Any]])
        XCTAssertFalse(nodes.isEmpty)
        XCTAssertEqual(nodes.first?["isSystemContainer"] as? Bool, true)

        let handle = try XCTUnwrap(nodes.first?["handle"] as? String)
        let assertionResponse = try await postJSON(
            path: "/assert-property",
            body: [
                "handle": handle,
                "property": "isSystemContainer",
                "boolValue": true
            ]
        )
        XCTAssertEqual(assertionResponse.statusCode, 200)
        let assertionPayload = try unpackSuccessEnvelope(from: assertionResponse.body)
        XCTAssertEqual(assertionPayload["passed"] as? Bool, true)
    }

    func testAssertHierarchyContainsCanTargetInternalViews() async throws {
        _ = try await pollHealth(timeout: 5) { payload in
            payload["status"] as? String == "active"
        }

        let response = try await postJSON(
            path: "/assert-hierarchy-contains",
            body: [
                "accessibilityIdentifierEquals": "MCP Internal Discoverability View",
                "isInternalView": true,
                "minimumCount": 1
            ]
        )
        XCTAssertEqual(response.statusCode, 200)
        let payload = try unpackSuccessEnvelope(from: response.body)
        XCTAssertEqual(payload["passed"] as? Bool, true)
        XCTAssertEqual(payload["matchCount"] as? Int, 1)
    }

    func testCaptureStateAndDiffStatesDetectMutation() async throws {
        _ = try await pollHealth(timeout: 5) { payload in
            payload["status"] as? String == "active"
        }

        let beforeResponse = try await postJSON(path: "/capture-state", body: [:])
        let beforePayload = try unpackSuccessEnvelope(from: beforeResponse.body)
        let beforeRef = try XCTUnwrap(beforePayload["stateRef"] as? String)

        let handle = try await queryHandle(accessibilityIdentifier: "MCP Tap Smoke Button")
        let listResponse = try await postJSON(
            path: "/properties",
            body: ["handle": handle, "panel": "attributes", "includeReadOnly": false]
        )
        let listPayload = try unpackSuccessEnvelope(from: listResponse.body)
        let sections = try XCTUnwrap(listPayload["sections"] as? [[String: Any]])
        let propertyRef = try XCTUnwrap(findPropertyRef(in: sections, titled: "Hidden"))

        _ = try await postJSON(
            path: "/set-property",
            body: ["propertyRef": propertyRef, "boolValue": true]
        )

        let afterResponse = try await postJSON(path: "/capture-state", body: [:])
        let afterPayload = try unpackSuccessEnvelope(from: afterResponse.body)
        let afterRef = try XCTUnwrap(afterPayload["stateRef"] as? String)

        let diffResponse = try await postJSON(
            path: "/diff-states",
            body: ["beforeRef": beforeRef, "afterRef": afterRef]
        )
        let diffPayload = try unpackSuccessEnvelope(from: diffResponse.body)
        XCTAssertGreaterThanOrEqual(diffPayload["changedCount"] as? Int ?? 0, 1)

        addTeardownBlock {
            try? await self.restoreHidden(accessibilityIdentifier: "MCP Tap Smoke Button")
        }
    }

    func testScenarioToolsManageNamedBaseline() async throws {
        _ = try await pollHealth(timeout: 5) { payload in
            payload["status"] as? String == "active"
        }

        let saveResponse = try await postJSON(
            path: "/save-scenario",
            body: ["name": "baseline"]
        )
        XCTAssertEqual(saveResponse.statusCode, 200)
        let savePayload = try unpackSuccessEnvelope(from: saveResponse.body)
        XCTAssertEqual(savePayload["name"] as? String, "baseline")

        let listResponse = try await postJSON(path: "/scenarios", body: [:])
        let listPayload = try unpackSuccessEnvelope(from: listResponse.body)
        let scenarios = try XCTUnwrap(listPayload["scenarios"] as? [[String: Any]])
        XCTAssertTrue(scenarios.contains { $0["name"] as? String == "baseline" })

        let handle = try await queryHandle(accessibilityIdentifier: "MCP Tap Smoke Button")
        let listPropertiesResponse = try await postJSON(
            path: "/properties",
            body: ["handle": handle, "panel": "attributes", "includeReadOnly": false]
        )
        let propertyPayload = try unpackSuccessEnvelope(from: listPropertiesResponse.body)
        let sections = try XCTUnwrap(propertyPayload["sections"] as? [[String: Any]])
        let propertyRef = try XCTUnwrap(findPropertyRef(in: sections, titled: "Hidden"))
        _ = try await postJSON(path: "/set-property", body: ["propertyRef": propertyRef, "boolValue": true])

        let diffResponse = try await postJSON(path: "/diff-scenario", body: ["name": "baseline"])
        let diffPayload = try unpackSuccessEnvelope(from: diffResponse.body)
        XCTAssertGreaterThanOrEqual(diffPayload["changedCount"] as? Int ?? 0, 1)

        let deleteResponse = try await postJSON(path: "/delete-scenario", body: ["name": "baseline"])
        XCTAssertEqual(deleteResponse.statusCode, 200)

        addTeardownBlock {
            try? await self.restoreHidden(accessibilityIdentifier: "MCP Tap Smoke Button")
        }
    }

    func testListPropertiesAndSetPropertyMutateSelectionProperty() async throws {
        _ = try await pollHealth(timeout: 5) { payload in
            payload["status"] as? String == "active"
        }

        let handle = try await queryHandle(accessibilityIdentifier: "MCP Tap Smoke Button")
        let initialPropertiesResponse = try await postJSON(
            path: "/properties",
            body: ["handle": handle, "panel": "attributes", "includeReadOnly": false]
        )
        XCTAssertEqual(initialPropertiesResponse.statusCode, 200)
        let initialPropertiesPayload = try unpackSuccessEnvelope(from: initialPropertiesResponse.body)
        let initialSections = try XCTUnwrap(initialPropertiesPayload["sections"] as? [[String: Any]])
        let property = try XCTUnwrap(findProperty(in: initialSections, titled: "Content Mode"))
        let propertyRef = try XCTUnwrap(property["propertyRef"] as? String)

        let setResponse = try await postJSON(
            path: "/set-property",
            body: ["propertyRef": propertyRef, "selectionIndex": 1]
        )
        XCTAssertEqual(setResponse.statusCode, 200)
        let setPayload = try unpackSuccessEnvelope(from: setResponse.body)
        XCTAssertEqual(setPayload["applied"] as? Bool, true)

        let refreshedHandle = try await queryHandle(accessibilityIdentifier: "MCP Tap Smoke Button")
        let refreshedPropertiesResponse = try await postJSON(
            path: "/properties",
            body: ["handle": refreshedHandle, "panel": "attributes", "includeReadOnly": false]
        )
        let refreshedPropertiesPayload = try unpackSuccessEnvelope(from: refreshedPropertiesResponse.body)
        let refreshedSections = try XCTUnwrap(refreshedPropertiesPayload["sections"] as? [[String: Any]])
        let refreshedProperty = try XCTUnwrap(findProperty(in: refreshedSections, titled: "Content Mode"))
        XCTAssertEqual(refreshedProperty["selectionIndex"] as? Int, 1)

        addTeardownBlock {
            try? await self.restoreSelection(
                accessibilityIdentifier: "MCP Tap Smoke Button",
                titled: "Content Mode",
                selectionIndex: 0
            )
        }
    }

    func testInjectedPanelToolsRegisterAndRemoveReadOnlySection() async throws {
        _ = try await pollHealth(timeout: 5) { payload in
            payload["status"] as? String == "active"
        }

        let handle = try await queryHandle(accessibilityIdentifier: "Content Stack View")
        let panelId = "agent-summary-panel"

        let registerResponse = try await postJSON(
            path: "/register-injected-panel",
            body: [
                "handle": handle,
                "panel": "attributes",
                "panelId": panelId,
                "sections": [
                    [
                        "title": "Agent",
                        "rows": [
                            [
                                "title": "Summary",
                                "properties": [
                                    [
                                        "id": "summary",
                                        "title": "Summary",
                                        "kind": "textField",
                                        "stringValue": "Investigating layout"
                                    ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        )
        XCTAssertEqual(registerResponse.statusCode, 200)
        let registerPayload = try unpackSuccessEnvelope(from: registerResponse.body)
        XCTAssertEqual(registerPayload["panelId"] as? String, panelId)

        let propertyListResponse = try await postJSON(
            path: "/properties",
            body: ["handle": handle, "panel": "attributes", "includeReadOnly": true]
        )
        XCTAssertEqual(propertyListResponse.statusCode, 200, String(data: propertyListResponse.body, encoding: .utf8) ?? "<non-utf8>")
        let propertyPayload = try unpackSuccessEnvelope(from: propertyListResponse.body)
        let sections = try XCTUnwrap(propertyPayload["sections"] as? [[String: Any]])
        let summaryProperty = try XCTUnwrap(findProperty(in: sections, titled: "Summary"))
        XCTAssertEqual(summaryProperty["stringValue"] as? String, "Investigating layout")
        XCTAssertEqual(summaryProperty["editable"] as? Bool, false)

        let removeResponse = try await postJSON(
            path: "/remove-injected-panel",
            body: ["panelId": panelId]
        )
        XCTAssertEqual(removeResponse.statusCode, 200)
        let removePayload = try unpackSuccessEnvelope(from: removeResponse.body)
        XCTAssertEqual(removePayload["removed"] as? Bool, true)

        let refreshedPropertiesResponse = try await postJSON(
            path: "/properties",
            body: ["handle": handle, "panel": "attributes", "includeReadOnly": true]
        )
        XCTAssertEqual(refreshedPropertiesResponse.statusCode, 200, String(data: refreshedPropertiesResponse.body, encoding: .utf8) ?? "<non-utf8>")
        let refreshedPayload = try unpackSuccessEnvelope(from: refreshedPropertiesResponse.body)
        let refreshedSections = try XCTUnwrap(refreshedPayload["sections"] as? [[String: Any]])
        XCTAssertNil(findProperty(in: refreshedSections, titled: "Summary"))
    }

    func testOldestHandleBecomesStaleAfterNinthQuery() async throws {
        _ = try await pollHealth(timeout: 5) { payload in
            payload["status"] as? String == "active"
        }

        let queryBody = ["accessibilityIdentifierEquals": "MCP Tap Smoke Button"]
        var firstHandle: String?
        var ninthHandle: String?

        for index in 1...9 {
            let response = try await postJSON(path: "/query", body: queryBody)
            let payload = try unpackSuccessEnvelope(from: response.body)
            let nodes = try XCTUnwrap(payload["nodes"] as? [[String: Any]])
            let handle = try XCTUnwrap(nodes.first?["handle"] as? String)

            if index == 1 {
                firstHandle = handle
            }

            if index == 9 {
                ninthHandle = handle
            }
        }

        let staleResponse = try await postJSON(
            path: "/resolve",
            body: ["handle": try XCTUnwrap(firstHandle)]
        )
        let stalePayload = try jsonObject(from: staleResponse.body)
        let staleError = try XCTUnwrap(stalePayload["error"] as? [String: Any])

        XCTAssertEqual(staleResponse.statusCode, 200)
        XCTAssertEqual(stalePayload["ok"] as? Bool, false)
        XCTAssertEqual(staleError["code"] as? String, "staleHandle")

        let freshResponse = try await postJSON(
            path: "/resolve",
            body: ["handle": try XCTUnwrap(ninthHandle)]
        )
        let freshPayload = try unpackSuccessEnvelope(from: freshResponse.body)

        XCTAssertEqual(freshResponse.statusCode, 200)
        XCTAssertEqual(freshPayload["accessibilityIdentifier"] as? String, "MCP Tap Smoke Button")
    }

    func testRefreshHandleRebindsExpiredHandleForExploration() async throws {
        _ = try await pollHealth(timeout: 5) { payload in
            payload["status"] as? String == "active"
        }

        let queryBody = ["accessibilityIdentifierEquals": "MCP Tap Smoke Button"]
        var firstHandle: String?
        var semanticReference: String?
        for index in 1...9 {
            let response = try await postJSON(path: "/query", body: queryBody)
            let payload = try unpackSuccessEnvelope(from: response.body)
            let nodes = try XCTUnwrap(payload["nodes"] as? [[String: Any]])
            let firstNode = try XCTUnwrap(nodes.first)
            let handle = try XCTUnwrap(firstNode["handle"] as? String)
            if index == 1 {
                firstHandle = handle
                semanticReference = firstNode["semanticReference"] as? String
            }
        }

        let staleResponse = try await postJSON(
            path: "/resolve",
            body: ["handle": try XCTUnwrap(firstHandle)]
        )
        let stalePayload = try jsonObject(from: staleResponse.body)
        XCTAssertEqual(stalePayload["ok"] as? Bool, false)

        let response = try await postJSON(
            path: "/refresh-handle",
            body: ["semanticReference": try XCTUnwrap(semanticReference)]
        )
        XCTAssertEqual(response.statusCode, 200)
        let payload = try unpackSuccessEnvelope(from: response.body)
        XCTAssertEqual(payload["rebound"] as? Bool, true)
        let reboundHandle = try XCTUnwrap(payload["handle"] as? String)
        XCTAssertFalse(reboundHandle.isEmpty)

        let resolved = try await postJSON(path: "/resolve", body: ["handle": reboundHandle])
        let resolvedPayload = try unpackSuccessEnvelope(from: resolved.body)
        XCTAssertEqual(resolvedPayload["accessibilityIdentifier"] as? String, "MCP Tap Smoke Button")
    }

    func testSubtreeReturnsDepthLimitedNodes() async throws {
        _ = try await pollHealth(timeout: 5) { payload in
            payload["status"] as? String == "active"
        }

        let handle = try await queryHandle(accessibilityIdentifier: "Content Stack View")
        let response = try await postJSON(path: "/subtree", body: ["handle": handle, "maxDepth": 1])
        XCTAssertEqual(response.statusCode, 200)
        let payload = try unpackSuccessEnvelope(from: response.body)
        let nodes = try XCTUnwrap(payload["nodes"] as? [[String: Any]])
        XCTAssertGreaterThanOrEqual(nodes.count, 1)
        XCTAssertNotNil(payload["semanticReference"] as? String)
        XCTAssertEqual(nodes.first?["accessibilityIdentifier"] as? String, "Content Stack View")
    }

    func testHealthAdvertisesLayerOperations() async throws {
        let health = try await pollHealth(timeout: 5) { payload in
            payload["status"] as? String == "active"
        }
        let operations = try XCTUnwrap(health["operations"] as? [String])
        XCTAssertTrue(operations.contains("layers"),
                      "/health must advertise the layers operation")
        XCTAssertTrue(operations.contains("toggleLayer"),
                      "/health must advertise the toggleLayer operation")
    }

    func testLayersReturnsPopulatedLayerEnvelope() async throws {
        _ = try await pollHealth(timeout: 5) { payload in
            payload["status"] as? String == "active"
        }

        let response = try await postJSON(path: "/layers", body: [:])
        XCTAssertEqual(response.statusCode, 200)

        let payload = try unpackSuccessEnvelope(from: response.body)
        let layers = try XCTUnwrap(payload["layers"] as? [[String: Any]])
        XCTAssertFalse(layers.isEmpty, "Example hierarchy must populate at least one built-in layer")

        let first = try XCTUnwrap(layers.first)
        XCTAssertEqual(Set(first.keys), Set(["name", "displayName", "active"]))
        XCTAssertFalse((first["name"] as? String ?? "").isEmpty)
        XCTAssertNotNil(first["active"] as? Bool)
    }

    func testToggleLayerFlipsActiveState() async throws {
        _ = try await pollHealth(timeout: 5) { payload in
            payload["status"] as? String == "active"
        }

        let layersResponse = try await postJSON(path: "/layers", body: [:])
        let layersPayload = try unpackSuccessEnvelope(from: layersResponse.body)
        let layers = try XCTUnwrap(layersPayload["layers"] as? [[String: Any]])
        let target = try XCTUnwrap(layers.first)
        let name = try XCTUnwrap(target["name"] as? String)
        let wasActive = try XCTUnwrap(target["active"] as? Bool)

        let toggleResponse = try await postJSON(path: "/toggle-layer", body: ["name": name])
        XCTAssertEqual(toggleResponse.statusCode, 200)
        let togglePayload = try unpackSuccessEnvelope(from: toggleResponse.body)
        XCTAssertEqual(togglePayload["name"] as? String, name)
        XCTAssertEqual(togglePayload["active"] as? Bool, !wasActive,
                       "toggle should flip the active state")

        addTeardownBlock {
            _ = try? await self.postJSON(path: "/toggle-layer", body: ["name": name])
        }
    }

    func testToggleLayerRejectsUnknownName() async throws {
        _ = try await pollHealth(timeout: 5) { payload in
            payload["status"] as? String == "active"
        }

        let response = try await postJSON(
            path: "/toggle-layer",
            body: ["name": "not-a-real-layer-name"]
        )
        XCTAssertEqual(response.statusCode, 200)

        let payload = try jsonObject(from: response.body)
        XCTAssertEqual(payload["ok"] as? Bool, false)
        let error = try XCTUnwrap(payload["error"] as? [String: Any])
        XCTAssertEqual(error["code"] as? String, "internalFailure")
        let details = try XCTUnwrap(error["details"] as? [String: Any])
        let message = try XCTUnwrap(details["message"] as? String)
        XCTAssertTrue(message.contains("not-a-real-layer-name"),
                      "error message should surface the unknown layer name, got: \(message)")
    }

    func testToggleLayerRejectsMalformedBody() async throws {
        _ = try await pollHealth(timeout: 5) { payload in
            payload["status"] as? String == "active"
        }

        let response = try await postJSON(path: "/toggle-layer", body: ["not_name": "x"])
        XCTAssertEqual(response.statusCode, 400)
    }

    func testSnapshotRejectsMissingAfterScreenUpdatesWithBadRequest() async throws {
        _ = try await pollHealth(timeout: 5) { payload in
            payload["status"] as? String == "active"
        }

        let queryResponse = try await postJSON(
            path: "/query",
            body: ["accessibilityIdentifierEquals": "Content Stack View"]
        )
        let queryPayload = try unpackSuccessEnvelope(from: queryResponse.body)
        let nodes = try XCTUnwrap(queryPayload["nodes"] as? [[String: Any]])
        let handle = try XCTUnwrap(nodes.first?["handle"] as? String)

        let response = try await postJSON(
            path: "/snapshot",
            body: ["handle": handle]
        )

        XCTAssertEqual(response.statusCode, 400)
    }

    // Returns the `result` dictionary from a /snapshot call against
    // the "Content Stack View" node — reusable by all snapshot tests.
    private func snapshotResult() async throws -> [String: Any] {
        _ = try await pollHealth(timeout: 5) { payload in
            payload["status"] as? String == "active"
        }

        let queryResponse = try await postJSON(
            path: "/query",
            body: ["accessibilityIdentifierEquals": "Content Stack View"]
        )
        let queryPayload = try unpackSuccessEnvelope(from: queryResponse.body)
        let nodes = try XCTUnwrap(queryPayload["nodes"] as? [[String: Any]])
        let handle = try XCTUnwrap(nodes.first?["handle"] as? String)

        let snapshotResponse = try await postJSON(
            path: "/snapshot",
            body: ["handle": handle, "afterScreenUpdates": true]
        )
        XCTAssertEqual(snapshotResponse.statusCode, 200)
        return try unpackSuccessEnvelope(from: snapshotResponse.body)
    }

    private func queryHandle(accessibilityIdentifier: String) async throws -> String {
        let queryResponse = try await postJSON(
            path: "/query",
            body: ["accessibilityIdentifierEquals": accessibilityIdentifier]
        )
        let queryPayload = try unpackSuccessEnvelope(from: queryResponse.body)
        let nodes = try XCTUnwrap(queryPayload["nodes"] as? [[String: Any]])
        return try XCTUnwrap(nodes.first?["handle"] as? String)
    }

    private func findPropertyRef(in sections: [[String: Any]], titled title: String) -> String? {
        findProperty(in: sections, titled: title)?["propertyRef"] as? String
    }

    private func findProperty(in sections: [[String: Any]], titled title: String) -> [String: Any]? {
        for section in sections {
            guard let rows = section["rows"] as? [[String: Any]] else { continue }
            for row in rows {
                guard let properties = row["properties"] as? [[String: Any]] else { continue }
                for property in properties where property["title"] as? String == title {
                    return property
                }
            }
        }

        return nil
    }

    private func restoreHidden(accessibilityIdentifier: String) async throws {
        let handle = try await queryHandle(accessibilityIdentifier: accessibilityIdentifier)
        let listResponse = try await postJSON(
            path: "/properties",
            body: ["handle": handle, "panel": "attributes", "includeReadOnly": false]
        )
        let listPayload = try unpackSuccessEnvelope(from: listResponse.body)
        let sections = try XCTUnwrap(listPayload["sections"] as? [[String: Any]])
        guard let propertyRef = findPropertyRef(in: sections, titled: "Hidden") else { return }
        _ = try await postJSON(
            path: "/set-property",
            body: ["propertyRef": propertyRef, "boolValue": false]
        )
    }

    private func restoreSelection(
        accessibilityIdentifier: String,
        titled title: String,
        selectionIndex: Int
    ) async throws {
        let handle = try await queryHandle(accessibilityIdentifier: accessibilityIdentifier)
        let listResponse = try await postJSON(
            path: "/properties",
            body: ["handle": handle, "panel": "attributes", "includeReadOnly": false]
        )
        let listPayload = try unpackSuccessEnvelope(from: listResponse.body)
        let sections = try XCTUnwrap(listPayload["sections"] as? [[String: Any]])
        guard let propertyRef = findPropertyRef(in: sections, titled: title) else { return }
        _ = try await postJSON(
            path: "/set-property",
            body: ["propertyRef": propertyRef, "selectionIndex": selectionIndex]
        )
    }

    private func pollHealth(
        timeout: TimeInterval,
        until predicate: @escaping ([String: Any]) -> Bool
    ) async throws -> [String: Any] {
        await MainActor.run {
            if Inspector.sharedInstance.state != .started {
                Inspector.sharedInstance.start()
            }
        }

        let deadline = Date().addingTimeInterval(timeout)
        var lastError: Error?

        while Date() < deadline {
            do {
                let response = try await request(path: "/health", method: "GET", body: nil)

                if response.statusCode == 200 {
                    let payload = try jsonObject(from: response.body)

                    if predicate(payload) {
                        return payload
                    }
                }
            } catch {
                lastError = error
            }

            try await Task.sleep(nanoseconds: 250_000_000)
        }

        if let lastError {
            throw lastError
        }

        XCTFail("Timed out waiting for /health to satisfy predicate")
        return [:]
    }

    private func postJSON(
        path: String,
        body: [String: Any]
    ) async throws -> HTTPResponse {
        try await request(path: path, method: "POST", body: body)
    }

    private func request(
        path: String,
        method: String,
        body: [String: Any]?
    ) async throws -> HTTPResponse {
        var request = URLRequest(url: baseURL.appendingPathComponent(String(path.dropFirst())))
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }

        let (data, urlResponse) = try await URLSession.shared.data(for: request)
        let response = try XCTUnwrap(urlResponse as? HTTPURLResponse)
        return HTTPResponse(statusCode: response.statusCode, body: data)
    }

    private func jsonObject(from data: Data) throws -> [String: Any] {
        let object = try JSONSerialization.jsonObject(with: data)
        return try XCTUnwrap(object as? [String: Any])
    }

    private func unpackSuccessEnvelope(from data: Data) throws -> [String: Any] {
        let payload = try jsonObject(from: data)
        XCTAssertEqual(payload["ok"] as? Bool, true)
        return try XCTUnwrap(payload["result"] as? [String: Any])
    }
}

private struct HTTPResponse {
    let statusCode: Int
    let body: Data
}
#endif
