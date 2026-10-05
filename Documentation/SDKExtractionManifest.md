# AgentUI SDK Extraction Manifest

This document is the migration ledger tracking the exact extraction of approved SwiftChat UI components into the reusable `AgentUI` Swift Package without redesigning, rebuilding, or re-styling any components.

## Extraction Rules & Invariants
1. **Source of Truth**: The approved SwiftChat UI code is the golden master. We extract the existing implementation directly; we do NOT rewrite, simplify, or redesign components.
2. **Access Control**: Broaden access modifiers (`internal` -> `public`, `private` -> `internal`) mechanically to satisfy module boundaries.
3. **Compatibility Adapters**: Existing app call sites are preserved through compatibility adapters and typealiases in the app/overlay.
4. **Visual Parity**: Every component maintains its exact frames, padding, corner radii, fonts, weights, colors, animations, and Liquid Glass effects (`.glassEffect`, `.buttonStyle(.glass)`, `.buttonBorderShape`).
5. **Separation of Concerns**: Production UI components migrate to `Packages/AgentUI`; offline fixtures, demo stores, and simulated drivers remain in the host demo.

---

## Component Migration Ledger

| Original Path | Dependencies | Destination in `AgentUI` | Migration Slice | Status | Invariant Visual Modifiers | Wrapper Needed |
|---|---|---|---|---|---|---|
| `swiftchat-overlay/Features/ToolPresentation/ToolExecutionDisclosure.swift` | `ToolCallInspection`, `ToolExecutionStatus`, `ToolCallInspectionView` | `Packages/AgentUI/Sources/AgentUI/ToolPresentation/ToolExecutionDisclosure.swift` | Slice 4 (ToolPresentation) | Extracted (Package owned, app bridged) | Single continuous glass surface: `.padding(.horizontal, 12).padding(.vertical, 8).toolExecutionGlassEffect()`, chevron rotation | Yes (Overlay re-export/alias) |
| `swiftchat-overlay/Features/ToolPresentation/ToolCallInspectionView.swift` | `ToolCallInspection`, `ToolExecutionStatus` | `Packages/AgentUI/Sources/AgentUI/ToolPresentation/ToolCallInspectionView.swift` | Slice 4 (ToolPresentation) | Extracted (Package owned, app bridged) | Mono font, divider opacity 0.35, argument scroll view cornerRadius 8, error orange background cornerRadius 6 | Yes |
| `swiftchat-overlay/Features/ToolPresentation/ToolCallInspection.swift` | None | `Packages/AgentUI/Sources/AgentUI/ToolPresentation/ToolCallInspection.swift` | Slice 4 (ToolPresentation) | Extracted (Package owned, app bridged) | Data model only | Yes (typealias) |
| `swiftchat-overlay/Features/ToolPresentation/ToolExecutionStatus.swift` | None | `Packages/AgentUI/Sources/AgentUI/ToolPresentation/ToolExecutionStatus.swift` | Slice 4 (ToolPresentation) | Extracted (Package owned, app bridged) | Enum only | Yes (typealias) |
| `swiftchat-overlay/Features/AgentActivity/AgentActivityModels.swift` | None | `Packages/AgentUI/Sources/AgentUI/AgentActivity/AgentActivityModels.swift` | Slice 5 (AgentActivity) | Extracted (Package owned, app bridged) | Data models only | Yes (typealias) |
| `swiftchat-overlay/Features/AgentActivity/AgentActivityStore.swift` | `Combine`, `AgentActivityModels` | `Packages/AgentUI/Sources/AgentUI/AgentActivity/AgentActivityStore.swift` | Slice 5 (AgentActivity) | Extracted (Package owned, app bridged) | ObservableObject state logic | Yes (typealias) |
| `swiftchat-overlay/Features/AgentActivity/AgentActivityTimelineView.swift` | `AgentActivityStore`, `AgentActivityRowView` | `Packages/AgentUI/Sources/AgentUI/AgentActivity/AgentActivityTimelineView.swift` | Slice 5 (AgentActivity) | Extracted (Package owned, app bridged) | Timeline spacing, progress indicators, "Working for Ns" / "Worked for Ns" | Yes (Bridge & alias) |
| `swiftchat-overlay/Features/AgentActivity/AgentActivityRowView.swift` | `AgentActivityModels`, `AgentActivityDetailViews` | `Packages/AgentUI/Sources/AgentUI/AgentActivity/AgentActivityRowView.swift` | Slice 5 (AgentActivity) | Extracted (Package owned, app bridged) | Row padding, chevron animation, step icons | Yes (typealias) |
| `swiftchat-overlay/Features/AgentActivity/AgentActivityDetailViews.swift` | `AgentActivityModels` | `Packages/AgentUI/Sources/AgentUI/AgentActivity/AgentActivityDetailViews.swift` | Slice 5 (AgentActivity) | Extracted (Package owned, app bridged) | Monospace inspection boxes, font sizing | Yes (typealiases) |
| `swiftchat-overlay/Features/SectionSources/InlineSectionSourcesView.swift` | `SectionSourceClusterRenderer`, `SectionSourcesPresentation` | `Packages/AgentUI/Sources/AgentUI/SectionSources/InlineSectionSourcesView.swift` | Slice 6 (SectionSources) | Extracted (Package owned, app bridged) | Cluster attachment to paragraph, tap gestures, sheet presentation | Yes (Wrapper) |
| `swiftchat-overlay/Features/SectionSources/SectionSourceClusterRenderer.swift` | `SectionSourcesPresentation` | `Packages/AgentUI/Sources/AgentUI/SectionSources/SectionSourceClusterRenderer.swift` | Slice 6 (SectionSources) | Extracted (Package owned, app bridged) | Favicon overlapping stack, border shape, counter pill | Yes (typealias) |
| `swiftchat-overlay/Features/SectionSources/SectionSourcesPresentation.swift` | None | `Packages/AgentUI/Sources/AgentUI/SectionSources/SectionSourcesPresentation.swift` | Slice 6 (SectionSources) | Extracted (Package owned, app bridged) | Source model & formatting | Yes (typealias) |
| `swiftchat-overlay/Features/RichMedia/InlineImageMediaView.swift` | None | `Packages/AgentUI/Sources/AgentUI/RichMedia/InlineImageMediaView.swift` | Slice 7 (RichMedia) | Extracted (Package owned, app bridged) | Max width, corner radius, aspect ratio, caption padding | Yes (typealias) |
| `swiftchat-overlay/Features/RichMedia/InlineVideoMediaView.swift` | `AVKit` | `Packages/AgentUI/Sources/AgentUI/RichMedia/InlineVideoMediaView.swift` | Slice 7 (RichMedia) | Extracted (Package owned, app bridged) | Video player aspect ratio, controls, corner radius | Yes (typealias) |
| `swiftchat-overlay/Features/RichMedia/InlineYouTubeMediaView.swift` | `WebKit` | `Packages/AgentUI/Sources/AgentUI/RichMedia/InlineYouTubeMediaView.swift` | Slice 7 (RichMedia) | Extracted (Package owned, app bridged) | 16:9 aspect ratio, webview corner radius, fallback card | Yes (typealias) |
| `swiftchat-overlay/Features/RichMedia/RichMediaFallbackView.swift` | None | `Packages/AgentUI/Sources/AgentUI/RichMedia/RichMediaFallbackView.swift` | Slice 7 (RichMedia) | Extracted (Package owned, app bridged) | Error card styling, icon, retry action | Yes (typealias) |
| `SwiftChat/Config/Theme.swift`, `Constants.swift`, `Color.swift` | None | `Packages/AgentUI/Sources/AgentUI/Primitives/` | Slice 8 (Primitives) | Extracted (Package owned, app bridged) | Liquid Glass modifiers, palette colors, spacing constants | Yes |
| `SwiftChat/Models/ChatModels.swift` (UI parts) | None | `Packages/AgentUI/Sources/AgentUI/Models/AgentUIModels.swift` | Slice 8 (Primitives) | Extracted (Package owned, app bridged) | MessageRole, MessageStatus, ContentPart presentation types | Yes (typealiases / adapters) |
| `SwiftChat/Views/MessageInputView.swift` | `ChatViewModel`, `SelectedModelMenu`, Pickers | `Packages/AgentUI/Sources/AgentUI/Composer/AgentComposerView.swift` | Slice 9 (Composer) | Extracted (Package owned, app bridged) | `RoundedRectangle(cornerRadius: 26)`, `.padding(.horizontal)`, `.buttonStyle(.glass)`, `.buttonBorderShape(.circle)`, mic and send geometries | Yes (`MessageInputView` adapter) |
| `swiftchat-overlay/Features/Composer/SelectedModelMenu.swift` | `ChatViewModel` / Composer driver | `Packages/AgentUI/Sources/AgentUI/Composer/SelectedModelMenu.swift` | Slice 9 (Composer) | Extracted (Package owned, app bridged) | Model button styling, menu hierarchy, icon placement | Yes (typealias / adapter) |
| `SwiftChat/Views/AttachmentPreviewBar.swift` | `AttachmentModels` | `Packages/AgentUI/Sources/AgentUI/Composer/AttachmentPreviewBar.swift` | Slice 9 (Composer) | Extracted (Package owned, app bridged) | Thumbnail sizes, delete badge, scroll geometry | Yes |
| `SwiftChat/Views/MessageView.swift` | `Message`, `LaTeXMarkdownView`, Bridges | `Packages/AgentUI/Sources/AgentUI/Message/AgentMessageView.swift` | Slice 10 (Messages) | Extracted (Package owned, app bridged) | `.frame(width: 32, height: 32)`, `HStack(spacing: 16)`, `.padding(.vertical, 8)`, footer Sources control, disclaimer text | Yes (`MessageView` adapter) |
| `SwiftChat/Views/LaTeXMarkdownView.swift` | `Textual`, `SwiftMath` | `Packages/AgentUI/Sources/AgentUI/Message/LaTeXMarkdownView.swift` | Slice 10 (Messages) | Extracted (Package owned, app bridged) | Textual / SwiftMath rendering, block styling, inline styling | Yes |
| `SwiftChat/Views/WebSearchBox.swift` | None | `Packages/AgentUI/Sources/AgentUI/Message/WebSearchBox.swift` | Slice 10 (Messages) | Extracted (Package owned, app bridged) | Search box background, query text, icon | Yes |
| `SwiftChat/Views/URLFetchBox.swift` | None | `Packages/AgentUI/Sources/AgentUI/Message/URLFetchBox.swift` | Slice 10 (Messages) | Extracted (Package owned, app bridged) | Fetch box styling, URL label, status spinner | Yes |
| `SwiftChat/Views/ChatListView.swift` | `MessageView`, ScrollViewReader | `Packages/AgentUI/Sources/AgentUI/Chat/AgentMessageListView.swift` | Slice 11 (ChatList) | Extracted (Package owned, app bridged) | ScrollToBottom button, auto-scroll behavior, list padding | Yes |
| `SwiftChat/Views/ChatSidebar.swift` | `ChatViewModel`, Conversations | `Packages/AgentUI/Sources/AgentUI/Sidebar/AgentChatSidebarView.swift` | Slice 11 (Sidebar) | Extracted (Package owned, app bridged) | Width = 300, iPad persistent / iPhone slide-over, toolbar toggle, drag thresholds | Yes |
| `SwiftChat/Views/ChatView.swift` | `ChatSidebar`, `ChatListView`, `MessageInputView` | `Packages/AgentUI/Sources/AgentUI/Chat/AgentChatView.swift` | Slice 12 (ChatShell) | Extracted (Package owned, app bridged) | Full layout composition, navigation bar, dark/light styling | Yes (`ChatView` forwards to `AgentChatView`) |

---

## Demo & Fixture Retention (Host Demo Only)
The following components remain owned exclusively by the demo application and are **NOT** packaged as production SDK APIs:
- `AgentActivityDemoDriver.swift`: Simulated activity event sequences for demo conversations.
- `ToolExecutionDemoStore.swift`: Seeded tool execution mock store.
- `ToolExecutionDemoBridge.swift`: Bridge hooking demo store into offline conversations.
- `ToolExecutionDemoViews.swift`: Mock tool result cards (e.g., GitHub PR #999 card, Weather card).
- Offline conversation seeding in `scripts/patch_swiftchat_full_demo.py`.
- Demo architecture diagram asset (`SwiftChat/Assets.xcassets/demo-architecture.imageset`).
