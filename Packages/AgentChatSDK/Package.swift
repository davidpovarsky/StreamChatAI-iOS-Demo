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
                "AgentChatSwiftChat",
                "AgentChatActivity",
                "AgentChatToolPresentation",
                "AgentChatSources",
                "AgentChatRichMedia",
                "AgentChatComposerExtensions",
                "AgentChatVoice"
            ]
        ),
        .library(name: "AgentChatCore", targets: ["AgentChatCore"]),
        .library(name: "AgentChatSwiftChat", targets: ["AgentChatSwiftChat"]),
        .library(name: "AgentChatActivity", targets: ["AgentChatActivity"]),
        .library(name: "AgentChatToolPresentation", targets: ["AgentChatToolPresentation"]),
        .library(name: "AgentChatSources", targets: ["AgentChatSources"]),
        .library(name: "AgentChatRichMedia", targets: ["AgentChatRichMedia"]),
        .library(name: "AgentChatComposerExtensions", targets: ["AgentChatComposerExtensions"]),
        .library(name: "AgentChatVoice", targets: ["AgentChatVoice"]),
        .library(name: "AgentChatVoiceLiveKit", targets: ["AgentChatVoiceLiveKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-async-algorithms.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.1.0"),
        .package(url: "https://github.com/tinfoilsh/textual.git", branch: "main"),
        .package(url: "https://github.com/mgriebling/SwiftMath.git", from: "1.6.0"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.10.0"),
        .package(url: "https://github.com/exyte/SVGView.git", from: "1.0.6"),
        .package(url: "https://github.com/airbnb/lottie-spm.git", from: "4.5.0"),
        .package(url: "https://github.com/EmergeTools/Pow.git", from: "0.3.1"),
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
            name: "AgentChatToolPresentation",
            dependencies: [
                "AgentChatCore",
                "AgentChatActivity",
                .product(name: "Pow", package: "Pow")
            ]
        ),
        .target(
            name: "AgentChatSources",
            dependencies: [
                "AgentChatCore"
            ]
        ),
        .target(
            name: "AgentChatRichMedia",
            dependencies: [
                "AgentChatCore",
                .product(name: "Kingfisher", package: "Kingfisher"),
                .product(name: "SVGView", package: "SVGView"),
                .product(name: "Lottie", package: "lottie-spm"),
                .product(name: "Pow", package: "Pow")
            ]
        ),
        .target(
            name: "AgentChatComposerExtensions",
            dependencies: [
                "AgentChatCore",
                .product(name: "EmojiKit", package: "EmojiKit")
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
            name: "AgentChatSwiftChat",
            dependencies: [
                "AgentChatCore",
                "AgentChatActivity",
                "AgentChatToolPresentation",
                "AgentChatSources",
                "AgentChatRichMedia",
                "AgentChatComposerExtensions",
                "AgentChatVoice",
                .product(name: "Textual", package: "textual"),
                .product(name: "SwiftMath", package: "SwiftMath")
            ]
        ),
        .target(
            name: "AgentChatSDK",
            dependencies: [
                "AgentChatCore",
                "AgentChatSwiftChat",
                "AgentChatActivity",
                "AgentChatToolPresentation",
                "AgentChatSources",
                "AgentChatRichMedia",
                "AgentChatComposerExtensions",
                "AgentChatVoice"
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
