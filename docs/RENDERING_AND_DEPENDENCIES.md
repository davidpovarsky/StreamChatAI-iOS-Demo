# Content Rendering & Dependencies Specification

## 1. Canonical Renderers by Content Kind

`AgentChatSDK` pairs each content type with a native renderer to ensure high performance, accessibility, and zero web view overhead.

| Content Kind | Canonical Renderer Target | Framework / Upstream Engine | Justification & Performance |
| :--- | :--- | :--- | :--- |
| **Markdown & Code** | `AgentChatMarkdown` | `Textual` (`StructuredText`) | Native TextKit parsing with syntax highlighting; preserves fast streaming token deltas. |
| **LaTeX Math** | `AgentChatMarkdown` | `SwiftMath` (`MTMathUILabel`) | High-fidelity TeX typography without WebViews; supports Hebrew bidirectional text. |
| **Data Visualizations** | `AgentChatResultCards` | Apple `Swift Charts` | Native iOS charts supporting Dynamic Type, VoiceOver, and spring animations. |
| **Maps & Locations** | `AgentChatResultCards` | Apple `MapKit` | Native vector maps with interactive pins, route lines, and 60 FPS gestures. |
| **Remote Images** | `AgentChatRichMedia` | `Kingfisher` (`KFImage`) | Asynchronous image loading with disk/memory caching; offline fixture pre-seeding. |
| **Vector Diagrams** | `AgentChatRichMedia` | `SVGView` (Exyte) | Scalable vector graphics rendered into native SwiftUI paths. |
| **Video & Audio** | `AgentChatRichMedia` | Apple `AVKit` / `AVFoundation` | Native hardware-accelerated H.264/HEVC playback and audio waveform scrubbers. |
| **External Web / Videos** | `AgentChatRichMedia` | Native Thumbnail + `openURL` | Fallback card rendering a native thumbnail and Safari handoff (zero WebKit). |
| **Opt-in Web Content** | `AgentChatWebContent` | Apple `WebKit` (`WKWebView`) | Strictly isolated in optional module; never imported by default chat pipeline. |

---

## 2. Upstream Dependencies & Licensing Matrix

| Dependency | Upstream Repository | Version / Pin | License | Integration Status |
| :--- | :--- | :--- | :--- | :--- |
| **Textual** | `tinfoilsh/textual` | `main` | MIT | Canonical markdown engine |
| **SwiftMath** | `mgriebling/SwiftMath` | `1.7.1` | MIT | Canonical math engine |
| **Kingfisher** | `onevcat/Kingfisher` | `8.3.0` | MIT | Image caching |
| **SVGView** | `exyte/SVGView` | `1.0.6` | MIT | Vector graphics |
| **Lottie** | `airbnb/lottie-ios` | `4.5.1` | Apache 2.0 | Indicator animations |
| **Swift Collections**| `apple/swift-collections` | `1.1.4` | Apache 2.0 | Ordered collections |
| **Async Algorithms** | `apple/swift-async-algorithms` | `1.0.3` | Apache 2.0 | Concurrency utilities |
| **LiveKit SDK** | `livekit/client-sdk-swift` | `2.0.14` | Apache 2.0 | Optional voice transport |

---

## 3. Evaluated Alternatives Not Integrated

1. **Highlightr (Syntax Highlighting)**:
   - *Status*: Rejected.
   - *Reason*: Depends on JavaScriptCore and bundled Highlight.js assets, introducing thread hopping and memory bloat. `Textual` provides superior native TextKit parsing.
2. **KaTeX via WKWebView**:
   - *Status*: Rejected.
   - *Reason*: Spawning `WKWebView` instances in message bubbles causes severe scrolling hitching and memory consumption. `SwiftMath` renders pure CoreGraphics equations.
3. **Pow (Visual Effects)**:
   - *Status*: Removed.
   - *Reason*: Introduced unnecessary proprietary dependencies for simple glows and shakes easily achieved with native iOS 27 SwiftUI modifiers.
4. **EmojiKit**:
   - *Status*: Removed.
   - *Reason*: Redundant; native iOS system keyboards and text inputs fully support emoji selection natively.
5. **GetStream Chat SDK / StreamChatUI**:
   - *Status*: Removed.
   - *Reason*: Legacy baggage; replaced by 100% native SwiftUI chat architecture.

---

## 4. WebKit Isolation Policy

To uphold the "100% native chat" invariant:
- **Zero WebKit in Base DAG**: Neither `AgentChatCore`, `AgentChatUI`, `AgentChatActivity`, nor `AgentChatSDK` import `WebKit`.
- **Isolated Target**: WebKit usage is restricted exclusively to `AgentChatWebContent`.
- **Native Preview Fallback**: In the base package, external links or YouTube videos render a static preview thumbnail with duration badges and an `openURL` handoff to Safari.
