import Foundation
import InspectorMCPWire

protocol InspectorMCPBridgeClient {
    func health() async throws -> InspectorMCPHealthResponse
    func query(_ request: InspectorMCPQueryRequest) async throws -> Result<InspectorMCPQueryResult, InspectorMCPTransportError>
    func resolve(_ request: InspectorMCPResolveRequest) async throws -> Result<InspectorMCPNode, InspectorMCPTransportError>
    func snapshot(_ request: InspectorMCPSnapshotRequest) async throws -> Result<InspectorMCPSnapshotResult, InspectorMCPTransportError>
    func inspect(_ request: InspectorMCPInspectRequest) async throws -> Result<InspectorMCPInspectResult, InspectorMCPTransportError>
    func tap(_ request: InspectorMCPTapRequest) async throws -> Result<InspectorMCPTapResult, InspectorMCPTransportError>
    func listProperties(_ request: InspectorMCPPropertyListRequest) async throws -> Result<InspectorMCPPropertyListResult, InspectorMCPTransportError>
    func setProperty(_ request: InspectorMCPSetPropertyRequest) async throws -> Result<InspectorMCPSetPropertyResult, InspectorMCPTransportError>
    func layers() async throws -> Result<InspectorMCPLayersResult, InspectorMCPTransportError>
    func toggleLayer(_ request: InspectorMCPToggleLayerRequest) async throws -> Result<InspectorMCPToggleLayerResult, InspectorMCPTransportError>
}

enum InspectorMCPServerError: Error, LocalizedError {
    case invalidArguments(String)
    case unknownTool(String)
    case unsupportedMethod(String)
    case transportFailure(String)
    case malformedResponse(String)
    case disabled(String)
    case readinessTimeout(String)
    case zeroBootedSimulators
    case multipleBootedSimulators([String])
    case bundleIDMissing
    case commandFailed(String)

    var errorDescription: String? {
        switch self {
        case let .invalidArguments(message),
             let .transportFailure(message),
             let .malformedResponse(message),
             let .disabled(message),
             let .readinessTimeout(message),
             let .commandFailed(message):
            return message
        case let .unknownTool(name):
            return "Unknown tool: \(name)"
        case let .unsupportedMethod(method):
            return "Unsupported method: \(method)"
        case .zeroBootedSimulators:
            return "Exactly one booted simulator is required, but none are booted"
        case let .multipleBootedSimulators(identifiers):
            return "Exactly one booted simulator is required, but found \(identifiers.count): \(identifiers.joined(separator: ", "))"
        case .bundleIDMissing:
            return "Bundle identifier must not be empty"
        }
    }
}

final class InspectorMCPHTTPBridgeClient: InspectorMCPBridgeClient {
    private let session: URLSession
    private let baseURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(
        session: URLSession = .shared,
        baseURL: URL = InspectorMCPBridgeEndpoint.baseURL
    ) {
        self.session = session
        self.baseURL = baseURL

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    func health() async throws -> InspectorMCPHealthResponse {
        let response = try await request(path: InspectorMCPBridgeEndpoint.healthPath, method: "GET", body: nil)

        guard response.statusCode == 200 else {
            throw InspectorMCPServerError.transportFailure("Unexpected /health status code: \(response.statusCode)")
        }

        return try decoder.decode(InspectorMCPHealthResponse.self, from: response.body)
    }

    func query(_ request: InspectorMCPQueryRequest) async throws -> Result<InspectorMCPQueryResult, InspectorMCPTransportError> {
        try await sendToolRequest(
            path: InspectorMCPBridgeEndpoint.queryPath,
            body: request
        )
    }

    func resolve(_ request: InspectorMCPResolveRequest) async throws -> Result<InspectorMCPNode, InspectorMCPTransportError> {
        try await sendToolRequest(
            path: InspectorMCPBridgeEndpoint.resolvePath,
            body: request
        )
    }

    func snapshot(_ request: InspectorMCPSnapshotRequest) async throws -> Result<InspectorMCPSnapshotResult, InspectorMCPTransportError> {
        try await sendToolRequest(
            path: InspectorMCPBridgeEndpoint.snapshotPath,
            body: request
        )
    }

    func inspect(_ request: InspectorMCPInspectRequest) async throws -> Result<InspectorMCPInspectResult, InspectorMCPTransportError> {
        try await sendToolRequest(
            path: InspectorMCPBridgeEndpoint.inspectPath,
            body: request
        )
    }

    func tap(_ request: InspectorMCPTapRequest) async throws -> Result<InspectorMCPTapResult, InspectorMCPTransportError> {
        try await sendToolRequest(
            path: InspectorMCPBridgeEndpoint.tapPath,
            body: request
        )
    }

    func listProperties(_ request: InspectorMCPPropertyListRequest) async throws -> Result<InspectorMCPPropertyListResult, InspectorMCPTransportError> {
        try await sendToolRequest(
            path: InspectorMCPBridgeEndpoint.propertiesPath,
            body: request
        )
    }

    func setProperty(_ request: InspectorMCPSetPropertyRequest) async throws -> Result<InspectorMCPSetPropertyResult, InspectorMCPTransportError> {
        try await sendToolRequest(
            path: InspectorMCPBridgeEndpoint.setPropertyPath,
            body: request
        )
    }

    func layers() async throws -> Result<InspectorMCPLayersResult, InspectorMCPTransportError> {
        try await sendToolRequest(
            path: InspectorMCPBridgeEndpoint.layersPath,
            body: EmptyRequestBody()
        )
    }

    func toggleLayer(_ request: InspectorMCPToggleLayerRequest) async throws -> Result<InspectorMCPToggleLayerResult, InspectorMCPTransportError> {
        try await sendToolRequest(
            path: InspectorMCPBridgeEndpoint.toggleLayerPath,
            body: request
        )
    }

    private func sendToolRequest<Body: Encodable, Success: Codable & Equatable>(
        path: String,
        body: Body
    ) async throws -> Result<Success, InspectorMCPTransportError> {
        let requestBody = try encoder.encode(body)
        let response = try await request(path: path, method: "POST", body: requestBody)

        guard response.statusCode == 200 else {
            throw InspectorMCPServerError.transportFailure("Unexpected status code \(response.statusCode) for \(path)")
        }

        if let success = try? decoder.decode(InspectorMCPSuccessEnvelope<Success>.self, from: response.body) {
            return .success(success.result)
        }

        if let failure = try? decoder.decode(InspectorMCPFailureEnvelope.self, from: response.body) {
            return .failure(failure.error)
        }

        throw InspectorMCPServerError.malformedResponse("Unable to decode transport response for \(path)")
    }

    private func request(
        path: String,
        method: String,
        body: Data?
    ) async throws -> (statusCode: Int, body: Data) {
        var request = URLRequest(url: baseURL.appendingPathComponent(String(path.dropFirst())))
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body

        let (responseBody, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw InspectorMCPServerError.transportFailure("Non-HTTP response from Inspector bridge")
        }

        return (httpResponse.statusCode, responseBody)
    }
}

private struct EmptyRequestBody: Encodable {
    func encode(to encoder: Encoder) throws {
        let container = encoder.container(keyedBy: EmptyCodingKey.self)
        _ = container
    }

    private enum EmptyCodingKey: CodingKey {}
}
