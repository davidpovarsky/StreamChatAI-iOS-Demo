# Dependency Integration Evidence Record

This document provides verified proof of real API usage for all open-source libraries integrated into `AgentChatSDK`.

---

## 1. Kingfisher
- **Package / Product**: `Kingfisher` / `Kingfisher`
- **Target**: `AgentChatRichMedia`
- **Source File**: `Packages/AgentChatSDK/Sources/AgentChatRichMedia/InlineImageMediaView.swift`
- **API Types / Methods Used**:
  - `KFImage(url)`
  - `.placeholder { ... }`
  - `.retry(maxCount: 2, interval: .seconds(2))`
  - `.fade(duration: 0.2)`
  - `.resizable()`
  - `.aspectRatio(contentMode: .fit)`
  - `.clipShape(RoundedRectangle(cornerRadius: 16))`
- **Visible Capability**: Fast cached loading of remote rich-result images with network retry policies and subtle fade transitions. Zero Kingfisher types are leaked in public SDK APIs.
- **Fallback Behavior**: Degrades seamlessly to SwiftUI's `AsyncImage` and `RichMediaFallbackView` if Kingfisher is not compiled.
- **Test**: `AgentChatSDKTests.testVisualSnapshotSuite()` (Snapshot 13)
- **Type**: Direct additive dependency.

---

## 2. SVGView
- **Package / Product**: `SVGView` / `SVGView`
- **Target**: `AgentChatRichMedia`
- **Source File**: `Packages/AgentChatSDK/Sources/AgentChatRichMedia/InlineSVGMediaView.swift`
- **API Types / Methods Used**:
  - `SVGView(string: svgString)`
  - `SVGView(contentsOf: url)`
  - `.aspectRatio(contentMode: .fit)`
- **Visible Capability**: Inline vector graphic rendering within chat message content parts, supporting AI-generated diagram and chart SVGs with responsive aspect ratio scaling.
- **Fallback Behavior**: Falls back to `RichMediaFallbackView(icon: "paintbrush.fill", title: ...)` on XML parsing failure or unsupported platforms.
- **Test**: `AgentChatSDKTests.testVisualSnapshotSuite()` (Snapshot 14)
- **Type**: Direct additive dependency.

---

## 3. Lottie
- **Package / Product**: `lottie-spm` / `Lottie`
- **Target**: `AgentChatRichMedia`
- **Source File**: `Packages/AgentChatSDK/Sources/AgentChatRichMedia/AgentLottieMediaView.swift`
- **Reachable Runtime Path**: `MessageView.contentPartView(_:)` (`case .lottie` -> `AgentLottieMediaView`)
- **API Types / Methods Used**:
  - `LottieView(animation: .named(animationName))`
  - `.playbackMode(.playing(...))`
  - `.resizable()`
  - `@Environment(\.accessibilityReduceMotion)`
- **Visible Capability**: Vector JSON animations for rich media content parts.
- **Fallback Behavior**: Replaces animation with a static SF Symbol (`Image(systemName: "sparkles")`) whenever Reduce Motion is enabled.
- **Test**: `AgentChatSDKTests.testRichMediaContentParts()`, `AgentChatSDKTests.testAgentLottieMediaViewReduceMotion()`
- **Type**: Direct additive dependency.

---

## 4. Pow
- **Package / Product**: `Pow` / `Pow`
- **Target**: `AgentChatRichMedia`, `AgentChatToolPresentation`
- **Source File**: `Packages/AgentChatSDK/Sources/AgentChatToolPresentation/ToolExecutionDisclosure.swift`, `Packages/AgentChatSDK/Sources/AgentChatRichMedia/AgentLottieMediaView.swift`
- **Reachable Runtime Path**: `ToolExecutionDisclosure.statusCompletedIndicator` and `AgentLottieMediaView.animatedView`
- **API Types / Methods Used**:
  - `import Pow`
  - `.changeEffect(.glow(color: ...), value: status == .completed)`
  - `.changeEffect(.glow(color: ...), value: animationName)`
- **Visible Capability**: Subtle glow micro-interaction on tool completion badge and rich media view.
- **Fallback Behavior**: Conditioned on `!reduceMotion`; renders static view when Reduce Motion is active or Pow is unavailable.
- **Test**: `AgentChatSDKTests.testToolExecutionDisclosurePowIntegration()`, `AgentChatSDKTests.testVisualSnapshotSuite()` (Snapshot 10, 12)
- **Type**: Direct additive dependency.

---

## 5. EmojiKit
- **Package / Product**: `EmojiKit` / `EmojiKit`
- **Target**: `AgentChatComposerExtensions`
- **Source File**: `Packages/AgentChatSDK/Sources/AgentChatComposerExtensions/AgentEmojiPicker.swift`
- **Reachable Runtime Path**: `MessageInputView.attachButton` ("Emoji" menu action -> `.sheet(isPresented: $showEmojiPicker)` -> `AgentEmojiPicker`)
- **API Types / Methods Used**:
  - `EmojiScrollGrid(emojis: Emoji.all, action: { emoji in onSelect(emoji.char) })`
  - `Emoji.all`
  - `emoji.char`
- **Visible Capability**: Full categorized emoji sheet launched from the '+' composer menu to insert emojis directly into the message input field.
- **Fallback Behavior**: Degrades to categorized SwiftUI `LazyVGrid` of unicode emojis if EmojiKit is not present.
- **Test**: `AgentChatSDKTests.testVisualSnapshotSuite()` (Snapshot 16 Composer)
- **Type**: Direct additive dependency.

---

## 6. swift-async-algorithms
- **Package / Product**: `swift-async-algorithms` / `AsyncAlgorithms`
- **Target**: `AgentChatCore`
- **Source File**: `Packages/AgentChatSDK/Sources/AgentChatCore/AsyncEventBuffer.swift`
- **API Types / Methods Used**:
  - `AsyncChannel<Element>()`
  - `channel.debounce(for: duration)` via `AsyncAlgorithms.debounce(for:)`
  - `channel.chunks(ofCount: count)` via `AsyncAlgorithms.chunks(ofCount:)`
- **Visible Capability**: Debounced and chunked async event streaming to prevent UI stutter during high-frequency token generation.
- **Fallback Behavior**: Native Swift Concurrency `AsyncStream`.
- **Test**: `AgentChatSDKTests.testAsyncEventBufferAsyncAlgorithmsStreaming()` (directly consumes `buffer.chunkedStream(count: 2)`)
- **Type**: Direct dependency.

---

## 7. swift-collections
- **Package / Product**: `swift-collections` / `Collections`
- **Target**: `AgentChatCore`
- **Source File**: `Packages/AgentChatSDK/Sources/AgentChatCore/AsyncEventBuffer.swift`
- **API Types / Methods Used**:
  - `Deque<Element>()`
  - `deque.append(_:)`
  - `deque.popFirst()`
  - `deque.count`
- **Visible Capability**: $O(1)$ ring buffer for activity timeline event retention and streaming chunk histories without unbounded memory growth.
- **Fallback Behavior**: Array slice buffer.
- **Test**: `AgentChatSDKTests.testAsyncEventBufferBoundedCapacity()`
- **Type**: Direct dependency.

---

## 8. LiveKit (LiveKit room/session transport foundation)
- **Package / Product**: `client-sdk-swift` / `LiveKit`
- **Target**: `AgentChatVoiceLiveKit`
- **Source File**: `Packages/AgentChatSDK/Sources/AgentChatVoiceLiveKit/LiveKitVoiceSessionProvider.swift`
- **API Types / Methods Used**:
  - `Room()`
  - `room.connect(url:token:)`
  - `room.disconnect()`
  - `actor LiveKitVoiceState` + `OSAllocatedUnfairLock`
- **Visible Capability**: LiveKit room/session transport foundation managing connection/disconnection lifecycle, error propagation, and Swift 6 async-safe state updates. (Does not claim full local/remote audio track publication in Phase 1).
- **Fallback Behavior**: Offline/mock provider (`AgentMockVoiceProvider`) allows complete offline demo and tests without server credentials.
- **Test**: `AgentChatSDKTests.testMockVoiceProviderLifecycle()`, full target compilation in simulator and device builds.
- **Type**: Direct dependency in optional target.

---

## 9. Textual (Golden SwiftChat Markdown Engine)
- **Package / Product**: `textual` / `Textual`
- **Target**: `AgentChatSwiftChat`
- **Source File**: `Packages/AgentChatSDK/Sources/AgentChatSwiftChat/Views/LaTeXMarkdownView.swift`
- **API Types / Methods Used**:
  - `StructuredText(markdown: strippedText)`
  - `.textual.structuredTextStyle(.gitHub)`
  - `.textual.highlighterTheme(isStreaming ? .plain : .default)`
  - `.textual.textSelection(.enabled)`
- **Visible Capability**: High-performance streaming Markdown with code highlighting, tables, and link parsing.
- **Type**: Canonical SwiftChat foundation engine.

---

## 10. SwiftMath (Golden SwiftChat LaTeX Engine)
- **Package / Product**: `SwiftMath` / `SwiftMath`
- **Target**: `AgentChatSwiftChat`
- **Source File**: `Packages/AgentChatSDK/Sources/AgentChatSwiftChat/Views/LaTeXMarkdownView.swift`
- **API Types / Methods Used**:
  - `LaTeXView(latex: latex, isDisplay: isDisplay, isDarkMode: isDarkMode)`
- **Visible Capability**: Native CoreGraphics math rendering for inline and block LaTeX equations.
- **Type**: Canonical SwiftChat foundation engine (Production).

---

## 11. Transitive Voice Media Infrastructure: WebRTC & Opus
- **Role**: Peer-to-peer real-time audio transport and low-latency audio encoding.
- **Type**: **Transitive** (provided automatically by `LiveKitWebRTC.xcframework` inside LiveKit SDK). No competing direct libraries installed.
