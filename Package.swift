// swift-tools-version: 6.1

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "Inspector",
    platforms: [
        .iOS(.v15)
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
        // MARK: - Existing

        .target(
            name: "Inspector",
            dependencies: [
                "UIKeyCommandTableView",
                "UIKeyboardAnimatable",
                "Coordinator"
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "InspectorTests",
            dependencies: ["Inspector"]
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
                .target(
                    name: "InspectorMacros",
                    condition: .when(traits: ["Debugging"])
                ),
                .target(
                    name: "Inspector",
                    condition: .when(traits: ["Debugging"])
                )
            ],
            swiftSettings: [
                .define("INSPECTOR_ENABLED", .when(traits: ["Debugging"]))
            ]
        ),

        // MARK: - New: Macro tests

        .testTarget(
            name: "InspectorMacrosTests",
            dependencies: [
                "InspectorMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax")
            ]
        )
    ]
)
