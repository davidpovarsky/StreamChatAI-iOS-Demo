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
- **Visible Capability**: Fast cached loading of remote rich-result images with network retry policies and subtle fade transitions.
- **Fallback Behavior**: Degrades seamlessly to SwiftUI's `AsyncImage` and `RichMediaFallbackView` if Kingfisher is not compiled.
- **Test**: `AgentChatSDKTests.testKingfisherRichMediaRendering()`
- **Type**: Direct dependency.

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
- **Fallback Behavior**: Falls back to `RichMediaFallbackView(icon: "paintbrush.fill", title: ...)` on parsing failure or unsupported platforms.
- **Test**: `AgentChatSDKTests.testInlineSVGMediaView()`
- **Type**: Direct dependency.

---

## 3. Lottie
- **Package / Product**: `lottie-spm` / `Lottie`
- **Target**: `AgentChatRichMedia`
- **Source File**: `Packages/AgentChatSDK/Sources/AgentChatRichMedia/AgentLottieMediaView.swift`
- **API Types / Methods Used**:
  - `LottieView(animation: .named(animationName))`
  - `.playbackMode(.playing(...))`
  - `.resizable()`
  - `@Environment(\.accessibilityReduceMotion)`
- **Visible Capability**: Smooth vector JSON animations for tool completion, generation finished badges, and voice mode transitions.
- **Fallback Behavior**: Replaces animation with a clean static SF Symbol (`Image(systemName: "sparkles")`) whenever Reduce Motion is enabled.
- **Test**: `AgentChatSDKTests.testLottieAnimationView()`
- **Type**: Direct dependency.

---

## 4. Pow
- **Package / Product**: `Pow` / `Pow`
- **Target**: `AgentChatRichMedia`, `AgentChatToolPresentation`
- **Source File**: `Packages/AgentChatSDK/Sources/AgentChatRichMedia/AgentLottieMediaView.swift`, `ToolExecutionDisclosure.swift`
- **API Types / Methods Used**:
  - `import Pow`
  - Spring micro-interaction effects for state transition feedback.
- **Visible Capability**: Delicate physical spring feedback on disclosure expansion and completion badge appearance.
- **Fallback Behavior**: Degrades to standard SwiftUI `.animation(.easeInOut)` when Pow is unavailable.
- **Test**: `AgentChatSDKTests.testToolExecutionDisclosure()`
- **Type**: Direct dependency.

---

## 5. EmojiKit
- **Package / Product**: `EmojiKit` / `EmojiKit`
- **Target**: `AgentChatComposerExtensions`
- **Source File**: `Packages/AgentChatSDK/Sources/AgentChatComposerExtensions/AgentEmojiPicker.swift`
- **API Types / Methods Used**:
  - `EmojiGrid(emojis: Emoji.all, selection: .single { emoji in ... })`
  - `Emoji.all`
  - `emoji.char`
- **Visible Capability**: Full categorized emoji sheet launched from the '+' composer menu to insert emojis directly into the message input field.
- **Fallback Behavior**: Degrades to categorized SwiftUI `LazyVGrid` of unicode emojis if EmojiKit is not present.
- **Test**: `AgentChatSDKTests.testEmojiPickerIntegration()`
- **Type**: Direct dependency.

---

## 6. swift-async-algorithms
- **Package / Product**: `swift-async-algorithms` / `AsyncAlgorithms`
- **Target**: `AgentChatCore`
- **Source File**: `Packages/AgentChatSDK/Sources/AgentChatCore/AsyncEventBuffer.swift`
- **API Types / Methods Used**:
  - `import AsyncAlgorithms`
  - `AsyncStream` sequencing and event channel handling.
- **Visible Capability**: Thread-safe streaming token buffering and sequencing.
- **Fallback Behavior**: Native Swift Concurrency `AsyncStream`.
- **Test**: `AgentChatSDKTests.testAsyncEventBuffer()`
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

## 8. LiveKit
- **Package / Product**: `client-sdk-swift` / `LiveKit`
- **Target**: `AgentChatVoiceLiveKit`
- **Source File**: `Packages/AgentChatSDK/Sources/AgentChatVoiceLiveKit/LiveKitVoiceSessionProvider.swift`
- **API Types / Methods Used**:
  - `Room()`
  - `room.connect(url:token:)`
  - `room.disconnect()`
- **Visible Capability**: Realtime bidirectional audio session management for interactive voice conversations.
- **Fallback Behavior**: Offline/mock provider (`AgentMockVoiceProvider`) allows complete offline demo and tests without server credentials.
- **Test**: `AgentChatSDKTests.testMockVoiceProviderLifecycle()`
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
- **Type**: Upstream baseline dependency.

---

## 10. SwiftMath (Golden SwiftChat LaTeX Engine)
- **Package / Product**: `SwiftMath` / `SwiftMath`
- **Target**: `AgentChatSwiftChat`
- **Source File**: `Packages/AgentChatSDK/Sources/AgentChatSwiftChat/Views/LaTeXMarkdownView.swift`
- **API Types / Methods Used**:
  - `LaTeXView(latex: latex, isDisplay: isDisplay, isDarkMode: isDarkMode)`
- **Visible Capability**: Native CoreGraphics math rendering for inline and block LaTeX equations.
- **Type**: Upstream baseline dependency.

---

## 11. WebRTC & Opus
- **Role**: Low-latency audio transport and codec infrastructure.
- **Type**: **Transitive** (provided by `LiveKitWebRTC.xcframework` inside LiveKit SDK). No competing direct libraries installed.
