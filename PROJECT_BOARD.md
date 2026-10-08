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
- **Kingfisher Non-Invasive Integration**: `Kingfisher` (`KFImage`) can be wrapped cleanly inside `SafeInlineImageMediaView` to provide disk/memory caching and progress indicators without leaking Kingfisher types to the public API or changing SwiftChat's `MessageContentPart` contract.
- **Eliminating Circular Module Dependencies**: Bridging `SelectedModelMenu` to SwiftChat's `ChatViewModel` via convenience extensions in `AgentChatSwiftChat/Views/SelectedModelMenu+Convenience.swift` decouples `AgentChatComposerExtensions` from `AgentChatSwiftChat`, allowing a strict acyclic DAG.
- **Accessibility & Micro-Animations**: `Lottie` and `Pow` should always be conditioned on `@Environment(\.accessibilityReduceMotion)` to respect user accessibility preferences, dropping gracefully to static SF Symbols and standard opacity fades.
- Wrapping `MTMathUILabel` in a `UIViewRepresentable` provides smooth LaTeX rendering without needing WebViews or JavaScript engines.
- Using `#if canImport(SwiftUI)` and `#if canImport(UIKit)` across SDK targets allows pure Swift domain models and parsers to type-check and run cross-platform while compiling full UI surfaces on iOS/macOS.
- Liquid Glass effects (`.glassEffect(.regular)`) on iOS 26+ gracefully degrade to `.ultraThinMaterial` and borders on iOS 16-18.
- SPM requires globally unique target names across all packages. Both `swift-cmark` and `swift-markdown-ui` declare a target named `cmark-gfm`, causing collision exit code 74 if both packages are present in the dependency graph.
- **OpenAI Fork Streaming Schemas (`tinfoilsh/openai-swift-fork`)**: `ResponseStreamEvent` uses typed cases `.reasoningText(.delta(Schemas.ResponseReasoningTextDeltaEvent))` where `delta` is directly `Swift.String`, and `.outputTextAnnotation(.added(Schemas.ResponseOutputTextAnnotationAddedEvent))` where `annotation` is an enum `Components.Schemas.Annotation` with case `.urlCitationBody(Components.Schemas.UrlCitationBody)`. Pattern matching directly against these typed schemas avoids type erasure, reflection, and JSON dictionary casting timeouts.

## Experiments / Investigations

- Category B Decision Gate: Completed. Highlightr (rejected), swift-markdown (rejected), STTextKitPlus (deferred), Motion (rejected), KaTeX (rejected), iosMath (isolated A/B testing harness in `AgentChatMathComparisonTests`).
- SwiftMath is canonical production renderer across all UI targets.

## Open Questions

- None. All Category B decision gates resolved per master alignment requirements.

## Planned / Todo

- [x] Implement isolated iosMath vs SwiftMath A/B test harness (`docs/IOSMATH_VS_SWIFTMATH_AB_TEST.md`).
- [x] Run full package targets build and real snapshot test suite (22 states verified).
- [x] Trigger and monitor GitHub Actions CI to generate `SwiftChat-AgentSDK-Demo-IPA`.
- [x] Verify final unsigned IPA artifact structure and completeness (3 IPAs generated and verified non-empty).

## In Progress / Verification

- None. Phase 1 Verification and Master Alignment 100% complete.

## Done

- [x] Baseline SwiftChat Safe Overlay Verification at `b9d2cc0` (100% clean check).
- [x] Corrective Realignment of `AgentChatSDK` around SwiftChat Full Demo (`d6f54cc`) + safe overlay
  - Date: 2026-10-08
  - Decision Gate Resolved: Highlightr (rejected), swift-markdown (rejected), KaTeX (rejected), STTextKitPlus (deferred), Motion (rejected), iosMath (isolated A/B test only).
  - Pushed to remote branch: `agent/swiftchat-sdk-chatgpt-stack-realignment`.
- [x] Phase 1 Verification & Master Prompt Realignment Completed
  - Date: 2026-10-08 / 2026-10-09
  - Final Remote Commit: `f4f5451`
  - GitHub Actions CI 100% Green:
    - `Build Full Chat SDK Demos` (Run `37800682616`): `completed success` (11m34s) -> `SwiftChat-Full-Demo-IPA` (22.25 MB)
    - `Build unsigned IPA` (Run `37800682343`): `completed success` (13m26s) -> `SwiftChat-AgentSDK-Demo-IPA` (20.96 MB), `StreamChatAI-Demo-IPA` (20.96 MB)
  - 22-State Snapshot Suite & Isolated iosMath vs SwiftMath A/B Test Suite: All tests passed on simulator and device targets.
  - Production LaTeX Canonical Renderer: 100% SwiftMath.

## Archive

- [x] Initial prototype extraction of AgentChatSDK (Superseded by SwiftChat Full Demo realignment on 2026-10-08).
