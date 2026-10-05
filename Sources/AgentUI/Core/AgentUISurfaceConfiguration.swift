// Sources/AgentUI/Core/AgentUISurfaceConfiguration.swift
#if canImport(SwiftUI)
import SwiftUI

@MainActor
public struct AgentUISurfaceConfiguration {
    public let toolRegistry: AgentToolSurfaceRegistry
    public let embeddedRegistry: AgentEmbeddedSurfaceRegistry

    public init(
        toolRegistry: AgentToolSurfaceRegistry = AgentToolSurfaceRegistry(),
        embeddedRegistry: AgentEmbeddedSurfaceRegistry = AgentEmbeddedSurfaceRegistry()
    ) {
        self.toolRegistry = toolRegistry
        self.embeddedRegistry = embeddedRegistry
    }
}
#endif
