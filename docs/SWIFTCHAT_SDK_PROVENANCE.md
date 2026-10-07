# SwiftChat SDK Source Provenance Record

This document records the exact provenance, upstream revision, adaptation type, and rationale for every component in `AgentChatSDK` derived from `sachaservan/SwiftChat` and the repository's `swiftchat-overlay`.

## Baseline References
- **Upstream Repository**: [https://github.com/sachaservan/SwiftChat](https://github.com/sachaservan/SwiftChat)
- **Pinned Upstream Commit**: `d6f54ccf9e84d2fec672b7b89d5a67dd6ee0f957` (`chore: update textual package`)
- **Repository Safe Overlay Commit**: `1667759e4a75604dd0fc3d8327b38b2c35102630` (`fix(swiftchat): use internal access level for tool presentation demo types`)
- **Patch Pipeline**: `scripts/patch_swiftchat_full_demo.py` + `scripts/upgrade_swiftchat_ui.py` + `scripts/apply_swiftchat_safe_overlay.py`

---

## Detailed File Provenance Log

| Target File in `AgentChatSDK` | Upstream / Overlay Source | Commit / Origin | Adaptation Type | Substantive Deviation Rationale |
|---|---|---|---|---|
| `AgentChatSwiftChat/Models/ChatModels.swift` | `upstream/SwiftChat/SwiftChat/Models/ChatModels.swift` | `d6f54cc` | Access-control adaptation | Made types (`Chat`, `Message`, `MessageRole`, `MessageContentPart`, `WebSearchSource`) `public` with `Sendable` conformity for cross-module usage. |
| `AgentChatSwiftChat/Models/AttachmentModels.swift` | `upstream/SwiftChat/SwiftChat/Models/AttachmentModels.swift` | `d6f54cc` | Access-control adaptation | `Attachment`, `AttachmentType` made public. |
| `AgentChatSwiftChat/Config/AppConfig.swift` | `upstream/SwiftChat/SwiftChat/Config/AppConfig.swift` | `d6f54cc` | Packaging adaptation | Replaced app-global singleton requirement with injectable configuration seam. |
| `AgentChatSwiftChat/Config/Constants.swift` | `upstream/SwiftChat/SwiftChat/Config/Constants.swift` | `d6f54cc` | Access-control adaptation | Constants exposed to package targets. |
| `AgentChatSwiftChat/Config/Theme.swift` | `upstream/SwiftChat/SwiftChat/Config/Theme.swift` | `d6f54cc` | Access-control adaptation | Color and layout themes exposed publicly. |
| `AgentChatSwiftChat/Extensions/Color+Extensions.swift` | `upstream/SwiftChat/SwiftChat/Extensions/Color.swift` & `Color+Hex.swift` | `d6f54cc` | Package consolidation | Combined color extension helpers into package resource-safe colors. |
| `AgentChatSwiftChat/Services/StreamingMarkdownChunker.swift` | `upstream/SwiftChat/SwiftChat/Services/StreamingMarkdownChunker.swift` | `d6f54cc` | Unchanged extraction | Streaming chunk token helper. |
| `AgentChatSwiftChat/Services/ThinkingSummaryService.swift` | `upstream/SwiftChat/SwiftChat/Services/ThinkingSummaryService.swift` | `d6f54cc` | Unchanged extraction | Reasoning text parser. |
| `AgentChatSwiftChat/Services/ThinkingTextChunker.swift` | `upstream/SwiftChat/SwiftChat/Services/ThinkingTextChunker.swift` | `d6f54cc` | Unchanged extraction | Incremental thinking token buffer. |
| `AgentChatSwiftChat/Views/LaTeXMarkdownView.swift` | `upstream/SwiftChat/SwiftChat/Views/LaTeXMarkdownView.swift` | `d6f54cc` | Access-control adaptation | Public initializer, preserved Textual and SwiftMath segment cache. |
| `AgentChatSwiftChat/Views/WebSearchBox.swift` | `upstream/SwiftChat/SwiftChat/Views/WebSearchBox.swift` | `d6f54cc` | Access-control adaptation | Preserved search indicator and source pill layout. |
| `AgentChatSwiftChat/Views/URLFetchBox.swift` | `upstream/SwiftChat/SwiftChat/Views/URLFetchBox.swift` | `d6f54cc` | Access-control adaptation | Preserved URL fetching indicator. |
| `AgentChatSwiftChat/Views/AttachmentPreviewBar.swift` | `upstream/SwiftChat/SwiftChat/Views/AttachmentPreviewBar.swift` | `d6f54cc` | Access-control adaptation | Preserved preview bar above composer. |
| `AgentChatSwiftChat/Views/MessageTableView.swift` | `upstream/SwiftChat/SwiftChat/Views/MessageTableView.swift` | `d6f54cc` | Access-control adaptation | Table list view wrapper. |
| `AgentChatSwiftChat/Views/ChatView.swift` | `upstream/SwiftChat/SwiftChat/Views/ChatView.swift` | `d6f54cc` | Package adaptation | Main container view adapted to be embeddable within host views. |
| `AgentChatSwiftChat/Views/MessageView.swift` | `upstream/SwiftChat/SwiftChat/Views/MessageView.swift` | `d6f54cc` + Overlay patches 001/004 | Overlay adaptation | Integrates `AgentActivityTimelineBridge`, `InlineSectionSourcesView`, `SafeInlineImageMediaView`, and `ToolExecutionDisclosure`. |
| `AgentChatSwiftChat/Views/MessageInputView.swift` | `upstream/SwiftChat/SwiftChat/Views/MessageInputView.swift` | `d6f54cc` + Overlay patch 002 | Overlay adaptation | Integrates `SelectedModelMenu` in '+' action button and maintains native dictation/audio. |
| `AgentChatSwiftChat/ViewModels/ChatViewModel.swift` | `upstream/SwiftChat/SwiftChat/ViewModels/ChatViewModel.swift` | `d6f54cc` + Overlay patch 003 | Package & Overlay adaptation | Core view model coordinating messaging, web search, reasoning state, and provider hooks. |
| `AgentChatActivity/*` | `swiftchat-overlay/Features/AgentActivity/*` | `1667759` | Direct overlay migration | AgentActivity models, store, timeline, rows, detail views, and demo drivers. |
| `AgentChatToolPresentation/*` | `swiftchat-overlay/Features/ToolPresentation/*` | `1667759` | Direct overlay migration | Tool inspection, disclosure cards, status indicators, and bridge stores. |
| `AgentChatSources/*` | `swiftchat-overlay/Features/SectionSources/*` | `1667759` | Direct overlay migration | Inline sources chips, cluster renderers, and sheet presentation. |
| `AgentChatRichMedia/*` | `swiftchat-overlay/Features/RichMedia/*` | `1667759` | Direct overlay migration + Additive add-ons | Proven inline image, video, and YouTube renderers + Kingfisher cache, SVGView, and Lottie animations. |
| `AgentChatComposerExtensions/*` | `swiftchat-overlay/Features/Composer/*` | `1667759` | Direct overlay migration + Additive add-ons | SelectedModelMenu + EmojiKit sheet. |
| `AgentChatVoice/*` | New additive module | Current | Provider abstraction | `AgentVoiceSessionProvider`, mock provider, and voice orb view. |
| `AgentChatVoiceLiveKit/*` | New additive module | Current | Provider implementation | LiveKit client session provider. |
| `AgentChatSDK/AgentChatSDK.swift` | New façade | Current | Public façade | Clean public entry point `AgentChatView(session:configuration:)`. |

---

## License & Compliance Notes
1. Upstream `sachaservan/SwiftChat` is licensed under the MIT License.
2. Overlay enhancements maintain compatible licensing.
3. All third-party library dependencies retain their respective open-source licenses as documented in `THIRD_PARTY_NOTICES.md`.
4. No proprietary assets or non-public code from ChatGPT have been incorporated.
