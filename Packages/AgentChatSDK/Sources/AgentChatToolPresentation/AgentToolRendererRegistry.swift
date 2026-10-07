#if canImport(SwiftUI)
import SwiftUI

/// Extensible registry allowing host applications to supply custom SwiftUI result views for specific tool names.
@MainActor
public final class AgentToolRendererRegistry: ObservableObject {
    public static let shared = AgentToolRendererRegistry()

    public typealias CustomRenderer = @MainActor (ToolCallInspection, ToolExecutionStatus) -> AnyView

    private var customRenderers: [String: CustomRenderer] = [:]

    public init() {}

    public func register(toolName: String, renderer: @escaping CustomRenderer) {
        customRenderers[toolName] = renderer
    }

    public func customView(for toolName: String, inspection: ToolCallInspection, status: ToolExecutionStatus) -> AnyView? {
        customRenderers[toolName]?(inspection, status)
    }

    public func hasCustomRenderer(for toolName: String) -> Bool {
        customRenderers[toolName] != nil
    }
}
#endif
