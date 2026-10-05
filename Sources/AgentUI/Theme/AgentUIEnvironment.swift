// Sources/AgentUI/Theme/AgentUIEnvironment.swift
#if canImport(SwiftUI)
import SwiftUI

extension EnvironmentValues {
    @Entry public var agentUITheme: AgentUITheme = .default
    @Entry public var agentUIDesignTokens: AgentUIDesignTokens = .default
}

extension View {
    public func agentUITheme(_ theme: AgentUITheme) -> some View {
        self.environment(\.agentUITheme, theme)
            .environment(\.agentUIDesignTokens, theme.tokens)
    }

    public func agentUIDesignTokens(_ tokens: AgentUIDesignTokens) -> some View {
        self.environment(\.agentUIDesignTokens, tokens)
    }
}
#endif
