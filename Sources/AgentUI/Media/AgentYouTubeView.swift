// Sources/AgentUI/Media/AgentYouTubeView.swift
#if canImport(SwiftUI)
import SwiftUI

#if canImport(WebKit)
import WebKit
#endif

public struct AgentYouTubeView: View {
    public let videoID: String
    public let title: String?
    public let subtitle: String?

    @State private var hasFailedLoading: Bool
    @Environment(\.agentUIDesignTokens) private var tokens

    public init(videoID: String, title: String? = nil, subtitle: String? = nil) {
        self.videoID = videoID
        self.title = title
        self.subtitle = subtitle
        let shouldFailImmediately = videoID.isEmpty || videoID.hasPrefix("invalid") || videoID == "error"
        self._hasFailedLoading = State(initialValue: shouldFailImmediately)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            #if canImport(WebKit) && os(iOS)
            if hasFailedLoading {
                fallbackPreview
            } else {
                YouTubeEmbedWebView(videoID: videoID, hasFailedLoading: $hasFailedLoading)
                    .aspectRatio(16 / 9, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: tokens.mediaCornerRadius))
                    .accessibilityIdentifier("agentui_youtube_player")
            }
            #else
            fallbackPreview
            #endif

            if let title {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.medium))
                        .lineLimit(1)
                    if let subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
                .padding(.leading, 4)
            }
        }
        .padding(.vertical, 4)
    }

    private var fallbackPreview: some View {
        VStack(alignment: .leading, spacing: 6) {
            Link(destination: URL(string: "https://www.youtube.com/watch?v=\(videoID)") ?? URL(string: "https://www.youtube.com")!) {
                ZStack {
                    AsyncImage(url: URL(string: "https://i.ytimg.com/vi/\(videoID)/hqdefault.jpg")) { img in
                        img.resizable().scaledToFill()
                    } placeholder: {
                        ZStack {
                            Color.black.opacity(0.85)
                            Image(systemName: "video.slash")
                                .font(.system(size: 28))
                                .foregroundStyle(.white.opacity(0.6))
                        }
                    }

                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.white, .red)
                        .shadow(radius: 4)
                }
                .aspectRatio(16 / 9, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: tokens.mediaCornerRadius))
            }
            .accessibilityIdentifier("agentui_youtube_fallback")

            HStack {
                Link(destination: URL(string: "https://www.youtube.com/watch?v=\(videoID)") ?? URL(string: "https://www.youtube.com")!) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.right.square")
                        Text(AgentLocalization.string("Open in YouTube"))
                    }
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.red)
                }
                Spacer()
            }
            .padding(.leading, 4)
        }
    }
}

#if canImport(WebKit) && os(iOS)
private struct YouTubeEmbedWebView: UIViewRepresentable {
    let videoID: String
    @Binding var hasFailedLoading: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.accessibilityIdentifier = "agentui_youtube_player"
        webView.navigationDelegate = context.coordinator
        webView.scrollView.isScrollEnabled = false
        if let url = URL(string: "https://www.youtube.com/embed/\(videoID)?playsinline=1") {
            webView.load(URLRequest(url: url))
        } else {
            Task { @MainActor in
                hasFailedLoading = true
            }
        }
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    final class Coordinator: NSObject, WKNavigationDelegate {
        let parent: YouTubeEmbedWebView

        init(_ parent: YouTubeEmbedWebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            Task { @MainActor in
                parent.hasFailedLoading = true
            }
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            Task { @MainActor in
                parent.hasFailedLoading = true
            }
        }
    }
}
#endif
#endif
