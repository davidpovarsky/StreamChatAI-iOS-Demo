// Sources/AgentUIShowcaseSupport/MockSurfaces/MockEmbeddedSessions.swift
#if canImport(SwiftUI)
import SwiftUI
import AgentUI

public enum MockEmbeddedSessions {
    @MainActor
    public static func registerAll(in registry: AgentEmbeddedSurfaceRegistry) {
        registry.registerResolver(for: "miniapp.form") { descriptor in
            AnyAgentEmbeddedResultSession(
                rootView: { AnyView(MockMiniAppFormView()) },
                tearDown: {}
            )
        }

        registry.registerResolver(for: "sefaria.source") { descriptor in
            AnyAgentEmbeddedResultSession(
                rootView: { AnyView(MockSefariaSourceCardView()) },
                tearDown: {}
            )
        }

        registry.registerResolver(for: "wikipedia.summary") { descriptor in
            AnyAgentEmbeddedResultSession(
                rootView: {
                    AnyView(
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Image(systemName: "globe")
                                Text("Wikipedia Summary")
                                    .font(.subheadline.weight(.bold))
                            }
                            Text("The Swift programming language is a general-purpose, multi-paradigm, compiled programming language developed by Apple Inc.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(12)
                    )
                },
                tearDown: {}
            )
        }

        registry.registerResolver(for: "embedded.test.card") { descriptor in
            AnyAgentEmbeddedResultSession(
                rootView: {
                    AnyView(
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "square.grid.2x2")
                                    .foregroundStyle(.blue)
                                Text(descriptor.title ?? "Interactive Embedded Surface")
                                    .font(.subheadline.weight(.semibold))
                            }
                            Text("Active session rendering inline content with support for full-screen and sheet modals.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(12)
                    )
                },
                tearDown: {}
            )
        }
    }
}
#endif
