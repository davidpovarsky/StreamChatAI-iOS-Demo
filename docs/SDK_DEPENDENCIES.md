# SDK Dependencies Hygiene & Inventory (Realigned)

This document tracks all external dependencies in **`AgentChatSDK`**, their role, category classification, target module, and integration/hygiene guardrails.

---

## 1. Category A: Safe Integrated Dependencies

These open-source libraries from ChatGPT's iOS dependency disclosures (and SwiftChat's core stack) are safely integrated in an additive, modular manner without displacing working SwiftChat components.

| Library | Version / Pin | SDK Target | Role & Usage | Fallback / Safety Mechanism |
|---|---|---|---|---|
| **Textual (`StructuredText`)** | `0.1.0` | `AgentChatSwiftChat` | Canonical SwiftChat Markdown & syntax highlighting engine. | Retained as golden baseline; no replacement without user approval. |
| **SwiftMath (`swiftui-math`)** | `0.1.0` | `AgentChatSwiftChat` | Canonical SwiftChat native LaTeX formula renderer. | Retained as golden baseline; no replacement without user approval. |
| **Kingfisher** | `8.8.0` | `AgentChatRichMedia` | Remote image caching and pipeline behind `SafeInlineImageMediaView`. | Native `AsyncImage` fallback on network failure or image decode error. Zero API leakage. |
| **SVGView** | `1.0.8` | `AgentChatRichMedia` | Scalable vector graphics renderer for `.svg` content parts (`InlineSVGMediaView`). | Graceful fallback view with asset title & error disclosure if XML parsing fails. |
| **Lottie (`lottie-spm`)** | `4.6.1` | `AgentChatRichMedia` | Micro-animations and animated badges (`AgentLottieMediaView`). | Automatically disabled when `@Environment(\.accessibilityReduceMotion)` is active; falls back to static SF Symbols. |
| **Pow** | `0.3.1` | `AgentChatRichMedia` | Spring transitions and physics-based view transitions. | Graceful static fade/scale when Reduce Motion is enabled. |
| **EmojiKit** | `1.0.0` | `AgentChatComposerExtensions` | Emoji reactions and composer picker (`AgentEmojiPicker`). | Native iOS emoji keyboard remains standard; sheet is optional and configurable. |
| **swift-collections** | `1.1.4` | `AgentChatCore` | `Collections.Deque` for FIFO streaming event buffer (`AsyncEventBuffer`). | Standard Apple open source. |
| **swift-async-algorithms** | `1.0.4` | `AgentChatCore` | Debouncing, throttling, and stream combination for activity events. | Standard Apple open source. |
| **LiveKit (`client-sdk-swift`)** | `2.17.0` | `AgentChatVoiceLiveKit` | Optional WebRTC transport for real-time voice (`LiveKitVoiceSessionProvider`). | Isolated in dedicated target; not linked by default host app; deterministic `AgentMockVoiceProvider` available. |
| **swift-snapshot-testing** | `1.19.6` | `AgentChatSDKTests` | Multi-device, light/dark, and RTL visual regression test assertions. | Test-only dependency. |

---

## 2. Category B: Decision-Gated Dependencies (On Hold)

These candidate libraries require **explicit user authorization** before replacing or displacing any working SwiftChat subsystem. See [`docs/REPLACEMENT_APPROVAL_REQUIRED.md`](file:///c:/Users/DAVID/Code/StreamChatAI-iOS-Demo/docs/REPLACEMENT_APPROVAL_REQUIRED.md) for detailed evaluation.

| Candidate Library | Proposed Subsystem | Incumbent in SwiftChat | Decision Gate Status |
|---|---|---|---|
| **Highlightr** | Code block syntax highlighting | `Textual.StructuredText` | **ON HOLD** — Awaiting user approval. |
| **iosMath** | Mathematical LaTeX formulas | `SwiftMath` (`MTMathUILabel`) | **ON HOLD** — Awaiting user approval. |
| **swift-markdown** / `cmark-gfm` | Markdown parsing | `Textual` AST / Foundation AttributedString | **ON HOLD** — Awaiting user approval (collides with StreamChat). |
| **KaTeX** | Web-based Math rendering | `SwiftMath` (Native UIKit/CoreText) | **REJECTED** — Avoid WebView overhead. |
| **STTextKitPlus** | TextKit 2 range selections | Native TextEditor / SwiftUI Selection | **ON HOLD** — Awaiting user approval. |
| **Motion** | Fluid animations | Standard SwiftUI Animations + `Pow` | **ON HOLD** — Awaiting user approval. |

---

## 3. Category C: Deliberately Excluded Dependencies

The following libraries from the ChatGPT dependency disclosures are excluded from `AgentChatSDK` as they are application-level concerns unrelated to a reusable chat SDK:

- **Monetization & Financial**: Stripe, Plaid, RevenueCat.
- **Analytics & Crash Reporting**: Segment, Sentry, Statsig.
- **Codegen & Plumbing**: OpenAPIKit, OpenAPI Generator, Yams, SwiftCSV, PhoneNumberKit, SimpleKeychain.
- **State Store Frameworks**: Sovran, Queue.
