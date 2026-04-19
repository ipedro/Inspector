// swift-tools-version: 6.1

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "Inspector",
    platforms: [
        .iOS(.v15),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "Inspector",
            targets: ["Inspector"]
        ),
        .library(
            name: "InspectorDynamic",
            type: .dynamic,
            targets: ["Inspector"]
        ),
        .library(
            name: "InspectorInterface",
            targets: ["InspectorInterface"]
        ),
        .library(
            name: "InspectorContract",
            targets: ["InspectorContract"]
        ),
        .executable(
            name: "InspectorMCPServer",
            targets: ["InspectorMCPServer"]
        )
    ],
    traits: [
        .trait(
            name: "Debugging",
            description: "Enables the full Inspector debug runtime, macro expansion, and InspectorInterface."
        )
    ],
    dependencies: [
        .package(url: "https://github.com/ipedro/UIKeyCommandTableView.git", from: "1.0.0"),
        .package(url: "https://github.com/ipedro/UIKeyboardAnimatable.git", from: "1.0.0"),
        .package(url: "https://github.com/ipedro/Coordinator.git", from: "2.1.2"),
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "600.0.0")
    ],
    targets: [
        // MARK: - Existing iOS library

        .target(
            name: "InspectorMCPWire",
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),

        .target(
            name: "InspectorContract",
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
        .target(
            name: "Inspector",
            dependencies: [
                "InspectorContract",
                "InspectorInterface",
                "InspectorMCPWire",
                .product(name: "UIKeyCommandTableView", package: "UIKeyCommandTableView", condition: .when(platforms: [.iOS])),
                .product(name: "UIKeyboardAnimatable", package: "UIKeyboardAnimatable", condition: .when(platforms: [.iOS])),
                .product(name: "Coordinator", package: "Coordinator", condition: .when(platforms: [.iOS]))
            ],
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .define("INSPECTOR_DEBUGGING", .when(traits: ["Debugging"])),
                .swiftLanguageMode(.v5)
            ]
        ),
        .executableTarget(
            name: "InspectorMCPServer",
            dependencies: [
                "InspectorMCPWire"
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
        .testTarget(
            name: "InspectorMCPWireTests",
            dependencies: [
                "InspectorMCPWire"
            ]
        ),
        .testTarget(
            name: "InspectorMCPServerTests",
            dependencies: [
                "InspectorMCPServer",
                "InspectorMCPWire"
            ]
        ),
        .testTarget(
            name: "InspectorTests",
            dependencies: [
                .target(name: "Inspector", condition: .when(platforms: [.iOS]))
            ],
            swiftSettings: [
                .define("INSPECTOR_DEBUGGING", .when(traits: ["Debugging"]))
            ]
        ),

        // MARK: - New: Macro executable

        .macro(
            name: "InspectorMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax")
            ]
        ),

        // MARK: - New: Thin always-importable interface

        .target(
            name: "InspectorInterface",
            dependencies: [
                "InspectorContract",
                .target(name: "InspectorMacros")
            ],
            swiftSettings: [
                .define("INSPECTOR_DEBUGGING", .when(traits: ["Debugging"]))
            ]
        ),

        // MARK: - New: Macro tests (macOS-compatible, no UIKit dependency)

        .testTarget(
            name: "InspectorMacrosTests",
            dependencies: [
                "InspectorMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax")
            ]
        )
    ]
)
