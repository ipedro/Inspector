// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

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
        )
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/ipedro/UIKeyCommandTableView.git", from: "0.2.1"),
        .package(url: "https://github.com/ipedro/UIKeyboardAnimatable.git", from: "0.3.0"),
        .package(url: "https://github.com/ipedro/UIKitOptions.git", from: "0.3.2"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Inspector",
            dependencies: [
                "UIKeyCommandTableView",
                "UIKeyboardAnimatable",
                "UIKitOptions"
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "InspectorTests",
            dependencies: ["Inspector"]
        ),
    ]
)
