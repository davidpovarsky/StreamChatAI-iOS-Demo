# SwiftChat Overlay to AgentChatSDK Migration Map (Realigned)

This document records the exact mechanical extraction and mapping of `swiftchat-overlay` components into the modular `AgentChatSDK` Swift Package targets.

---

## 1. Component Mapping Table

| Legacy Overlay File in `swiftchat-overlay/` | Target SPM Module in `Packages/AgentChatSDK/` | New Realigned File & Type | Enhancements / Integration |
|---|---|---|---|
| `Features/AgentActivity/AgentActivityModels.swift` | `AgentChatActivity` | `AgentActivityModels.swift` (`AgentActivityItem`, `AgentActivitySession`, `AgentActivityStepKind`) | Sendable, Codable, decoupled from app-specific state. |
| `Features/AgentActivity/AgentActivityStore.swift` | `AgentChatActivity` | `AgentActivityStore.swift` (`AgentActivityStore`) | ObservableObject store managing active sessions and step transitions. |
| `Features/AgentActivity/AgentActivityRowView.swift` | `AgentChatActivity` | `AgentActivityRowView.swift` (`AgentActivityRowView`) | Dynamic Type accessible row view for timeline entries. |
| `Features/AgentActivity/AgentActivityTimelineView.swift` | `AgentChatActivity` | `AgentActivityTimelineView.swift` (`AgentActivityTimelineView`, `AgentActivityTimelineBridge`) | Expandable reasoning disclosure with elapsed time chip. |
| `Features/AgentActivity/AgentActivityDetailViews.swift` | `AgentChatActivity` | `AgentActivityDetailViews.swift` (`AgentActivityDetailSheet`, `FaviconView`) | Inspection sheets for activity steps and argument payloads. |
| `Features/AgentActivity/AgentActivityDemoDriver.swift` | `AgentChatActivity` | `AgentActivityDemoDriver.swift` (`AgentActivityDemoDriver`) | Deterministic mock activity generator for previews and testing. |
| `Features/ToolPresentation/ToolExecutionDisclosure.swift` | `AgentChatToolPresentation` | `ToolExecutionDisclosure.swift` (`ToolExecutionDisclosure`, `LiquidGlassStyle`) | Adaptive tool card with iOS 26 liquid glass / iOS 17 material fallback. |
| `Features/ToolPresentation/ToolCallInspection.swift` | `AgentChatToolPresentation` | `ToolCallInspection.swift` (`ToolCallInspection`, `ToolExecutionStatus`) | Sendable inspection models with formatted payload representations. |
| `Features/ToolPresentation/ToolCallInspectionView.swift` | `AgentChatToolPresentation` | `ToolCallInspectionView.swift` (`ToolCallInspectionView`) | Expandable arguments, duration, status, and payload clipboard copy. |
| `Features/ToolPresentation/AgentToolRendererRegistry.swift` | `AgentChatToolPresentation` | `AgentToolRendererRegistry.swift` (`AgentToolRendererRegistry`) | Pluggable renderer registry for domain-specific tool cards. |
| `Features/SectionSources/SectionSourcesPresentation.swift` | `AgentChatSources` | `SectionSourcesPresentation.swift` (`SectionSourcesPresentation`) | Citation extraction decomposing text body from trailing source clusters. |
| `Features/SectionSources/InlineSectionSourcesView.swift` | `AgentChatSources` | `InlineSectionSourcesView.swift` (`InlineSectionSourcesView`, `SourcesSheetView`) | Citation pill clusters with favicon icons and modal source sheets. |
| `Features/RichMedia/InlineImageMediaView.swift` | `AgentChatRichMedia` | `SafeInlineImageMediaView.swift` (`SafeInlineImageMediaView`) | Upgraded with Kingfisher image caching while retaining existing interface and graceful fallback. |
| `Features/RichMedia/InlineVideoMediaView.swift` | `AgentChatRichMedia` | `SafeInlineVideoMediaView.swift` (`SafeInlineVideoMediaView`) | Video thumbnail preview card with native playback launch. |
| `Features/RichMedia/InlineYouTubeMediaView.swift` | `AgentChatRichMedia` | `SafeInlineYouTubeMediaView.swift` (`SafeInlineYouTubeMediaView`) | YouTube thumbnail card with red play badge and external deep linking. |
| `Features/RichMedia/RichMediaFallbackView.swift` | `AgentChatRichMedia` | `RichMediaFallbackView.swift` (`RichMediaFallbackView`) | Defensive fallback card for failed or missing multimedia items. |
| `Features/Composer/SelectedModelMenu.swift` | `AgentChatComposerExtensions` | `SelectedModelMenu.swift` (`SelectedModelMenu`) | Reusable capsule model picker menu supporting dynamic models. |

---

## 2. Additive Feature Enhancements (ChatGPT Stack)

In addition to the direct mechanical extraction of overlay features, `AgentChatSDK` introduces safe additive modules:

| New Component | Target Module | Backing Library | Description |
|---|---|---|---|
| `InlineSVGMediaView` | `AgentChatRichMedia` | `SVGView` | Renders vector graphics when a `MessageContentPart` contains SVG XML. |
| `AgentLottieMediaView` | `AgentChatRichMedia` | `Lottie` + `Pow` | Optional vector micro-animations respecting Reduce Motion. |
| `AgentEmojiPicker` | `AgentChatComposerExtensions` | `EmojiKit` | Additive emoji selection sheet accessed via composer '+' menu. |
| `AgentVoiceOrbView` | `AgentChatVoice` | Native SwiftUI | Glowing reactive orb visualizer for voice interactions. |
| `LiveKitVoiceSessionProvider` | `AgentChatVoiceLiveKit` | `client-sdk-swift` | WebRTC transport provider isolated in dedicated package target. |
| `AsyncEventBuffer` | `AgentChatCore` | `swift-collections` & `swift-async-algorithms` | FIFO streaming buffer and async pipeline for timeline events. |

---

## 3. Preserved Upstream SwiftChat Components

All core chat UI, layout, and rendering engines remain faithful to `sachaservan/SwiftChat`:
- `ChatContainer`, `ChatView`, `ChatViewModel` -> `AgentChatSwiftChat`
- `MessageView`, `MessageInputView`, `AttachmentPreviewBar` -> `AgentChatSwiftChat`
- `LaTeXMarkdownView`, `WebSearchBox`, `URLFetchBox` -> `AgentChatSwiftChat`
- Text formatting powered by `Textual` (`StructuredText`) and LaTeX powered by `SwiftMath`.

The overlay patch scripts (`scripts/apply_swiftchat_safe_overlay.py` and `scripts/verify_swiftchat_safe_overlay.py`) remain functional and verified at commit `b9d2cc0` for standalone upstream workflows.
