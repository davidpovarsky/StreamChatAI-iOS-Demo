// Sources/AgentUIShowcaseSupport/ScenarioCatalog/ShowcaseScenarios.swift
import Foundation
import AgentUI

public struct ShowcaseScenario: Identifiable, Sendable {
    public let id: String
    public let category: String
    public let title: String
    public let description: String
    public let initialMessages: [AgentMessage]
    public let initialActivities: [AgentMessageID: AgentActivitySession]

    public init(
        id: String,
        category: String,
        title: String,
        description: String,
        initialMessages: [AgentMessage] = [],
        initialActivities: [AgentMessageID: AgentActivitySession] = [:]
    ) {
        self.id = id
        self.category = category
        self.title = title
        self.description = description
        self.initialMessages = initialMessages
        self.initialActivities = initialActivities
    }
}

public enum ShowcaseCatalog {
    public static let allScenarios: [ShowcaseScenario] = [
        // MARK: - 1. Chat Basics
        ShowcaseScenario(
            id: "chat.plain",
            category: "Chat Basics",
            title: "Standard Chat & Markdown",
            description: "Clean typography, headings, lists, bold text and markdown formatting.",
            initialMessages: [
                AgentMessage(role: .user, blocks: [.markdown(id: "u1", content: "Tell me about AgentUI SDK")]),
                AgentMessage(role: .assistant, blocks: [.markdown(id: "a1", content: "AgentUI is a reusable Swift Package that provides a complete chat UI layer for AI agent applications.")])
            ]
        ),
        ShowcaseScenario(
            id: "chat.markdown.long",
            category: "Chat Basics",
            title: "Long Markdown Document",
            description: "Headings H1-H4, ordered/unordered lists, blockquotes, horizontal rules and tables.",
            initialMessages: [
                AgentMessage(role: .user, blocks: [.markdown(id: "u_long", content: "Provide the architecture specification")]),
                AgentMessage(role: .assistant, blocks: [.markdown(id: "a_long", content: MockData.longMarkdownText)])
            ]
        ),
        ShowcaseScenario(
            id: "chat.code",
            category: "Chat Basics",
            title: "Code Block with Copy",
            description: "Syntax highlighted code block with copy to clipboard and language pill.",
            initialMessages: [
                AgentMessage(role: .user, blocks: [.markdown(id: "u2", content: "How do I use AgentChatView?")]),
                AgentMessage(role: .assistant, blocks: [.markdown(id: "a2", content: MockData.codeSampleText)])
            ]
        ),
        ShowcaseScenario(
            id: "chat.math",
            category: "Chat Basics",
            title: "Mathematical Formulas",
            description: "LaTeX-style mathematical formulas in centered block and inline.",
            initialMessages: [
                AgentMessage(role: .user, blocks: [.markdown(id: "u3", content: "Show me the quadratic formula")]),
                AgentMessage(role: .assistant, blocks: [.markdown(id: "a3", content: MockData.mathSampleText)])
            ]
        ),
        ShowcaseScenario(
            id: "chat.streaming",
            category: "Chat Basics",
            title: "Streaming Message",
            description: "Active streaming state showing partial response and animated indicator.",
            initialMessages: [
                AgentMessage(
                    role: .assistant,
                    blocks: [.markdown(id: "a_stream", content: "Streaming partial tokens in real time...")],
                    isStreaming: true
                )
            ]
        ),
        ShowcaseScenario(
            id: "chat.cancelled",
            category: "Chat Basics",
            title: "Cancelled Generation",
            description: "Request stopped mid-flight with distinct cancelled state representation.",
            initialMessages: [
                AgentMessage(role: .user, blocks: [.markdown(id: "u_c", content: "Generate large report")]),
                AgentMessage(
                    role: .assistant,
                    blocks: [.markdown(id: "a_c", content: "Generation was cancelled by the host runtime.")],
                    error: AgentUIError(code: "request_cancelled", message: "Request cancelled")
                )
            ]
        ),
        ShowcaseScenario(
            id: "chat.failure",
            category: "Chat Basics",
            title: "Error & Retry Banner",
            description: "Displays service failure error message with retry affordance.",
            initialMessages: [
                AgentMessage(role: .user, blocks: [.markdown(id: "u_f", content: "Run remote command")]),
                AgentMessage(
                    role: .assistant,
                    blocks: [],
                    error: AgentUIError(code: "network_timeout", message: "Connection to agent server timed out after 30s")
                )
            ]
        ),
        ShowcaseScenario(
            id: "chat.hebrew",
            category: "Chat Basics",
            title: "Hebrew & RTL Layout",
            description: "Right-to-left Hebrew conversation layout, alignment and formatting.",
            initialMessages: [
                AgentMessage(role: .user, blocks: [.markdown(id: "u4", content: "תוכל להסביר לי על AgentUI בעברית?")]),
                AgentMessage(role: .assistant, blocks: [.markdown(id: "a4", content: MockData.hebrewSampleText)])
            ]
        ),

        // MARK: - 2. Sources & Citations
        ShowcaseScenario(
            id: "sources.inline.short",
            category: "Sources",
            title: "Short Paragraph Inline Cluster",
            description: "Inline favicon cluster positioned at paragraph end with sheet interaction.",
            initialMessages: [
                AgentMessage(
                    role: .assistant,
                    blocks: [.markdown(id: "a_sec_short", content: "Swift is developed openly at Swift.org by the open-source community.")],
                    sectionSources: ["a_sec_short": [MockData.sampleSources[0], MockData.sampleSources[1]]]
                )
            ]
        ),
        ShowcaseScenario(
            id: "sources.inline.wrapping",
            category: "Sources",
            title: "Long Paragraph Wrapping Cluster",
            description: "Inline cluster wrapping naturally to the next line when the text fills the row.",
            initialMessages: [
                AgentMessage(
                    role: .assistant,
                    blocks: [.markdown(id: "a_sec_wrap", content: "The Swift programming language is designed to make writing and maintaining correct programs easier for the developer with memory safety, type inference, and modern concurrency.")],
                    sectionSources: ["a_sec_wrap": [MockData.sampleSources[0], MockData.sampleSources[2]]]
                )
            ]
        ),
        ShowcaseScenario(
            id: "sources.footer",
            category: "Sources",
            title: "Footer Sources Pill",
            description: "Message footer pill showing total sources count and opening all-sources sheet.",
            initialMessages: [
                AgentMessage(
                    role: .assistant,
                    blocks: [.markdown(id: "a_foot", content: "Extensive documentation is provided for Swift on iOS and iPadOS.")],
                    allSources: MockData.sampleSources
                )
            ]
        ),
        ShowcaseScenario(
            id: "sources.many",
            category: "Sources",
            title: "12 Deduplicated Sources",
            description: "Preserves deterministic first-seen domain order across 12 distinct citations.",
            initialMessages: [
                AgentMessage(
                    role: .assistant,
                    blocks: [.markdown(id: "a_12", content: "Comprehensive references across Apple platforms and developer ecosystems.")],
                    allSources: MockData.twelveSampleSources
                )
            ]
        ),

        // MARK: - 3. Activity Timeline
        ShowcaseScenario(
            id: "activity.timeline",
            category: "Activity",
            title: "Running Timeline",
            description: "Active reasoning steps, web searches, and live elapsed timer.",
            initialMessages: [
                AgentMessage(id: "msg-act-run", role: .assistant, blocks: [])
            ],
            initialActivities: [
                AgentMessageID("msg-act-run"): AgentActivitySession(
                    messageID: AgentMessageID("msg-act-run"),
                    items: [
                        AgentActivityItem(kind: .reasoning, status: .running, title: "Analyzing repository layout", summary: "Scanning project files and Package.swift")
                    ],
                    answerStarted: false,
                    isExpanded: true
                )
            ]
        ),
        ShowcaseScenario(
            id: "activity.autocollapse",
            category: "Activity",
            title: "Completed & Auto-Collapse",
            description: "Auto-collapsed activity summary pill 'Worked for 3s' once response starts.",
            initialMessages: [
                AgentMessage(
                    id: "msg-act-done",
                    role: .assistant,
                    blocks: [.markdown(id: "a_done", content: "Here are the completed project recommendations.")]
                )
            ],
            initialActivities: [
                AgentMessageID("msg-act-done"): AgentActivitySession(
                    messageID: AgentMessageID("msg-act-done"),
                    items: [
                        AgentActivityItem(kind: .reasoning, status: .completed, title: "Thinking through architecture", summary: "Evaluated modular package dependencies."),
                        AgentActivityItem(kind: .webSearch(query: "swift concurrency"), status: .completed, title: "Searched Swift Concurrency docs"),
                        AgentActivityItem(kind: .genericTool(toolName: "verify_types"), status: .completed, title: "Ran typecheck verification")
                    ],
                    answerStarted: true,
                    isExpanded: false
                )
            ]
        ),
        ShowcaseScenario(
            id: "activity.nested",
            category: "Activity",
            title: "Expanded Nested Activity",
            description: "Fully expanded timeline revealing intermediate reasoning and tool queries.",
            initialMessages: [
                AgentMessage(
                    id: "msg-act-nest",
                    role: .assistant,
                    blocks: [.markdown(id: "a_nest", content: "Search complete.")]
                )
            ],
            initialActivities: [
                AgentMessageID("msg-act-nest"): AgentActivitySession(
                    messageID: AgentMessageID("msg-act-nest"),
                    items: [
                        AgentActivityItem(kind: .reasoning, status: .completed, title: "Analyzing requirements", summary: "Parsed user input and planned 3 tool calls."),
                        AgentActivityItem(kind: .webSearch(query: "swift testing"), status: .completed, title: "Queried Swift Testing docs"),
                        AgentActivityItem(kind: .codeExecution(language: "swift"), status: .completed, title: "Executed unit tests")
                    ],
                    answerStarted: true,
                    isExpanded: true
                )
            ]
        ),

        // MARK: - 4. Tool Execution & ONE-SURFACE DISCLOSURE
        ShowcaseScenario(
            id: "tool.disclosure",
            category: "Tool Execution",
            title: "One-Surface Tool Disclosure",
            description: "CRITICAL FIX: Continuous surface without detached card or visual gap when expanded.",
            initialMessages: [
                AgentMessage(
                    id: "msg-tool",
                    role: .assistant,
                    blocks: [
                        .toolExecution(
                            id: "tool-gh",
                            execution: AgentToolExecution(
                                handlerID: "github.search",
                                inspection: ToolCallInspection(
                                    callID: "call_0948",
                                    service: "GitHub Search API",
                                    toolName: "search_repositories",
                                    arguments: "{\"query\": \"AgentUI\", \"stars\": \">100\", \"secret\": \"12345\"}",
                                    resultSummary: "Found repository davidpovarsky/StreamChatAI-iOS-Demo with 5 matching files."
                                ),
                                status: .completed,
                                isExpanded: true
                            )
                        )
                    ]
                )
            ]
        ),
        ShowcaseScenario(
            id: "tool.websearch",
            category: "Tool Execution",
            title: "Web Search Tool",
            description: "Web search tool call surface with query inspection and redacted auth tokens.",
            initialMessages: [
                AgentMessage(
                    id: "msg-tool-web",
                    role: .assistant,
                    blocks: [
                        .toolExecution(
                            id: "tool-web",
                            execution: AgentToolExecution(
                                handlerID: "web_search",
                                inspection: ToolCallInspection(
                                    callID: "call_web_01",
                                    service: "DuckDuckGo",
                                    toolName: "web_search",
                                    arguments: "{\"query\": \"iOS 18 Liquid Glass\", \"apiKey\": \"sk-secret123\"}",
                                    resultSummary: "Returned 10 top web results."
                                ),
                                status: .completed,
                                isExpanded: false
                            )
                        )
                    ]
                )
            ]
        ),
        ShowcaseScenario(
            id: "tool.command",
            category: "Tool Execution",
            title: "Terminal Command Tool",
            description: "Command execution tool surface with stdout inspection.",
            initialMessages: [
                AgentMessage(
                    id: "msg-tool-cmd",
                    role: .assistant,
                    blocks: [
                        .toolExecution(
                            id: "tool-cmd",
                            execution: AgentToolExecution(
                                handlerID: "command_exec",
                                inspection: ToolCallInspection(
                                    callID: "call_cmd_01",
                                    service: "Local Shell",
                                    toolName: "run_command",
                                    arguments: "{\"command\": \"swift test\"}",
                                    resultSummary: "Executed 22 tests with 0 failures."
                                ),
                                status: .completed,
                                isExpanded: false
                            )
                        )
                    ]
                )
            ]
        ),
        ShowcaseScenario(
            id: "tool.failed",
            category: "Tool Execution",
            title: "Failed Tool Call",
            description: "Tool execution encountering an error with diagnostic message.",
            initialMessages: [
                AgentMessage(
                    id: "msg-tool-err",
                    role: .assistant,
                    blocks: [
                        .toolExecution(
                            id: "tool-err",
                            execution: AgentToolExecution(
                                handlerID: "file_operation",
                                inspection: ToolCallInspection(
                                    callID: "call_err_01",
                                    service: "File System",
                                    toolName: "read_file",
                                    arguments: "{\"path\": \"/missing/file.txt\"}",
                                    resultSummary: nil,
                                    errorMessage: "File not found: /missing/file.txt"
                                ),
                                status: .failed,
                                isExpanded: true
                            )
                        )
                    ]
                )
            ]
        ),

        // MARK: - 5. Embedded Results & Mini Apps
        ShowcaseScenario(
            id: "embedded.sheet",
            category: "Embedded Results",
            title: "Expand to Sheet",
            description: "Embedded result session with expand-to-sheet modal presentation.",
            initialMessages: [
                AgentMessage(
                    role: .assistant,
                    blocks: [
                        .embeddedResult(
                            id: "embed-sheet-1",
                            descriptor: AgentEmbeddedPresentationDescriptor(
                                handlerID: "miniapp.form",
                                title: "Interactive Control Widget",
                                sizing: .init(preset: .regular),
                                expansion: AgentExpansionDescriptor(allowedModes: [.sheet], preferredMode: .sheet),
                                payload: .init(actions: [
                                    AgentEmbeddedContentAction(title: "Save Config", actionID: "save"),
                                    AgentEmbeddedContentAction(title: "Reset", actionID: "reset")
                                ])
                            )
                        )
                    ]
                )
            ]
        ),
        ShowcaseScenario(
            id: "embedded.fullscreen",
            category: "Embedded Results",
            title: "Expand to FullScreen",
            description: "Embedded result session configured for fullScreen presentation.",
            initialMessages: [
                AgentMessage(
                    role: .assistant,
                    blocks: [
                        .embeddedResult(
                            id: "embed-fs-1",
                            descriptor: AgentEmbeddedPresentationDescriptor(
                                handlerID: "embedded.test.card",
                                title: "Full Screen Mini App",
                                sizing: .init(preset: .large),
                                expansion: AgentExpansionDescriptor(allowedModes: [.fullScreen, .sheet], preferredMode: .fullScreen),
                                payload: .init(actions: [
                                    AgentEmbeddedContentAction(title: "Expand Fullscreen", actionID: "fullscreen"),
                                    AgentEmbeddedContentAction(title: "Details", actionID: "sheet")
                                ])
                            )
                        )
                    ]
                )
            ]
        ),
        ShowcaseScenario(
            id: "embedded.actions",
            category: "Embedded Results",
            title: "Embedded Host Actions",
            description: "Embedded card with actions wired to AgentHostActions (Copy, URL, Window).",
            initialMessages: [
                AgentMessage(
                    role: .assistant,
                    blocks: [
                        .embeddedResult(
                            id: "embed-act-1",
                            descriptor: AgentEmbeddedPresentationDescriptor(
                                handlerID: "embedded.test.card",
                                title: "Action Dispatcher",
                                sizing: .init(preset: .compact),
                                expansion: AgentExpansionDescriptor(allowedModes: [.sheet], preferredMode: .sheet),
                                payload: .init(actions: [
                                    AgentEmbeddedContentAction(title: "Open Docs", actionID: "https://developer.apple.com"),
                                    AgentEmbeddedContentAction(title: "Request Window", actionID: "window"),
                                    AgentEmbeddedContentAction(title: "Custom Action", actionID: "custom_ping")
                                ])
                            )
                        )
                    ]
                )
            ]
        ),
        ShowcaseScenario(
            id: "embedded.unresolved",
            category: "Embedded Results",
            title: "Unresolved Handler Fallback",
            description: "Displays clean dashed fallback placeholder when handler is unregistered.",
            initialMessages: [
                AgentMessage(
                    role: .assistant,
                    blocks: [
                        .embeddedResult(
                            id: "embed-unresolved",
                            descriptor: AgentEmbeddedPresentationDescriptor(
                                handlerID: "unregistered.custom.tool",
                                title: "Unknown Plugin Surface",
                                sizing: .init(preset: .compact),
                                payload: .empty
                            )
                        )
                    ]
                )
            ]
        ),

        // MARK: - 6. Media
        ShowcaseScenario(
            id: "media.zoom",
            category: "Media",
            title: "Native Zoom Image Navigation",
            description: "Image opening into full viewer with native zoom transition and gestures.",
            initialMessages: [
                AgentMessage(
                    role: .assistant,
                    blocks: [
                        .image(
                            id: "img-zoom-target",
                            url: URL(string: "https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?w=800"),
                            altText: "Generative Artwork",
                            caption: "Tap to open native zoom viewer"
                        )
                    ]
                )
            ]
        ),
        ShowcaseScenario(
            id: "media.youtube.success",
            category: "Media",
            title: "YouTube Video Embed",
            description: "Inline YouTube video embed player with 16:9 ratio.",
            initialMessages: [
                AgentMessage(
                    role: .assistant,
                    blocks: [
                        .youtube(id: "yt-ok", videoID: "dQw4w9WgXcQ", title: "Video Demonstration", subtitle: "Official Walkthrough")
                    ]
                )
            ]
        ),
        ShowcaseScenario(
            id: "media.youtube.fallback",
            category: "Media",
            title: "YouTube Fallback on Error",
            description: "Detects runtime failure and displays polished fallback with link.",
            initialMessages: [
                AgentMessage(
                    role: .assistant,
                    blocks: [
                        .youtube(id: "yt-err", videoID: "invalid_id_fail", title: "Unavailable Video", subtitle: "Fallback view demonstration")
                    ]
                )
            ]
        ),

        // MARK: - 7. Native Structured Blocks
        ShowcaseScenario(
            id: "native.cards",
            category: "Native Blocks",
            title: "Native UI Cards & Actions",
            description: "All fields: systemImage, title, subtitle, body, footnote, keyValues, and actions.",
            initialMessages: [
                AgentMessage(
                    role: .assistant,
                    blocks: [
                        .nativeUI(
                            id: "card-full",
                            block: AgentNativeUIBlock(
                                family: .card,
                                title: "Build Verification",
                                subtitle: "AgentUI Hardening Suite",
                                body: "All verification suites passed without warnings.",
                                footnote: "Verified with Swift 6 strict concurrency.",
                                systemImage: "checkmark.seal.fill",
                                keyValues: [
                                    ("Engine", "AgentUI SDK 0.1.0"),
                                    ("Target", "iOS 18+ / iPadOS 18+"),
                                    ("Status", "Passing")
                                ],
                                actions: [
                                    AgentNativeBlockActionItem(title: "View Logs", iconSystemName: "doc.text", action: .hostAction(actionID: "view_logs", payload: nil)),
                                    AgentNativeBlockActionItem(title: "Copy Summary", iconSystemName: "doc.on.doc", action: .copy("Build Verification Passing"))
                                ]
                            )
                        )
                    ]
                )
            ]
        ),
        ShowcaseScenario(
            id: "native.children",
            category: "Native Blocks",
            title: "Nested Native Children",
            description: "Hierarchical native UI blocks with nested child cards.",
            initialMessages: [
                AgentMessage(
                    role: .assistant,
                    blocks: [
                        .nativeUI(
                            id: "parent-card",
                            block: AgentNativeUIBlock(
                                family: .card,
                                title: "Project Structure",
                                subtitle: "Multi-Module Architecture",
                                body: "The following sub-components are active:",
                                children: [
                                    AgentNativeUIBlock(
                                        family: .calculation,
                                        title: "Coverage Target: 22 / 22",
                                        body: "100%"
                                    ),
                                    AgentNativeUIBlock(
                                        family: .source,
                                        title: "StreamChatAI-iOS-Demo",
                                        subtitle: "agent/agentui-sdk-hardening-v2"
                                    )
                                ]
                            )
                        )
                    ]
                )
            ]
        ),
        ShowcaseScenario(
            id: "native.error",
            category: "Native Blocks",
            title: "Native Error Block",
            description: "Engine-neutral error card with retry action button.",
            initialMessages: [
                AgentMessage(
                    role: .assistant,
                    blocks: [
                        .nativeUI(
                            id: "err-block",
                            block: AgentNativeUIBlock(
                                family: .error,
                                title: "Failed to connect to gateway",
                                body: "Endpoint returned HTTP 503 Service Unavailable.",
                                footnote: "Check network settings or proxy configuration.",
                                actions: [
                                    AgentNativeBlockActionItem(title: "Retry Connection", iconSystemName: "arrow.clockwise", action: .hostAction(actionID: "retry_connection", payload: nil))
                                ]
                            )
                        )
                    ]
                )
            ]
        )
    ]
}
