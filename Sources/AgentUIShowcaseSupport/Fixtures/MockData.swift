// Sources/AgentUIShowcaseSupport/Fixtures/MockData.swift
import Foundation
import AgentUI

public enum MockData {
    public static let sampleSources: [AgentSource] = [
        AgentSource(title: "Swift.org Documentation", url: "https://swift.org/documentation"),
        AgentSource(title: "Apple Developer Documentation", url: "https://developer.apple.com"),
        AgentSource(title: "GitHub Repository", url: "https://github.com/davidpovarsky/StreamChatAI-iOS-Demo"),
        AgentSource(title: "Swift Evolution Proposals", url: "https://github.com/swiftlang/swift-evolution")
    ]

    public static let twelveSampleSources: [AgentSource] = [
        AgentSource(title: "Swift.org Documentation", url: "https://swift.org/documentation"),
        AgentSource(title: "Apple Developer Documentation", url: "https://developer.apple.com"),
        AgentSource(title: "GitHub Repository", url: "https://github.com/davidpovarsky/StreamChatAI-iOS-Demo"),
        AgentSource(title: "Swift Evolution Proposals", url: "https://github.com/swiftlang/swift-evolution"),
        AgentSource(title: "WWDC Sessions", url: "https://developer.apple.com/videos"),
        AgentSource(title: "Swift Forums", url: "https://forums.swift.org"),
        AgentSource(title: "LLVM Project", url: "https://llvm.org"),
        AgentSource(title: "Wikipedia: Swift", url: "https://en.wikipedia.org/wiki/Swift_(programming_language)"),
        AgentSource(title: "Hacking with Swift", url: "https://www.hackingwithswift.com"),
        AgentSource(title: "Swift by Sundell", url: "https://swiftbysundell.com"),
        AgentSource(title: "Point-Free", url: "https://www.pointfree.co"),
        AgentSource(title: "NSHipster", url: "https://nshipster.com")
    ]

    public static let hebrewSampleText = """
    שלום! להלן סקירה של ארכיטקטורת ה-SDK החדשה עבור AgentUI:

    1. **מודולריות מלאה**: החבילה אינה תלויה במנועי AI ספציפיים ופועלת באמצעות Event Stream ניטרלי.
    2. **שפת עיצוב אחידה**: שפת ה-Liquid Glass החדשה מיושמת עם Fallback מסודר ל-iOS 18+.
    3. **משטח רציף יחיד**: תיבת ה-Tool Execution מכילה את פרטי הקריאה הטכניים ללא כרטיסיות נפרדות או רווחים.
    """

    public static let codeSampleText = """
    Here is an example of creating an AgentUI chat session:

    ```swift
    import AgentUI

    @State private var session = AgentUISession(
        runtime: MyCustomRuntime(),
        models: [
            AgentModelDescriptor(id: "gpt-4o", displayName: "GPT-4o"),
            AgentModelDescriptor(id: "claude-3-5", displayName: "Claude 3.5 Sonnet")
        ]
    )

    var body: some View {
        AgentChatView(session: session)
    }
    ```
    """

    public static let mathSampleText = """
    The quadratic formula solves equations of the form $ax^2 + bx + c = 0$:

    $$x = \\frac{-b \\pm \\sqrt{b^2 - 4ac}}{2a}$$
    """

    public static let longMarkdownText = """
    # AgentUI Architecture Overview

    AgentUI is a modular Swift Package providing reusable chat UI for AI agents.

    ## Key Capabilities

    1. **Streaming First**: Deterministic identity preservation across delta tokens.
    2. **Cross-Platform Verification**: Compiles cleanly with standard Swift tools.
    3. **Native Navigation Transitions**: Interactive zoom image viewer.

    ### Design Principles

    > Great agent interfaces present technical complexity with clarity and calmness.

    ---

    | Feature | Status | Target |
    | :--- | :--- | :--- |
    | Tool Disclosure | Single Surface | iOS 18+ |
    | LaTeX Math | Typeset | All |
    | Mini Apps | Sheet / FullScreen | iPadOS / iOS |

    * Built with Swift 6 and strict concurrency safety.
    * Centralized design tokens and theme adaptation.
    """
}
