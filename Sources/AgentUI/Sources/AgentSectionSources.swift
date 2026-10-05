// Sources/AgentUI/Sources/AgentSectionSources.swift
#if canImport(SwiftUI)
import SwiftUI

public struct AgentSectionSources: View {
    public let sectionID: String
    public let sources: [AgentSource]

    @State private var isSheetPresented = false
    @Environment(\.agentUITheme) private var theme

    public init(sectionID: String, sources: [AgentSource]) {
        self.sectionID = sectionID
        self.sources = sources
    }

    public var body: some View {
        Button {
            isSheetPresented = true
        } label: {
            HStack(spacing: 4) {
                AgentSourceCluster(sources: sources)
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(theme.surfaceBackground)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $isSheetPresented) {
            AgentSourcesSheet(title: "Section Sources", sources: sources)
                .presentationDetents([.medium, .large])
        }
        .accessibilityLabel("Section sources (\(sources.count))")
    }
}

public struct AgentSourcesFooterPill: View {
    public let sources: [AgentSource]

    @State private var isSheetPresented = false
    @Environment(\.agentUITheme) private var theme

    public init(sources: [AgentSource]) {
        self.sources = sources
    }

    public var body: some View {
        Button {
            isSheetPresented = true
        } label: {
            HStack(spacing: 6) {
                AgentSourceCluster(sources: sources, maxVisible: 3)
                Text("Sources")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(theme.secondaryText)
                Text("\(sources.count)")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(theme.tertiaryText)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(theme.surfaceBackground)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $isSheetPresented) {
            AgentSourcesSheet(title: "All Sources", sources: sources)
                .presentationDetents([.medium, .large])
        }
        .accessibilityLabel("All sources for message (\(sources.count))")
        .padding(.top, 4)
    }
}
#endif
