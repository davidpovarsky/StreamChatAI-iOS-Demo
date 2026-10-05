// Sources/AgentUI/Theme/AgentUIGlassStyle.swift
#if canImport(SwiftUI)
import SwiftUI

public struct AgentUIGlassModifier: ViewModifier {
    public let cornerRadius: CGFloat

    public init(cornerRadius: CGFloat = 14) {
        self.cornerRadius = cornerRadius
    }

    public func body(content: Content) -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            content
                .glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
        } else {
            content
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.5)
                )
        }
    }
}

extension View {
    public func agentGlassEffect(cornerRadius: CGFloat = 14) -> some View {
        self.modifier(AgentUIGlassModifier(cornerRadius: cornerRadius))
    }
}
#endif
