# Mandatory Replacement Decision Gate — Subsystem Approval Required

> [!IMPORTANT]
> Per Section 9 of the Master Prompt, libraries from ChatGPT's dependency list that overlap with subsystems already present in the selected SwiftChat implementation **MUST NOT** replace working SwiftChat code without explicit user approval.
>
> All safe, additive integrations (Category A) are implemented cleanly alongside the SwiftChat baseline. The following candidates are held at this Decision Gate.

---

## Comparison of Candidate Replacements vs. Existing SwiftChat Subsystems

| Candidate | Existing SwiftChat subsystem | Current upstream implementation | Proposed library | Benefit | Regression risk | Migration cost | Binary/build cost | Recommendation |
|---|---|---|---|---|---|---|---|---|
| **Highlightr** | Syntax highlighting for fenced code blocks | `Textual` (`StructuredText` with `.gitHub` style) | `raspu/Highlightr` (highlight.js in JS runtime) | Wide range of esoteric language grammars | **High**: JS runtime initialization overhead, higher memory in message lists, possible threading issues during token streaming | **Moderate**: Requires tearing down Textual code blocks and injecting `UIViewRepresentable` | High (~1.5 MB bundle with JS assets) | **Keep SwiftChat's Textual Highlighter** |
| **iosMath** | LaTeX formula rendering (inline & display math) | `mgriebling/SwiftMath` (`LaTeXView` via CoreGraphics) | `kostub/iosMath` (`MTMathUILabel`) | Mature LaTeX engine identical to ChatGPT iOS app | **Moderate**: Requires `UIViewRepresentable` wrapper; dynamic height calculation in SwiftUI lists requires custom sizing hooks | **Low-to-moderate**: SwiftChat already has a robust segment cache for `SwiftMath` | Low (~300 KB font bundle) | **Keep SwiftMath as default**; provide iosMath only as opt-in adapter if requested |
| **swift-markdown / cmark-gfm** | Markdown AST parsing and text formatting | `tinfoilsh/textual` (`StructuredText`) | `apple/swift-markdown` / `cmark-gfm` | Official Apple CommonMark AST | **Very High**: SPM target name collision (`cmark-gfm`) across ecosystem packages; breaking Textual layout pipeline | **Very High**: Complete rewrite of `LaTeXMarkdownView` | Heavy C compilation | **Keep SwiftChat's Textual Pipeline** |
| **KaTeX** | LaTeX math rendering via web engine | `mgriebling/SwiftMath` (native) | `KaTeX` (WebKit / JS) | Identical rendering to web KaTeX | **Very High**: WebKit/WKWebView in message cells causes scroll stutter and heavy memory leaks | **High**: Requires web message bridge | Web resources & engine | **Reject / Keep SwiftMath** |
| **STTextKitPlus** | Text selection, range inspection & copy | Native SwiftUI `.textSelection(.enabled)` & Textual | `krzyzanowskim/STTextKitPlus` | Low-level TextKit 2 line fragment inspection | **Low-to-moderate**: Adds complexity without user-visible benefit over native iOS text selection | **High** if modifying Textual internals | Negligible | **Keep SwiftChat Native Selection** |
| **Motion** | Gesture-driven fluid animations | SwiftUI `.animation` & `Pow` spring transitions | `Motion` (Fluid animations) | UIKit-level gesture velocity preservation | **Moderate**: Selected SwiftChat UI is pure SwiftUI; mixing UIKit motion drivers degrades declarative state transitions | **Moderate**: Rewiring gesture handlers | Small | **Keep SwiftUI + Pow** |

---

## Decision Gate Items Submitted for User Approval

1. **Syntax Highlighting**:
   - Keep current SwiftChat `Textual` syntax highlighting? *(Recommended)*
   - Or replace with `Highlightr` (highlight.js)?
2. **LaTeX Math Rendering**:
   - Keep current SwiftChat `SwiftMath` native CoreGraphics rendering? *(Recommended)*
   - Or replace canonical math renderer with `iosMath` (`MTMathUILabel`)?
3. **Markdown Engine**:
   - Keep current SwiftChat `Textual` (`StructuredText`) markdown engine? *(Recommended)*
   - Or replace with `apple/swift-markdown` + `cmark-gfm`?
4. **TextKit & Gestures**:
   - Keep current SwiftUI native selection and gestures? *(Recommended)*
   - Or replace with `STTextKitPlus` / `Motion`?

*No code replacements for these candidate subsystems have been performed. SwiftChat's approved baseline implementations remain 100% active and intact.*
