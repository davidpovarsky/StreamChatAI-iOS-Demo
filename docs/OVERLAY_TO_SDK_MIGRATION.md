# SwiftChat Overlay to AgentChatSDK Migration Map

This document records the migration of legacy `swiftchat-overlay` components into the reusable `AgentChatSDK` Swift Package structure.

## 1. Component Mapping Table

| Legacy Overlay File | Target SDK Module | New Component | Notes / Upgrades |
|---|---|---|---|
| `swiftchat-overlay/Features/AgentActivity/AgentActivityModels.swift` | `AgentChatCore` | `AgentActivityModels.swift`, `AgentActivityEvents.swift` | Upgraded into Sendable public structs (`AgentActivityItem`, `AgentActivitySession`, `AgentActivityEvent`). |
| `swiftchat-overlay/Features/AgentActivity/AgentActivityStore.swift` | `AgentChatActivity` | `AgentActivityStore.swift` | Decoupled from SwiftChat view models; uses `AgentChatCore` domain types. |
| `swiftchat-overlay/Features/AgentActivity/AgentActivityRowView.swift` | `AgentChatActivity` | `AgentActivityRowView.swift` | Uses public `AgentActivityItem` and dynamic type scaling. |
| `swiftchat-overlay/Features/AgentActivity/AgentActivityTimelineView.swift` | `AgentChatActivity` | `AgentActivityTimelineView.swift` | Reusable SwiftUI view with expand/collapse and elapsed time chips. |
| `swiftchat-overlay/Features/AgentActivity/AgentActivityDetailViews.swift` | `AgentChatActivity` | `AgentActivityDetailViews.swift` | Modal inspection sheets for step summaries, arguments, and sources. |
| `swiftchat-overlay/Features/AgentActivity/AgentActivityDemoDriver.swift` | `AgentChatActivity` & `AgentChatIntegrations` | `AgentActivityDemoDriver.swift`, `DeterministicDemoDriver.swift` | Provides deterministic scenario runners for web research and tool execution. |
| `swiftchat-overlay/Features/ToolPresentation/ToolExecutionDisclosure.swift` | `AgentChatRichResults` | `ToolExecutionDisclosure.swift` | Liquid Glass disclosure container with `#available(iOS 26.0, *)` and ultra-thin material fallback. |
| `swiftchat-overlay/Features/ToolPresentation/ToolCallInspection.swift` | `AgentChatRichResults` | `ToolCallInspection.swift` | Decoupled from app-specific models into clean Sendable inspection payload. |
| `swiftchat-overlay/Features/ToolPresentation/ToolCallInspectionView.swift` | `AgentChatRichResults` | `ToolCallInspectionView.swift` | Expandable arguments, duration, and output inspection with copy actions. |
| `swiftchat-overlay/Features/ToolPresentation/ToolExecutionStatus.swift` | `AgentChatRichResults` | `ToolCallInspection.swift` (`ToolExecutionStatus`) | Standardized execution status enum (.running, .completed, .failed). |
| `swiftchat-overlay/Features/SectionSources/SectionSourcesPresentation.swift` | `AgentChatRendering` | `SectionSourcesPresentation.swift` | Decomposes markdown text from trailing citation paragraphs. |
| `swiftchat-overlay/Features/SectionSources/InlineSectionSourcesView.swift` | `AgentChatRendering` | `InlineSectionSourcesView.swift` | Reusable source chips with favicon badges and `SourcesSheetView`. |
| `swiftchat-overlay/Features/RichMedia/InlineImageMediaView.swift` | `AgentChatMedia` | `AgentRemoteImageView.swift` | Powered by `Kingfisher` with placeholders, caching, and `AgentImagePreviewSheet`. |
| `swiftchat-overlay/Features/RichMedia/InlineVideoMediaView.swift` | `AgentChatMedia` | `AgentVideoMediaView.swift` | Native video player thumbnail view with external open fallback. |
| `swiftchat-overlay/Features/RichMedia/InlineYouTubeMediaView.swift` | `AgentChatMedia` | `AgentVideoMediaView.swift` (`AgentYouTubeMediaView`) | YouTube player card with red play badge and external deep link. |
| `swiftchat-overlay/Features/RichMedia/RichMediaFallbackView.swift` | `AgentChatMedia` | `AgentMediaFallbackView.swift` | Graceful fallback card for missing or errored media. |
| `swiftchat-overlay/Features/Composer/SelectedModelMenu.swift` | `AgentChatUI` | `AgentSelectedModelMenu.swift` | Reusable model selector capsule driven by `AgentComposerConfiguration`. |

---

## 2. Legacy Patch Scripts Status

The scripts in `scripts/`:
- `scripts/apply_swiftchat_safe_overlay.py`
- `scripts/verify_swiftchat_safe_overlay.py`
- `scripts/patch_swiftchat_full_demo.py`
- `scripts/upgrade_swiftchat_ui.py`

are preserved intact for backward compatibility with the existing SwiftChat showcase CI job.

**Standard consumers of `AgentChatSDK` do NOT require any patch scripts.** Another iOS app can import the package directly via Swift Package Manager and instantiate `AgentChatView(session: session)`.
