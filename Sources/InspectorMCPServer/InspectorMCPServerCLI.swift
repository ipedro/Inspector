import Foundation

@main
struct InspectorMCPServerCLI {
    static func main() async {
        do {
            let command = try InspectorMCPLaunchCommand(arguments: Array(CommandLine.arguments.dropFirst()))
            let bridgeClient = InspectorMCPHTTPBridgeClient()
            let launcher = InspectorMCPAppLauncher(bridgeClient: bridgeClient)

            switch command {
            case let .launch(options):
                _ = try await launcher.prepare(options: options)
                try await runStdioServer(bridgeClient: bridgeClient)
            }
        } catch {
            fputs("\(error.localizedDescription)\n", stderr)
            exit(EXIT_FAILURE)
        }
    }

    private static func runStdioServer(bridgeClient: InspectorMCPBridgeClient) async throws {
        let session = InspectorMCPServerSession(bridgeClient: bridgeClient)

        while let line = readLine(strippingNewline: true) {
            guard !line.isEmpty else {
                continue
            }

            if let response = try await session.handleMessage(Data(line.utf8)) {
                FileHandle.standardOutput.write(response)
                FileHandle.standardOutput.write(Data("\n".utf8))
            }
        }
    }
}

private enum InspectorMCPLaunchCommand {
    case launch(InspectorMCPLaunchOptions)

    init(arguments: [String]) throws {
        guard let subcommand = arguments.first else {
            throw InspectorMCPServerError.invalidArguments("Expected subcommand: launch")
        }

        switch subcommand {
        case "launch":
            self = .launch(try InspectorMCPLaunchOptions(arguments: Array(arguments.dropFirst())))
        default:
            throw InspectorMCPServerError.invalidArguments("Unsupported subcommand: \(subcommand)")
        }
    }
}
