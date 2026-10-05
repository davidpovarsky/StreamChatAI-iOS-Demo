// Sources/AgentUI/Rendering/AgentMathView.swift
#if canImport(SwiftUI)
import SwiftUI

public struct AgentMathView: View {
    public let formula: String
    public let isBlock: Bool

    @Environment(\.agentUITheme) private var theme
    @Environment(\.agentUIDesignTokens) private var tokens

    public init(formula: String, isBlock: Bool = true) {
        self.formula = formula
        self.isBlock = isBlock
    }

    private var ast: MathAST {
        AgentMathParser.parse(formula)
    }

    public var body: some View {
        if isBlock {
            HStack {
                Spacer()
                MathASTView(ast: ast, isBlock: true, baseSize: 18)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(theme.surfaceBackground)
                    .clipShape(RoundedRectangle(cornerRadius: tokens.cardCornerRadius))
                    .overlay(
                        RoundedRectangle(cornerRadius: tokens.cardCornerRadius)
                            .strokeBorder(theme.borderColor, lineWidth: 0.5)
                    )
                Spacer()
            }
            .padding(.vertical, 6)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Math formula: \(formula)")
        } else {
            MathASTView(ast: ast, isBlock: false, baseSize: 15)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Math formula: \(formula)")
        }
    }
}

public struct MathASTView: View {
    public let ast: MathAST
    public let isBlock: Bool
    public let baseSize: CGFloat
    public let scale: CGFloat

    public init(ast: MathAST, isBlock: Bool = true, baseSize: CGFloat = 16, scale: CGFloat = 1.0) {
        self.ast = ast
        self.isBlock = isBlock
        self.baseSize = baseSize
        self.scale = scale
    }

    private var currentSize: CGFloat {
        baseSize * scale
    }

    public var body: some View {
        switch ast {
        case .variable(let s):
            Text(s)
                .font(.system(size: currentSize, design: .serif).italic())
                .foregroundStyle(Color.primary)

        case .number(let n):
            Text(n)
                .font(.system(size: currentSize, design: .serif))
                .foregroundStyle(Color.primary)

        case .op(let o):
            Text(o)
                .font(.system(size: currentSize, weight: .regular, design: .serif))
                .foregroundStyle(Color.primary)
                .padding(.horizontal, 2)

        case .symbol(let s):
            Text(s)
                .font(.system(size: currentSize, design: .serif))
                .foregroundStyle(Color.primary)

        case .fraction(let num, let den):
            VStack(spacing: 2) {
                MathASTView(ast: num, isBlock: isBlock, baseSize: baseSize, scale: scale * 0.9)
                Rectangle()
                    .fill(Color.primary)
                    .frame(height: max(1.0, currentSize * 0.07))
                MathASTView(ast: den, isBlock: isBlock, baseSize: baseSize, scale: scale * 0.9)
            }
            .padding(.horizontal, 3)
            .fixedSize()

        case .squareRoot(let rad):
            HStack(alignment: .top, spacing: 1) {
                Text("√")
                    .font(.system(size: currentSize * 1.25, weight: .light, design: .serif))
                    .foregroundStyle(Color.primary)
                VStack(spacing: 2) {
                    Rectangle()
                        .fill(Color.primary)
                        .frame(height: max(1.0, currentSize * 0.07))
                    MathASTView(ast: rad, isBlock: isBlock, baseSize: baseSize, scale: scale)
                        .padding(.horizontal, 2)
                        .padding(.top, 1)
                }
            }
            .fixedSize()

        case .superscript(let base, let exp):
            HStack(alignment: .bottom, spacing: 1) {
                MathASTView(ast: base, isBlock: isBlock, baseSize: baseSize, scale: scale)
                MathASTView(ast: exp, isBlock: isBlock, baseSize: baseSize, scale: scale * 0.72)
                    .offset(y: -currentSize * 0.42)
            }

        case .subscripted(let base, let sub):
            HStack(alignment: .bottom, spacing: 1) {
                MathASTView(ast: base, isBlock: isBlock, baseSize: baseSize, scale: scale)
                MathASTView(ast: sub, isBlock: isBlock, baseSize: baseSize, scale: scale * 0.72)
                    .offset(y: currentSize * 0.25)
            }

        case .sequence(let items):
            HStack(alignment: .center, spacing: 1) {
                ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                    MathASTView(ast: item, isBlock: isBlock, baseSize: baseSize, scale: scale)
                }
            }

        case .empty:
            EmptyView()
        }
    }
}
#endif
