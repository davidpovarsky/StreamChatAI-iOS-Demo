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

    @Environment(\.agentUIDesignTokens) private var tokens

    public init(videoID: String, title: String? = nil, subtitle: String? = nil) {
        self.videoID = videoID
        self.title = title
        self.subtitle = subtitle
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            #if canImport(WebKit) && os(iOS)
            YouTubeEmbedWebView(videoID: videoID)
                .aspectRatio(16 / 9, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: tokens.mediaCornerRadius))
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
        Link(destination: URL(string: "https://www.youtube.com/watch?v=\(videoID)")!) {
            ZStack {
                AsyncImage(url: URL(string: "https://i.ytimg.com/vi/\(videoID)/hqdefault.jpg")) { img in
                    img.resizable().scaledToFill()
                } placeholder: {
                    Color.black.opacity(0.8)
                }

                Image(systemName: "play.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.white, .red)
                    .shadow(radius: 4)
            }
            .aspectRatio(16 / 9, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: tokens.mediaCornerRadius))
        }
    }
}

#if canImport(WebKit) && os(iOS)
private struct YouTubeEmbedWebView: UIViewRepresentable {
    let videoID: String

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.scrollView.isScrollEnabled = false
        if let url = URL(string: "https://www.youtube.com/embed/\(videoID)?playsinline=1") {
            webView.load(URLRequest(url: url))
        }
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
#endif
#endif
