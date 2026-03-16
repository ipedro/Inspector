// swift-tools-version:5.10

import PackageDescription

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
        )
    ],
    dependencies: [
        .package(url: "https://github.com/ipedro/UIKeyCommandTableView.git", from: "1.0.0"),
        .package(url: "https://github.com/ipedro/UIKeyboardAnimatable.git", from: "1.0.0"),
        .package(url: "https://github.com/ipedro/Coordinator.git", from: "2.1.2")
    ],
    targets: [
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
        )
    ]
)
