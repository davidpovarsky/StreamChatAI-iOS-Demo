// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AgentChatSDK",
    defaultLocalization: "en",
    platforms: [
        .iOS("27.0")
    ],
    products: [
        .library(
            name: "AgentChatSDK",
            targets: [
                "AgentChatSDK",
                "AgentChatCore",
                "AgentChatMotion",
                "AgentChatMarkdown",
                "AgentChatSources",
                "AgentChatRichMedia",
                "AgentChatActivity",
                "AgentChatToolPresentation",
                "AgentChatResultCards",
                "AgentChatComposer",
                "AgentChatCanvas",
                "AgentChatVoice",
                "AgentChatUI"
            ]
        ),
        .library(name: "AgentChatCore", targets: ["AgentChatCore"]),
        .library(name: "AgentChatMotion", targets: ["AgentChatMotion"]),
        .library(name: "AgentChatMarkdown", targets: ["AgentChatMarkdown"]),
        .library(name: "AgentChatSources", targets: ["AgentChatSources"]),
        .library(name: "AgentChatRichMedia", targets: ["AgentChatRichMedia"]),
        .library(name: "AgentChatActivity", targets: ["AgentChatActivity"]),
        .library(name: "AgentChatToolPresentation", targets: ["AgentChatToolPresentation"]),
        .library(name: "AgentChatResultCards", targets: ["AgentChatResultCards"]),
        .library(name: "AgentChatComposer", targets: ["AgentChatComposer"]),
        .library(name: "AgentChatCanvas", targets: ["AgentChatCanvas"]),
        .library(name: "AgentChatVoice", targets: ["AgentChatVoice"]),
        .library(name: "AgentChatUI", targets: ["AgentChatUI"]),
        .library(name: "AgentChatVoiceLiveKit", targets: ["AgentChatVoiceLiveKit"]),
        .library(name: "AgentChatWebContent", targets: ["AgentChatWebContent"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-async-algorithms.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.1.0"),
        .package(url: "https://github.com/tinfoilsh/textual.git", branch: "main"),
        .package(url: "https://github.com/mgriebling/SwiftMath.git", from: "1.6.0"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.10.0"),
        .package(url: "https://github.com/exyte/SVGView.git", from: "1.0.6"),
        .package(url: "https://github.com/airbnb/lottie-spm.git", from: "4.5.0"),
        .package(url: "https://github.com/livekit/client-sdk-swift.git", from: "2.0.0"),
        .package(url: "https://github.com/kostub/iosMath.git", from: "2.3.0"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.17.0")
    ],
    targets: [
        .target(
            name: "AgentChatCore",
            dependencies: [
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
                .product(name: "Collections", package: "swift-collections")
            ]
        ),
        .target(
            name: "AgentChatMotion",
            dependencies: [
                "AgentChatCore"
            ]
        ),
        .target(
            name: "AgentChatSources",
            dependencies: [
                "AgentChatCore"
            ]
        ),
        .target(
            name: "AgentChatMarkdown",
            dependencies: [
                "AgentChatCore",
                .product(name: "Textual", package: "textual"),
                .product(name: "SwiftMath", package: "SwiftMath")
            ]
        ),
        .target(
            name: "AgentChatRichMedia",
            dependencies: [
                "AgentChatCore",
                .product(name: "Kingfisher", package: "Kingfisher"),
                .product(name: "SVGView", package: "SVGView"),
                .product(name: "Lottie", package: "lottie-spm")
            ]
        ),
        .target(
            name: "AgentChatActivity",
            dependencies: [
                "AgentChatCore",
                "AgentChatSources",
                "AgentChatMotion"
            ]
        ),
        .target(
            name: "AgentChatToolPresentation",
            dependencies: [
                "AgentChatCore",
                "AgentChatActivity",
                "AgentChatSources",
                "AgentChatMotion"
            ]
        ),
        .target(
            name: "AgentChatResultCards",
            dependencies: [
                "AgentChatCore",
                "AgentChatMarkdown",
                "AgentChatSources",
                "AgentChatRichMedia",
                "AgentChatMotion"
            ]
        ),
        .target(
            name: "AgentChatComposer",
            dependencies: [
                "AgentChatCore",
                "AgentChatMotion"
            ]
        ),
        .target(
            name: "AgentChatCanvas",
            dependencies: [
                "AgentChatCore",
                "AgentChatMotion"
            ]
        ),
        .target(
            name: "AgentChatVoice",
            dependencies: [
                "AgentChatCore",
                "AgentChatMotion"
            ]
        ),
        .target(
            name: "AgentChatUI",
            dependencies: [
                "AgentChatCore",
                "AgentChatMotion",
                "AgentChatMarkdown",
                "AgentChatSources",
                "AgentChatRichMedia",
                "AgentChatActivity",
                "AgentChatToolPresentation",
                "AgentChatResultCards",
                "AgentChatComposer",
                "AgentChatCanvas",
                "AgentChatVoice"
            ]
        ),
        .target(
            name: "AgentChatSDK",
            dependencies: [
                "AgentChatCore",
                "AgentChatMotion",
                "AgentChatMarkdown",
                "AgentChatSources",
                "AgentChatRichMedia",
                "AgentChatActivity",
                "AgentChatToolPresentation",
                "AgentChatResultCards",
                "AgentChatComposer",
                "AgentChatCanvas",
                "AgentChatVoice",
                "AgentChatUI"
            ]
        ),
        .target(
            name: "AgentChatVoiceLiveKit",
            dependencies: [
                "AgentChatVoice",
                .product(name: "LiveKit", package: "client-sdk-swift")
            ]
        ),
        .target(
            name: "AgentChatWebContent",
            dependencies: [
                "AgentChatCore"
            ]
        ),
        .testTarget(
            name: "AgentChatSDKTests",
            dependencies: [
                "AgentChatSDK",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ]
        ),
        .testTarget(
            name: "AgentChatMathComparisonTests",
            dependencies: [
                "AgentChatCore",
                "AgentChatMarkdown",
                .product(name: "iosMath", package: "iosMath"),
                .product(name: "SwiftMath", package: "SwiftMath"),
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ]
        )
    ]
)
