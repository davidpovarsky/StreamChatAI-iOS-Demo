# AgentUI Architecture & Verification Matrix

## Architectural Principles

1. **Presentation Separation**: AgentUI owns rendering, layout, glass materials, animations, and session presentation state. The host app owns model connectivity, credentials, and tool execution engines.
2. **Neutral Event Streams**: Interaction flows through typed `AgentUIEvent` values yielded by an `AsyncThrowingStream`.
3. **Continuous Glass Surface**: Tool disclosures and inspection details render as a single continuous surface (`AgentGlassCard`) without detached sub-cards or visual gaps.
4. **Stable Streaming Identities**: Block identities (`blk-{ordinal}-{kind}`) remain deterministic across incremental token arrivals to prevent SwiftUI layout thrashing.
5. **Native Media Navigation**: Fullscreen image viewing uses iOS native zoom transitions (`.matchedTransitionSource` and `.navigationTransition(.zoom)`), preserving navigation hierarchy.
6. **Isolated Registries**: Tool and embedded surface registries are owned per-view instance or explicitly injected, preventing shared singleton state pollution across multiple agent windows.

## Verification Matrix

| Subsystem / Capability | Implementation Status | Unit Tested | Simulator Tested | CI Tested | Physical Device Verified |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **No Mutable Shared Registries** | Implemented | ✅ Yes | ✅ Yes | ✅ Yes | Pending Device Run |
| **Host Actions Injected & Dispatched** | Implemented | ✅ Yes | ✅ Yes | ✅ Yes | Pending Device Run |
| **Tool Disclosure Single Surface** | Implemented | ✅ Yes | ✅ UI Test | ✅ Yes | Pending Device Run |
| **Sanitized Tool Inspection Redaction** | Implemented | ✅ Yes | ✅ Yes | ✅ Yes | N/A (Unit Logic) |
| **Native Zoom Image Viewer & Gestures** | Implemented | ✅ Yes | ✅ UI Test | ✅ Yes | Requires Physical Inspection |
| **Full Markdown (Headings, Lists, Tables)**| Implemented | ✅ Yes | ✅ UI Test | ✅ Yes | Pending Device Run |
| **Streaming Block Identity Stability** | Implemented | ✅ Yes | ✅ Yes | ✅ Yes | Pending Device Run |
| **LaTeX Math AST & Typesetting** | Implemented | ✅ Yes | ✅ UI Test | ✅ Yes | Pending Device Run |
| **Inline Section Sources at Paragraph End**| Implemented | ✅ Yes | ✅ UI Test | ✅ Yes | Pending Device Run |
| **Deterministic Favicon Resolution** | Implemented | ✅ Yes | ✅ Yes | ✅ Yes | Pending Device Run |
| **Embedded Sheet & Fullscreen Expansion** | Implemented | ✅ Yes | ✅ UI Test | ✅ Yes | Pending Device Run |
| **Embedded Session Lifecycle & Teardown** | Implemented | ✅ Yes | ✅ Yes | ✅ Yes | Pending Device Run |
| **Native Blocks All Fields & Actions** | Implemented | ✅ Yes | ✅ Yes | ✅ Yes | Pending Device Run |
| **YouTube Runtime Failure Fallback** | Implemented | ✅ Yes | ✅ UI Test | ✅ Yes | Pending Device Run |
| **SDK UI Strings Localized (EN & HE RTL)** | Implemented | ✅ Yes | ✅ UI Test | ✅ Yes | Pending Device Run |
| **Cancelled State Status Modeling** | Implemented | ✅ Yes | ✅ Yes | ✅ Yes | Pending Device Run |
| **Showcase Comprehensive Scenario Catalog** | Implemented | ✅ Yes | ✅ UI Test | ✅ Yes | Pending Device Run |
| **iPad Layout & Split Sidebar Support** | Implemented | ✅ Yes | ✅ UI Test | ✅ Yes | Pending Device Run |
| **Showcase IPA Device Build** | Implemented | N/A | N/A | ✅ CI Job | Ready for User Sideloading |
