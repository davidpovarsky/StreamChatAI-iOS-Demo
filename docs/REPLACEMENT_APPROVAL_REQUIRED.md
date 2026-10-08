# Subsystem Replacement Decisions & Approval Status

> [!IMPORTANT]
> The architectural decision for `AgentChatSDK` is fixed:
> **The selected upgraded SwiftChat Full Demo is the golden product foundation.**
> Working SwiftChat subsystems are not replaced. Candidate replacements have been evaluated and resolved as recorded below.

---

## 1. Summary of Fixed Subsystem Decisions

| Subsystem | Incumbent in SwiftChat | Evaluated Candidate | User Decision | Final Production Architecture |
|---|---|---|---|---|
| **Syntax Highlighting** | `Textual` (`StructuredText`) | `Highlightr` (highlight.js) | **REJECTED AS REPLACEMENT** | Production uses `Textual`. `Highlightr` is removed from runtime dependencies. |
| **Markdown Parsing** | `Textual` / Foundation | `swift-markdown` / `cmark-gfm` | **REJECTED AS REPLACEMENT** | Production uses `Textual`. Avoids ecosystem target collisions with `StreamChatAI`'s `cmark-gfm`. |
| **Text Selection** | Native SwiftUI `.textSelection(.enabled)` & `Textual` | `STTextKitPlus` | **NOT APPROVED / DEFERRED** | Production uses native selection. `STTextKitPlus` is omitted from runtime dependencies. |
| **Animations** | Native SwiftUI + `Pow` | `Motion` | **REJECTED** | Production uses SwiftUI animations + `Pow` micro-interactions. `Motion` is omitted. |
| **Web Math** | `SwiftMath` (Native) | `KaTeX` (WebView) | **REJECTED FOR CURRENT SDK** | No WebKit overhead in chat cells. |
| **LaTeX Math Formula Rendering** | `SwiftMath` (`mgriebling/SwiftMath` via `swiftui-math`) | `iosMath` (`kostub/iosMath` via `MTMathUILabel`) | **A/B TEST ONLY — DO NOT REPLACE SWIFTMATH** | Production remains `SwiftMath`. `iosMath` is evaluated strictly in an isolated test & comparison harness (`docs/IOSMATH_VS_SWIFTMATH_AB_TEST.md`). |

---

## 2. Accurate Technical Evaluation: iosMath vs. SwiftMath

Both libraries are modern, active, and maintained open-source packages:

- **`SwiftMath` (`mgriebling/SwiftMath` / `swiftui-math`)**:
  - Maintained upstream Swift package.
  - Native SwiftUI / CoreText drawing without WebViews.
  - Integrated directly into SwiftChat's `LaTeXMarkdownView` segment cache.
  - Fast, lightweight binary footprint.
  - **Status**: Production default in `AgentChatSwiftChat`.

- **`iosMath` (`kostub/iosMath`)**:
  - Active Swift Package with recent commits, tags, and maintenance.
  - Native UIKit formula renderer (`MTMathUILabel` using TeX layout engine and Latin Modern Math fonts).
  - Used in production by the official ChatGPT iOS application.
  - Requires `UIViewRepresentable` bridging and manual layout sizing inside SwiftUI lists.
  - **Status**: Tested strictly in isolated A/B comparison harness (`AgentChatMathComparisonTests`). SwiftMath is **not** replaced in production.
