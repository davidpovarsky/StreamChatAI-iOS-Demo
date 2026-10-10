# Comprehensive A/B Test Report: SwiftMath vs. iosMath

**Document Purpose**: Objective, side-by-side technical evaluation of `SwiftMath` (Incumbent Production Renderer) and `iosMath` (Candidate Evaluated Renderer from ChatGPT iOS Dependency Disclosures).

> [!IMPORTANT]
> **Production Status Confirmation**: Production in `AgentChatSDK` / `AgentChatSwiftChat` **remains 100% on `SwiftMath`** (`LaTeXMarkdownView`). `iosMath` is linked strictly inside the isolated comparison target `AgentChatMathComparisonTests` for A/B testing and benchmarking.

---

## 1. Classification Methodology

To ensure truthful, verifiable documentation, all statements in this report are categorized into:
- **[Measured]**: Empirically asserted in automated test suite (`MathComparisonTests.swift`).
- **[Observed in Snapshots]**: Visually inspected via comparison snapshot fixtures.
- **[Derived from Upstream Documentation]**: Sourced from official package repositories and Apple developer documentation.
- **[Not Measured]**: Qualitative engineering assessments not instrumented for micro-benchmarks.

---

## 2. Executive Summary & Comparison Matrix

| Evaluation Dimension | `SwiftMath` (`mgriebling/SwiftMath` via `swiftui-math`) | `iosMath` (`kostub/iosMath` via `MTMathUILabel`) | Classification | Analysis & Tradeoffs |
|---|---|---|---|---|
| **Production Role** | **Canonical Production Default** | **Isolated Test/Comparison Harness Only** | *Architectural Decision* | SwiftMath is already integrated into SwiftChat's AST tokenizer and cell cache. |
| **Upstream Maintenance** | Active Swift package; Swift 6 / modern Concurrency compatible. | Active Swift package; modern SPM support. | *[Derived from Upstream]* | Both packages are actively maintained SPM packages. |
| **Rendering Technology** | Native SwiftUI / CoreGraphics & CoreText vector path drawing. | Native UIKit `MTMathUILabel` using TeX font typesetting engine. | *[Derived from Upstream]* | Both render natively without WebKit/WKWebView overhead. |
| **Package Integration & Footprint** | Pure Swift library; standard font assets. | Objective-C/Swift package; bundles Latin Modern Math OTF fonts. | *[Derived from Upstream / Not Measured]* | SwiftMath has lower overhead; iosMath bundles complete TeX font OTFs. |
| **SwiftUI Ergonomics** | Direct `MathView(equation:)` SwiftUI component. | Requires `UIViewRepresentable` bridge (`IOSMathViewBridge`). | *[Measured in Harness]* | SwiftMath integrates natively into declarative SwiftUI stacks without bridging. |
| **Dynamic Height & Sizing** | Native SwiftUI intrinsic content size and layout negotiation. | Requires auto-layout compression resistance hooks to avoid clipping in `ScrollView`. | *[Observed in Snapshots]* | SwiftMath participates naturally in SwiftUI layout passes. |
| **Inline Math** (`$E=mc^2$`) | Excellent; fits smoothly into surrounding text baselines. | Good; requires font size matching to surrounding text label. | *[Observed in Snapshots]* | SwiftMath renders smoothly within `LaTeXMarkdownView` segments. |
| **Display Math** (`$$\frac{a}{b}$$`) | Crisp vector rendering; proper fraction bar alignment. | Classical Donald Knuth TeX typesetting rules and spacing. | *[Observed in Snapshots]* | iosMath has authentic TeX typography; SwiftMath is sharper in modern flat UI. |
| **Matrices & Arrays** | Supports standard `\begin{pmatrix}` and tabular arrays. | Full LaTeX array support with customizable bracket types. | *[Measured in Harness]* | Both parse and render 2x2 and NxM matrices without crashing. |
| **Unicode & Hebrew** | Preserves mathematical LTR ordering within RTL containers. | Handles Unicode inside `\text{}`; LTR formula layout inside RTL containers. | *[Measured in Harness]* | Both preserve mathematical LTR ordering when enclosed in an RTL Hebrew view hierarchy. |
| **Dark Mode Adaptation** | Immediate automatic SwiftUI environment color scheme response. | Requires updating `textColor` in `updateUIView(_:context:)`. | *[Observed in Snapshots]* | SwiftMath dynamically responds to `.colorScheme` changes without manual invalidation. |
| **Streaming Token Influx** | Returns nil / parser error during incomplete syntax; no crash. | Returns nil / parser error during incomplete syntax; no crash. | *[Measured in Harness]* | Both fail gracefully on incomplete tokens and recover once tokens are closed. |

---

## 3. Benchmark Fixtures Evaluated

The isolated test suite `AgentChatMathComparisonTests` evaluates the following exact formula fixtures across both engines:

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
   *Evaluated at 320 pt (narrow iPhone), 400 pt (standard iPhone), and 768 pt (iPad).*
8. **Mixed Text and Math**:
   $$\text{For all } x > 0, \quad \ln(x) \le x - 1$$
9. **Unicode & Hebrew UI Context**:
   $$\text{משוואת איינשטיין: } E = mc^2$$

---

## 4. Streaming Stability & Progressive Generation [Measured in Harness]

During live token generation, LLMs stream LaTeX incrementally. The automated test `testStreamingMathProgressiveIncrements()` evaluates the progressive sequence:
- `\frac{1}{` (incomplete fraction)
- `\frac{1}{2}` (valid fraction)
- `\frac{1}{2} + ` (valid expression)
- `\frac{1}{2} + \sqrt{` (incomplete radical)
- `\frac{1}{2} + \sqrt{x}` (valid equation)
- `\frac{1}{2} + \sqrt{x} = 0` (complete statement)

### Verified Findings:
- **`SwiftMath`**: `SwiftMath.MTMathListBuilder(string: token).build()` safely returns `nil` and records an error for incomplete syntax tokens (`\frac{1}{`, `\sqrt{`), without throwing an unhandled exception or crashing. Upon receiving closed brackets, valid `MTMathList` objects are produced.
- **`iosMath`**: `iosMath.MTMathListBuilder(string: token).build()` safely returns `nil` and populates `builder.error` and `label.error` for incomplete syntax tokens without crashing.
- **Summary**: Neither engine crashes during progressive streaming influx.

---

## 5. Layout & RTL / Hebrew Support [Observed in Snapshots]

In an RTL environment (`.environment(\.layoutDirection, .rightToLeft)`):
- Math formulas are universally read Left-to-Right (LTR).
- Both `SwiftMath` and `iosMath` preserve LTR formula alignment while permitting right-aligned labels in the surrounding chat container.
- `SwiftMath` automatically aligns with SwiftUI text flow, whereas `iosMath`'s `textAlignment = .center` requires container styling.

---

## 6. Neutral Evidence-Based Recommendation

1. **Keep SwiftMath as Production Default**:
   - `SwiftMath` is natively integrated into `AgentChatSwiftChat`'s `LaTeXMarkdownView` segment cache.
   - It requires zero UIKit bridging, participates naturally in SwiftUI animation transactions, and has a lower binary footprint.
   - It handles incomplete streaming tokens without crashing.

2. **Preserve iosMath in Comparison Target**:
   - `iosMath` provides authentic TeX typographical spacing and Latin Modern Math fonts.
   - It is kept in `AgentChatMathComparisonTests` for benchmarking, regression verification, and reference.

**Final Determination**: **SwiftMath remains the canonical production math renderer.** No production replacement is executed.
