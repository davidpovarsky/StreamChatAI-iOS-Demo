#if canImport(SwiftUI)
import SwiftUI
#if canImport(WebKit)
import WebKit
#endif
import AgentChatCore

private enum YouTubeLoadState: Equatable { case loading, ready, failed }

public struct SafeInlineYouTubeMediaView: View {
    public let part: MessageContentPart
    public let isDarkMode: Bool
    @State private var state: YouTubeLoadState = .loading

    public init(part: MessageContentPart, isDarkMode: Bool) {
        self.part = part
        self.isDarkMode = isDarkMode
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Group {
                if let videoID, state != .failed {
                    ZStack {
#if canImport(WebKit) && !os(macOS)
                        YouTubeTopLevelWebView(videoID: videoID, state: $state)
#else
                        fallbackPreview(videoID: videoID)
#endif
                        if state == .loading { ProgressView().tint(.white) }
                    }
                } else if let videoID {
                    fallbackPreview(videoID: videoID)
                } else {
                    RichMediaFallbackView(
                        icon: "play.rectangle",
                        title: part.title ?? "YouTube video unavailable",
                        isDarkMode: isDarkMode
                    )
                }
            }
            .aspectRatio(16 / 9, contentMode: .fit)
            .frame(maxWidth: 480)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            if let title = part.title {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.system(size: 13, weight: .medium)).lineLimit(1)
                    if let subtitle = part.subtitle {
                        Text(subtitle).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                    }
                }
                .padding(.leading, 4)
            }
        }
        .padding(.vertical, 4)
    }

    private func fallbackPreview(videoID: String) -> some View {
        Button {
#if canImport(UIKit)
            if let url = URL(string: "https://www.youtube.com/watch?v=\(videoID)") {
                UIApplication.shared.open(url)
            }
#endif
        } label: {
            ZStack {
                AsyncImage(url: URL(string: "https://i.ytimg.com/vi/\(videoID)/hqdefault.jpg")) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.black.opacity(0.9)
                }
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(.white, .red)
                    .shadow(radius: 4)
            }
        }
        .buttonStyle(.plain)
    }

    private var videoID: String? {
        if let direct = part.youtubeVideoID, !direct.isEmpty { return direct }
        guard let raw = part.url, let url = URL(string: raw) else { return nil }
        if url.host?.contains("youtu.be") == true {
            return String(url.path.dropFirst())
        }
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            return components.queryItems?.first(where: { $0.name == "v" })?.value
        }
        return nil
    }
}

#if canImport(WebKit) && canImport(UIKit)
private struct YouTubeTopLevelWebView: UIViewRepresentable {
    let videoID: String
    @Binding var state: YouTubeLoadState

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.scrollView.isScrollEnabled = false
        webView.isOpaque = false
        webView.backgroundColor = .black
        loadVideo(in: webView)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    private func loadVideo(in webView: WKWebView) {
        let html = """
        <!DOCTYPE html><html><head><meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no"><style>*{margin:0;padding:0;background-color:#000;overflow:hidden;}html,body{height:100%;}iframe{border:0;width:100%;height:100%;}</style></head><body><iframe src="https://www.youtube-nocookie.com/embed/\(videoID)?playsinline=1&rel=0&modestbranding=1" allow="autoplay; encrypted-media; picture-in-picture" allowfullscreen></iframe></body></html>
        """
        webView.loadHTMLString(html, baseURL: URL(string: "https://www.youtube-nocookie.com"))
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        let parent: YouTubeTopLevelWebView
        init(_ parent: YouTubeTopLevelWebView) { self.parent = parent }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.async { self.parent.state = .ready }
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async { self.parent.state = .failed }
        }
    }
}
#endif
#endif
