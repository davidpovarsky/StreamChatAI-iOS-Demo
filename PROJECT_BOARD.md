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

## Experiments / Investigations

- Category B Decision Gate: Evaluate `Highlightr` vs `Textual` syntax parser performance during streaming updates once user provides direction.
- Category B Decision Gate: Benchmark `iosMath` vs `SwiftMath` rendering latency on complex mathematical papers once user provides direction.

## Open Questions

- Will the user approve replacing `Textual` with `Highlightr` or `SwiftMath` with `iosMath`? (See `docs/REPLACEMENT_APPROVAL_REQUIRED.md`).

## Planned / Todo

- [ ] Await user response to Category B Decision Gate in `docs/REPLACEMENT_APPROVAL_REQUIRED.md`.
- [ ] Verify Demo Host and CI workflows packaging for `SwiftChat-AgentSDK-Demo-IPA`.

## Done

- [x] Corrective Realignment of `AgentChatSDK` around SwiftChat Full Demo (`d6f54cc`) + safe overlay
  - Date: 2026-10-08
  - Branch: `agent/swiftchat-sdk-chatgpt-stack-realignment`
  - Modules: `AgentChatCore`, `AgentChatActivity`, `AgentChatToolPresentation`, `AgentChatSources`, `AgentChatRichMedia`, `AgentChatComposerExtensions`, `AgentChatVoice`, `AgentChatVoiceLiveKit`, `AgentChatSwiftChat`, `AgentChatSDK`
  - Safe Category A Additions: Kingfisher, SVGView, Lottie, Pow, EmojiKit, swift-collections, swift-async-algorithms, LiveKit.
  - Decision Gate Established: `docs/REPLACEMENT_APPROVAL_REQUIRED.md` gating Category B libraries.
  - Documentation Artifacts: `docs/CURRENT_AGENTCHATSDK_REALIGNMENT_AUDIT.md`, `docs/CHATGPT_DEPENDENCY_DECISION_MATRIX.md`, `docs/SWIFTCHAT_SDK_PROVENANCE.md`, `THIRD_PARTY_NOTICES.md`, `docs/DEPENDENCY_INTEGRATION_EVIDENCE.md`.
- [x] Baseline SwiftChat Safe Overlay Verification at `b9d2cc0` (100% clean check).

## Archive

- [x] Initial prototype extraction of AgentChatSDK (Superseded by SwiftChat Full Demo realignment on 2026-10-08).
