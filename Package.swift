// swift-tools-version:5.4

import PackageDescription

let package = Package(
    name: "Inspector",
    platforms: [
        .iOS(.v11)
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
        )
    ],
    dependencies: [
        .package(url: "https://github.com/ipedro/UIKeyCommandTableView.git", from: "0.2.1"),
        .package(url: "https://github.com/ipedro/UIKeyboardAnimatable.git", from: "0.3.0"),
        .package(url: "https://github.com/ipedro/UIKitOptions.git", from: "0.3.2"),
        .package(url: "https://github.com/ipedro/Coordinator.git", .exact("1.0.2"))
    ],
    targets: [
        .target(
            name: "Inspector",
            dependencies: [
                "UIKeyCommandTableView",
                "UIKeyboardAnimatable",
                "UIKitOptions",
                "Coordinator"
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "InspectorTests",
            dependencies: ["Inspector"]
        )
    ]
)
