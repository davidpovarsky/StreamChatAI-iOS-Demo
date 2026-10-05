//
//  WebSearchBox.swift
//  AgentUI
//
//  Extracted existing WebSearchBox unchanged.
//

import SwiftUI
import UIKit

public struct NoHighlightButtonStyle: ButtonStyle {
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

public struct PulsingAnimation: ViewModifier {
    public let delay: Double
    @State private var isPulsing = false

    public init(delay: Double = 0.0) {
        self.delay = delay
    }

    public func body(content: Content) -> some View {
        content
            .opacity(isPulsing ? 1.0 : 0.3)
            .animation(
                .easeInOut(duration: 0.6)
                    .repeatForever(autoreverses: true)
                    .delay(delay),
                value: isPulsing
            )
            .onAppear {
                isPulsing = true
            }
    }
}

public struct SearchingDotsView: View {
    public let isDarkMode: Bool

    public init(isDarkMode: Bool) {
        self.isDarkMode = isDarkMode
    }

    public var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<3) { index in
                Circle()
                    .frame(width: 5, height: 5)
                    .modifier(PulsingAnimation(delay: 0.15 * Double(index)))
            }
        }
        .foregroundColor(.blue)
    }
}

public struct WebSearchBox: View {
    public let webSearchState: WebSearchState
    public let isDarkMode: Bool
    public let isStreaming: Bool
    public let webSearchSummary: String?
    public let onTap: () -> Void

    public init(
        webSearchState: WebSearchState,
        isDarkMode: Bool,
        isStreaming: Bool = false,
        webSearchSummary: String? = nil,
        onTap: @escaping () -> Void
    ) {
        self.webSearchState = webSearchState
        self.isDarkMode = isDarkMode
        self.isStreaming = isStreaming
        self.webSearchSummary = webSearchSummary
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: onTap) {
            HStack {
                headerContent
                Spacer()
                if webSearchState.status != .searching && !webSearchState.sources.isEmpty {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(isDarkMode ? .white.opacity(0.4) : .black.opacity(0.4))
                }
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(NoHighlightButtonStyle())
        .disabled(webSearchState.status == .searching || webSearchState.sources.isEmpty)
    }

    @ViewBuilder
    private var headerContent: some View {
        switch webSearchState.status {
        case .searching:
            HStack(spacing: 8) {
                SearchingDotsView(isDarkMode: isDarkMode)
                if let summary = webSearchSummary, !summary.isEmpty {
                    Text(summary)
                        .font(.subheadline)
                        .foregroundColor(isDarkMode ? .white : .black.opacity(0.8))
                        .lineLimit(1)
                        .truncationMode(.tail)
                } else if let query = webSearchState.query {
                    Text("Searching: \(query)")
                        .font(.subheadline)
                        .foregroundColor(isDarkMode ? .white : .black.opacity(0.8))
                        .lineLimit(1)
                        .truncationMode(.tail)
                } else {
                    Text("Searching the web...")
                        .font(.subheadline)
                        .foregroundColor(isDarkMode ? .white : .black.opacity(0.8))
                }
            }

        case .completed:
            HStack(spacing: 8) {
                Image(systemName: "globe")
                    .foregroundColor(.blue)
                    .font(.system(size: 14))

                if webSearchState.sources.isEmpty {
                    Text("Web search completed")
                        .font(.subheadline)
                        .foregroundColor(isDarkMode ? .white.opacity(0.7) : .black.opacity(0.6))
                } else {
                    Text("\(webSearchState.sources.count) source\(webSearchState.sources.count == 1 ? "" : "s") found")
                        .font(.subheadline)
                        .foregroundColor(isDarkMode ? .white.opacity(0.7) : .black.opacity(0.6))

                    sourceFavicons
                }
            }

        case .failed:
            HStack(spacing: 8) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
                    .font(.system(size: 14))
                Text("Search failed")
                    .font(.subheadline)
                    .foregroundColor(.red.opacity(0.8))
            }

        case .blocked:
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                    .font(.system(size: 14))
                Text(webSearchState.reason ?? "Search blocked")
                    .font(.subheadline)
                    .foregroundColor(.orange.opacity(0.8))
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
        }
    }

    @ViewBuilder
    private var sourceFavicons: some View {
        HStack(spacing: -4) {
            ForEach(Array(webSearchState.sources.prefix(4).enumerated()), id: \.element.id) { index, source in
                FaviconView(url: source.url, isDarkMode: isDarkMode)
                    .zIndex(Double(4 - index))
            }
            if webSearchState.sources.count > 4 {
                Text("+\(webSearchState.sources.count - 4)")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(isDarkMode ? .white.opacity(0.6) : .black.opacity(0.6))
                    .padding(.leading, 6)
            }
        }
    }
}

public struct SourceRowView: View {
    public let source: WebSearchSource
    public let isDarkMode: Bool

    public init(source: WebSearchSource, isDarkMode: Bool) {
        self.source = source
        self.isDarkMode = isDarkMode
    }

    private var displayHost: String {
        guard let url = URL(string: source.url),
              let host = url.host else { return source.url }
        return host.replacingOccurrences(of: "www.", with: "")
    }

    public var body: some View {
        Button(action: openURL) {
            HStack(spacing: 10) {
                FaviconView(url: source.url, isDarkMode: isDarkMode)

                VStack(alignment: .leading, spacing: 2) {
                    Text(source.title)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(isDarkMode ? .white : .black.opacity(0.85))
                        .lineLimit(1)
                        .truncationMode(.tail)

                    Text(displayHost)
                        .font(.system(size: 11))
                        .foregroundColor(isDarkMode ? .white.opacity(0.5) : .black.opacity(0.5))
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(isDarkMode ? .white.opacity(0.4) : .black.opacity(0.4))
            }
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func openURL() {
        guard let url = URL(string: source.url) else { return }
        UIApplication.shared.open(url)
    }
}
