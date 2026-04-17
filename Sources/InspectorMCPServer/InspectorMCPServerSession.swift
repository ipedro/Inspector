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
                    "instructions": "Use query to discover nodes, then resolve or snapshot returned handles. Stale handles require a fresh query."
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
