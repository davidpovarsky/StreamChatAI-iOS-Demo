# ChatGPT iOS Dependency Decision Matrix

This matrix categorizes all open-source libraries identified from ChatGPT's iOS dependency and license disclosures into their designated classification within the SwiftChat-derived `AgentChatSDK`.

---

## 1. Classification Categories

- **Integrated / Additive (Approved)**: Adds new capabilities or improves existing surfaces without replacing working SwiftChat components.
- **Compared Only (A/B Test)**: Evaluated in dedicated non-production test harnesses; does not replace production components.
- **Rejected as Replacement / Duplicate**: Proposed replacements for working SwiftChat components that are formally rejected.
- **Deferred**: Not adopted at this time; preserved native path is sufficient.
- **Transitive**: Provided automatically by approved high-level frameworks.
- **Not Relevant to Selected SDK**: App-level concerns outside the scope of a modular Chat UI SDK.

---

## 2. Complete Dependency Matrix

| Library | Role / Purpose | Classification | Target in AgentChatSDK | Status & Architecture Decision |
|---|---|---|---|---|
| **Textual (`StructuredText`)** | Markdown & code syntax highlighting | **Canonical Foundation** | `AgentChatSwiftChat` | **KEEP** — Selected golden SwiftChat renderer. Unbroken layout parity. |
| **SwiftMath (`swiftui-math`)** | Native LaTeX mathematical formulas | **Canonical Foundation** | `AgentChatSwiftChat` | **KEEP IN PRODUCTION** — Canonical production renderer in `LaTeXMarkdownView`. |
| **Kingfisher** | Remote image loading, caching & prefetching | **Integrated / Additive** | `AgentChatRichMedia` | **APPROVED** — Caching engine behind `SafeInlineImageMediaView` without public API leakage. |
| **SVGView** | SVG vector graphic rendering | **Integrated / Additive** | `AgentChatRichMedia` | **APPROVED** — Renders vector content parts (`InlineSVGMediaView`) with graceful fallback. |
| **Lottie (`lottie-spm`)** | Vector micro-animations | **Integrated / Additive** | `AgentChatRichMedia` | **APPROVED** — Accessible status animations (`AgentLottieMediaView`); respects Reduce Motion. |
| **Pow** | SwiftUI physics micro-interactions | **Integrated / Additive** | `AgentChatRichMedia` | **APPROVED** — Spring transitions on tool and status disclosures; respects Reduce Motion. |
| **EmojiKit** | Emoji catalog and picker | **Integrated / Additive** | `AgentChatComposerExtensions` | **APPROVED** — Additive emoji picker popover (`AgentEmojiPicker`) in composer '+' menu. |
| **swift-collections** | Ordered collections & deques | **Integrated / Additive** | `AgentChatCore` | **APPROVED** — Bounded FIFO event buffers (`Collections.Deque`) in `AsyncEventBuffer`. |
| **swift-async-algorithms** | Async stream debouncing & merging | **Integrated / Additive** | `AgentChatCore` | **APPROVED** — Debounces and merges high-frequency streaming events in `AsyncEventBuffer`. |
| **LiveKit `client-sdk-swift`** | Realtime audio/video WebRTC transport | **Integrated / Additive** | `AgentChatVoiceLiveKit` (Optional) | **APPROVED AS OPTIONAL PROVIDER** — Real WebRTC room connection isolated in dedicated target. |
| **WebRTC** | Peer-to-peer media transport | **Transitive** | Transitive via LiveKit | Handled transitively by LiveKit WebRTC XCFramework; no redundant direct dependency. |
| **Opus** | Low-latency audio codec | **Transitive** | Transitive via LiveKit | Integrated inside WebRTC audio engine; no redundant wrapper needed. |
| **libfvad** | Voice activity detection | **Deferred / Evaluated** | `AgentChatVoice` (Abstractions) | Scaffolded behind `AgentVoiceActivityDetecting`; external C-library vendoring avoided for build safety. |
| **iosMath** | Native LaTeX rendering (`MTMathUILabel`) | **Compared Only** | `AgentChatMathComparisonTests` | **A/B TEST ONLY** — Evaluated in dedicated comparison harness; does NOT replace SwiftMath in production. |
| **Highlightr** | Code syntax highlighting via highlight.js | **Rejected as Replacement** | *Omitted* | **REJECTED** — Textual is retained; avoids JS runtime overhead and layout regressions. |
| **swift-markdown / cmark-gfm** | CommonMark / GFM AST parser | **Rejected as Replacement** | *Omitted* | **REJECTED** — Textual is retained; avoids SPM target collision with StreamChatAI's `cmark-gfm`. |
| **KaTeX** | Web-based LaTeX math renderer | **Rejected as Replacement** | *Omitted* | **REJECTED** — SwiftMath is retained; avoids WKWebView memory and scrolling penalties. |
| **STTextKitPlus** | TextKit 2 range inspection | **Deferred / Not Approved** | *Omitted* | **DEFERRED** — SwiftChat native selection & Textual are sufficient; no user-visible benefit. |
| **Motion** | Fluid interaction animation framework | **Rejected as Replacement** | *Omitted* | **REJECTED** — Native SwiftUI animations + Pow provide fluid physics without UIKit bridges. |
| **Segment (`analytics-swift`)** | Product analytics tracking | **Not relevant to SDK** | *Excluded* | Host app concern. SDK must not bundle telemetry trackers. |
| **Stripe (`stripe-ios`)** | In-app payment processing | **Not relevant to SDK** | *Excluded* | Commercial app concern, not chat UI SDK. |
| **Plaid (`plaid-ios`)** | Financial account linking | **Not relevant to SDK** | *Excluded* | Banking integration, not chat UI SDK. |
| **RevenueCat (`purchases-ios`)**| Subscription management | **Not relevant to SDK** | *Excluded* | Host paywall concern. |
| **Sentry (`sentry-cocoa`)** | Crash reporting | **Not relevant to SDK** | *Excluded* | Host diagnostics concern. |
| **Statsig (`statsig-ios`)** | Feature flags & experimentation | **Not relevant to SDK** | *Excluded* | Host configuration platform. |
| **PhoneNumberKit** | Phone number formatting | **Not relevant to SDK** | *Excluded* | Authentication concern. |
| **OpenAPIKit / Generator** | OpenAPI codegen & schema parsing | **Not relevant to SDK** | *Excluded* | Host backend toolchain. |
| **SwiftCSV / Yams** | CSV / YAML parsers | **Not relevant to SDK** | *Excluded* | Standard `Codable` and JSON are sufficient. |
| **SimpleKeychain** | iOS Keychain wrapper | **Not relevant to SDK** | *Excluded* | Credential security belongs in host app. |
