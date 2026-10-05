// Showcase/Sources/ShowcaseApp.swift
import SwiftUI
import AgentUI
import AgentUIShowcaseSupport

@main
struct ShowcaseApp: App {
    init() {
        // Register mock tool and embedded surfaces once
        MockToolSurfaces.registerAll(in: AgentToolSurfaceRegistry.shared)
        MockEmbeddedSessions.registerAll(in: AgentEmbeddedSurfaceRegistry.shared)
    }

    var body: some Scene {
        WindowGroup {
            ShowcaseRootView()
        }
    }
}
