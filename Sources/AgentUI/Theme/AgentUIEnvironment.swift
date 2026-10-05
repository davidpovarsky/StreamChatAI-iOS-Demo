// Sources/AgentUI/Theme/AgentUIEnvironment.swift
#if canImport(SwiftUI)
import SwiftUI

private struct AgentUIThemeKey: EnvironmentKey {
    static let defaultValue = AgentUITheme.default
}

private struct AgentUIDesignTokensKey: EnvironmentKey {
    static let defaultValue = AgentUIDesignTokens.default
}

extension EnvironmentValues {
    public var agentUITheme: AgentUITheme {
        get { self[AgentUIThemeKey.self] }
        set { self[AgentUIThemeKey.self] = newValue }
    }

    public var agentUIDesignTokens: AgentUIDesignTokens {
        get { self[AgentUIDesignTokensKey.self] }
        set { self[AgentUIDesignTokensKey.self] = newValue }
    }
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
