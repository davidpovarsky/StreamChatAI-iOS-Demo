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
    dependencies: [
        .package(url: "https://github.com/tinfoilsh/textual", branch: "main"),
        .package(url: "https://github.com/mgriebling/SwiftMath", from: "1.7.3")
    ],
    targets: [
        .target(
            name: "AgentUI",
            dependencies: [
                .product(name: "Textual", package: "textual"),
                .product(name: "SwiftMath", package: "SwiftMath")
            ]
        ),
        .testTarget(
            name: "AgentUITests",
            dependencies: ["AgentUI"]
        )
    ]
)
