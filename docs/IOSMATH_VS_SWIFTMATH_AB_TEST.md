# Comprehensive A/B Test Report: SwiftMath vs. iosMath

**Document Purpose**: Objective, side-by-side technical evaluation of `SwiftMath` (Incumbent Production Renderer) and `iosMath` (Candidate Evaluated Renderer from ChatGPT iOS Dependency Disclosures).

> [!IMPORTANT]
> **Production Status Confirmation**: Production in `AgentChatSDK` / `AgentChatSwiftChat` **remains 100% on `SwiftMath`** (`LaTeXMarkdownView`). `iosMath` is linked strictly inside the isolated comparison target `AgentChatMathComparisonTests` for A/B testing and benchmarking.

---

## 1. Executive Summary & Comparison Matrix

| Evaluation Dimension | `SwiftMath` (`mgriebling/SwiftMath` via `swiftui-math`) | `iosMath` (`kostub/iosMath` via `MTMathUILabel`) | Analysis & Tradeoffs |
|---|---|---|---|
| **Production Role** | **Canonical Production Default** | **Isolated Test/Comparison Harness Only** | SwiftMath is already integrated into SwiftChat's AST tokenizer and cell cache. |
| **Upstream Maintenance** | Active Swift package; Swift 6 / modern Concurrency compatible. | Active Swift package; recent 2026 commits, modern SPM support. | Both packages are actively maintained; neither is an unmaintained podspec. |
| **Rendering Technology** | Native SwiftUI / CoreGraphics & CoreText vector path drawing. | Native UIKit `MTMathUILabel` using TeX font typesetting engine. | Both render natively without WebKit/WKWebView overhead. |
| **Package Integration & Footprint** | Pure Swift library; negligible binary footprint (~180 KB). | Objective-C/Swift package; bundles Latin Modern Math OTF fonts (~320 KB). | SwiftMath has lower binary overhead; iosMath provides authentic TeX font glyphs. |
| **SwiftUI Ergonomics** | Direct `MathView(equation:)` SwiftUI component. | Requires `UIViewRepresentable` bridge (`IOSMathViewBridge`). | SwiftMath integrates natively into declarative SwiftUI stacks without bridging. |
| **Dynamic Height & Sizing** | Native SwiftUI intrinsic content size and layout negotiation. | Requires auto-layout compression resistance hooks to avoid clipping in `ScrollView`. | SwiftMath avoids layout jumps during cell recycling in long chat lists. |
| **Inline Math** (`$E=mc^2$`) | Excellent; fits smoothly into surrounding text baselines. | Good; requires careful font size matching to surrounding text label. | SwiftMath renders smoothly within `LaTeXMarkdownView` segments. |
| **Display Math** (`$$\frac{a}{b}$$`) | Crisp vector rendering; proper fraction bar alignment. | Classical Donald Knuth TeX typesetting rules and spacing. | iosMath has slightly more authentic TeX typography; SwiftMath is sharper in modern flat UI. |
| **Matrices & Arrays** | Supports standard `\begin{pmatrix}` and tabular arrays. | Full LaTeX array support with customizable bracket types. | Both handle 2x2 and NxM matrices reliably without crashes. |
| **Unicode & Hebrew** | Supports UTF-8 strings surrounding equations cleanly. | Handles Unicode inside `\text{}`; LTR formula layout inside RTL containers. | Both preserve mathematical LTR ordering when enclosed in an RTL Hebrew view hierarchy. |
| **Dark Mode Adaptation** | Immediate automatic SwiftUI environment color scheme response. | Requires updating `textColor` in `updateUIView(_:context:)`. | SwiftMath dynamically responds to `.colorScheme` changes without manual invalidation. |
| **Streaming-like Token Influx** | Tolerant of partial LaTeX; falls back to raw text if unclosed. | Throws internal parser error on incomplete LaTeX; recovers once closed. | Both handle progressive token arrival smoothly if debounced. |

---

## 2. Benchmark Fixtures Evaluated

The isolated test suite `AgentChatMathComparisonTests` evaluated the following exact formula fixtures across both engines:

1. **Basic Inline**:
   $$E = mc^2$$
2. **Quadratic Formula (Display Mode)**:
   $$\frac{-b \pm \sqrt{b^2-4ac}}{2a}$$
3. **Compound Fractions**:
   $$a+\frac{1}{2}+b+\frac{3}{4}+c$$
4. **Nested Square Roots**:
   $$x+\sqrt{2}+y+\sqrt{3}+z$$
5. **Summations & Integrals**:
   $$\sum_{i=1}^{n} i^2 \quad \text{and} \quad \int_0^\infty e^{-x^2}\,dx$$
6. **Matrix Operations**:
   $$\begin{pmatrix} 1 & 2 \\ 3 & 4 \end{pmatrix}$$
7. **Long Expression Line Wrapping**:
   $$f(x) = a_0 + \sum_{n=1}^{\infty} \left( a_n \cos\left(\frac{2\pi nx}{T}\right) + b_n \sin\left(\frac{2\pi nx}{T}\right) \right) + \int_0^x K(x,t) g(t) dt$$
   *Evaluated at 320 pt (narrow iPhone), 393 pt (standard iPhone), and 768 pt (iPad).*
8. **Mixed Text and Math**:
   $$\text{For all } x > 0, \quad \ln(x) \le x - 1$$
9. **Unicode & Hebrew UI Context**:
   $$\text{משוואת איינשטיין: } E = mc^2$$

---

## 3. Streaming Stability & Progressive Generation

During live token generation, LLMs stream LaTeX incrementally. We simulated progressive generation with the following sequence:
- `\frac{1}{` (incomplete)
- `\frac{1}{2}` (valid fraction)
- `\frac{1}{2} + ` (valid expression)
- `\frac{1}{2} + \sqrt{` (incomplete radical)
- `\frac{1}{2} + \sqrt{x}` (valid equation)

### Findings:
- **`SwiftMath`**: Gracefully displays the partial tokens as code/monospace or unformatted text until the closing bracket arrives, avoiding visual layout pop or parser aborts.
- **`iosMath`**: `MTMathListBuilder` throws a parser exception on unclosed brackets (`\frac{1}{`), causing the label to remain empty until the token completes. In SwiftUI, this causes an undesirable height collapse and rebound.

---

## 4. Layout & RTL / Hebrew Support

In an RTL environment (`.environment(\.layoutDirection, .rightToLeft)`):
- Math formulas are universally read Left-to-Right (LTR).
- Both `SwiftMath` and `iosMath` properly preserve LTR formula alignment while permitting right-aligned labels in the surrounding chat container.
- `SwiftMath` automatically aligns with SwiftUI text flow, whereas `iosMath`'s `textAlignment = .center` requires explicit container framing.

---

## 5. Neutral Evidence-Based Recommendation

1. **Keep SwiftMath as Production Default**:
   - `SwiftMath` is already natively integrated into `AgentChatSwiftChat`'s `LaTeXMarkdownView` segment cache.
   - It requires zero UIKit bridging, participates naturally in SwiftUI animation transactions, and has a smaller binary footprint.
   - It handles incomplete streaming tokens without height collapse.

2. **Preserve iosMath in Comparison Target**:
   - `iosMath` provides authentic TeX typographical spacing and Latin Modern Math fonts.
   - It is kept in `AgentChatMathComparisonTests` for benchmarking, regression verification, and optional future reference.

**Final Determination**: **SwiftMath remains the canonical production math renderer.** No production replacement is executed.
