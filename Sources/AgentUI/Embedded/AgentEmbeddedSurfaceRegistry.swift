// Sources/AgentUI/Embedded/AgentEmbeddedSurfaceRegistry.swift
#if canImport(SwiftUI)
import SwiftUI

@MainActor
public final class AgentEmbeddedSurfaceRegistry {
    public static let shared = AgentEmbeddedSurfaceRegistry()

    public typealias Resolver = @MainActor (AgentEmbeddedPresentationDescriptor) -> (any AgentEmbeddedResultSession)?
    private var resolvers: [String: Resolver] = [:]

    public init() {}

    public func registerResolver(for handlerID: String, resolver: @escaping Resolver) {
        resolvers[handlerID] = resolver
    }

    public func resolve(descriptor: AgentEmbeddedPresentationDescriptor) -> (any AgentEmbeddedResultSession)? {
        if let resolver = resolvers[descriptor.handlerID] {
            return resolver(descriptor)
        }
        return nil
    }
}

private struct AgentEmbeddedSurfaceRegistryKey: EnvironmentKey {
    static let defaultValue: AgentEmbeddedSurfaceRegistry? = nil
}

extension EnvironmentValues {
    @MainActor
    public var agentEmbeddedSurfaces: AgentEmbeddedSurfaceRegistry {
        get { self[AgentEmbeddedSurfaceRegistryKey.self] ?? AgentEmbeddedSurfaceRegistry.shared }
        set { self[AgentEmbeddedSurfaceRegistryKey.self] = newValue }
    }
}
#endif
