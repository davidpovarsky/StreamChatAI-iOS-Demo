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
- **Original Line Count**: 663 lines
- **Visual Dependencies**: `CustomTextEditor`, `AttachmentPreviewBar`, `SelectedModelMenu`, `CameraPickerView`, `DocumentPickerView`, Liquid Glass button style, `RoundedRectangle(cornerRadius: 26)`
- **App/Runtime Dependencies**: Decoupled via `AgentComposerDriving` protocol
- **Current Package Counterpart**: `Packages/AgentUI/Sources/AgentUI/Composer/AgentComposerView.swift` (691 lines)
- **Status**: **EXTRACTED - FULL PACKAGE OWNERSHIP**
- **Extraction Strategy**: Mechanically extracted complete `MessageInputView` into `Packages/AgentUI` as `AgentComposerView`.
- **Host Bridge**: `SwiftChat/Views/MessageInputView.swift` (23 lines) adapts `ChatViewModel` to `AgentComposerDriving` and renders `AgentComposerView`.
- **Visual Invariants**: Corner radius 26, iPad max width 600, editor min/default/max heights (36/120), pulse animation for mic recording, Send/Stop icon transition, + menu actions (Camera, Photos, Files, Web Search toggle).

---

### 9. MessageView (`SwiftChat/Views/MessageView.swift`)
- **Original Line Count**: 1859 lines
- **Visual Dependencies**: `LaTeXMarkdownView`, `WebSearchBox`, `URLFetchBox`, `MessageAttachmentIndicator`, `SourcesButton`/`SourcesSheetView`, `CollapsibleThinkingBox`, `AgentActivityTimelineBridge`, `ToolExecutionDemoBridge`, `InlineSectionSourcesView`, `SafeInlineImageMediaView`, `SafeInlineVideoMediaView`, `SafeInlineYouTubeMediaView`, `InlineLinkPreviewView`, `LoadingDotsView`, error banners, raw content modal
- **App/Runtime Dependencies**: Decoupled via `AgentMessageDriving` protocol and `AgentMessage` model
- **Current Package Counterpart**: `Packages/AgentUI/Sources/AgentUI/Message/AgentMessageView.swift` (1540 lines)
- **Status**: **EXTRACTED - FULL PACKAGE OWNERSHIP**
- **Extraction Strategy**: Mechanically extracted complete `MessageView` into `Packages/AgentUI` as `AgentMessageView` with all presentation sheets and leaf views.
- **Host Bridge**: `SwiftChat/Views/MessageView.swift` (33 lines) maps host `Message` to `AgentMessage` and renders `AgentMessageView`.
- **Visual Invariants**: 32x32 action buttons with 16pt spacing, user/assistant alignment, thinking disclosure box, section sources cluster, rich link previews, image/video/YouTube containers, disclaimer footer.

---

### 10. MessageTableView (`SwiftChat/Views/MessageTableView.swift`)
- **Original Line Count**: 715 lines
- **Visual Dependencies**: `UITableView`, `UITableViewCell`, `UIHostingController` wrapping `AgentMessageView`, scrolling indicators, keyboard offset calculations
- **App/Runtime Dependencies**: Decoupled via `AgentMessageDriving` protocol
- **Current Package Counterpart**: `Packages/AgentUI/Sources/AgentUI/Chat/AgentMessageTableView.swift` (887 lines)
- **Status**: **EXTRACTED - FULL PACKAGE OWNERSHIP**
- **Extraction Strategy**: Complete `UITableView`-backed `MessageTableView` extracted into `Packages/AgentUI` as `AgentMessageTableView` maintaining 120fps streaming performance and height caching.
- **Host Bridge**: `SwiftChat/Views/MessageTableView.swift` (52 lines) delegates directly to `AgentMessageTableView`.
- **Visual Invariants**: Message wrapper caching, row height caching, single-cell updates during streaming without reloading the whole table, scroll-to-user-message, scroll-to-bottom, keyboard show/hide inset handling.

---

### 11. ChatListView (`SwiftChat/Views/ChatListView.swift`)
- **Original Line Count**: 167 lines
- **Visual Dependencies**: `AgentMessageTableView`, `AgentComposerView`, scroll-to-bottom floating button (glass circle), keyboard observers
- **App/Runtime Dependencies**: Decoupled via `AgentMessageDriving` and `AgentComposerDriving`
- **Current Package Counterpart**: `Packages/AgentUI/Sources/AgentUI/Chat/AgentMessageListView.swift` (288 lines)
- **Status**: **EXTRACTED - FULL PACKAGE OWNERSHIP**
- **Extraction Strategy**: Extracted complete `ChatListView` orchestration into `Packages/AgentUI` as `AgentMessageListView`.
- **Host Bridge**: `SwiftChat/Views/ChatListView.swift` (55 lines) bridges to `AgentMessageListView`.
- **Visual Invariants**: Safe area bottom inset, iPad 600pt composer max width, scroll-to-bottom button visibility condition and animation, keyboard notification handling.

---

### 12. ChatSidebar (`SwiftChat/Views/ChatSidebar.swift`)
- **Original Line Count**: 172 lines
- **Visual Dependencies**: SwiftUI `List`, `ContentUnavailableView`, swipe actions (Rename, Delete), Alerts
- **App/Runtime Dependencies**: Decoupled via `AgentChatSessionDescriptor`
- **Current Package Counterpart**: `Packages/AgentUI/Sources/AgentUI/Sidebar/AgentChatSidebarView.swift` (210 lines)
- **Status**: **EXTRACTED - FULL PACKAGE OWNERSHIP**
- **Extraction Strategy**: Extracted exact `ChatSidebar` visual implementation into `Packages/AgentUI` as `AgentChatSidebarView`.
- **Host Bridge**: `SwiftChat/Views/ChatSidebar.swift` (55 lines) bridges host `Chat` models to `AgentChatSidebarView`.
- **Visual Invariants**: Search filter by title and message content, session list row appearance, delete alert message text, rename alert binding.

---

### 13. ChatView (`SwiftChat/Views/ChatView.swift`) / ChatContainer
- **Original Line Count**: 257 lines
- **Visual Dependencies**: `NavigationSplitView` with compact column fallback, custom toolbar items, `ImageViewerOverlay`, `AgentWelcomeView`, `MenuToXButton`
- **App/Runtime Dependencies**: Pure presentation shell hosting sidebar and detail content
- **Current Package Counterpart**: `Packages/AgentUI/Sources/AgentUI/Chat/AgentChatView.swift` (169 lines)
- **Status**: **EXTRACTED - FULL PACKAGE OWNERSHIP**
- **Extraction Strategy**: Extracted complete `ChatContainer` shell into `Packages/AgentUI` as `AgentChatView`.
- **Host Bridge**: `SwiftChat/Views/ChatView.swift` (118 lines) hosts `AgentChatView` wiring app-level image viewer and settings sheets.
- **Visual Invariants**: Compact column toggle behavior, "New Chat" toolbar and sidebar buttons, custom navigation bar appearance (transparent on iOS 26, opaque fallback), image viewer presentation.

---

## 14. Core UI Ownership Verification Summary

| Component | Package Path | Package Lines | App Bridge Path | App Bridge Lines | Reimplementation? | Sole Owner Verified |
| :--- | :--- | :---: | :--- | :---: | :---: | :---: |
| **Composer** | `Sources/AgentUI/Composer/AgentComposerView.swift` | 691 | `SwiftChat/Views/MessageInputView.swift` | 23 | **NO** | **YES** |
| **MessageView** | `Sources/AgentUI/Message/AgentMessageView.swift` | 1540 | `SwiftChat/Views/MessageView.swift` | 33 | **NO** | **YES** |
| **MessageTableView** | `Sources/AgentUI/Chat/AgentMessageTableView.swift` | 887 | `SwiftChat/Views/MessageTableView.swift` | 52 | **NO** | **YES** |
| **ChatListView** | `Sources/AgentUI/Chat/AgentMessageListView.swift` | 288 | `SwiftChat/Views/ChatListView.swift` | 55 | **NO** | **YES** |
| **ChatSidebar** | `Sources/AgentUI/Sidebar/AgentChatSidebarView.swift` | 210 | `SwiftChat/Views/ChatSidebar.swift` | 55 | **NO** | **YES** |
| **ChatShell** | `Sources/AgentUI/Chat/AgentChatView.swift` | 169 | `SwiftChat/Views/ChatView.swift` | 118 | **NO** | **YES** |

Total extracted package core lines: **3,785 lines** across the 6 major surfaces.
Total bridge code in host app: **336 lines** total across all 6 bridge files (all strictly under their respective limits).
Safe overlay patches: **9 clean patches** against the upstream golden baseline.
Frozen files preserved: `ContentView.swift`, `LaTeXMarkdownView.swift`, `WebSearchBox.swift`, `Color.swift`.
