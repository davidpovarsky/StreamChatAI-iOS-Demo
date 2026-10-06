# Core Extraction Audit

## Executive Summary

This audit assesses all core visual views in the materialized SwiftChat full demo to guide the complete, lossless migration into `Packages/AgentUI`. Each component is evaluated for visual dependencies, runtime hooks, current package state, exact extraction strategy, host bridging, and immutable visual invariants.

---

## Component Audit Matrix

### 1. LaTeXMarkdownView (`SwiftChat/Views/LaTeXMarkdownView.swift`)
- **Line Count**: 1044 lines
- **Visual Dependencies**: `SwiftUI`, `Textual` (AST Markdown parser & renderer), `SwiftMath` (LaTeX math parser & MTMathUILabel / MTMathList), Color system
- **App/Runtime Dependencies**: None (pure presentation driven by `content: String`, `isDarkMode: Bool`, `isStreaming: Bool`)
- **Current Package Counterpart**: `Packages/AgentUI/Sources/AgentUI/Message/LaTeXMarkdownView.swift` (1044 lines)
- **Status**: Near-exact (diverges only in public declarations and initializer scope)
- **Extraction Strategy**: Align package implementation directly with materialized upstream file, exposing `public` initializers and structures while maintaining full code parity.
- **Host Bridge Required**: None; upstream can directly use `AgentUI.LaTeXMarkdownView` or retain a typealias.
- **Visual Invariants**: Exact regex for inline `\(...\)` and display `\[...\]` math, syntax highlighting tokens, custom table rendering, code block copy action.

---

### 2. WebSearchBox (`SwiftChat/Views/WebSearchBox.swift`)
- **Line Count**: 226 lines
- **Visual Dependencies**: `SwiftUI`, `FaviconView`, `SearchingDotsView`, `PulsingAnimation`, `NoHighlightButtonStyle`
- **App/Runtime Dependencies**: `WebSearchState`, `WebSearchSource`
- **Current Package Counterpart**: `Packages/AgentUI/Sources/AgentUI/Message/WebSearchBox.swift` (233 lines)
- **Status**: Near-exact (modularized `FaviconView` and helper styles)
- **Extraction Strategy**: Harmonize package version with upstream, ensuring all properties and visual states (searching, completed, failed) match exactly.
- **Host Bridge Required**: Upstream uses `AgentUI.WebSearchBox` via typealias or direct bridge.
- **Visual Invariants**: 16x16 favicon size, 3-dot pulse animation with staggered delays, rounded capsule styling, sources sheet presentation trigger.

---

### 3. URLFetchBox (`SwiftChat/Views/URLFetchBox.swift`)
- **Line Count**: 171 lines
- **Visual Dependencies**: `SwiftUI`, `FaviconView`
- **App/Runtime Dependencies**: `URLFetchState`
- **Current Package Counterpart**: `Packages/AgentUI/Sources/AgentUI/Message/URLFetchBox.swift` (179 lines)
- **Status**: Near-exact (public access control differences)
- **Extraction Strategy**: Keep package version synchronized with upstream.
- **Host Bridge Required**: Upstream uses `AgentUI.URLFetchBox`.
- **Visual Invariants**: Row layout, status badge colors, domain hostname resolution, tap-to-expand details.

---

### 4. MessageAttachmentIndicator (`SwiftChat/Views/MessageAttachmentIndicator.swift`)
- **Line Count**: 294 lines
- **Visual Dependencies**: `SwiftUI`, `UIKit` (UIImage)
- **App/Runtime Dependencies**: `Attachment` model, `ChatViewModel` (image viewer opening)
- **Current Package Counterpart**: `Packages/AgentUI/Sources/AgentUI/Message/MessageAttachmentIndicator.swift` (311 lines)
- **Status**: Near-exact (package uses clean closure `onSelectImage` instead of hard dependency on `SwiftChat.ChatViewModel`)
- **Extraction Strategy**: Maintain callback-driven decoupling in package while ensuring identical thumbnail rendering and layout.
- **Host Bridge Required**: Upstream bridges `ChatViewModel.showImageViewer` via `onSelectImage` closure.
- **Visual Invariants**: 80x80 thumbnail sizing, 3-column grid for multi-image attachments, document extension badges (PDF, TXT, MD, CSV, HTML).

---

### 5. AttachmentPreviewBar (`SwiftChat/Views/AttachmentPreviewBar.swift`)
- **Line Count**: 132 lines
- **Visual Dependencies**: `SwiftUI`, `UIKit` (UIImage)
- **App/Runtime Dependencies**: `Attachment` model, removal callback
- **Current Package Counterpart**: `Packages/AgentUI/Sources/AgentUI/Composer/AttachmentPreviewBar.swift` (152 lines)
- **Status**: Near-exact
- **Extraction Strategy**: Keep public component in package with exact geometry.
- **Host Bridge Required**: Direct consumption by composer.
- **Visual Invariants**: Horizontal scroll row, 60x60 thumbnail with remove button overlay at top-trailing corner.

---

### 6. CameraPickerView (`SwiftChat/Views/CameraPickerView.swift`)
- **Line Count**: 50 lines
- **Visual Dependencies**: `UIViewControllerRepresentable` wrapping `UIImagePickerController` (.camera)
- **App/Runtime Dependencies**: `(UIImage) -> Void` callback
- **Current Package Counterpart**: `Packages/AgentUI/Sources/AgentUI/Composer/CameraPickerView.swift` (52 lines)
- **Status**: Exact
- **Extraction Strategy**: Retain in package with public initializer.
- **Host Bridge Required**: Direct consumption.
- **Visual Invariants**: Standard camera modal presentation and dismissal.

---

### 7. DocumentPickerView (`SwiftChat/Views/DocumentPickerView.swift`)
- **Line Count**: 69 lines
- **Visual Dependencies**: `UIViewControllerRepresentable` wrapping `UIDocumentPickerViewController`
- **App/Runtime Dependencies**: `(URL, String) -> Void` callback
- **Current Package Counterpart**: `Packages/AgentUI/Sources/AgentUI/Composer/DocumentPickerView.swift` (73 lines)
- **Status**: Exact
- **Extraction Strategy**: Retain in package with public initializer.
- **Host Bridge Required**: Direct consumption.
- **Visual Invariants**: UTType filtering for PDF, plain text, markdown, CSV, and HTML.

---

### 8. MessageInputView (`SwiftChat/Views/MessageInputView.swift`)
- **Line Count**: 663 lines
- **Visual Dependencies**: `CustomTextEditor`, `AttachmentPreviewBar`, `SelectedModelMenu`, `CameraPickerView`, `DocumentPickerView`, Liquid Glass button style, `RoundedRectangle(cornerRadius: 26)`
- **App/Runtime Dependencies**: `ChatViewModel` (text binding, attachments, model switching, web search toggle, audio recording, message sending, streaming cancellation)
- **Current Package Counterpart**: `Packages/AgentUI/Sources/AgentUI/Composer/AgentComposerView.swift` (510 lines)
- **Status**: **PROVISIONAL / DIVERGENT** (Current package composer is simplified and missing exact layout branches)
- **Extraction Strategy**: Mechanically extract the complete 663-line materialized `MessageInputView` into `Packages/AgentUI` as the definitive `AgentComposerView`. Define comprehensive `AgentComposerDriving` protocol exposing all required driver actions.
- **Host Bridge Required**: `SwiftChat/Views/MessageInputView.swift` becomes a thin bridge adapting `ChatViewModel` to `AgentComposerDriving` and rendering `AgentComposerView`.
- **Visual Invariants**: Corner radius 26, iPad max width 600, editor min/default/max heights (36/120), pulse animation for mic recording, Send/Stop icon transition, + menu actions (Camera, Photos, Files, Web Search toggle).

---

### 9. MessageView (`SwiftChat/Views/MessageView.swift`)
- **Line Count**: 1859 lines
- **Visual Dependencies**: `LaTeXMarkdownView`, `WebSearchBox`, `URLFetchBox`, `MessageAttachmentIndicator`, `SourcesButton`/`SourcesSheetView`, `CollapsibleThinkingBox`, `AgentActivityTimelineBridge`, `ToolExecutionDemoBridge`, `InlineSectionSourcesView`, `SafeInlineImageMediaView`, `SafeInlineVideoMediaView`, `SafeInlineYouTubeMediaView`, `InlineLinkPreviewView`, `LoadingDotsView`, error banners, raw content modal
- **App/Runtime Dependencies**: `Message`, `ChatViewModel` (regenerate, thinking summary, sheets)
- **Current Package Counterpart**: `Packages/AgentUI/Sources/AgentUI/Message/AgentMessageView.swift` (421 lines)
- **Status**: **PROVISIONAL / DIVERGENT** (Current package message view is only 421 lines, has `EmptyView` for link previews, and lacks full sheets and states)
- **Extraction Strategy**: Mechanically extract the full 1859-line materialized `MessageView` into `Packages/AgentUI` as `AgentMessageView`. Ensure package models losslessly support all message fields. Wire leaf components (`ToolPresentation`, `AgentActivity`, `SectionSources`, `RichMedia`).
- **Host Bridge Required**: Upstream `SwiftChat/Views/MessageView.swift` becomes a thin bridge adapting host `Message` and `ChatViewModel` to `AgentMessageView`.
- **Visual Invariants**: 32x32 action buttons with 16pt spacing, user/assistant alignment, thinking disclosure box, section sources cluster, rich link previews, image/video/YouTube containers, disclaimer footer.

---

### 10. MessageTableView (`SwiftChat/Views/MessageTableView.swift`)
- **Line Count**: 715 lines
- **Visual Dependencies**: `UITableView`, `UITableViewCell`, `UIHostingController` wrapping `MessageView`, scrolling indicators, keyboard offset calculations
- **App/Runtime Dependencies**: `ChatViewModel` (messages array, currentChat ID, `isScrollInteractionActive`)
- **Current Package Counterpart**: **MISSING** (Package currently uses `ScrollView` + `LazyVStack` which breaks streaming performance and height caching)
- **Status**: **PROVISIONAL / MISSING IN PACKAGE**
- **Extraction Strategy**: Extract the full 715-line `UITableView`-backed `MessageTableView` into `Packages/AgentUI` as `AgentMessageTableView`. Use driver protocol `AgentMessageTableDriving`.
- **Host Bridge Required**: Upstream `MessageTableView` becomes a thin bridge forwarding to `AgentMessageTableView`.
- **Visual Invariants**: Message wrapper caching, row height caching, single-cell updates during streaming without reloading the whole table, scroll-to-user-message, scroll-to-bottom, keyboard show/hide inset handling.

---

### 11. ChatListView (`SwiftChat/Views/ChatListView.swift`)
- **Line Count**: 167 lines
- **Visual Dependencies**: `MessageTableView`, `MessageInputView`, scroll-to-bottom floating button (glass circle), keyboard observers
- **App/Runtime Dependencies**: `ChatViewModel`, `SettingsManager`
- **Current Package Counterpart**: `Packages/AgentUI/Sources/AgentUI/Chat/AgentMessageListView.swift` (92 lines)
- **Status**: **PROVISIONAL / DIVERGENT**
- **Extraction Strategy**: Extract the complete `ChatListView` orchestration into `Packages/AgentUI` as `AgentMessageListView` (backed by `AgentMessageTableView` and `AgentComposerView`).
- **Host Bridge Required**: Upstream `ChatListView` bridges to `AgentMessageListView`.
- **Visual Invariants**: Safe area bottom inset, iPad 600pt composer max width, scroll-to-bottom button visibility condition and animation, keyboard notification handling.

---

### 12. ChatSidebar (`SwiftChat/Views/ChatSidebar.swift`)
- **Line Count**: 172 lines
- **Visual Dependencies**: SwiftUI `List`, `ContentUnavailableView`, swipe actions (Rename, Delete), Alerts
- **App/Runtime Dependencies**: `ChatViewModel` (`chats`, `currentChat`, `selectChat`, `deleteChat`, `updateChatTitle`, `createNewChat`)
- **Current Package Counterpart**: `Packages/AgentUI/Sources/AgentUI/Sidebar/AgentChatSidebarView.swift` (193 lines)
- **Status**: **PROVISIONAL / DIVERGENT**
- **Extraction Strategy**: Extract the exact `ChatSidebar` visual implementation into `Packages/AgentUI` as `AgentChatSidebarView` driven by `AgentSidebarDriving`.
- **Host Bridge Required**: Upstream `ChatSidebar` delegates to `AgentChatSidebarView`.
- **Visual Invariants**: Search filter by title and message content, session list row appearance, delete alert message text, rename alert binding.

---

### 13. ChatView (`SwiftChat/Views/ChatView.swift`) / ChatContainer
- **Line Count**: 257 lines
- **Visual Dependencies**: `NavigationSplitView` with compact column fallback, custom toolbar items, `ImageViewerOverlay`, `WelcomeView`, `MenuToXButton`
- **App/Runtime Dependencies**: `ChatViewModel`, `SettingsManager`
- **Current Package Counterpart**: `Packages/AgentUI/Sources/AgentUI/Chat/AgentChatView.swift` (81 lines)
- **Status**: **PROVISIONAL / DIVERGENT**
- **Extraction Strategy**: Move the complete materialized `ChatContainer` and helper types into `Packages/AgentUI` as `AgentChatView`. Preserve navigation column management, toolbar item placement, and appearance setup.
- **Host Bridge Required**: Upstream `ContentView` and `ChatView` delegate to `AgentChatView`.
- **Visual Invariants**: Compact column toggle behavior, "New Chat" toolbar and sidebar buttons, custom navigation bar appearance (transparent on iOS 26, opaque fallback), image viewer presentation.
