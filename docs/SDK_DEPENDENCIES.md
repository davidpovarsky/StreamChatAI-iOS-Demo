# SDK Dependencies Hygiene & Inventory (Realigned)

This document tracks all external dependencies in **`AgentChatSDK`**, their role, category classification, target module, and integration/hygiene guardrails.

---

## 1. Category A: Safe Approved Dependencies (Runtime & Core)

These open-source libraries from ChatGPT's iOS dependency disclosures (and SwiftChat's core stack) are safely integrated in an additive, modular manner without displacing working SwiftChat components.

| Library | Version / Pin | SDK Target | Role & Usage | Fallback / Safety Mechanism |
|---|---|---|---|---|
| **Textual (`StructuredText`)** | `0.1.0` | `AgentChatSwiftChat` | Canonical SwiftChat Markdown & syntax highlighting engine. | Retained as golden baseline; unbroken parity with full demo. |
| **SwiftMath (`swiftui-math`)** | `0.1.0` | `AgentChatSwiftChat` | Canonical SwiftChat native LaTeX formula renderer. | Production renderer in `LaTeXMarkdownView`. CoreText native drawing. |
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

## 2. Decision Gate: Rejected & Compared Dependencies

Following the user's fixed architectural decisions:

| Candidate Library | Proposed Subsystem | Incumbent in SwiftChat | Final Status |
|---|---|---|---|
| **Highlightr** | Code block syntax highlighting | `Textual.StructuredText` | **REJECTED** — Omitted from runtime dependency graph. Textual is retained. |
| **swift-markdown** / `cmark-gfm` | Markdown parsing | `Textual` AST / Foundation AttributedString | **REJECTED** — Omitted from runtime dependency graph. Avoids SPM target collisions. |
| **KaTeX** | Web-based Math rendering | `SwiftMath` (Native UIKit/CoreText) | **REJECTED** — Avoids WebView overhead in table cells. |
| **STTextKitPlus** | TextKit 2 range selections | Native TextEditor / SwiftUI Selection | **DEFERRED** — Omitted from runtime dependency graph. Native selection is sufficient. |
| **Motion** | Fluid animations | Standard SwiftUI Animations + `Pow` | **REJECTED** — Omitted from runtime dependency graph. SwiftUI + Pow retained. |
| **iosMath** | Mathematical LaTeX formulas | `SwiftMath` (`MTMathUILabel`) | **A/B TEST ONLY** — Linked strictly in isolated `AgentChatMathComparisonTests` / comparison harness. Does NOT replace SwiftMath in production. |

---

## 3. Excluded Non-Chat Dependencies

The following libraries from ChatGPT dependency disclosures are excluded from `AgentChatSDK` as they are application-level concerns unrelated to a reusable chat SDK:

- **Monetization & Financial**: Stripe, Plaid, RevenueCat.
- **Analytics & Crash Reporting**: Segment, Sentry, Statsig.
- **Codegen & Plumbing**: OpenAPIKit, OpenAPI Generator, Yams, SwiftCSV, PhoneNumberKit, SimpleKeychain.
- **State Store Frameworks**: Sovran, Queue.
