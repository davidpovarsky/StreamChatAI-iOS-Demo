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
        // 1. Chat basics
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
            id: "chat.hebrew",
            category: "Chat Basics",
            title: "Hebrew & RTL Layout",
            description: "Right-to-left Hebrew conversation layout, alignment and formatting.",
            initialMessages: [
                AgentMessage(role: .user, blocks: [.markdown(id: "u4", content: "תוכל להסביר לי על AgentUI בעברית?")]),
                AgentMessage(role: .assistant, blocks: [.markdown(id: "a4", content: MockData.hebrewSampleText)])
            ]
        ),

        // 2. Sources & Citations
        ShowcaseScenario(
            id: "sources.all",
            category: "Sources",
            title: "Section & Footer Citations",
            description: "Paragraph end cluster and all-sources footer pill opening sheets.",
            initialMessages: [
                AgentMessage(
                    role: .assistant,
                    blocks: [.markdown(id: "a5", content: "The Swift standard library contains extensive collections and concurrency tools.")],
                    allSources: MockData.sampleSources
                )
            ]
        ),

        // 3. Activity Timeline
        ShowcaseScenario(
            id: "activity.timeline",
            category: "Activity",
            title: "Agent Process & Auto-Collapse",
            description: "ChatGPT-style activity timeline showing reasoning, tool progress and elapsed duration.",
            initialMessages: [
                AgentMessage(
                    id: "msg-act",
                    role: .assistant,
                    blocks: [.markdown(id: "a6", content: "Task analysis completed successfully.")]
                )
            ],
            initialActivities: [
                AgentMessageID("msg-act"): AgentActivitySession(
                    messageID: AgentMessageID("msg-act"),
                    items: [
                        AgentActivityItem(kind: .reasoning, status: .completed, title: "Thinking through architecture", summary: "Evaluated modular package dependencies."),
                        AgentActivityItem(kind: .webSearch(query: "swift concurrency"), status: .completed, title: "Searched Swift Concurrency docs"),
                        AgentActivityItem(kind: .genericTool(toolName: "verify_types"), status: .completed, title: "Ran typecheck verification")
                    ],
                    answerStarted: true,
                    isExpanded: true
                )
            ]
        ),

        // 4. Tool Execution & BUG FIX VERIFICATION
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

        // 5. Embedded Results & Mini Apps
        ShowcaseScenario(
            id: "embedded.miniapp",
            category: "Embedded Results",
            title: "Interactive Mini App & Sheet",
            description: "Arbitrary stateful mini app hosted inline with expand-to-sheet affordance.",
            initialMessages: [
                AgentMessage(
                    role: .assistant,
                    blocks: [
                        .embeddedResult(
                            id: "embed-1",
                            descriptor: AgentEmbeddedPresentationDescriptor(
                                handlerID: "miniapp.form",
                                title: "Interactive Control Widget",
                                sizing: .init(preset: .regular),
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
            id: "embedded.sefaria",
            category: "Embedded Results",
            title: "Hanlin Sefaria Source Card",
            description: "Mock Sefaria Hebrew/English text source card hosted via embedded registry.",
            initialMessages: [
                AgentMessage(
                    role: .assistant,
                    blocks: [
                        .embeddedResult(
                            id: "embed-sefaria",
                            descriptor: AgentEmbeddedPresentationDescriptor(
                                handlerID: "sefaria.source",
                                title: "Sefaria Library Source",
                                sizing: .init(preset: .compact),
                                payload: .empty
                            )
                        )
                    ]
                )
            ]
        ),

        // 6. Media
        ShowcaseScenario(
            id: "media.gallery",
            category: "Media",
            title: "Rich Media & Fullscreen Zoom",
            description: "Inline images with fullscreen interactive pinch zoom and dismissal.",
            initialMessages: [
                AgentMessage(
                    role: .assistant,
                    blocks: [
                        .image(id: "img-1", url: URL(string: "https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?w=800"), altText: "Art", caption: "Generated generative artwork illustration"),
                        .youtube(id: "yt-1", videoID: "dQw4w9WgXcQ", title: "Video Demonstration", subtitle: "Agent capabilities walkthrough")
                    ]
                )
            ]
        ),

        // 7. Native Structured Blocks
        ShowcaseScenario(
            id: "native.blocks",
            category: "Native Blocks",
            title: "Structured Cards & Calculations",
            description: "Engine-neutral cards, key-value items, calculation and search results blocks.",
            initialMessages: [
                AgentMessage(
                    role: .assistant,
                    blocks: [
                        .nativeUI(
                            id: "card-1",
                            block: AgentNativeUIBlock(
                                family: .card,
                                title: "System Diagnostics",
                                subtitle: "Runtime Performance",
                                body: "All verification suites passed without warnings.",
                                keyValues: [
                                    ("Engine", "AgentUI SDK 0.1.0"),
                                    ("Platform", "iOS 18+ / iOS 26 Liquid Glass"),
                                    ("Status", "Operational")
                                ]
                            )
                        ),
                        .nativeUI(
                            id: "calc-1",
                            block: AgentNativeUIBlock(
                                family: .calculation,
                                title: "sqrt(144) * 5",
                                body: "60"
                            )
                        )
                    ]
                )
            ]
        )
    ]
}
