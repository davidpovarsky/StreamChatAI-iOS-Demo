#if canImport(SwiftUI)
import AgentChatCore
import SwiftUI

public struct InlineSectionSourcesView: View {
    public let sources: [AgentSource]
    public let onSelectSource: ((AgentSource) -> Void)?

    @State private var showingSheet = false

    public init(sources: [AgentSource], onSelectSource: ((AgentSource) -> Void)? = nil) {
        self.sources = sources
        self.onSelectSource = onSelectSource
    }

    public var body: some View {
        if !sources.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(sources.prefix(4))) { source in
                            sourceChip(for: source)
                        }

                        if sources.count > 4 {
                            Button {
                                showingSheet = true
                            } label: {
                                Text("+\(sources.count - 4) more")
                                    .font(.system(size: 11, weight: .semibold))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color.secondary.opacity(0.12), in: Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(.vertical, 4)
            .sheet(isPresented: $showingSheet) {
                SourcesSheetView(sources: sources)
            }
        }
    }

    private func sourceChip(for source: AgentSource) -> some View {
        Button {
            if let onSelect = onSelectSource {
                onSelect(source)
            } else if let url = URL(string: source.url) {
                #if canImport(UIKit)
                UIApplication.shared.open(url)
                #endif
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "link")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)

                Text(source.domain)
                    .font(.system(size: 11, weight: .medium))
                    .lineLimit(1)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.secondary.opacity(0.1), in: Capsule())
            .overlay(
                Capsule().strokeBorder(Color.primary.opacity(0.06), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
    }
}

public struct SourcesSheetView: View {
    public let sources: [AgentSource]
    @Environment(\.dismiss) private var dismiss

    public init(sources: [AgentSource]) {
        self.sources = sources
    }

    public var body: some View {
        NavigationStack {
            List(sources) { source in
                Link(destination: URL(string: source.url) ?? URL(string: "https://google.com")!) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(source.title)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.primary)

                        Text(source.domain)
                            .font(.caption)
                            .foregroundStyle(.blue)

                        if let snippet = source.snippet {
                            Text(snippet)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Sources (\(sources.count))")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
#endif
