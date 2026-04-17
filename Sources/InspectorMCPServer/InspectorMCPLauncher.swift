import Foundation
import InspectorMCPWire

struct InspectorMCPLaunchOptions {
    let xcodeProjectPath: String
    let scheme: String
    let bundleID: String

    init(arguments: [String]) throws {
        var values: [String: String] = [:]
        var index = 0

        while index < arguments.count {
            let key = arguments[index]
            let valueIndex = index + 1
            guard valueIndex < arguments.count else {
                throw InspectorMCPServerError.invalidArguments("Missing value for \(key)")
            }

            values[key] = arguments[valueIndex]
            index += 2
        }

        guard let xcodeProjectPath = values["--xcodeproj"], !xcodeProjectPath.isEmpty else {
            throw InspectorMCPServerError.invalidArguments("Missing --xcodeproj")
        }

        guard let scheme = values["--scheme"], !scheme.isEmpty else {
            throw InspectorMCPServerError.invalidArguments("Missing --scheme")
        }

        guard let bundleID = values["--bundle-id"], !bundleID.isEmpty else {
            throw InspectorMCPServerError.bundleIDMissing
        }

        self.xcodeProjectPath = xcodeProjectPath
        self.scheme = scheme
        self.bundleID = bundleID
    }
}

enum InspectorMCPLaunchMode {
    case attached
    case launched
}

struct InspectorMCPLaunchPreparation {
    let simulatorUDID: String
    let launchMode: InspectorMCPLaunchMode
}

protocol InspectorMCPProcessRunning {
    func run(_ executable: String, _ arguments: [String]) throws -> String
}

final class InspectorMCPAppLauncher {
    private let bridgeClient: InspectorMCPHTTPBridgeClient
    private let processRunner: InspectorMCPProcessRunning

    init(
        bridgeClient: InspectorMCPHTTPBridgeClient,
        processRunner: InspectorMCPProcessRunning = InspectorMCPProcessRunner()
    ) {
        self.bridgeClient = bridgeClient
        self.processRunner = processRunner
    }

    func prepare(options: InspectorMCPLaunchOptions) async throws -> InspectorMCPLaunchPreparation {
        let simulatorUDID = try singleBootedSimulatorUDID()

        if let reachableHealth = try await pollForHealth(timeout: 0.5) {
            return try await finalizePreparation(
                simulatorUDID: simulatorUDID,
                initialHealth: reachableHealth,
                launchMode: .attached,
                expectedBundleID: options.bundleID
            )
        }

        let appPath = try buildAndLocateApp(options: options, simulatorUDID: simulatorUDID)
        _ = try processRunner.run("/usr/bin/xcrun", ["simctl", "install", simulatorUDID, appPath])
        _ = try processRunner.run("/usr/bin/xcrun", ["simctl", "launch", simulatorUDID, options.bundleID])

        let health = try await waitForInitialHealth()
        return try await finalizePreparation(
            simulatorUDID: simulatorUDID,
            initialHealth: health,
            launchMode: .launched,
            expectedBundleID: options.bundleID
        )
    }

    func finalizePreparation(
        simulatorUDID: String,
        initialHealth: InspectorMCPHealthResponse,
        launchMode: InspectorMCPLaunchMode,
        expectedBundleID: String
    ) async throws -> InspectorMCPLaunchPreparation {
        try validateHealth(initialHealth, expectedBundleID: expectedBundleID)

        switch initialHealth.status {
        case .disabled:
            throw InspectorMCPServerError.disabled("Inspector MCP bridge is disabled")
        case .active:
            return .init(simulatorUDID: simulatorUDID, launchMode: launchMode)
        case .notStarted:
            _ = try await waitForActiveHealth()
            return .init(simulatorUDID: simulatorUDID, launchMode: launchMode)
        }
    }

    private func validateHealth(
        _ health: InspectorMCPHealthResponse,
        expectedBundleID: String
    ) throws {
        guard health.bundleIdentifier == expectedBundleID else {
            let observedBundleID = health.bundleIdentifier ?? "<unknown>"
            throw InspectorMCPServerError.transportFailure(
                "Inspector bridge endpoint is occupied by \(observedBundleID), expected \(expectedBundleID)"
            )
        }
    }

    private func singleBootedSimulatorUDID() throws -> String {
        let output = try processRunner.run(
            "/usr/bin/xcrun",
            ["simctl", "list", "devices", "booted"]
        )

        let identifiers = output
            .split(separator: "\n")
            .compactMap { line -> String? in
                guard line.contains("(Booted)") else {
                    return nil
                }

                let components = line.split(separator: "(")
                guard components.count >= 2 else {
                    return nil
                }

                return components[1].replacingOccurrences(of: ")", with: "").trimmingCharacters(in: .whitespaces)
            }

        switch identifiers.count {
        case 0:
            throw InspectorMCPServerError.zeroBootedSimulators
        case 1:
            return identifiers[0]
        default:
            throw InspectorMCPServerError.multipleBootedSimulators(identifiers)
        }
    }

    private func buildAndLocateApp(
        options: InspectorMCPLaunchOptions,
        simulatorUDID: String
    ) throws -> String {
        let destination = "platform=iOS Simulator,id=\(simulatorUDID)"

        _ = try processRunner.run(
            "/usr/bin/xcodebuild",
            [
                "-project", options.xcodeProjectPath,
                "-scheme", options.scheme,
                "-destination", destination,
                "build"
            ]
        )

        let buildSettings = try processRunner.run(
            "/usr/bin/xcodebuild",
            [
                "-project", options.xcodeProjectPath,
                "-scheme", options.scheme,
                "-destination", destination,
                "-showBuildSettings"
            ]
        )

        guard
            let targetBuildDir = buildSetting(named: "TARGET_BUILD_DIR", in: buildSettings),
            let fullProductName = buildSetting(named: "FULL_PRODUCT_NAME", in: buildSettings)
        else {
            throw InspectorMCPServerError.malformedResponse("Unable to locate built app from xcodebuild settings")
        }

        return URL(fileURLWithPath: targetBuildDir).appendingPathComponent(fullProductName).path
    }

    private func buildSetting(named name: String, in output: String) -> String? {
        output
            .split(separator: "\n")
            .first { line in
                line.trimmingCharacters(in: .whitespaces).hasPrefix("\(name) = ")
            }
            .flatMap { line in
                line.split(separator: "=", maxSplits: 1).last.map {
                    $0.trimmingCharacters(in: .whitespaces)
                }
            }
    }

    private func waitForInitialHealth() async throws -> InspectorMCPHealthResponse {
        guard let health = try await pollForHealth(timeout: 15) else {
            throw InspectorMCPServerError.readinessTimeout("Inspector bridge did not expose /health within 15 seconds")
        }

        return health
    }

    private func waitForActiveHealth() async throws -> InspectorMCPHealthResponse {
        let deadline = Date().addingTimeInterval(15)

        while Date() < deadline {
            if let health = try await pollForHealth(timeout: 0.25) {
                switch health.status {
                case .active:
                    return health
                case .disabled:
                    throw InspectorMCPServerError.disabled("Inspector MCP bridge is disabled")
                case .notStarted:
                    break
                }
            }

            try await Task.sleep(nanoseconds: 250_000_000)
        }

        throw InspectorMCPServerError.readinessTimeout("Inspector bridge remained notStarted for 15 seconds")
    }

    private func pollForHealth(timeout: TimeInterval) async throws -> InspectorMCPHealthResponse? {
        let deadline = Date().addingTimeInterval(timeout)

        repeat {
            do {
                return try await bridgeClient.health()
            } catch {
                if Date() >= deadline {
                    return nil
                }
            }

            try await Task.sleep(nanoseconds: 250_000_000)
        } while Date() < deadline

        return nil
    }
}

private final class InspectorMCPProcessRunner: InspectorMCPProcessRunning {
    func run(_ executable: String, _ arguments: [String]) throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments

        let standardOutput = Pipe()
        let standardError = Pipe()
        process.standardOutput = standardOutput
        process.standardError = standardError

        try process.run()
        process.waitUntilExit()

        let outputData = standardOutput.fileHandleForReading.readDataToEndOfFile()
        let errorData = standardError.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: outputData, encoding: .utf8) ?? ""
        let errorOutput = String(data: errorData, encoding: .utf8) ?? ""

        guard process.terminationStatus == 0 else {
            throw InspectorMCPServerError.commandFailed((output + errorOutput).trimmingCharacters(in: .whitespacesAndNewlines))
        }

        return output
    }
}
