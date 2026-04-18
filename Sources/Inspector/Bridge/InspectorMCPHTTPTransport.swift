#if INSPECTOR_DEBUGGING && canImport(UIKit) && targetEnvironment(simulator)
import Foundation
import Network
import InspectorMCPWire
import UIKit

private enum InspectorMCPHTTPTransportError: Error {
    case malformedRequest(String)

    var message: String {
        switch self {
        case let .malformedRequest(message):
            return message
        }
    }
}

private struct InspectorMCPHTTPRequest {
    let method: String
    let path: String
    let body: Data
}

private struct InspectorMCPHTTPResponse {
    let statusCode: Int
    let body: Data
    let contentType: String

    init(statusCode: Int, body: Data, contentType: String = "application/json") {
        self.statusCode = statusCode
        self.body = body
        self.contentType = contentType
    }

    var serialized: Data {
        let reasonPhrase: String
        switch statusCode {
        case 200:
            reasonPhrase = "OK"
        case 400:
            reasonPhrase = "Bad Request"
        case 404:
            reasonPhrase = "Not Found"
        case 500:
            reasonPhrase = "Internal Server Error"
        default:
            reasonPhrase = "Error"
        }

        var header = "HTTP/1.1 \(statusCode) \(reasonPhrase)\r\n"
        header += "Content-Type: \(contentType)\r\n"
        header += "Content-Length: \(body.count)\r\n"
        header += "Connection: close\r\n"
        header += "\r\n"

        return Data(header.utf8) + body
    }
}

private final class InspectorMCPHTTPServer {
    private let queue = DispatchQueue(label: "am.pedro.inspector.mcp.http")
    private var listener: NWListener?

    func startIfNeeded() {
        queue.sync {
            guard listener == nil else {
                return
            }

            do {
                let parameters = NWParameters.tcp
                parameters.requiredLocalEndpoint = .hostPort(
                    host: .init(InspectorMCPBridgeEndpoint.host),
                    port: .init(integerLiteral: InspectorMCPBridgeEndpoint.port)
                )

                let listener = try NWListener(using: parameters)
                listener.newConnectionHandler = { [weak self] connection in
                    self?.handle(connection)
                }
                listener.stateUpdateHandler = { _ in }
                listener.start(queue: self.queue)
                self.listener = listener
            } catch {
                assertionFailure("Failed to start Inspector MCP HTTP transport: \(error)")
            }
        }
    }

    func stop() {
        queue.sync {
            listener?.cancel()
            listener = nil
        }
    }

    private func handle(_ connection: NWConnection) {
        connection.start(queue: queue)
        receive(on: connection, buffer: Data())
    }

    private func receive(on connection: NWConnection, buffer: Data) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65_536) { [weak self] data, _, isComplete, error in
            guard let self else {
                connection.cancel()
                return
            }

            if error != nil {
                connection.cancel()
                return
            }

            var buffer = buffer
            if let data {
                buffer.append(data)
            }

            do {
                if let request = try self.parseRequest(from: buffer) {
                    let response = try self.route(request)
                    connection.send(content: response.serialized, completion: .contentProcessed { _ in
                        connection.cancel()
                    })
                    return
                }
            } catch let error as InspectorMCPHTTPTransportError {
                let response = self.transportFailureResponse(
                    statusCode: 400,
                    message: error.message
                )
                connection.send(content: response.serialized, completion: .contentProcessed { _ in
                    connection.cancel()
                })
                return
            } catch {
                let response = self.transportFailureResponse(
                    statusCode: 500,
                    message: "Internal server error"
                )
                connection.send(content: response.serialized, completion: .contentProcessed { _ in
                    connection.cancel()
                })
                return
            }

            if isComplete {
                connection.cancel()
                return
            }

            self.receive(on: connection, buffer: buffer)
        }
    }

    private func parseRequest(from data: Data) throws -> InspectorMCPHTTPRequest? {
        let delimiter = Data("\r\n\r\n".utf8)
        guard let headerRange = data.range(of: delimiter) else {
            return nil
        }

        let headerData = data[..<headerRange.lowerBound]
        guard let headerString = String(data: headerData, encoding: .utf8) else {
            throw InspectorMCPHTTPTransportError.malformedRequest("Invalid UTF-8 headers")
        }

        let lines = headerString.components(separatedBy: "\r\n")
        guard let requestLine = lines.first else {
            throw InspectorMCPHTTPTransportError.malformedRequest("Missing request line")
        }

        let requestParts = requestLine.split(separator: " ")
        guard requestParts.count == 3 else {
            throw InspectorMCPHTTPTransportError.malformedRequest("Malformed request line")
        }

        let method = String(requestParts[0])
        let path = String(requestParts[1])

        var headers: [String: String] = [:]
        for line in lines.dropFirst() {
            let parts = line.split(separator: ":", maxSplits: 1)
            guard parts.count == 2 else {
                continue
            }

            headers[String(parts[0]).lowercased()] = String(parts[1]).trimmingCharacters(in: .whitespaces)
        }

        let contentLength = Int(headers["content-length"] ?? "0") ?? 0
        let bodyStart = headerRange.upperBound
        let totalLength = data.distance(from: data.startIndex, to: bodyStart) + contentLength

        guard data.count >= totalLength else {
            return nil
        }

        let body = data[bodyStart..<data.index(bodyStart, offsetBy: contentLength)]

        return InspectorMCPHTTPRequest(method: method, path: path, body: Data(body))
    }

    private func route(_ request: InspectorMCPHTTPRequest) throws -> InspectorMCPHTTPResponse {
        switch (request.method, request.path) {
        case ("GET", InspectorMCPBridgeEndpoint.healthPath):
            return try jsonResponse(healthResponse())
        case ("POST", InspectorMCPBridgeEndpoint.queryPath):
            let payload: InspectorMCPQueryRequest = try decode(request.body, allowedKeys: [
                "nodeKind",
                "classNameContains",
                "displayNameContains",
                "elementNameContains",
                "accessibilityIdentifierEquals"
            ])

            do {
                return try jsonResponse(
                    InspectorMCPSuccessEnvelope(result: try bridgeQueryResult(for: payload))
                )
            } catch let error as InspectorBridgeError {
                return try jsonResponse(InspectorMCPFailureEnvelope(error: transportError(for: error)))
            }
        case ("POST", InspectorMCPBridgeEndpoint.resolvePath):
            let payload: InspectorMCPResolveRequest = try decode(
                request.body,
                allowedKeys: ["handle"]
            )

            do {
                return try jsonResponse(
                    InspectorMCPSuccessEnvelope(result: try bridgeResolveResult(for: payload))
                )
            } catch let error as InspectorBridgeError {
                return try jsonResponse(InspectorMCPFailureEnvelope(error: transportError(for: error)))
            }
        case ("POST", InspectorMCPBridgeEndpoint.snapshotPath):
            let payload: InspectorMCPSnapshotRequest = try decode(
                request.body,
                allowedKeys: ["handle", "afterScreenUpdates"]
            )

            do {
                return try jsonResponse(
                    InspectorMCPSuccessEnvelope(result: try bridgeSnapshotResult(for: payload))
                )
            } catch let error as InspectorBridgeError {
                return try jsonResponse(InspectorMCPFailureEnvelope(error: transportError(for: error)))
            }
        case ("POST", InspectorMCPBridgeEndpoint.inspectPath):
            let payload: InspectorMCPInspectRequest = try decode(
                request.body,
                allowedKeys: ["handle"]
            )

            do {
                return try jsonResponse(
                    InspectorMCPSuccessEnvelope(result: try bridgeInspectResult(for: payload))
                )
            } catch let error as InspectorBridgeError {
                return try jsonResponse(InspectorMCPFailureEnvelope(error: transportError(for: error)))
            }
        case ("POST", InspectorMCPBridgeEndpoint.tapPath):
            let payload: InspectorMCPTapRequest = try decode(
                request.body,
                allowedKeys: ["handle"]
            )

            do {
                return try jsonResponse(
                    InspectorMCPSuccessEnvelope(result: try bridgeTapResult(for: payload))
                )
            } catch let error as InspectorBridgeError {
                return try jsonResponse(InspectorMCPFailureEnvelope(error: transportError(for: error)))
            }
        case ("POST", InspectorMCPBridgeEndpoint.propertiesPath):
            let payload: InspectorMCPPropertyListRequest = try decode(
                request.body,
                allowedKeys: ["handle", "panel", "includeReadOnly"]
            )

            do {
                return try jsonResponse(
                    InspectorMCPSuccessEnvelope(result: try bridgePropertyListResult(for: payload))
                )
            } catch let error as InspectorBridgeError {
                return try jsonResponse(InspectorMCPFailureEnvelope(error: transportError(for: error)))
            }
        case ("POST", InspectorMCPBridgeEndpoint.setPropertyPath):
            let payload: InspectorMCPSetPropertyRequest = try decode(
                request.body,
                allowedKeys: ["propertyRef", "boolValue", "numberValue", "stringValue", "selectionIndex"]
            )

            do {
                return try jsonResponse(
                    InspectorMCPSuccessEnvelope(result: try bridgeSetPropertyResult(for: payload))
                )
            } catch let error as InspectorBridgeError {
                return try jsonResponse(InspectorMCPFailureEnvelope(error: transportError(for: error)))
            }
        case ("POST", InspectorMCPBridgeEndpoint.layersPath):
            do {
                return try jsonResponse(
                    InspectorMCPSuccessEnvelope(result: try bridgeLayersResult())
                )
            } catch let error as InspectorBridgeError {
                return try jsonResponse(InspectorMCPFailureEnvelope(error: transportError(for: error)))
            }
        case ("POST", InspectorMCPBridgeEndpoint.toggleLayerPath):
            let payload: InspectorMCPToggleLayerRequest = try decode(
                request.body,
                allowedKeys: ["name"]
            )

            do {
                return try jsonResponse(
                    InspectorMCPSuccessEnvelope(result: try bridgeToggleLayerResult(for: payload))
                )
            } catch let error as InspectorBridgeError {
                return try jsonResponse(InspectorMCPFailureEnvelope(error: transportError(for: error)))
            }
        default:
            return transportFailureResponse(statusCode: 404, message: "Unknown route")
        }
    }

    private func decode<Payload: Decodable>(
        _ data: Data,
        allowedKeys: Set<String>
    ) throws -> Payload {
        let object = try JSONSerialization.jsonObject(with: data)
        guard let dictionary = object as? [String: Any] else {
            throw InspectorMCPHTTPTransportError.malformedRequest("Expected JSON object body")
        }

        let unexpectedKeys = Set(dictionary.keys).subtracting(allowedKeys)
        guard unexpectedKeys.isEmpty else {
            throw InspectorMCPHTTPTransportError.malformedRequest("Unexpected keys: \(unexpectedKeys.sorted().joined(separator: ", "))")
        }

        do {
            return try JSONDecoder().decode(Payload.self, from: data)
        } catch {
            throw InspectorMCPHTTPTransportError.malformedRequest("Malformed request body")
        }
    }

    private func healthResponse() -> InspectorMCPHealthResponse {
        let bridgeEnabled = Inspector.sharedInstance.configuration.enableMCPBridge
        let inspectorStarted = Inspector.sharedInstance.state == .started

        let status: InspectorMCPHealthStatus
        switch (bridgeEnabled, inspectorStarted) {
        case (false, _):
            status = .disabled
        case (true, false):
            status = .notStarted
        case (true, true):
            status = .active
        }

        return InspectorMCPHealthResponse(
            status: status,
            bridgeEnabled: bridgeEnabled,
            inspectorStarted: inspectorStarted,
            bundleIdentifier: Bundle.main.bundleIdentifier,
            operations: [.query, .resolve, .snapshot, .inspect, .tap, .listProperties, .setProperty, .layers, .toggleLayer],
            apiVersion: 2
        )
    }

    private func bridgeQueryResult(for request: InspectorMCPQueryRequest) throws -> InspectorMCPQueryResult {
        let response = try Inspector.bridgeQuery(
            .init(
                nodeKind: request.nodeKind.flatMap(bridgeNodeKind(from:)),
                classNameContains: request.classNameContains,
                displayNameContains: request.displayNameContains,
                elementNameContains: request.elementNameContains,
                accessibilityIdentifierEquals: request.accessibilityIdentifierEquals
            )
        )

        return InspectorMCPQueryResult(
            expiresAt: response.expiresAt,
            nodes: response.nodes.map(wireNode(from:))
        )
    }

    private func bridgeResolveResult(for request: InspectorMCPResolveRequest) throws -> InspectorMCPNode {
        wireNode(from: try Inspector.bridgeResolve(.init(rawValue: request.handle)))
    }

    private func bridgeSnapshotResult(for request: InspectorMCPSnapshotRequest) throws -> InspectorMCPSnapshotResult {
        let artifact = try Inspector.bridgeSnapshot(
            .init(rawValue: request.handle),
            afterScreenUpdates: request.afterScreenUpdates
        )

        return InspectorMCPSnapshotResult(
            handle: artifact.handle.rawValue,
            mimeType: "image/png",
            pngPath: artifact.pngURL.path,
            size: .init(width: artifact.size.width.doubleValue, height: artifact.size.height.doubleValue),
            deviceScale: artifact.deviceScale.doubleValue,
            createdAt: artifact.createdAt
        )
    }

    private func bridgeInspectResult(for request: InspectorMCPInspectRequest) throws -> InspectorMCPInspectResult {
        _ = try Inspector.bridgeInspect(.init(rawValue: request.handle))
        return InspectorMCPInspectResult(handle: request.handle, presented: true)
    }

    private func bridgeTapResult(for request: InspectorMCPTapRequest) throws -> InspectorMCPTapResult {
        _ = try Inspector.bridgeTap(.init(rawValue: request.handle))
        return InspectorMCPTapResult(handle: request.handle, dispatched: true)
    }

    private func bridgePropertyListResult(for request: InspectorMCPPropertyListRequest) throws -> InspectorMCPPropertyListResult {
        let response = try Inspector.bridgeListProperties(
            .init(rawValue: request.handle),
            panel: bridgePanel(from: request.panel),
            includeReadOnly: request.includeReadOnly
        )

        return InspectorMCPPropertyListResult(
            handle: response.handle.rawValue,
            expiresAt: response.expiresAt,
            panel: wirePanel(from: response.panel),
            sections: response.sections.map(wirePropertySection(from:))
        )
    }

    private func bridgeSetPropertyResult(for request: InspectorMCPSetPropertyRequest) throws -> InspectorMCPSetPropertyResult {
        let mutationValue = try bridgeMutationValue(from: request)
        let result = try Inspector.bridgeSetProperty(reference: request.propertyRef, value: mutationValue)
        return InspectorMCPSetPropertyResult(
            propertyRef: result.propertyRef,
            applied: result.applied,
            refreshRecommended: result.refreshRecommended
        )
    }

    private func bridgeLayersResult() throws -> InspectorMCPLayersResult {
        let layers = try Inspector.bridgeLayers()
        return InspectorMCPLayersResult(layers: layers.map(wireLayerState(from:)))
    }

    private func bridgeToggleLayerResult(for request: InspectorMCPToggleLayerRequest) throws -> InspectorMCPToggleLayerResult {
        let state = try Inspector.bridgeToggleLayer(name: request.name)
        return InspectorMCPToggleLayerResult(name: state.name, active: state.active)
    }

    private func wireLayerState(from state: InspectorBridgeLayerState) -> InspectorMCPLayerState {
        InspectorMCPLayerState(name: state.name, displayName: state.displayName, active: state.active)
    }

    private func bridgeNodeKind(from value: InspectorMCPNodeKind) -> InspectorBridgeNodeKind {
        switch value {
        case .window:
            return .window
        case .viewController:
            return .viewController
        case .view:
            return .view
        }
    }

    private func wireNode(from node: InspectorBridgeNode) -> InspectorMCPNode {
        InspectorMCPNode(
            handle: node.handle.rawValue,
            nodeKind: wireNodeKind(from: node.nodeKind),
            backingObjectType: node.backingObjectType,
            className: node.className,
            displayName: node.displayName,
            elementName: node.elementName,
            accessibilityIdentifier: node.accessibilityIdentifier,
            frame: .init(
                x: node.frame.origin.x.doubleValue,
                y: node.frame.origin.y.doubleValue,
                width: node.frame.size.width.doubleValue,
                height: node.frame.size.height.doubleValue
            ),
            isHidden: node.isHidden,
            isUserInteractionEnabled: node.isUserInteractionEnabled,
            depth: node.depth,
            parentHandle: node.parentHandle?.rawValue,
            childHandles: node.childHandles.map(\.rawValue),
            childCount: node.childCount
        )
    }

    private func wireNodeKind(from value: InspectorBridgeNodeKind) -> InspectorMCPNodeKind {
        switch value {
        case .window:
            return .window
        case .viewController:
            return .viewController
        case .view:
            return .view
        }
    }

    private func transportError(for error: InspectorBridgeError) -> InspectorMCPTransportError {
        switch error {
        case .disabled:
            return .init(code: .disabled, message: "Inspector MCP bridge is disabled", details: .empty)
        case .notStarted:
            return .init(code: .notStarted, message: "Inspector has not started yet", details: .empty)
        case .staleHandle:
            return .init(code: .staleHandle, message: "Handle is stale; issue a fresh query", details: .empty)
        case .stalePropertyReference:
            return .init(code: .stalePropertyReference, message: "Property reference is stale; list properties again", details: .empty)
        case let .snapshotUnavailable(reason):
            return .init(
                code: .snapshotUnavailable,
                message: "Snapshot is unavailable",
                details: .snapshotUnavailable(reason: wireSnapshotReason(from: reason))
            )
        case .unsupportedTarget:
            return .init(code: .unsupportedTarget, message: "Inspector MCP bridge is unavailable on this target", details: .empty)
        case let .invalidPropertyValue(message):
            return .init(code: .invalidPropertyValue, message: "Property value is invalid", details: .internalFailure(message: message))
        case let .internalFailure(message):
            return .init(code: .internalFailure, message: "Inspector bridge failed internally", details: .internalFailure(message: message))
        }
    }

    private func bridgePanel(from value: InspectorMCPEditablePanel) -> InspectorBridgeEditablePanel {
        switch value {
        case .identity:
            return .identity
        case .attributes:
            return .attributes
        case .size:
            return .size
        }
    }

    private func wirePanel(from value: InspectorBridgeEditablePanel) -> InspectorMCPEditablePanel {
        switch value {
        case .identity:
            return .identity
        case .attributes:
            return .attributes
        case .size:
            return .size
        }
    }

    private func wirePropertySlot(from value: InspectorBridgeEditablePropertySlot) -> InspectorMCPEditablePropertySlot {
        switch value {
        case .property:
            return .property
        case .titleAccessory:
            return .titleAccessory
        }
    }

    private func wirePropertyKind(from value: InspectorBridgeEditablePropertyKind) -> InspectorMCPEditablePropertyKind {
        switch value {
        case .toggle:
            return .toggle
        case .stepper:
            return .stepper
        case .textField:
            return .textField
        case .textView:
            return .textView
        case .optionsList:
            return .optionsList
        case .textButtonGroup:
            return .textButtonGroup
        case .imageButtonGroup:
            return .imageButtonGroup
        }
    }

    private func wirePropertySection(from value: InspectorBridgeEditablePropertySection) -> InspectorMCPEditablePropertySection {
        InspectorMCPEditablePropertySection(
            title: value.title,
            rows: value.rows.map { row in
                InspectorMCPEditablePropertyRow(
                    title: row.title,
                    subtitle: row.subtitle,
                    properties: row.properties.map(wireEditableProperty(from:))
                )
            }
        )
    }

    private func wireEditableProperty(from value: InspectorBridgeEditablePropertyDescriptor) -> InspectorMCPEditableProperty {
        InspectorMCPEditableProperty(
            propertyRef: value.propertyRef,
            path: .init(
                panel: wirePanel(from: value.path.panel),
                section: value.path.section,
                row: value.path.row,
                slot: wirePropertySlot(from: value.path.slot),
                index: value.path.index
            ),
            title: value.title,
            kind: wirePropertyKind(from: value.kind),
            editable: value.editable,
            boolValue: value.boolValue,
            numberValue: value.numberValue,
            stringValue: value.stringValue,
            selectionIndex: value.selectionIndex,
            minimum: value.minimum,
            maximum: value.maximum,
            step: value.step,
            isDecimal: value.isDecimal,
            options: value.options,
            nullable: value.nullable
        )
    }

    private func bridgeMutationValue(from request: InspectorMCPSetPropertyRequest) throws -> InspectorBridgePropertyMutationValue {
        let populatedValues = [
            request.boolValue != nil,
            request.numberValue != nil,
            request.stringValue != nil,
            request.selectionIndex != nil
        ].filter { $0 }

        guard populatedValues.count == 1 else {
            throw InspectorBridgeError.invalidPropertyValue("exactly one value field must be provided")
        }

        if let boolValue = request.boolValue {
            return .bool(boolValue)
        }
        if let numberValue = request.numberValue {
            return .number(numberValue)
        }
        if request.stringValue != nil {
            return .string(request.stringValue)
        }
        return .selection(request.selectionIndex)
    }

    private func wireSnapshotReason(from value: InspectorBridgeSnapshotUnavailableReason) -> InspectorMCPSnapshotUnavailableReason {
        switch value {
        case .lostConnection:
            return .lostConnection
        case .noWindow:
            return .noWindow
        case .frameIsEmpty:
            return .frameIsEmpty
        case .isHidden:
            return .isHidden
        case .captureFailed:
            return .captureFailed
        case .runtimeSnapshotUnavailable:
            return .runtimeSnapshotUnavailable
        }
    }

    private func jsonResponse<Payload: Encodable>(_ payload: Payload) throws -> InspectorMCPHTTPResponse {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return InspectorMCPHTTPResponse(statusCode: 200, body: try encoder.encode(payload))
    }

    private func transportFailureResponse(statusCode: Int, message: String) -> InspectorMCPHTTPResponse {
        let payload = ["message": message]
        let body = (try? JSONSerialization.data(withJSONObject: payload)) ?? Data()
        return InspectorMCPHTTPResponse(statusCode: statusCode, body: body)
    }
}

private let sharedInspectorMCPHTTPServer = InspectorMCPHTTPServer()

func startInspectorMCPHTTPTransportIfNeeded() {
    sharedInspectorMCPHTTPServer.startIfNeeded()
}

func stopInspectorMCPHTTPTransport() {
    sharedInspectorMCPHTTPServer.stop()
}

private extension CGFloat {
    var doubleValue: Double { Double(self) }
}
#endif
