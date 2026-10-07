# ChatGPT iOS Dependency Decision Matrix

This matrix categorizes all open-source libraries identified from ChatGPT's iOS dependency and license disclosure into their appropriate role within the SwiftChat-derived `AgentChatSDK`.

## Classification Categories
- **Relevant / Additive (Category A)**: Adds new capabilities or improves existing surfaces without replacing working SwiftChat components.
- **Relevant / Replacement Candidate (Category B)**: Competes with or would replace an existing SwiftChat subsystem. **Must NOT be adopted without explicit user approval.**
- **Transitive Infrastructure**: Included transitively by approved high-level frameworks (e.g. WebRTC within LiveKit).
- **Not Relevant to Selected SDK (Category C)**: App-level analytics, payments, identity, backend generators, or auxiliary tooling outside the scope of a modular Chat UI SDK.

---

## Complete Dependency Matrix

| Library | Role / Purpose | Classification | Target in AgentChatSDK | Integration / Exclusion Rationale |
|---|---|---|---|---|
| **Kingfisher** | Remote image loading, caching & prefetching | **Relevant / Additive** | `AgentChatRichMedia` | Used as an internal caching engine behind `SafeInlineImageMediaView` without altering message layout. |
| **SVGView** | SVG vector graphic rendering | **Relevant / Additive** | `AgentChatRichMedia` | Adds a new inline SVG content-part renderer (`InlineSVGMediaView`) for AI-generated vector graphics. |
| **Lottie (`lottie-spm`)** | Vector JSON animations | **Relevant / Additive** | `AgentChatRichMedia` | Subtle, accessible animations for generation complete, tool success, and voice transitions. Respects Reduce Motion. |
| **Pow** | SwiftUI physics micro-interactions | **Relevant / Additive** | `AgentChatRichMedia` / `AgentChatComposerExtensions` | Delicate change transitions for tool completion badges and citation expansion. Respects Reduce Motion. |
| **EmojiKit** | Emoji catalog and picker | **Relevant / Additive** | `AgentChatComposerExtensions` | Extends SwiftChat composer's '+' attachment menu with an optional emoji sheet without displacing existing inputs. |
| **swift-async-algorithms** | Async stream sequencing & debouncing | **Relevant / Additive** | `AgentChatCore` | Debouncing high-frequency stream events and merging activity streams safely. |
| **swift-collections** | Ordered collections & deques | **Relevant / Additive** | `AgentChatCore` | Efficient bounded ring buffers for activity timeline events and streaming chunks. |
| **LiveKit `client-sdk-swift`**| Realtime bidirectional audio transport | **Relevant / Additive** | `AgentChatVoiceLiveKit` (Optional) | Powers realtime voice mode session behind `AgentVoiceSessionProvider`. Does not replace dictation/Whisper input. |
| **WebRTC** | Realtime media peer-to-peer transport | **Transitive** | Transitive in `AgentChatVoiceLiveKit` | Supplied transitively by `client-sdk-swift`. No competing direct WebRTC stack introduced. |
| **Opus** | Low-latency audio codec | **Transitive** | Transitive in `AgentChatVoiceLiveKit` | Handled internally by LiveKit/WebRTC audio pipeline. No duplicate wrapper needed. |
| **libfvad** | Local voice activity detection | **Relevant / Additive** | `AgentChatVoice` (Behind abstraction) | Abstracted behind `AgentVoiceActivityDetecting` for local speech start/stop detection if needed. |
| **Highlightr** | Code syntax highlighting via highlight.js | **Relevant / Replacement candidate** | *Gated in Decision Gate* | SwiftChat currently uses `Textual` for fenced code blocks. Highlightr would replace Textual's code renderer. **Requires User Approval.** |
| **iosMath** | Native LaTeX rendering (`MTMathUILabel`) | **Relevant / Replacement candidate** | *Gated in Decision Gate* | SwiftChat currently uses `SwiftMath` (`LaTeXView`). Replacing SwiftMath with iosMath **Requires User Approval.** |
| **swift-markdown / cmark-gfm** | CommonMark / GFM markdown AST parser | **Relevant / Replacement candidate** | *Gated in Decision Gate* | SwiftChat currently uses `Textual` (`StructuredText`). Previous pass had `cmark-gfm` target collisions. **Requires User Approval.** |
| **KaTeX** | Web/HTML-based LaTeX math renderer | **Relevant / Replacement candidate** | *Gated in Decision Gate* | Alternative math renderer. Adding it alongside SwiftMath would duplicate engines. **Requires User Approval.** |
| **STTextKitPlus** | TextKit 2 range and selection utilities | **Relevant / Replacement candidate** | *Gated in Decision Gate* | SwiftChat's text selection is handled natively by SwiftUI and Textual. Replacing it **Requires User Approval.** |
| **Motion** | Fluid interaction animation framework | **Relevant / Replacement candidate** | *Gated in Decision Gate* | SwiftChat uses native SwiftUI animations + Pow springs. Adopting Motion would alter gestures. **Requires User Approval.** |
| **Segment (`analytics-swift`)**| Product analytics tracking | **Not relevant to selected SDK** | *Excluded* | Host app concern. SDK must not impose third-party analytics trackers or collect user telemetry. |
| **Stripe (`stripe-ios`)** | In-app payment processing | **Not relevant to selected SDK** | *Excluded* | Billing and commerce belong in host app, not in a reusable chat UI library. |
| **Plaid (`plaid-ios`)** | Financial account linking | **Not relevant to selected SDK** | *Excluded* | Domain-specific integration not part of chat UI SDK. |
| **RevenueCat (`purchases-ios`)**| Subscription management | **Not relevant to selected SDK** | *Excluded* | Host app paywall and entitlement management concern. |
| **Sentry (`sentry-cocoa`)** | Crash reporting and error tracking | **Not relevant to selected SDK** | *Excluded* | Crash diagnostics belong in host application binary. |
| **Statsig (`statsig-ios`)** | Feature flag and experimentation engine | **Not relevant to selected SDK** | *Excluded* | Feature flag platform is host app architecture. |
| **PhoneNumberKit** | International phone number parsing | **Not relevant to selected SDK** | *Excluded* | Chat SDK does not handle phone number authentication or SMS. |
| **OpenAPIKit** | OpenAPI document specification parser | **Not relevant to selected SDK** | *Excluded* | Host backend API contract modeling tool, not UI SDK runtime. |
| **swift-openapi-generator** | Client code generator for OpenAPI | **Not relevant to selected SDK** | *Excluded* | Build-time code generation tool for API clients. |
| **swift-openapi-runtime** | Runtime transport for OpenAPI clients | **Not relevant to selected SDK** | *Excluded* | Host HTTP client layer. SDK uses abstract `AgentChatRuntimeProvider`. |
| **SwiftCSV** | CSV file parser | **Not relevant to selected SDK** | *Excluded* | Table parsing in SwiftChat is handled directly via markdown tables in `LaTeXMarkdownView`. |
| **Yams** | YAML parser and emitter | **Not relevant to selected SDK** | *Excluded* | JSON/tool payloads are handled with standard `Codable` and `JSONSerialization`. |
| **SimpleKeychain** | iOS Keychain wrapper | **Not relevant to selected SDK** | *Excluded* | Secret storage belongs to host app credential manager. |
| **Sovran** | Event bus used by Segment | **Not relevant to selected SDK** | *Excluded* | Transitive dependency of Segment; not needed for chat UI. |
| **Queue** | Background task queue | **Not relevant to selected SDK** | *Excluded* | Swift Concurrency (`TaskGroup`, `AsyncStream`) handles all SDK asynchronous work. |
| **JSONSafeEncoding** | JSON serialization helpers | **Not relevant to selected SDK** | *Excluded* | Standard library `JSONEncoder` with custom date strategies is sufficient. |
| **MemberwiseInit** | Macro for synthesising initializers | **Not relevant to selected SDK** | *Excluded* | Avoids build-time macro overhead and compiler complexity in SDK consumers. |
| **Publishable** | Property wrapper for Combine publishers | **Not relevant to selected SDK** | *Excluded* | SDK uses standard `@Published` and Swift Concurrency `AsyncStream`. |
| **Factory** | Dependency injection container | **Not relevant to selected SDK** | *Excluded* | SDK uses explicit constructor injection and SwiftUI environment objects. |
| **SwiftProtobuf** | Protocol Buffers runtime | **Not relevant to selected SDK** | *Excluded* | SDK event interchange uses lightweight JSON and typed Swift structs. |
| **swift-http-types** | HTTP abstractions | **Not relevant to selected SDK** | *Excluded* | Networking transport is delegated to host runtime protocols. |
| **swift-log** | Standard logging API | **Not relevant to selected SDK** | *Excluded* | Standard `os.Logger` used internally with minimal footprint. |
| **swift-numerics** | Advanced numerical routines | **Not relevant to selected SDK** | *Excluded* | No specialized mathematical calculation needs beyond Swift Math. |
| **swift-case-paths** | Enum case reflection | **Not relevant to selected SDK** | *Excluded* | Pattern matching in Swift standard library is sufficient. |
| **swift-custom-dump** | Debug printing utility | **Not relevant to selected SDK** | *Excluded* | Development-only debugging utility; not needed in production SDK. |
| **swift-issue-reporting** | Runtime issue logging | **Not relevant to selected SDK** | *Excluded* | Diagnostics handled via `os.Logger`. |
| **swift-tagged** | Type-safe wrapper for phantom types | **Not relevant to selected SDK** | *Excluded* | Standard Swift type definitions used for clarity and simplicity. |
