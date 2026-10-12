import SwiftUI
import AgentChatCore

public struct AgentSourceChipsView: View {
    public let sources: [WebSearchSource]
    public let onSelectSource: ((WebSearchSource) -> Void)?

    @State private var showingSheet = false

    public init(sources: [WebSearchSource], onSelectSource: ((WebSearchSource) -> Void)? = nil) {
        self.sources = sources
        self.onSelectSource = onSelectSource
    }

    private func domain(for urlString: String) -> String {
        guard let url = URL(string: urlString), let host = url.host else {
            return urlString
        }
        return host.hasPrefix("www.") ? String(host.dropFirst(4)) : host
    }

    private var uniqueDomains: [(domain: String, source: WebSearchSource)] {
        var seen = Set<String>()
        var list: [(String, WebSearchSource)] = []
        for src in sources {
            let d = domain(for: src.url)
            if !seen.contains(d) {
                seen.insert(d)
                list.append((d, src))
            }
        }
        return list
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(uniqueDomains, id: \.domain) { item in
                    Button {
                        if let onSelect = onSelectSource {
                            onSelect(item.source)
                        } else {
                            showingSheet = true
                        }
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "globe")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                            Text(item.domain)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.primary)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.secondary.opacity(0.12))
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Source domain: \(item.domain)")
                }

                if sources.count > uniqueDomains.count {
                    Button {
                        showingSheet = true
                    } label: {
                        Text("+\(sources.count - uniqueDomains.count) more")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color.secondary.opacity(0.08))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 2)
        }
        .sheet(isPresented: $showingSheet) {
            SourcesSheetView(sources: sources, isDarkMode: false)
                .presentationDetents([.medium, .large])
        }
    }
}
