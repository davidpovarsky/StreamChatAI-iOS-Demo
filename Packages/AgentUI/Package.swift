// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AgentUI",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "AgentUI",
            targets: ["AgentUI"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "AgentUI",
            dependencies: []
        ),
        .testTarget(
            name: "AgentUITests",
            dependencies: ["AgentUI"]
        )
    ]
)
