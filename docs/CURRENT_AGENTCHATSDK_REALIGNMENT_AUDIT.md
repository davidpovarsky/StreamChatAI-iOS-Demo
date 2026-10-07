# Current AgentChatSDK Realignment Audit

## Executive Summary

Commit `2930e0d3b1d63306dda9e09b83b079105544a31f` introduced an independent `Packages/AgentChatSDK` implementation that inadvertently duplicated the chat user interface and domain models rather than packaging the approved `sachaservan/SwiftChat` experience and existing `swiftchat-overlay` capabilities.

This audit classifies every source file currently in `Packages/AgentChatSDK` into one of four mandatory categories:
1. **DELETE / RETIRE**: Duplicates or conflicts with existing SwiftChat or overlay features.
2. **MIGRATE**: Contains useful functionality that must be extracted, aligned with, or moved into the SwiftChat-derived SDK modules.
3. **KEEP AS ADAPTER**: Provider-facing or library-facing glue that does not recreate UI and bridges host runtimes cleanly.
4. **REQUIRES USER APPROVAL**: Candidates that would replace working SwiftChat subsystems (such as syntax highlighting, LaTeX rendering, or markdown parsing).

---

## File-by-File Classification Matrix

| Path | Current Role | Target Classification | Realignment Action & Destination |
|---|---|---|---|
| `Package.swift` | Root package definition with competing targets | **MIGRATE** | Restructure targets into SwiftChat-derived architecture: `AgentChatSDK`, `AgentChatSwiftChat`, `AgentChatActivity`, `AgentChatToolPresentation`, `AgentChatSources`, `AgentChatRichMedia`, `AgentChatComposerExtensions`, `AgentChatVoice`, `AgentChatVoiceLiveKit`. |
| `Sources/AgentChatUI/AgentChatView.swift` | Independently written `ScrollView` + `LazyVStack` chat view | **DELETE / RETIRE** | Retire independent UI. The public `AgentChatView` will be the façade hosting the packaged SwiftChat-derived `ChatView`. |
| `Sources/AgentChatUI/AgentComposerView.swift` | Custom composer recreating text field, action buttons | **DELETE / RETIRE** | Retire in favor of selected SwiftChat `MessageInputView` preserved from golden baseline. |
| `Sources/AgentChatUI/AgentMessageRowView.swift` | Custom message row recreating avatars, bubble, layout | **DELETE / RETIRE** | Retire in favor of selected SwiftChat `MessageView` + overlay bridges. |
| `Sources/AgentChatUI/AgentEmojiPicker.swift` | Emoji sheet using EmojiKit | **MIGRATE** | Move into `AgentChatComposerExtensions` and attach as an additive option in SwiftChat's '+' action menu. |
| `Sources/AgentChatUI/AgentLottieView.swift` | Lottie vector animation wrapper | **MIGRATE** | Move into `AgentChatRichMedia` as `AgentLottieMediaView` for rich result animations (reduced-motion safe). |
| `Sources/AgentChatUI/AgentSelectedModelMenu.swift` | Re-implementation of overlay model selector | **MIGRATE** | Align with `swiftchat-overlay/Features/Composer/SelectedModelMenu.swift` in `AgentChatComposerExtensions`. |
| `Sources/AgentChatRendering/AgentMarkdownParser.swift` | Parallel custom regex markdown parser | **DELETE / RETIRE** | Recreates SwiftChat's `LaTeXMarkdownView` / `Textual` pipeline. Retire from canonical path. |
| `Sources/AgentChatRendering/AgentMarkdownView.swift` | Custom AST-based markdown view | **DELETE / RETIRE** | Recreates SwiftChat's `LaTeXMarkdownView`. Canonical rendering stays on SwiftChat + Textual. |
| `Sources/AgentChatRendering/AgentCodeBlockView.swift` | Highlightr-based code block view | **REQUIRES USER APPROVAL** | Candidate replacement for Textual code formatting. Gated under Decision Gate per Section 9.1. |
| `Sources/AgentChatRendering/AgentMathView.swift` | iosMath-based `MTMathUILabel` LaTeX view | **REQUIRES USER APPROVAL** | Candidate replacement for SwiftMath. Gated under Decision Gate per Section 9.2. |
| `Sources/AgentChatRendering/AgentSVGView.swift` | SVGView-backed inline SVG renderer | **MIGRATE** | Migrate into `AgentChatRichMedia` as `InlineSVGMediaView` to provide additive SVG rendering in chat parts. |
| `Sources/AgentChatRendering/AgentTextSelectionHelper.swift` | STTextKitPlus selection helper | **REQUIRES USER APPROVAL** | Candidate text interaction helper. Gated under Decision Gate per Section 9.5. |
| `Sources/AgentChatRendering/InlineSectionSourcesView.swift` | Re-implementation of sources renderer | **MIGRATE** | Consolidate with overlay `InlineSectionSourcesView.swift` into `AgentChatSources`. |
| `Sources/AgentChatRendering/SectionSourcesPresentation.swift` | Re-implementation of source presentation models | **MIGRATE** | Consolidate with overlay `SectionSourcesPresentation.swift` into `AgentChatSources`. |
| `Sources/AgentChatActivity/AgentActivityDemoDriver.swift` | Overlay demo driver | **MIGRATE** | Migrate directly into `AgentChatActivity`, preserving overlay provenance. |
| `Sources/AgentChatActivity/AgentActivityDetailViews.swift` | Activity detail sheet views | **MIGRATE** | Migrate directly into `AgentChatActivity`, preserving overlay provenance. |
| `Sources/AgentChatActivity/AgentActivityRowView.swift` | Activity row UI component | **MIGRATE** | Migrate directly into `AgentChatActivity`, preserving overlay provenance. |
| `Sources/AgentChatActivity/AgentActivityStore.swift` | Activity event store | **MIGRATE** | Migrate directly into `AgentChatActivity`, preserving overlay provenance. |
| `Sources/AgentChatActivity/AgentActivityTimelineView.swift` | Activity timeline bar/cards | **MIGRATE** | Migrate directly into `AgentChatActivity`, preserving overlay provenance. |
| `Sources/AgentChatRichResults/ToolCallInspection.swift` | Tool call inspection model | **MIGRATE** | Migrate to `AgentChatToolPresentation`, aligning with overlay. |
| `Sources/AgentChatRichResults/ToolCallInspectionView.swift` | Tool inspection sheet | **MIGRATE** | Migrate to `AgentChatToolPresentation`, aligning with overlay. |
| `Sources/AgentChatRichResults/ToolExecutionDisclosure.swift` | Tool disclosure card | **MIGRATE** | Migrate to `AgentChatToolPresentation`, aligning with overlay. |
| `Sources/AgentChatRichResults/AgentRichResultView.swift` | Custom tool renderer host | **MIGRATE** | Move to `AgentChatRichMedia` as additive custom result container. |
| `Sources/AgentChatRichResults/AgentToolRendererRegistry.swift` | Extensible registry for host tool result UI | **KEEP AS ADAPTER** | Keep in `AgentChatToolPresentation` for host runtime extensibility. |
| `Sources/AgentChatMedia/AgentRemoteImageView.swift` | Kingfisher image loader wrapper | **MIGRATE** | Migrate to `AgentChatRichMedia` to back `SafeInlineImageMediaView` with caching and retry states. |
| `Sources/AgentChatMedia/AgentVideoMediaView.swift` | Video player view | **MIGRATE** | Consolidate with overlay `InlineVideoMediaView` in `AgentChatRichMedia`. |
| `Sources/AgentChatVoice/AgentMockVoiceProvider.swift` | Deterministic voice simulation | **KEEP AS ADAPTER** | Keep in `AgentChatVoice` for offline testing and demo without credentials. |
| `Sources/AgentChatVoice/AgentVoiceOrbView.swift` | Voice animation orb view | **MIGRATE** | Move into `AgentChatVoice` for voice interaction mode. |
| `Sources/AgentChatVoiceLiveKit/LiveKitVoiceSessionProvider.swift` | LiveKit WebRTC session provider | **KEEP AS ADAPTER** | Keep in optional `AgentChatVoiceLiveKit` module. |
| `Sources/AgentChatCore/AgentModels.swift` | Competing message, chat, and role models | **DELETE / RETIRE** | Competing models retired. SwiftChat's `Message`, `Chat`, and `MessageContentPart` are the canonical models. |
| `Sources/AgentChatCore/AgentContracts.swift` | Provider protocols for runtime integration | **KEEP AS ADAPTER** | Keep and refine in `AgentChatCore` to bridge host AI backends (such as Hanlin) into SwiftChat. |
| `Sources/AgentChatCore/AgentChatSession.swift` | Competing session object | **MIGRATE** | Adapt into a coordinator bridging `ChatViewModel`, stores, and `AgentChatRuntimeProvider`. |
| `Sources/AgentChatCore/AgentConfiguration.swift` | Feature configuration structure | **MIGRATE** | Keep in `AgentChatCore` to configure SDK feature toggles and appearance safely. |
| `Sources/AgentChatCore/AgentActivityEvents.swift` | Raw activity event DTOs | **MIGRATE** | Keep in `AgentChatActivity` as clean event input types. |
| `Sources/AgentChatIntegrations/DeterministicDemoDriver.swift` | Offline demo driver | **MIGRATE** | Update to drive SwiftChat's canonical `ChatViewModel` and overlay stores directly. |
| `Sources/AgentChatIntegrations/StreamChatAIAdapter.swift` | Comparison adapter for StreamChatAI | **KEEP AS ADAPTER** | Preserve as optional comparison adapter. |
| `Sources/AgentChatSDK/AgentChatSDK.swift` | Public façade entry point | **MIGRATE** | Re-export canonical SwiftChat UI and configuration types. |
| `Tests/AgentChatSDKTests/AgentChatSDKTests.swift` | Unit tests | **MIGRATE** | Expand to test real SwiftChat-derived UI, overlay components, and additive libraries. |

---

## Summary of Realignment Plan

1. **Retire Competing Primary UI**:
   - `AgentChatView.swift` (handwritten version)
   - `AgentComposerView.swift`
   - `AgentMessageRowView.swift`
   - `AgentMarkdownView.swift` & `AgentMarkdownParser.swift`
   - Competing `AgentMessage` / `AgentSession` models.
2. **Promote SwiftChat Core**:
   Extract SwiftChat's views, models, and view model into `AgentChatSwiftChat`.
3. **Migrate Proven Overlay Modules**:
   Consolidate `swiftchat-overlay` features (`AgentActivity`, `ToolPresentation`, `SectionSources`, `RichMedia`, `SelectedModelMenu`) directly into the SDK package targets.
4. **Integrate Approved Additive Libraries (Category A)**:
   - Kingfisher (caching behind `AgentChatRichMedia`)
   - SVGView (inline vector rendering)
   - Lottie (micro-animations)
   - Pow (subtle spring/transition feedback)
   - EmojiKit (composer '+' popover extension)
   - swift-async-algorithms & swift-collections (event debouncing and ring buffers)
   - LiveKit (optional realtime voice module)
5. **Gate Replacement Candidates (Category B)**:
   Highlightr, iosMath, swift-markdown, STTextKitPlus, Motion require explicit user decision before replacing any SwiftChat baseline.
