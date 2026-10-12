import SwiftUI
import AgentChatCore

@MainActor
public protocol AgentResultRenderer: Sendable {
    func canRender(result: AgentResult) -> Bool
    @ViewBuilder func render(result: AgentResult, onAction: @escaping (AgentChatUserAction) -> Void) -> AnyView
}

@MainActor
public final class AgentResultRendererRegistry {
    public static let shared = AgentResultRendererRegistry()

    private var customRenderers: [AgentResultKind: any AgentResultRenderer] = [:]

    public init() {}

    public func register(kind: AgentResultKind, renderer: any AgentResultRenderer) {
        customRenderers[kind] = renderer
    }

    public func unregister(kind: AgentResultKind) {
        customRenderers.removeValue(forKey: kind)
    }

    @ViewBuilder
    public func view(for result: AgentResult, onAction: @escaping (AgentChatUserAction) -> Void) -> some View {
        if let custom = customRenderers[result.kind], custom.canRender(result: result) {
            custom.render(result: result, onAction: onAction)
        } else {
            AgentResultDispatcher(result: result, onAction: onAction)
        }
    }
}
