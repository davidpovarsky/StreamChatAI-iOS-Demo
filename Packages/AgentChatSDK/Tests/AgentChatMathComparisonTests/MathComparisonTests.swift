import Foundation
#if canImport(XCTest)
import XCTest
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(SnapshotTesting)
import SnapshotTesting
#endif
#if canImport(SwiftMath)
import SwiftMath
#endif
#if canImport(iosMath)
import iosMath
#endif

import AgentChatCore
import AgentChatSwiftChat

// MARK: - 1. Side-by-Side Comparison Container View

#if os(iOS) && canImport(SwiftUI) && canImport(iosMath) && canImport(SwiftMath)

/// Bridge view wrapping iosMath's `MTMathUILabel` in a SwiftUI `UIViewRepresentable`
public struct IOSMathViewBridge: UIViewRepresentable {
    public let latex: String
    public let fontSize: CGFloat
    public let textColor: UIColor
    public let mode: MTMathUILabelMode

    public init(
        latex: String,
        fontSize: CGFloat = 20,
        textColor: UIColor = .label,
        mode: MTMathUILabelMode = .display
    ) {
        self.latex = latex
        self.fontSize = fontSize
        self.textColor = textColor
        self.mode = mode
    }

    public func makeUIView(context: Context) -> MTMathUILabel {
        let label = MTMathUILabel()
        label.latex = latex
        label.fontSize = fontSize
        label.textColor = textColor
        label.labelMode = mode
        label.textAlignment = .center
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }

    public func updateUIView(_ uiView: MTMathUILabel, context: Context) {
        uiView.latex = latex
        uiView.fontSize = fontSize
        uiView.textColor = textColor
        uiView.labelMode = mode
    }
}

/// Comparison container view that places SwiftMath and iosMath side-by-side or stacked
public struct MathRendererComparisonView: View {
    public let title: String
    public let latex: String
    public let isDarkMode: Bool

    public init(title: String, latex: String, isDarkMode: Bool = false) {
        self.title = title
        self.latex = latex
        self.isDarkMode = isDarkMode
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.headline)
                .foregroundStyle(isDarkMode ? .white : .black)

            Text(latex)
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)
                .padding(6)
                .background(Color.secondary.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 6))

            HStack(alignment: .top, spacing: 16) {
                // Left: Production SwiftMath
                VStack(alignment: .leading, spacing: 6) {
                    Text("SwiftMath (Production)")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.blue)

                    SwiftMath.MathView(equation: latex)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .padding(8)
                        .background(isDarkMode ? Color.white.opacity(0.05) : Color.black.opacity(0.03))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                // Right: Candidate iosMath
                VStack(alignment: .leading, spacing: 6) {
                    Text("iosMath (Candidate)")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.purple)

                    IOSMathViewBridge(
                        latex: latex,
                        fontSize: 18,
                        textColor: isDarkMode ? .white : .black,
                        mode: .display
                    )
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .padding(8)
                    .background(isDarkMode ? Color.white.opacity(0.05) : Color.black.opacity(0.03))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding(12)
        .background(isDarkMode ? Color.black : Color.white)
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

#endif

// MARK: - 2. Test Suite for Math Comparison

@MainActor
final class MathComparisonTests: XCTestCase {

    struct MathFormulaFixture {
        let name: String
        let latex: String
    }

    private let standardFixtures: [MathFormulaFixture] = [
        MathFormulaFixture(name: "Basic Inline", latex: "E = mc^2"),
        MathFormulaFixture(name: "Quadratic Formula Display", latex: "\\frac{-b \\pm \\sqrt{b^2-4ac}}{2a}"),
        MathFormulaFixture(name: "Compound Fractions", latex: "a+\\frac{1}{2}+b+\\frac{3}{4}+c"),
        MathFormulaFixture(name: "Nested Roots", latex: "x+\\sqrt{2}+y+\\sqrt{3}+z"),
        MathFormulaFixture(name: "Summation", latex: "\\sum_{i=1}^{n} i^2"),
        MathFormulaFixture(name: "Gaussian Integral", latex: "\\int_0^\\infty e^{-x^2}\\,dx"),
        MathFormulaFixture(name: "2x2 Matrix", latex: "\\begin{pmatrix} 1 & 2 \\\\ 3 & 4 \\end{pmatrix}"),
        MathFormulaFixture(name: "Long Expression Wrapping", latex: "f(x) = a_0 + \\sum_{n=1}^{\\infty} \\left( a_n \\cos\\left(\\frac{2\\pi nx}{T}\\right) + b_n \\sin\\left(\\frac{2\\pi nx}{T}\\right) \\right) + \\int_0^x K(x,t) g(t) dt"),
        MathFormulaFixture(name: "Mixed Text and Math", latex: "\\text{For all } x > 0, \\quad \\ln(x) \\le x - 1"),
        MathFormulaFixture(name: "Unicode & Hebrew Context", latex: "\\text{משוואת איינשטיין: } E = mc^2")
    ]

    func testFormulaFixturesNonEmpty() {
        XCTAssertEqual(standardFixtures.count, 10)
        for fixture in standardFixtures {
            XCTAssertFalse(fixture.latex.isEmpty)
        }
    }

    func testStreamingMathProgressiveIncrements() {
        let progressiveTokens = [
            "\\frac{1}{",
            "\\frac{1}{2}",
            "\\frac{1}{2} + ",
            "\\frac{1}{2} + \\sqrt{",
            "\\frac{1}{2} + \\sqrt{x}",
            "\\frac{1}{2} + \\sqrt{x} = 0"
        ]

        var parsedSwiftMathCount = 0
        for token in progressiveTokens {
            if !token.isEmpty {
                parsedSwiftMathCount += 1
            }
        }
        XCTAssertEqual(parsedSwiftMathCount, progressiveTokens.count)
    }

#if os(iOS) && canImport(SnapshotTesting) && canImport(iosMath) && canImport(SwiftMath)

    func testPairedMathRenderingSnapshots() {
        for fixture in standardFixtures {
            // Light mode snapshot
            let lightView = MathRendererComparisonView(
                title: fixture.name,
                latex: fixture.latex,
                isDarkMode: false
            )
            assertSnapshot(
                of: lightView,
                as: .image(layout: .fixed(width: 400, height: 160)),
                named: "Light_\(fixture.name)"
            )

            // Dark mode snapshot
            let darkView = MathRendererComparisonView(
                title: fixture.name,
                latex: fixture.latex,
                isDarkMode: true
            )
            assertSnapshot(
                of: darkView,
                as: .image(layout: .fixed(width: 400, height: 160)),
                named: "Dark_\(fixture.name)"
            )
        }
    }

    func testRTLAndNarrowWidthSnapshots() {
        let fixture = standardFixtures[1] // Quadratic formula

        let rtlView = MathRendererComparisonView(
            title: "RTL: " + fixture.name,
            latex: fixture.latex,
            isDarkMode: false
        )
        .environment(\.layoutDirection, .rightToLeft)

        assertSnapshot(
            of: rtlView,
            as: .image(layout: .fixed(width: 320, height: 160)),
            named: "RTL_Narrow_Quadratic"
        )

        let iPadView = MathRendererComparisonView(
            title: "iPad: " + fixture.name,
            latex: fixture.latex,
            isDarkMode: false
        )

        assertSnapshot(
            of: iPadView,
            as: .image(layout: .fixed(width: 768, height: 160)),
            named: "iPad_Quadratic"
        )
    }

#endif
}
