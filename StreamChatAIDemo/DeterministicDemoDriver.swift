import SwiftUI
import AgentChatSDK

@MainActor
public final class DeterministicDemoDriver: ObservableObject {
    public let session: AgentChatSession
    @Published public var isRunning: Bool = false
    @Published public var isPaused: Bool = false
    @Published public var currentScenarioId: String? = nil
    @Published public var playbackSpeed: Double = 1.0

    private var executionTask: Task<Void, Never>?
    private var pendingEvents: [DemoScenarioEvent] = []
    private var eventIndex: Int = 0

    public init(session: AgentChatSession) {
        self.session = session
    }

    // MARK: - Playback Controls

    public func pause() {
        isPaused = true
    }

    public func resume() {
        isPaused = false
    }

    public func step() {
        guard eventIndex < pendingEvents.count else { return }
        let next = pendingEvents[eventIndex]
        eventIndex += 1
        session.apply(event: next.event)
        if eventIndex >= pendingEvents.count {
            isRunning = false
        }
    }

    public func reset() {
        executionTask?.cancel()
        executionTask = nil
        isRunning = false
        isPaused = false
        pendingEvents = []
        eventIndex = 0
        session.clearMessages()
    }

    // MARK: - Run Scenario

    public func runScenario(id: String) {
        reset()
        currentScenarioId = id
        guard let scenario = allScenarios.first(where: { $0.id == id }) else { return }

        // Post user message turn
        session.sendMessage(scenario.userPrompt)
        pendingEvents = scenario.events
        eventIndex = 0
        isRunning = true

        executionTask = Task { @MainActor in
            for eventItem in scenario.events {
                guard !Task.isCancelled else { break }

                while self.isPaused && !Task.isCancelled {
                    try? await Task.sleep(nanoseconds: 100_000_000)
                }

                let delay = max(10_000_000, UInt64(Double(eventItem.atMs) * 1_000_000 / self.playbackSpeed))
                try? await Task.sleep(nanoseconds: delay)

                guard !Task.isCancelled else { break }
                self.session.apply(event: eventItem.event)
                self.eventIndex += 1
            }
            self.isRunning = false
        }
    }

    // MARK: - All 26 Scenarios

    public var allScenarios: [DemoScenario] {
        [
            // 01: Plain Chat
            DemoScenario(
                id: "01_plain_chat",
                title: "01. Plain Streamed Chat",
                summary: "Stream arbitrary text with token deltas and stop/retry controls",
                userPrompt: "Tell me about the design philosophy of Apple platforms.",
                events: [
                    .init(atMs: 200, event: .contentDelta(messageId: "auto", text: "Apple design balances clarity, deference, and depth.")),
                    .init(atMs: 400, event: .contentDelta(messageId: "auto", text: " In iOS 27, native SwiftUI delivers fluid spring motion and seamless layout adaptability.")),
                    .init(atMs: 600, event: .finished)
                ]
            ),

            // 02: Web Research
            DemoScenario(
                id: "02_web_research",
                title: "02. Web Research (8 Sources)",
                summary: "Hierarchical activity with 8 search source chips, collapsed by default",
                userPrompt: "Research native UI libraries for Apple platforms in 2026.",
                events: [
                    .init(atMs: 100, event: .groupStarted(runId: "run-02", groupId: "research", stage: .research, title: "Web Research")),
                    .init(atMs: 200, event: .toolRequested(runId: "run-02", groupId: "research", operationId: "s-1", tool: "web_search", title: "Searched 8 websites", arguments: "{\"query\": \"swiftui ui libraries\"}")),
                    .init(atMs: 600, event: .toolCompleted(runId: "run-02", operationId: "s-1", resultSummary: "8 sites indexed", payload: nil, sources: [
                        WebSearchSource(title: "Apple Developer Documentation", url: "https://developer.apple.com"),
                        WebSearchSource(title: "Swift.org Open Source", url: "https://swift.org"),
                        WebSearchSource(title: "GitHub Swift Packages", url: "https://github.com"),
                        WebSearchSource(title: "Textual Markdown", url: "https://textual.org"),
                        WebSearchSource(title: "SwiftMath LaTeX", url: "https://swiftmath.org"),
                        WebSearchSource(title: "Kingfisher Image Caching", url: "https://onevcat.com"),
                        WebSearchSource(title: "Exyte SVGView", url: "https://exyte.com"),
                        WebSearchSource(title: "Swift Charts Reference", url: "https://developer.apple.com/charts")
                    ])),
                    .init(atMs: 800, event: .runFinished(runId: "run-02", status: .completed)),
                    .init(atMs: 900, event: .contentDelta(messageId: "auto", text: "## Native Research Findings\n\nApple platforms heavily reward 100% native SwiftUI components over embedded web views. Sources show that using native renderers reduces memory pressure and eliminates gesture latency.")),
                    .init(atMs: 1200, event: .finished)
                ]
            ),

            // 03: Multistage Reasoning
            DemoScenario(
                id: "03_multistage_reasoning",
                title: "03. Multistage Reasoning",
                summary: "Planning, research, and verification phases collapsed under one run header",
                userPrompt: "Plan a migration of a legacy chat SDK to native iOS 27 SwiftUI.",
                events: [
                    .init(atMs: 100, event: .groupStarted(runId: "run-03", groupId: "g1", stage: .planning, title: "Architecture Analysis")),
                    .init(atMs: 200, event: .toolRequested(runId: "run-03", groupId: "g1", operationId: "op-1", tool: "dep_audit", title: "Auditing Package Manifest", arguments: "{}")),
                    .init(atMs: 400, event: .toolCompleted(runId: "run-03", operationId: "op-1", resultSummary: "Identified legacy dependencies", payload: nil, sources: [])),
                    .init(atMs: 500, event: .groupStarted(runId: "run-03", groupId: "g2", stage: .coding, title: "Target Refactoring")),
                    .init(atMs: 600, event: .toolRequested(runId: "run-03", groupId: "g2", operationId: "op-2", tool: "swift_builder", title: "Extracting AgentChatMarkdown", arguments: "{}")),
                    .init(atMs: 800, event: .toolCompleted(runId: "run-03", operationId: "op-2", resultSummary: "Clean compilation", payload: nil, sources: [])),
                    .init(atMs: 900, event: .groupStarted(runId: "run-03", groupId: "g3", stage: .verification, title: "Golden Snapshots & CI")),
                    .init(atMs: 1000, event: .toolRequested(runId: "run-03", groupId: "g3", operationId: "op-3", tool: "xcode_test", title: "Running 22 Snapshot Baselines", arguments: "{}")),
                    .init(atMs: 1200, event: .toolCompleted(runId: "run-03", operationId: "op-3", resultSummary: "22/22 green", payload: nil, sources: [])),
                    .init(atMs: 1300, event: .runFinished(runId: "run-03", status: .completed)),
                    .init(atMs: 1400, event: .contentDelta(messageId: "auto", text: "The multi-stage migration is planned across 3 verification checkpoints with zero regressions.")),
                    .init(atMs: 1500, event: .finished)
                ]
            ),

            // 04: Parallel Work
            DemoScenario(
                id: "04_parallel_work",
                title: "04. Parallel Concurrent Tasks",
                summary: "Concurrent operations executing simultaneously with independent state",
                userPrompt: "Run security and performance audits in parallel.",
                events: [
                    .init(atMs: 100, event: .groupStarted(runId: "run-04", groupId: "par", stage: .verification, title: "Parallel Audit")),
                    .init(atMs: 200, event: .toolRequested(runId: "run-04", groupId: "par", operationId: "sec", tool: "security_scanner", title: "Security Scan", arguments: "{}")),
                    .init(atMs: 250, event: .toolRequested(runId: "run-04", groupId: "par", operationId: "perf", tool: "perf_analyzer", title: "Instruments Memory Trace", arguments: "{}")),
                    .init(atMs: 500, event: .toolProgress(runId: "run-04", operationId: "sec", progress: 0.5, message: "Inspecting sandboxing...")),
                    .init(atMs: 600, event: .toolCompleted(runId: "run-04", operationId: "perf", resultSummary: "0 leaks detected", payload: nil, sources: [])),
                    .init(atMs: 800, event: .toolCompleted(runId: "run-04", operationId: "sec", resultSummary: "100% compliant", payload: nil, sources: [])),
                    .init(atMs: 900, event: .runFinished(runId: "run-04", status: .completed)),
                    .init(atMs: 1000, event: .contentDelta(messageId: "auto", text: "Both parallel verification passes completed with zero defects.")),
                    .init(atMs: 1100, event: .finished)
                ]
            ),

            // 05: Tool Inspection
            DemoScenario(
                id: "05_tool_inspection",
                title: "05. Tool Call Inspection",
                summary: "Examine arguments, timings, and credentials redaction in inspector sheet",
                userPrompt: "Fetch recent GitHub commits for davidpovarsky/StreamChatAI-iOS-Demo.",
                events: [
                    .init(atMs: 100, event: .groupStarted(runId: "run-05", groupId: "gh", stage: .coding, title: "GitHub Integration")),
                    .init(atMs: 200, event: .toolRequested(runId: "run-05", groupId: "gh", operationId: "gh-op", tool: "github_api", title: "Fetching commits", arguments: "{\"repo\": \"davidpovarsky/StreamChatAI-iOS-Demo\", \"token\": \"ghp_secretTokenExample123\"}")),
                    .init(atMs: 600, event: .toolCompleted(runId: "run-05", operationId: "gh-op", resultSummary: "Retrieved HEAD 78dd20f", payload: "{\"head\": \"78dd20f\", \"branch\": \"agent/swiftchat-sdk-chatgpt-stack-realignment\"}", sources: [WebSearchSource(title: "GitHub Repository", url: "https://github.com/davidpovarsky/StreamChatAI-iOS-Demo")])),
                    .init(atMs: 700, event: .runFinished(runId: "run-05", status: .completed)),
                    .init(atMs: 800, event: .contentDelta(messageId: "auto", text: "Found latest commit `78dd20f`. Open the info button in the activity group to inspect arguments.")),
                    .init(atMs: 900, event: .finished)
                ]
            ),

            // 06: Approval Accept
            DemoScenario(
                id: "06_approval_accept",
                title: "06. Approval Card (Accept)",
                summary: "Action-required permission card visible outside collapsed activity tree",
                userPrompt: "Add Design Review to my calendar for Tuesday 10:30 AM.",
                events: [
                    .init(atMs: 100, event: .runStarted(runId: "run-06", messageId: "auto")),
                    .init(atMs: 200, event: .approvalRequested(approval: ApprovalRequest(
                        id: "app-cal-1",
                        runId: "run-06",
                        title: "Create Calendar Event",
                        descriptionText: "Event: Design Review\nTime: Tuesday, 10:30 AM – 11:30 AM\nLocation: Cupertino Meeting Room",
                        provider: "EventKit"
                    ))),
                    .init(atMs: 400, event: .contentDelta(messageId: "auto", text: "Please review and approve the calendar modification request above."))
                ]
            ),

            // 07: Approval Deny
            DemoScenario(
                id: "07_approval_deny",
                title: "07. Approval Card (Deny)",
                summary: "Deny permission request and verify no fabricated success is emitted",
                userPrompt: "Delete all completed tasks in Reminders.",
                events: [
                    .init(atMs: 100, event: .runStarted(runId: "run-07", messageId: "auto")),
                    .init(atMs: 200, event: .approvalRequested(approval: ApprovalRequest(
                        id: "app-rem-1",
                        runId: "run-07",
                        title: "Delete Reminders",
                        descriptionText: "This action will permanently delete 14 completed tasks.",
                        provider: "EventKit"
                    )))
                ]
            ),

            // 08: Failure & Retry
            DemoScenario(
                id: "08_tool_failure_retry",
                title: "08. Tool Failure & Retry",
                summary: "Network timeout failure with prominent retry button and error details",
                userPrompt: "Connect to live model endpoint.",
                events: [
                    .init(atMs: 100, event: .groupStarted(runId: "run-08", groupId: "net", stage: .custom, title: "Network Connection")),
                    .init(atMs: 200, event: .toolRequested(runId: "run-08", groupId: "net", operationId: "t-net", tool: "api_connect", title: "Connecting to remote gateway", arguments: "{}")),
                    .init(atMs: 600, event: .toolFailed(runId: "run-08", operationId: "t-net", error: "Gateway timeout: 504 Gateway Timeout")),
                    .init(atMs: 700, event: .runFinished(runId: "run-08", status: .failed)),
                    .init(atMs: 800, event: .resultProduced(result: AgentResult(
                        messageId: "auto",
                        kind: .error,
                        title: "Connection Failed",
                        payload: AgentResultPayload(contentText: "Could not reach remote server. Tap Retry to attempt a fallback connection.")
                    )))
                ]
            ),

            // 09: Tool Cancel
            DemoScenario(
                id: "09_tool_cancel",
                title: "09. Tool Cancellation",
                summary: "Cancel active operation and observe clean animation stop",
                userPrompt: "Start long database indexing.",
                events: [
                    .init(atMs: 100, event: .groupStarted(runId: "run-09", groupId: "db", stage: .coding, title: "Indexing")),
                    .init(atMs: 200, event: .toolRequested(runId: "run-09", groupId: "db", operationId: "op-idx", tool: "db_indexer", title: "Building index...", arguments: "{}")),
                    .init(atMs: 800, event: .runFinished(runId: "run-09", status: .cancelled)),
                    .init(atMs: 900, event: .contentDelta(messageId: "auto", text: "Operation was cancelled by user request."))
                ]
            ),

            // 10: Markdown Streaming
            DemoScenario(
                id: "10_markdown_streaming",
                title: "10. Markdown Streaming",
                summary: "Fragmented headings, nested bullets, code fences, and tables",
                userPrompt: "Show markdown syntax formatting.",
                events: [
                    .init(atMs: 100, event: .contentDelta(messageId: "auto", text: "### Markdown Demonstration\n\n")),
                    .init(atMs: 200, event: .contentDelta(messageId: "auto", text: "Here is a comparison table:\n\n| Feature | Status |\n|---|---|\n")),
                    .init(atMs: 400, event: .contentDelta(messageId: "auto", text: "| Native SwiftUI | Active |\n| Hierarchical Activity | Collapsed by Default |\n\n")),
                    .init(atMs: 600, event: .contentDelta(messageId: "auto", text: "```swift\nlet architecture = \"Native SwiftUI\"\n```\n")),
                    .init(atMs: 800, event: .finished)
                ]
            ),

            // 11: Math & Hebrew RTL
            DemoScenario(
                id: "11_math_rtl",
                title: "11. LaTeX Math & Hebrew RTL",
                summary: "Mixed bidirectional text with SwiftMath equations",
                userPrompt: "הסבר על משוואת שרדינגר בעברית.",
                events: [
                    .init(atMs: 200, event: .contentDelta(messageId: "auto", text: "משוואת שרדינגר התלויה בזמן מתארת את התפתחות מצב הקוונטי:\n\n$$i\\hbar\\frac{\\partial}{\\partial t}\\Psi = \\hat{H}\\Psi$$\n\nהמשוואה מציגה כיווניות תקינה של נוסחה בתוך טקסט עברי.")),
                    .init(atMs: 400, event: .finished)
                ]
            ),

            // 12: Images & Vector SVG
            DemoScenario(
                id: "12_images_svg",
                title: "12. Images & SVG Diagram",
                summary: "Native Kingfisher image caching and Exyte SVG vector diagram",
                userPrompt: "Show the system architecture diagram and icon.",
                events: [
                    .init(atMs: 200, event: .resultProduced(result: AgentResult(
                        messageId: "auto",
                        kind: .svg,
                        title: "System Architecture Vector Diagram",
                        payload: AgentResultPayload(metadata: [
                            "svgString": .string("<svg viewBox='0 0 240 80' xmlns='http://www.w3.org/2000/svg'><rect width='240' height='80' rx='12' fill='#0A84FF' opacity='0.15'/><text x='120' y='46' font-size='16' font-family='system-ui' font-weight='bold' fill='#0A84FF' text-anchor='middle'>AgentChatCore ➔ UI</text></svg>")
                        ])
                    ))),
                    .init(atMs: 400, event: .finished)
                ]
            ),

            // 13: Video & Audio
            DemoScenario(
                id: "13_video_audio",
                title: "13. Inline Video & Audio Player",
                summary: "Native AVKit video playback and audio waveform scrubber",
                userPrompt: "Play tutorial video and audio recording.",
                events: [
                    .init(atMs: 200, event: .resultProduced(result: AgentResult(
                        messageId: "auto",
                        kind: .audio,
                        title: "Voice Memo Recording",
                        payload: AgentResultPayload(subtitle: "Duration: 02:45")
                    ))),
                    .init(atMs: 400, event: .finished)
                ]
            ),

            // 14: File & Artifact
            DemoScenario(
                id: "14_file_artifact",
                title: "14. File Artifact & Share Sheet",
                summary: "Generated PDF document descriptor with native share link",
                userPrompt: "Export the architecture spec as PDF.",
                events: [
                    .init(atMs: 200, event: .resultProduced(result: AgentResult(
                        messageId: "auto",
                        kind: .file,
                        title: "AgentChatSDK_Architecture_iOS27.pdf",
                        payload: AgentResultPayload(subtitle: "Size: 2.4 MB")
                    ))),
                    .init(atMs: 400, event: .finished)
                ]
            ),

            // 15: Swift Charts
            DemoScenario(
                id: "15_chart_interactions",
                title: "15. Interactive Swift Charts",
                summary: "Bar, Line, Area toggle with data points and totals",
                userPrompt: "Analyze monthly token throughput.",
                events: [
                    .init(atMs: 200, event: .resultProduced(result: AgentResult(
                        messageId: "auto",
                        kind: .chart,
                        title: "Monthly Token Consumption",
                        payload: AgentResultPayload(
                            subtitle: "Measured in thousands of tokens",
                            metadata: ["points": .string("Jan:34,Feb:52,Mar:41,Apr:68,May:85,Jun:94")]
                        )
                    ))),
                    .init(atMs: 400, event: .finished)
                ]
            ),

            // 16: MapKit Route
            DemoScenario(
                id: "16_map_route",
                title: "16. Native MapKit Route",
                summary: "MapKit pins in Cupertino with selectable stops",
                userPrompt: "Show route between Apple Park and Infinite Loop.",
                events: [
                    .init(atMs: 200, event: .resultProduced(result: AgentResult(
                        messageId: "auto",
                        kind: .map,
                        title: "Cupertino Campus Navigation",
                        payload: AgentResultPayload()
                    ))),
                    .init(atMs: 400, event: .finished)
                ]
            ),

            // 17: Interactive Form
            DemoScenario(
                id: "17_native_form",
                title: "17. Interactive Form Calculator",
                summary: "Slider, Toggle, Segmented Picker with live computed total and submit action",
                userPrompt: "Calculate team subscription cost.",
                events: [
                    .init(atMs: 200, event: .resultProduced(result: AgentResult(
                        messageId: "auto",
                        kind: .form,
                        title: "Interactive Team Pricing Calculator",
                        payload: AgentResultPayload()
                    ))),
                    .init(atMs: 400, event: .finished)
                ]
            ),

            // 18: Canvas Revisions
            DemoScenario(
                id: "18_canvas_revisions",
                title: "18. Canvas Document Revisions",
                summary: "Diff comparison, strikethrough original, accept/reject actions",
                userPrompt: "Revise paragraph 2 of the SDK overview.",
                events: [
                    .init(atMs: 200, event: .resultProduced(result: AgentResult(
                        messageId: "auto",
                        kind: .canvasDocument,
                        title: "Document Revision: Overview",
                        payload: AgentResultPayload()
                    ))),
                    .init(atMs: 400, event: .finished)
                ]
            ),

            // 19: MCP & Skills
            DemoScenario(
                id: "19_skills_mcp",
                title: "19. Discovered Tools & MCP",
                summary: "Showcase tool discovery catalog with inspector",
                userPrompt: "Discover available Model Context Protocol (MCP) tools.",
                events: [
                    .init(atMs: 200, event: .resultProduced(result: AgentResult(
                        messageId: "auto",
                        kind: .toolFallback,
                        title: "Discovered MCP Tools: 6 Servers Connected",
                        payload: AgentResultPayload(contentText: "Available: GitHub, Apple DevTools, Memory, Slack, Filesystem, SQLite.")
                    ))),
                    .init(atMs: 400, event: .finished)
                ]
            ),

            // 20: Health & Reminders
            DemoScenario(
                id: "20_health_reminders",
                title: "20. HealthKit & Reminders Cards",
                summary: "Domain-specific UI cards with simulated confirmation",
                userPrompt: "Show my health summary and reminder list.",
                events: [
                    .init(atMs: 150, event: .resultProduced(result: AgentResult(
                        messageId: "auto",
                        kind: .health,
                        title: "Activity Trends",
                        payload: AgentResultPayload()
                    ))),
                    .init(atMs: 300, event: .resultProduced(result: AgentResult(
                        messageId: "auto",
                        kind: .reminder,
                        title: "Review Pull Request #42",
                        payload: AgentResultPayload()
                    ))),
                    .init(atMs: 400, event: .finished)
                ]
            ),

            // 21: Voice UI
            DemoScenario(
                id: "21_voice_ui",
                title: "21. Realtime Voice Interface",
                summary: "Audio level visualization and mock voice state transitions",
                userPrompt: "Start voice consultation mode.",
                events: [
                    .init(atMs: 200, event: .contentDelta(messageId: "auto", text: "Voice session active with `AgentMockVoiceProvider`.\n\nMicrophone waveform and ambient listening simulated.")),
                    .init(atMs: 400, event: .finished)
                ]
            ),

            // 22: Declarative MiniApp
            DemoScenario(
                id: "22_rich_ui_miniapp",
                title: "22. Declarative MiniApp UI",
                summary: "Interactive multi-tab mini widget embedded in chat transcript",
                userPrompt: "Display project dashboard mini app.",
                events: [
                    .init(atMs: 200, event: .resultProduced(result: AgentResult(
                        messageId: "auto",
                        kind: .miniApp,
                        title: "Project Health & Diagnostics",
                        payload: AgentResultPayload()
                    ))),
                    .init(atMs: 400, event: .finished)
                ]
            ),

            // 23: WebKit Isolation Fallback
            DemoScenario(
                id: "23_html_youtube_fallback",
                title: "23. External Video Fallback (Zero WebKit)",
                summary: "Native preview card with external link button",
                userPrompt: "Play external YouTube video.",
                events: [
                    .init(atMs: 200, event: .resultProduced(result: AgentResult(
                        messageId: "auto",
                        kind: .webContentFallback,
                        title: "WWDC26 Keynote: Native SwiftUI",
                        payload: AgentResultPayload(urlString: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")
                    ))),
                    .init(atMs: 400, event: .finished)
                ]
            ),

            // 24: Multi-Session Isolation
            DemoScenario(
                id: "24_multi_session",
                title: "24. Multi-Session Isolation",
                summary: "Create independent conversation without cross-session leakage",
                userPrompt: "Open a separate isolated session.",
                events: [
                    .init(atMs: 200, event: .contentDelta(messageId: "auto", text: "Session state is strictly scoped to this instance. No singleton activity leakage.")),
                    .init(atMs: 400, event: .finished)
                ]
            ),

            // 25: Stress Long Chat
            DemoScenario(
                id: "25_stress_long_chat",
                title: "25. Stress Test: Long Chat",
                summary: "Populate transcript with multiple turns to exercise LazyVStack",
                userPrompt: "Generate multiple turn conversation.",
                events: [
                    .init(atMs: 100, event: .contentDelta(messageId: "auto", text: "Turn 1: LazyVStack ensures fast scroll performance.\n")),
                    .init(atMs: 200, event: .contentDelta(messageId: "auto", text: "Turn 2: Stable IDs preserve scroll anchor without jumping.\n")),
                    .init(atMs: 300, event: .contentDelta(messageId: "auto", text: "Turn 3: Memory footprint remains bounded.")),
                    .init(atMs: 400, event: .finished)
                ]
            ),

            // 26: Permissions & Error Boundary
            DemoScenario(
                id: "26_permissions_errors",
                title: "26. Permissions & Error Recovery",
                summary: "Graceful handling of permission denial without app crash",
                userPrompt: "Request microphone permission.",
                events: [
                    .init(atMs: 200, event: .resultProduced(result: AgentResult(
                        messageId: "auto",
                        kind: .error,
                        title: "Microphone Access Denied",
                        payload: AgentResultPayload(contentText: "Voice input requires permission in iOS Settings. Text input remains available.")
                    ))),
                    .init(atMs: 400, event: .finished)
                ]
            )
        ]
    }
}
