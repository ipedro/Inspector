#if INSPECTOR_DEBUGGING && canImport(UIKit) && targetEnvironment(simulator)
import Foundation
import XCTest

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
        XCTAssertEqual(health["operations"] as? [String], ["query", "resolve", "snapshot"])
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
        XCTAssertEqual(nodes?.count, 1)

        let node = try XCTUnwrap(nodes?.first)
        XCTAssertEqual(node["nodeKind"] as? String, "view")
        XCTAssertEqual(node["accessibilityIdentifier"] as? String, "Content Stack View")
        XCTAssertFalse((node["handle"] as? String ?? "").isEmpty)

        let expectedKeys = [
            "handle",
            "nodeKind",
            "backingObjectType",
            "className",
            "displayName",
            "elementName",
            "accessibilityIdentifier",
            "frame",
            "isHidden",
            "isUserInteractionEnabled",
            "depth",
            "parentHandle",
            "childHandles",
            "childCount"
        ]

        XCTAssertEqual(Set(node.keys), Set(expectedKeys))
    }

    func testSnapshotReturnsBase64PNGEnvelope() async throws {
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
            body: [
                "handle": handle,
                "afterScreenUpdates": true
            ]
        )

        XCTAssertEqual(snapshotResponse.statusCode, 200)

        let snapshotPayload = try unpackSuccessEnvelope(from: snapshotResponse.body)
        XCTAssertEqual(snapshotPayload["handle"] as? String, handle)
        XCTAssertEqual(snapshotPayload["mimeType"] as? String, "image/png")
        XCTAssertFalse((snapshotPayload["pngBase64"] as? String ?? "").isEmpty)

        let size = try XCTUnwrap(snapshotPayload["size"] as? [String: Any])
        XCTAssertGreaterThan((size["width"] as? Double) ?? 0, 0)
        XCTAssertGreaterThan((size["height"] as? Double) ?? 0, 0)
        XCTAssertGreaterThan((snapshotPayload["scale"] as? Double) ?? 0, 0)
    }

    func testOldestHandleBecomesStaleAfterNinthQuery() async throws {
        _ = try await pollHealth(timeout: 5) { payload in
            payload["status"] as? String == "active"
        }

        let queryBody = ["accessibilityIdentifierEquals": "Content Stack View"]
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
        XCTAssertEqual(freshPayload["accessibilityIdentifier"] as? String, "Content Stack View")
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

    private func pollHealth(
        timeout: TimeInterval,
        until predicate: @escaping ([String: Any]) -> Bool
    ) async throws -> [String: Any] {
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
