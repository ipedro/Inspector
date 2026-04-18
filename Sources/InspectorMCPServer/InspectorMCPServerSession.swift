import Foundation
import InspectorMCPWire

final class InspectorMCPServerSession {
    private let bridgeClient: InspectorMCPBridgeClient

    init(bridgeClient: InspectorMCPBridgeClient) {
        self.bridgeClient = bridgeClient
    }

    func handleMessage(_ data: Data) async throws -> Data? {
        let requestObject = try JSONObject.decodeObject(from: data)
        guard let method = requestObject["method"] as? String else {
            throw InspectorMCPServerError.invalidArguments("Missing JSON-RPC method")
        }

        if method == "notifications/initialized" {
            return nil
        }

        let requestID = requestObject["id"]

        switch method {
        case "initialize":
            return try encodeResponse(
                id: requestID,
                result: [
                    "protocolVersion": (requestObject["params"] as? [String: Any])?["protocolVersion"] as? String ?? "2025-11-25",
                    "capabilities": [
                        "tools": [
                            "listChanged": false
                        ]
                    ],
                    "serverInfo": [
                        "name": "InspectorMCPServer",
                        "version": "2.0.0"
                    ],
                    "instructions": "Use query to discover nodes, then resolve or snapshot returned handles. For semantic actions, use list_actions before perform_action. For assertions, use assert_property / assert_visible / assert_hierarchy_contains. For property mutation, use list_properties before set_property. Mutation tools can stale handles immediately, so issue a fresh query after UI changes."
                ]
            )
        case "tools/list":
            return try encodeResponse(
                id: requestID,
                result: [
                    "tools": toolsListResult()
                ]
            )
        case "tools/call":
            guard let params = requestObject["params"] as? [String: Any] else {
                return encodeErrorResponse(
                    id: requestID,
                    code: -32602,
                    message: "Missing tools/call params"
                )
            }

            guard let toolName = params["name"] as? String else {
                return encodeErrorResponse(
                    id: requestID,
                    code: -32602,
                    message: "Missing tool name"
                )
            }

            let arguments = params["arguments"] as? [String: Any] ?? [:]

            do {
                let result = try await handleToolCall(named: toolName, arguments: arguments)
                return try encodeResponse(id: requestID, result: result)
            } catch let error as InspectorMCPServerError {
                if case .unknownTool = error {
                    return encodeErrorResponse(
                        id: requestID,
                        code: -32602,
                        message: error.localizedDescription
                    )
                }

                return encodeErrorResponse(
                    id: requestID,
                    code: -32000,
                    message: error.localizedDescription
                )
            }
        default:
            return encodeErrorResponse(
                id: requestID,
                code: -32601,
                message: "Method not found: \(method)"
            )
        }
    }

    private func toolsListResult() -> [[String: Any]] {
        [
            toolDefinition(
                name: "query",
                description: "Query the live Inspector hierarchy and return matching nodes.",
                schema: [
                    "type": "object",
                    "additionalProperties": false,
                    "properties": [
                        "nodeKind": [
                            "type": "string",
                            "enum": ["window", "viewController", "view"]
                        ],
                        "classNameContains": ["type": "string"],
                        "displayNameContains": ["type": "string"],
                        "elementNameContains": ["type": "string"],
                        "accessibilityIdentifierEquals": ["type": "string"]
                    ]
                ]
            ),
            toolDefinition(
                name: "resolve",
                description: "Resolve a previously returned handle into the latest node details.",
                schema: [
                    "type": "object",
                    "additionalProperties": false,
                    "properties": [
                        "handle": ["type": "string"]
                    ],
                    "required": ["handle"]
                ]
            ),
            toolDefinition(
                name: "snapshot",
                description: "Capture a PNG snapshot for a handle. Returns an absolute host file path — use the Read tool on pngPath to load image bytes.",
                schema: [
                    "type": "object",
                    "additionalProperties": false,
                    "properties": [
                        "handle": [
                            "type": "string",
                            "description": "Opaque handle returned by query or resolve."
                        ],
                        "afterScreenUpdates": [
                            "type": "boolean",
                            "description": "Whether to flush pending view updates before capture. Default true."
                        ]
                    ],
                    "required": ["handle", "afterScreenUpdates"]
                ]
            ),
            toolDefinition(
                name: "inspect",
                description: "Open the Inspector UI focused on the given handle. Stacks on top of any currently-presented Inspector session.",
                schema: [
                    "type": "object",
                    "additionalProperties": false,
                    "properties": [
                        "handle": [
                            "type": "string",
                            "description": "Opaque handle returned by query or resolve."
                        ]
                    ],
                    "required": ["handle"]
                ],
                annotations: [
                    "readOnlyHint": false,
                    "destructiveHint": false,
                    "idempotentHint": false,
                    "openWorldHint": true
                ]
            ),
            toolDefinition(
                name: "tap",
                description: "Semantically activate an exact-handle UIControl. MVP scope is button-like controls only; this is not synthetic touch injection or gesture dispatch.",
                schema: [
                    "type": "object",
                    "additionalProperties": false,
                    "properties": [
                        "handle": [
                            "type": "string",
                            "description": "Opaque handle returned by query or resolve. Must resolve to a tappable UIControl."
                        ]
                    ],
                    "required": ["handle"]
                ],
                annotations: [
                    "readOnlyHint": false,
                    "destructiveHint": false,
                    "idempotentHint": false,
                    "openWorldHint": true
                ]
            ),
            toolDefinition(
                name: "list_actions",
                description: "List semantic actions available for a node using Inspector's existing action model. Returns opaque actionRef values for perform_action.",
                schema: [
                    "type": "object",
                    "additionalProperties": false,
                    "properties": [
                        "handle": [
                            "type": "string",
                            "description": "Opaque handle returned by query or resolve."
                        ]
                    ],
                    "required": ["handle"]
                ]
            ),
            toolDefinition(
                name: "perform_action",
                description: "Perform one semantic action using an actionRef returned by list_actions. Action refs are ephemeral and should be rediscovered after mutation.",
                schema: [
                    "type": "object",
                    "additionalProperties": false,
                    "properties": [
                        "actionRef": [
                            "type": "string",
                            "description": "Opaque action reference returned by list_actions."
                        ]
                    ],
                    "required": ["actionRef"]
                ],
                annotations: [
                    "readOnlyHint": false,
                    "destructiveHint": false,
                    "idempotentHint": false,
                    "openWorldHint": true
                ]
            ),
            toolDefinition(
                name: "assert_property",
                description: "Assert a specific resolved node property against one expected typed value.",
                schema: [
                    "type": "object",
                    "additionalProperties": false,
                    "properties": [
                        "handle": ["type": "string", "description": "Opaque handle returned by query or resolve."],
                        "property": ["type": "string", "enum": ["className","displayName","elementName","accessibilityIdentifier","backingObjectType","isHidden","isUserInteractionEnabled","isInternalView","isSystemContainer","childCount","depth"]],
                        "boolValue": ["type": "boolean"],
                        "numberValue": ["type": "number"],
                        "stringValue": ["type": "string"]
                    ],
                    "required": ["handle", "property"]
                ]
            ),
            toolDefinition(
                name: "assert_visible",
                description: "Assert that a node is currently visible (not hidden).",
                schema: [
                    "type": "object",
                    "additionalProperties": false,
                    "properties": [
                        "handle": ["type": "string", "description": "Opaque handle returned by query or resolve."]
                    ],
                    "required": ["handle"]
                ]
            ),
            toolDefinition(
                name: "assert_hierarchy_contains",
                description: "Assert that the current live hierarchy contains at least a minimum number of nodes matching query-style filters.",
                schema: [
                    "type": "object",
                    "additionalProperties": false,
                    "properties": [
                        "nodeKind": ["type": "string", "enum": ["window", "viewController", "view"]],
                        "classNameContains": ["type": "string"],
                        "displayNameContains": ["type": "string"],
                        "elementNameContains": ["type": "string"],
                        "accessibilityIdentifierEquals": ["type": "string"],
                        "isInternalView": ["type": "boolean"],
                        "isSystemContainer": ["type": "boolean"],
                        "minimumCount": ["type": "integer"]
                    ]
                ]
            ),
            toolDefinition(
                name: "list_properties",
                description: "List editable properties for a node by reusing Inspector's existing panel property model. Returns opaque propertyRef values for later set_property calls.",
                schema: [
                    "type": "object",
                    "additionalProperties": false,
                    "properties": [
                        "handle": [
                            "type": "string",
                            "description": "Opaque handle returned by query or resolve."
                        ],
                        "panel": [
                            "type": "string",
                            "enum": ["identity", "attributes", "size"],
                            "description": "Inspector panel whose editable properties should be projected."
                        ],
                        "includeReadOnly": [
                            "type": "boolean",
                            "description": "Whether to include supported-but-read-only descriptors. Default false."
                        ]
                    ],
                    "required": ["handle", "panel", "includeReadOnly"]
                ]
            ),
            toolDefinition(
                name: "set_property",
                description: "Apply one property mutation using a propertyRef returned by list_properties. Exactly one compatible value field must be provided.",
                schema: [
                    "type": "object",
                    "additionalProperties": false,
                    "properties": [
                        "propertyRef": [
                            "type": "string",
                            "description": "Opaque property reference returned by list_properties."
                        ],
                        "boolValue": ["type": "boolean"],
                        "numberValue": ["type": "number"],
                        "stringValue": ["type": "string"],
                        "selectionIndex": ["type": "integer"]
                    ],
                    "required": ["propertyRef"]
                ],
                annotations: [
                    "readOnlyHint": false,
                    "destructiveHint": false,
                    "idempotentHint": false,
                    "openWorldHint": true
                ]
            ),
            toolDefinition(
                name: "list_layers",
                description: "List built-in Inspector view-hierarchy layers populated in the live app, with each layer's current active (highlighted) state.",
                schema: [
                    "type": "object",
                    "additionalProperties": false,
                    "properties": [:]
                ]
            ),
            toolDefinition(
                name: "toggle_layer",
                description: "Toggle a view-hierarchy layer on or off by its `name` (as returned by list_layers). Flipping is fire-and-forget; the reported active state reflects the intended post-toggle state.",
                schema: [
                    "type": "object",
                    "additionalProperties": false,
                    "properties": [
                        "name": [
                            "type": "string",
                            "description": "Layer name returned by list_layers — e.g. Wireframes, Controls, Text Views."
                        ]
                    ],
                    "required": ["name"]
                ],
                annotations: [
                    "readOnlyHint": false,
                    "destructiveHint": false,
                    "idempotentHint": false,
                    "openWorldHint": true
                ]
            )
        ]
    }

    private func toolDefinition(
        name: String,
        description: String,
        schema: [String: Any],
        annotations: [String: Any] = [
            "readOnlyHint": true,
            "destructiveHint": false,
            "idempotentHint": true,
            "openWorldHint": true
        ]
    ) -> [String: Any] {
        [
            "name": name,
            "description": description,
            "inputSchema": schema,
            "annotations": annotations
        ]
    }

    private func handleToolCall(
        named toolName: String,
        arguments: [String: Any]
    ) async throws -> [String: Any] {
        switch toolName {
        case "query":
            let request = try JSONObject.decode(
                InspectorMCPQueryRequest.self,
                from: arguments
            )
            let result = try await bridgeClient.query(request)
            return try toolResult(
                for: result,
                successText: { queryResult in
                    "Query matched \(queryResult.nodes.count) node(s)."
                }
            )
        case "resolve":
            let request = try JSONObject.decode(
                InspectorMCPResolveRequest.self,
                from: arguments
            )
            let result = try await bridgeClient.resolve(request)
            return try toolResult(
                for: result,
                successText: { node in
                    "Resolved \(node.className) for handle \(node.handle)."
                }
            )
        case "snapshot":
            let request = try JSONObject.decode(
                InspectorMCPSnapshotRequest.self,
                from: arguments
            )
            let result = try await bridgeClient.snapshot(request)
            return try toolResult(
                for: result,
                successText: { snapshot in
                    "Captured \(snapshot.mimeType) snapshot for handle \(snapshot.handle)."
                }
            )
        case "inspect":
            let request = try JSONObject.decode(
                InspectorMCPInspectRequest.self,
                from: arguments
            )
            let result = try await bridgeClient.inspect(request)
            return try toolResult(
                for: result,
                successText: { inspectResult in
                    "Presented Inspector UI for handle \(inspectResult.handle)."
                }
            )
        case "tap":
            let request = try JSONObject.decode(
                InspectorMCPTapRequest.self,
                from: arguments
            )
            let result = try await bridgeClient.tap(request)
            return try toolResult(
                for: result,
                successText: { tapResult in
                    "Dispatched semantic tap for handle \(tapResult.handle)."
                }
            )
        case "list_actions":
            let request = try JSONObject.decode(
                InspectorMCPActionListRequest.self,
                from: arguments
            )
            let result = try await bridgeClient.listActions(request)
            return try toolResult(
                for: result,
                successText: { actionResult in
                    "Listed \(actionResult.actions.count) semantic action(s) for handle \(actionResult.handle)."
                }
            )
        case "perform_action":
            let request = try JSONObject.decode(
                InspectorMCPPerformActionRequest.self,
                from: arguments
            )
            let result = try await bridgeClient.performAction(request)
            return try toolResult(
                for: result,
                successText: { actionResult in
                    "Performed semantic action \(actionResult.actionRef)."
                }
            )
        case "assert_property":
            let request = try JSONObject.decode(
                InspectorMCPAssertPropertyRequest.self,
                from: arguments
            )
            let result = try await bridgeClient.assertProperty(request)
            return try toolResult(
                for: result,
                successText: { assertion in
                    "Assertion on \(assertion.property.rawValue) \(assertion.passed ? "passed" : "failed")."
                }
            )
        case "assert_visible":
            let request = try JSONObject.decode(
                InspectorMCPAssertVisibleRequest.self,
                from: arguments
            )
            let result = try await bridgeClient.assertVisible(request)
            return try toolResult(
                for: result,
                successText: { assertion in
                    "Visibility assertion \(assertion.passed ? "passed" : "failed") for handle \(assertion.handle)."
                }
            )
        case "assert_hierarchy_contains":
            let request = try JSONObject.decode(
                InspectorMCPAssertHierarchyContainsRequest.self,
                from: arguments
            )
            let result = try await bridgeClient.assertHierarchyContains(request)
            return try toolResult(
                for: result,
                successText: { assertion in
                    "Hierarchy assertion \(assertion.passed ? "passed" : "failed") with \(assertion.matchCount) match(es)."
                }
            )
        case "list_properties":
            let request = try JSONObject.decode(
                InspectorMCPPropertyListRequest.self,
                from: arguments
            )
            let result = try await bridgeClient.listProperties(request)
            return try toolResult(
                for: result,
                successText: { propertyResult in
                    let propertyCount = propertyResult.sections
                        .flatMap(\.rows)
                        .flatMap(\.properties)
                        .count
                    return "Listed \(propertyCount) editable property descriptor(s) for handle \(propertyResult.handle)."
                }
            )
        case "set_property":
            let request = try JSONObject.decode(
                InspectorMCPSetPropertyRequest.self,
                from: arguments
            )
            let result = try await bridgeClient.setProperty(request)
            return try toolResult(
                for: result,
                successText: { setResult in
                    "Applied property mutation for \(setResult.propertyRef)."
                }
            )
        case "list_layers":
            let result = try await bridgeClient.layers()
            return try toolResult(
                for: result,
                successText: { layersResult in
                    "Listed \(layersResult.layers.count) populated layer(s)."
                }
            )
        case "toggle_layer":
            let request = try JSONObject.decode(
                InspectorMCPToggleLayerRequest.self,
                from: arguments
            )
            let result = try await bridgeClient.toggleLayer(request)
            return try toolResult(
                for: result,
                successText: { toggleResult in
                    "Layer \(toggleResult.name) is now \(toggleResult.active ? "active" : "inactive")."
                }
            )
        default:
            throw InspectorMCPServerError.unknownTool(toolName)
        }
    }

    private func toolResult<Success: Encodable>(
        for result: Result<Success, InspectorMCPTransportError>,
        successText: (Success) -> String
    ) throws -> [String: Any] {
        switch result {
        case let .success(success):
            return [
                "content": [
                    [
                        "type": "text",
                        "text": successText(success)
                    ]
                ],
                "structuredContent": try JSONObject.encodeObject(success),
                "isError": false
            ]
        case let .failure(error):
            return [
                "content": [
                    [
                        "type": "text",
                        "text": "\(error.code.rawValue): \(error.message)"
                    ]
                ],
                "structuredContent": try JSONObject.encodeObject(error),
                "isError": true
            ]
        }
    }

    private func encodeResponse(
        id: Any?,
        result: [String: Any]
    ) throws -> Data {
        try JSONObject.encodeObject([
            "jsonrpc": "2.0",
            "id": id ?? NSNull(),
            "result": result
        ])
    }

    private func encodeErrorResponse(
        id: Any?,
        code: Int,
        message: String
    ) -> Data {
        try! JSONObject.encodeObject([
            "jsonrpc": "2.0",
            "id": id ?? NSNull(),
            "error": [
                "code": code,
                "message": message
            ]
        ])
    }
}

private enum JSONObject {
    static func decodeObject(from data: Data) throws -> [String: Any] {
        let object = try JSONSerialization.jsonObject(with: data)
        guard let dictionary = object as? [String: Any] else {
            throw InspectorMCPServerError.invalidArguments("Expected JSON object")
        }
        return dictionary
    }

    static func decode<T: Decodable>(
        _ type: T.Type,
        from object: [String: Any]
    ) throws -> T {
        let data = try JSONSerialization.data(withJSONObject: object)
        return try JSONDecoder().decode(T.self, from: data)
    }

    static func encodeObject<T: Encodable>(_ value: T) throws -> [String: Any] {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(AnyEncodable(value))
        let object = try JSONSerialization.jsonObject(with: data)
        guard let dictionary = object as? [String: Any] else {
            throw InspectorMCPServerError.malformedResponse("Expected JSON object result")
        }
        return dictionary
    }

    static func encodeObject(_ value: [String: Any]) throws -> Data {
        try JSONSerialization.data(withJSONObject: value)
    }
}

private struct AnyEncodable: Encodable {
    private let encodeBlock: (Encoder) throws -> Void

    init<T: Encodable>(_ value: T) {
        encodeBlock = value.encode(to:)
    }

    func encode(to encoder: Encoder) throws {
        try encodeBlock(encoder)
    }
}
