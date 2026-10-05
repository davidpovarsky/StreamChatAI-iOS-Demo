// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "AgentUI",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
        .visionOS(.v2)
    ],
    products: [
        .library(
            name: "AgentUI",
            targets: ["AgentUI"]
        ),
        .library(
            name: "AgentUIShowcaseSupport",
            targets: ["AgentUIShowcaseSupport"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "AgentUI",
            dependencies: [],
            path: "Sources/AgentUI",
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .target(
            name: "AgentUIShowcaseSupport",
            dependencies: ["AgentUI"],
            path: "Sources/AgentUIShowcaseSupport",
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .testTarget(
            name: "AgentUITests",
            dependencies: [
                "AgentUI",
                "AgentUIShowcaseSupport"
            ],
            path: "Tests/AgentUITests",
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        )
    ]
)
