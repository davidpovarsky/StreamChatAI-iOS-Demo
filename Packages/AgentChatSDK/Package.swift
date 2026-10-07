// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AgentChatSDK",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "AgentChatSDK",
            targets: [
                "AgentChatSDK",
                "AgentChatCore",
                "AgentChatUI",
                "AgentChatRendering",
                "AgentChatActivity",
                "AgentChatRichResults",
                "AgentChatMedia",
                "AgentChatVoice",
                "AgentChatIntegrations"
            ]
        ),
        .library(name: "AgentChatCore", targets: ["AgentChatCore"]),
        .library(name: "AgentChatUI", targets: ["AgentChatUI"]),
        .library(name: "AgentChatRendering", targets: ["AgentChatRendering"]),
        .library(name: "AgentChatActivity", targets: ["AgentChatActivity"]),
        .library(name: "AgentChatRichResults", targets: ["AgentChatRichResults"]),
        .library(name: "AgentChatMedia", targets: ["AgentChatMedia"]),
        .library(name: "AgentChatVoice", targets: ["AgentChatVoice"]),
        .library(name: "AgentChatVoiceLiveKit", targets: ["AgentChatVoiceLiveKit"]),
        .library(name: "AgentChatIntegrations", targets: ["AgentChatIntegrations"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-async-algorithms.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.1.0"),
        .package(url: "https://github.com/swiftlang/swift-markdown.git", from: "0.4.0"),
        .package(url: "https://github.com/raspu/Highlightr.git", from: "2.1.2"),
        .package(url: "https://github.com/kostub/iosMath.git", from: "2.3.0"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.10.0"),
        .package(url: "https://github.com/exyte/SVGView.git", from: "1.0.6"),
        .package(url: "https://github.com/airbnb/lottie-spm.git", from: "4.5.0"),
        .package(url: "https://github.com/EmergeTools/Pow.git", from: "0.3.1"),
        .package(url: "https://github.com/krzyzanowskim/STTextKitPlus.git", from: "0.3.1"),
        .package(url: "https://github.com/danielsaidi/EmojiKit.git", exact: "1.0.0"),
        .package(url: "https://github.com/livekit/client-sdk-swift.git", from: "2.0.0"),
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
            name: "AgentChatActivity",
            dependencies: [
                "AgentChatCore"
            ]
        ),
        .target(
            name: "AgentChatRichResults",
            dependencies: [
                "AgentChatCore",
                "AgentChatActivity",
                .product(name: "Lottie", package: "lottie-spm"),
                .product(name: "Pow", package: "Pow")
            ]
        ),
        .target(
            name: "AgentChatMedia",
            dependencies: [
                "AgentChatCore",
                .product(name: "Kingfisher", package: "Kingfisher")
            ]
        ),
        .target(
            name: "AgentChatRendering",
            dependencies: [
                "AgentChatCore",
                .product(name: "Markdown", package: "swift-markdown"),
                .product(name: "Highlightr", package: "Highlightr"),
                .product(name: "iosMath", package: "iosMath"),
                .product(name: "SVGView", package: "SVGView"),
                .product(name: "STTextKitPlus", package: "STTextKitPlus")
            ]
        ),
        .target(
            name: "AgentChatVoice",
            dependencies: [
                "AgentChatCore"
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
            name: "AgentChatUI",
            dependencies: [
                "AgentChatCore",
                "AgentChatActivity",
                "AgentChatRichResults",
                "AgentChatRendering",
                "AgentChatMedia",
                "AgentChatVoice",
                .product(name: "EmojiKit", package: "EmojiKit"),
                .product(name: "Pow", package: "Pow"),
                .product(name: "Lottie", package: "lottie-spm")
            ]
        ),
        .target(
            name: "AgentChatIntegrations",
            dependencies: [
                "AgentChatCore",
                "AgentChatUI",
                "AgentChatActivity",
                "AgentChatRichResults",
                "AgentChatRendering"
            ]
        ),
        .target(
            name: "AgentChatSDK",
            dependencies: [
                "AgentChatCore",
                "AgentChatUI",
                "AgentChatActivity",
                "AgentChatRichResults",
                "AgentChatRendering",
                "AgentChatMedia",
                "AgentChatVoice",
                "AgentChatIntegrations"
            ]
        ),
        .testTarget(
            name: "AgentChatSDKTests",
            dependencies: [
                "AgentChatSDK",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ]
        )
    ]
)
