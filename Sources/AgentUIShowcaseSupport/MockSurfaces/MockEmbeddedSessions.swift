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
    }
}
#endif
