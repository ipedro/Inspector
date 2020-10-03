// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HierarchyInspector",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(name: "HierarchyInspector", targets: ["HierarchyInspector"]),
        .executable(name: "HierarchyInspectorExample", targets: ["HierarchyInspectorExample"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "HierarchyInspector",
            dependencies: []),
        .target(
            name: "HierarchyInspectorExample",
            dependencies: ["HierarchyInspector"]),
        .testTarget(
            name: "HierarchyInspectorTests",
            dependencies: ["HierarchyInspector"]),
    ]
)
