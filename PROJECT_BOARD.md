# Project Board

This is a living working-memory document for this repository.
It is intentionally lightweight. Humans and coding agents should update it when useful discoveries, ideas, plans, optimizations, problems, or follow-up work arise during normal development.
Do not turn this into a duplicate issue tracker or a dump of temporary thoughts.

## Inbox

Quick captures that still need classification.

## Ideas & Opportunities

- Pluggable WebRTC/LiveKit voice transport adapter (`AgentChatVoiceLiveKit`) for zero-latency bidirectional voice duplex.
- Multi-column canvas / artifact inspector for iPad Stage Manager.
- Streaming math token parser that incrementally closes LaTeX math blocks (`$$...$$`) during active generation.

## Discoveries & Tips

- **SwiftChat Golden Parity**: Upstream `sachaservan/SwiftChat` relies on `Textual` (`StructuredText`) for markdown/syntax highlighting and `SwiftMath` for LaTeX math. Attempting to replace these with `Highlightr` or `iosMath` breaks visual parity with the full demo and risks package collisions (e.g. `cmark-gfm`). All proposed replacements must remain gated behind explicit user approval.
- **Kingfisher Non-Invasive Integration**: `Kingfisher` (`KFImage`) can be wrapped cleanly inside `SafeInlineImageMediaView` to provide disk/memory caching and progress indicators without leaking Kingfisher types to the public API or changing SwiftChat's `MessageContentPart` contract. Pre-seeding `ImageCache.default.store(fixtureImage, forKey:)` enables 100% deterministic offline snapshot testing.
- **Eliminating Circular Module Dependencies**: Bridging `SelectedModelMenu` to SwiftChat's `ChatViewModel` via convenience extensions in `AgentChatSwiftChat/Views/SelectedModelMenu+Convenience.swift` decouples `AgentChatComposerExtensions` from `AgentChatSwiftChat`, allowing a strict acyclic DAG.
- **Accessibility & Micro-Animations**: `Lottie` and `Pow` (`.changeEffect(.glow(...))`) are conditioned on `@Environment(\.accessibilityReduceMotion)` (with optional `forceReduceMotion` override for deterministic testing) to respect user accessibility preferences, dropping gracefully to static SF Symbols and non-animated indicators.
- **Swift 6 Concurrency & Lock Safety in LiveKit**: `NSLock.lock()`/`unlock()` is unavailable in Swift 6 `async` contexts (`-warn-concurrency`). Using an `actor` (`LiveKitVoiceState`) and `OSAllocatedUnfairLock` (`import os`) for synchronous state access eliminates concurrency warnings/errors cleanly.
- **Standalone SwiftMath vs iosMath Hebrew `\text{...}`**: In side-by-side snapshots (`Light_Unicode-Hebrew-Context.png`), standalone `iosMath.MTMathUILabel` cascades to the iOS system Hebrew font inside `\text{...}`, whereas standalone `SwiftMath.MTMathUILabel` uses its bundled Latin Modern Math font and omits non-Latin glyphs inside `\text{...}`. Production `LaTeXMarkdownView` in `AgentChatSwiftChat` avoids this by tokenizing Hebrew prose outside `$...$` via `StructuredText` and passing only math expressions to `SwiftMath`.
- **JSONSerialization Slash Escaping**: `JSONSerialization.data(withJSONObject:options:)` escapes `/` as `\/` unless `.withoutEscapingSlashes` is included in `WritingOptions`.
- Wrapping `MTMathUILabel` in a `UIViewRepresentable` provides smooth LaTeX rendering without needing WebViews or JavaScript engines.
- Using `#if canImport(SwiftUI)` and `#if canImport(UIKit)` across SDK targets allows pure Swift domain models and parsers to type-check and run cross-platform while compiling full UI surfaces on iOS/macOS.
- Liquid Glass effects (`.glassEffect(.regular)`) on iOS 26+ gracefully degrade to `.ultraThinMaterial` and borders on iOS 16-18.
- SPM requires globally unique target names across all packages. Both `swift-cmark` and `swift-markdown-ui` declare a target named `cmark-gfm`, causing collision exit code 74 if both packages are present in the dependency graph.
- **OpenAI Fork Streaming Schemas (`tinfoilsh/openai-swift-fork`)**: `ResponseStreamEvent` uses typed cases `.reasoningText(.delta(Schemas.ResponseReasoningTextDeltaEvent))` where `delta` is directly `Swift.String`, and `.outputTextAnnotation(.added(Schemas.ResponseOutputTextAnnotationAddedEvent))` where `annotation` is an enum `Components.Schemas.Annotation` with case `.urlCitationBody(Components.Schemas.UrlCitationBody)`. Pattern matching directly against these typed schemas avoids type erasure, reflection, and JSON dictionary casting timeouts.

## Experiments / Investigations

- Category B Decision Gate: Completed. Highlightr (rejected), swift-markdown (rejected), STTextKitPlus (deferred), Motion (rejected), KaTeX (rejected), iosMath (isolated A/B testing harness in `AgentChatMathComparisonTests`).
- SwiftMath is canonical production renderer across all UI targets.

## Open Questions

- None. All Category B decision gates and Phase 1 CI verification gates resolved.

## Planned / Todo

- [ ] Complete CI verification and generate release unsigned IPA for iOS 27.0.

## In Progress / Verification

- **Phase 2 — Native SwiftUI iOS 27 Architecture & SDK Showcase Realignment**:
  - Modular DAG defined in `Packages/AgentChatSDK/Package.swift` targeting `.iOS("27.0")`.
  - Canonical immutable models in `AgentChatCore` (`CanonicalModels.swift`, `AgentEventReducer.swift`, `VirtualClock.swift`).
  - Hierarchical agent activity component `AgentHierarchicalActivityView` (collapsed by default: `Worked for...`).
  - Visible approval cards outside tree (`AgentApprovalRequestCard`).
  - Rich interactive result cards (`ChartResultView`, `MapResultView`, `FormResultView`, `CanvasResultViews`, `NativeResultCards`).
  - 100% native showcase demo in `StreamChatAIDemo` (4 tabs: Playground, Scenarios with all 26 scenarios, Component Gallery, Motion Lab).
  - CI workflow configured for macOS 15 / Xcode 27 / iOS 27 simulator testing and unsigned IPA packaging.

## Done

- [x] **Phase 2 Core SDK Architecture & Native UI Implementation (2026-10-12)**
  - Replaced legacy SwiftChat UI views with 100% native SwiftUI components.
  - Decoupled singletons; per-session observable state in `AgentChatSession`.
  - Native media fallback for YouTube and isolated WebKit in optional `AgentChatWebContent`.
  - Removed obsolete dependencies (`Pow`, `EmojiKit`, `openai-swift-fork`, GetStream).
  - Comprehensive unit and snapshot tests updated for native views.
- [x] **Phase 1 — Truthful CI, Snapshot, Dependency & Build Verification Complete (2026-10-11)**
  - **Verified Code & Snapshot Commit SHA**: `350bac6` (`350bac6c9a5e63f6d136b13c6496b21a5ee8df7f`) on branch `agent/swiftchat-sdk-chatgpt-stack-realignment`

  - **CI Run IDs & URLs**:
    - `Build unsigned IPA`: Run `38130569625` (`completed success`) — `https://github.com/davidpovarsky/StreamChatAI-iOS-Demo/actions/runs/38130569625`
    - `Build Full Chat SDK Demos`: Run `38130569567` (`completed success`) — `https://github.com/davidpovarsky/StreamChatAI-iOS-Demo/actions/runs/38130569567`
  - **Hard CI Failure Gates**: Removed all `|| echo` failure-swallowing from `.github/workflows/build-ipa.yml` and `.github/workflows/build-full-demos.yml`; configured `set -euo pipefail` and `-scheme AgentChatSDK-Package`.
  - **Test Summary**:
    - `AgentChatSDKTests`: Executed 11 tests, with 0 failures (0 unexpected) in 4.983 seconds.
    - `AgentChatMathComparisonTests`: Executed 4 tests, with 0 failures (0 unexpected) in 3.680 seconds.
  - **Snapshot Verification Status**: 48 golden `.png` snapshot files committed under `Packages/AgentChatSDK/Tests/AgentChatSDKTests/__Snapshots__/AgentChatSDKTests/` (26 files: 22 visual states `01_EmptyInitialChat` through `22_iPadRegularWidth` + 2 `Pow` + 2 `Lottie`) and `Packages/AgentChatSDK/Tests/AgentChatMathComparisonTests/__Snapshots__/MathComparisonTests/` (22 files: 10 Light + 10 Dark + 1 RTL Narrow + 1 iPad Regular). Re-verified in CI with recording OFF and 0 failures.
  - **LiveKit Target Build Status**: `AgentChatVoiceLiveKit` (`LiveKitVoiceSessionProvider.swift`) refactored with `actor LiveKitVoiceState` and `OSAllocatedUnfairLock`; verified `** BUILD SUCCEEDED **` on both `iphoneos` and `iphonesimulator` with 0 Swift 6 concurrency errors. Documented truthfully as `LiveKit room/session transport foundation`.
  - **`SwiftMath` vs `iosMath` Decision Summary**: `SwiftMath` remains the 100% canonical production math renderer in `AgentChatSwiftChat` (`LaTeXMarkdownView`); `iosMath` is retained strictly in the isolated `AgentChatMathComparisonTests` target for side-by-side visual and progressive-streaming evaluation (`docs/IOSMATH_VS_SWIFTMATH_AB_TEST.md`).
  - **Final IPA Artifacts & Sizes**:
    - `SwiftChat-AgentSDK-Demo-IPA` (`SwiftChat-AgentSDK-Demo-unsigned.ipa`): `21,214,466` bytes (`20.23 MB`), valid zip containing `Payload/StreamChatAI Demo.app` (95 entries).
    - `StreamChatAI-Demo-IPA` (`StreamChatAI-Demo-unsigned.ipa`): `21,214,466` bytes (`20.23 MB`), valid zip containing `Payload/StreamChatAI Demo.app` (95 entries).
    - `SwiftChat-Full-Demo-IPA` (`SwiftChat-Full-Demo-unsigned.ipa`): `22,420,741` bytes (`21.38 MB`), valid zip containing `Payload/SwiftChat.app` (73 entries).
- [x] Baseline SwiftChat Safe Overlay Verification at `b9d2cc0` (100% clean check).
- [x] Corrective Realignment of `AgentChatSDK` around SwiftChat Full Demo (`d6f54cc`) + safe overlay (2026-10-08).

## Archive

- [x] Initial prototype extraction of AgentChatSDK (Superseded by SwiftChat Full Demo realignment on 2026-10-08).
