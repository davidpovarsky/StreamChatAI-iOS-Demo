// Sources/AgentUI/Theme/AgentUITheme.swift
import Foundation

#if canImport(SwiftUI)
import SwiftUI

public struct AgentUITheme: Sendable, Equatable {
    public var accentColor: Color
    public var userBubbleBackground: Color
    public var userBubbleForeground: Color
    public var assistantBubbleBackground: Color
    public var surfaceBackground: Color
    public var primaryText: Color
    public var secondaryText: Color
    public var tertiaryText: Color
    public var borderColor: Color
    public var codeBackground: Color
    public var errorColor: Color
    public var tokens: AgentUIDesignTokens

    public init(
        accentColor: Color = .blue,
        userBubbleBackground: Color = .blue,
        userBubbleForeground: Color = .white,
        assistantBubbleBackground: Color = Color.clear,
        surfaceBackground: Color = Color.secondary.opacity(0.08),
        primaryText: Color = .primary,
        secondaryText: Color = .secondary,
        tertiaryText: Color = Color.secondary.opacity(0.6),
        borderColor: Color = Color.primary.opacity(0.12),
        codeBackground: Color = Color.secondary.opacity(0.10),
        errorColor: Color = .orange,
        tokens: AgentUIDesignTokens = .default
    ) {
        self.accentColor = accentColor
        self.userBubbleBackground = userBubbleBackground
        self.userBubbleForeground = userBubbleForeground
        self.assistantBubbleBackground = assistantBubbleBackground
        self.surfaceBackground = surfaceBackground
        self.primaryText = primaryText
        self.secondaryText = secondaryText
        self.tertiaryText = tertiaryText
        self.borderColor = borderColor
        self.codeBackground = codeBackground
        self.errorColor = errorColor
        self.tokens = tokens
    }

    public static let `default` = AgentUITheme()
}
#else
public struct AgentUITheme: Sendable, Equatable {
    public var accentColorHex: String
    public var tokens: AgentUIDesignTokens

    public init(
        accentColorHex: String = "#007AFF",
        tokens: AgentUIDesignTokens = .default
    ) {
        self.accentColorHex = accentColorHex
        self.tokens = tokens
    }

    public static let `default` = AgentUITheme()
}
#endif
