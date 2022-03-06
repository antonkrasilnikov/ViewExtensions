// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ViewExtensions",
    platforms: [
            .iOS(.v10)
        ],
    products: [
        .library(
            name: "ViewExtensions",
            targets: ["PureLayout", "ViewExtensions"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "PureLayout",
            dependencies: []),
        .target(
            name: "ViewExtensions",
            dependencies: ["PureLayout"]),
    ]
)
