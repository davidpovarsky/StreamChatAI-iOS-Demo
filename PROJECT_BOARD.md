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

- `swift-markdown` and `iosMath` require careful encapsulation to avoid forcing transitive framework imports on host applications.
- Wrapping `MTMathUILabel` in a `UIViewRepresentable` provides smooth LaTeX rendering without needing WebViews or JavaScript engines.
- Using `#if canImport(SwiftUI)` and `#if canImport(UIKit)` across SDK targets allows pure Swift domain models and parsers to type-check and run cross-platform while compiling full UI surfaces on iOS/macOS.
- Liquid Glass effects (`.glassEffect(.regular)`) on iOS 26+ gracefully degrade to `.ultraThinMaterial` and borders on iOS 16-18.
- SPM requires globally unique target names across all packages. Both `swift-cmark` and `swift-markdown-ui` declare a target named `cmark-gfm`, causing collision exit code 74 if both packages are present in the dependency graph. `AgentChatRendering` implements its parser adapter without pulling `swift-cmark` to ensure seamless coexistence with `StreamChatAI`.
- `StreamChatAI` 0.12.0 uses `SystemLanguageModel.contextSize` which broke on Xcode 26 beta; pinning `StreamChatAI` to `exactVersion: "0.10.0"` in `project.yml` ensures rock-solid builds.

## Experiments / Investigations

- Compare `Highlightr` vs. custom regex syntax parser for memory efficiency on high-frequency streaming token updates.
- Test `Pow` physics transitions for live tool execution state changes.

## Open Questions

- What is the optimal debounce interval for incoming stream chunks when rendering dynamic Markdown ASTs?

## Planned / Todo

- [ ] Add interactive charts/graph block renderer to `AgentChatRendering`.
- [ ] Add vision/camera live stream analyzer block to `AgentChatMedia`.

## Done

- [x] Extraction and implementation of modular `AgentChatSDK` (`Packages/AgentChatSDK`)
  - Implemented: 2026-10-07
  - Modules: `AgentChatCore`, `AgentChatActivity`, `AgentChatRichResults`, `AgentChatRendering`, `AgentChatMedia`, `AgentChatVoice`, `AgentChatVoiceLiveKit`, `AgentChatUI`, `AgentChatIntegrations`, `AgentChatSDK`
  - Integration: `StreamChatAIDemo` consumes `AgentChatSDK` as a Swift Package with 5 deterministic scenarios.
  - Docs: `docs/SDK_DEPENDENCIES.md`, `docs/AGENT_CHAT_SDK_ARCHITECTURE.md`, `docs/OVERLAY_TO_SDK_MIGRATION.md`


## Archive

Older completed/superseded items that still have historical value.
