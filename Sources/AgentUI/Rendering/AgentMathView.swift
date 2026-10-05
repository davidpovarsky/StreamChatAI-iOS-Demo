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

    public var body: some View {
        if isBlock {
            HStack {
                Spacer()
                Text(cleanFormula)
                    .font(.system(.body, design: .serif).italic())
                    .foregroundStyle(theme.primaryText)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(theme.surfaceBackground)
                    .clipShape(RoundedRectangle(cornerRadius: tokens.cardCornerRadius))
                Spacer()
            }
            .padding(.vertical, 4)
        } else {
            Text(cleanFormula)
                .font(.system(.body, design: .serif).italic())
                .foregroundStyle(theme.primaryText)
        }
    }

    private var cleanFormula: String {
        formula.trimmingCharacters(in: CharacterSet(charactersIn: "$ "))
    }
}
#endif
