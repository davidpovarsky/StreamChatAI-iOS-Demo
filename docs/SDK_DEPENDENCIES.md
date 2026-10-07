# SDK Dependencies Hygiene & Inventory

This document tracks all external dependencies used in the **AgentChatSDK** architecture, their target modules, and rationale.

| Library | SDK Module | Purpose | Runtime/Test | Optional | Notes |
|---|---|---|---|---|---|
| **swift-markdown** | `AgentChatRendering` | Markdown AST parsing and block decomposition | Runtime | No | Official Swift AST parser used inside `AgentMarkdownParser` without exposing types to host apps. |
| **Highlightr** | `AgentChatRendering` | Native syntax highlighting for fenced code blocks | Runtime | Yes (graceful fallback) | Wrapped in `AgentCodeBlockView`. Provides syntax themes (Atom One Dark, GitHub, etc.). |
| **iosMath** | `AgentChatRendering` | Native LaTeX mathematical formula rendering | Runtime | Yes (graceful fallback) | Wraps `MTMathUILabel` in `AgentMathView`. No WebView or JS overhead. |
| **Kingfisher** | `AgentChatMedia` | Remote image downloading, disk/memory caching, and placeholders | Runtime | Yes (graceful fallback) | Wrapped in `AgentRemoteImageView`. `KFImage` is never exposed in public API. |
| **SVGView** | `AgentChatRendering` | Scalable vector graphics (SVG) SwiftUI rendering | Runtime | Yes (graceful fallback) | Wrapped in `AgentSVGView` with tap-to-expand preview. |
| **Lottie (lottie-spm)** | `AgentChatUI`, `AgentChatRichResults` | Vector animation playback for tool/generation completion | Runtime | Yes | Used for optional states with native SwiftUI icon fallbacks; respects Reduce Motion. |
| **Pow** | `AgentChatUI`, `AgentChatRichResults` | Subtle transition effects and change animations | Runtime | Yes | Applied sparingly to status transitions and message insertions; respects accessibility. |
| **STTextKitPlus** | `AgentChatRendering` | TextKit 2 range and selection helpers | Runtime | Yes | Isolated in `AgentTextSelectionHelper` for precise search/snippet selection. |
| **EmojiKit** | `AgentChatUI` | Emoji picker sheet and grid integration | Runtime | Yes | Modular composer sheet integration; host app can toggle off via configuration. |
| **swift-async-algorithms** | `AgentChatCore` | Async stream composition, debouncing, and event merging | Runtime | No | Standard Apple async primitives for timeline and streaming events. |
| **swift-collections** | `AgentChatCore` | Ordered event buffers and deques | Runtime | No | `Deque` used for FIFO timeline management and event dispatch. |
| **LiveKit (client-sdk-swift)** | `AgentChatVoiceLiveKit` | WebRTC realtime audio and voice transport | Runtime | Yes (isolated target) | Fully isolated behind `AgentVoiceSessionProvider`; not bundled into core chat module. |
| **swift-snapshot-testing** | `AgentChatSDKTests` | Visual regression and snapshot verification | Test | No | Test dependency for verifying light/dark, RTL, and multi-device surfaces. |

---

## Libraries Deliberately Excluded (Hygiene Guardrails)

The following libraries from the ChatGPT dependency screen are excluded as they do not contribute to chat UI, streaming, or rendering:

- **Financial / Subscriptions**: Stripe, Plaid, RevenueCat
- **Analytics & Crash**: Segment, Sentry, Statsig
- **Network / Codegen boilerplate**: OpenAPIKit, OpenAPI Generator, Yams, SwiftCSV, PhoneNumberKit, SimpleKeychain
- **State stores**: Sovran, Queue
