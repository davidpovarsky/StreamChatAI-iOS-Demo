// Sources/AgentUI/Tools/AgentToolSurfaceRegistry.swift
#if canImport(SwiftUI)
import SwiftUI

@MainActor
public final class AgentToolSurfaceRegistry {
    public static let shared = AgentToolSurfaceRegistry()

    private var providers: [String: AnyAgentToolSurfaceProvider] = [:]

    public init() {}

    public func registerToolHandler<V: View>(
        _ handlerID: String,
        @ViewBuilder builder: @escaping @MainActor @Sendable (AgentToolSurfaceContext) -> V
    ) {
        providers[handlerID] = AnyAgentToolSurfaceProvider(builder)
    }

    public func registerProvider(_ provider: AnyAgentToolSurfaceProvider, for handlerID: String) {
        providers[handlerID] = provider
    }

    public func provider(for handlerID: String) -> AnyAgentToolSurfaceProvider? {
        providers[handlerID]
    }

    @ViewBuilder
    public func resolve(execution: AgentToolExecution) -> some View {
        if let provider = providers[execution.handlerID] {
            provider.makeBody(context: AgentToolSurfaceContext(execution: execution))
        } else {
            DefaultToolPresentationView(execution: execution)
        }
    }
}

public struct DefaultToolPresentationView: View {
    public let execution: AgentToolExecution

    public init(execution: AgentToolExecution) {
        self.execution = execution
    }

    public var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "wrench.and.screwdriver")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.primary)
                .frame(width: 24, height: 24)
                .background(Color.primary.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 6))

            VStack(alignment: .leading, spacing: 1) {
                Text(execution.inspection.toolName)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                if let service = execution.inspection.service {
                    Text(service)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

extension EnvironmentValues {
    @Entry public var agentToolSurfaces: AgentToolSurfaceRegistry? = nil
}
#endif
