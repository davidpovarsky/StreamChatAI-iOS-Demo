//
//  InlineYouTubeMediaView.swift
//  AgentUI
//

import SwiftUI
import WebKit

public enum YouTubeLoadState: Equatable, Sendable { case loading, ready, failed }

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
                        YouTubeTopLevelWebView(videoID: videoID, state: $state)
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
            UIApplication.shared.open(URL(string: "https://www.youtube.com/watch?v=\(videoID)")!)
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
            .clipped()
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open YouTube video")
    }

    private var videoID: String? {
        if let id = part.youtubeVideoID, !id.isEmpty { return id }
        guard let value = part.url, let url = URL(string: value) else { return nil }
        if url.host?.contains("youtu.be") == true { return url.pathComponents.dropFirst().first }
        return URLComponents(url: url, resolvingAgainstBaseURL: false)?
            .queryItems?.first(where: { $0.name == "v" })?.value
    }
}

public struct YouTubeTopLevelWebView: UIViewRepresentable {
    public let videoID: String
    @Binding public var state: YouTubeLoadState

    public init(videoID: String, state: Binding<YouTubeLoadState>) {
        self.videoID = videoID
        self._state = state
    }

    public func makeCoordinator() -> Coordinator { Coordinator(state: $state) }

    public func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = .all
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.scrollView.isScrollEnabled = false
        webView.isOpaque = true
        webView.backgroundColor = .black
        load(videoID: videoID, in: webView)
        return webView
    }

    public func updateUIView(_ webView: WKWebView, context: Context) {
        context.coordinator.state = $state
        if context.coordinator.videoID != videoID { load(videoID: videoID, in: webView) }
        context.coordinator.videoID = videoID
    }

    private func load(videoID: String, in webView: WKWebView) {
        let value = "https://www.youtube.com/embed/\(videoID)?playsinline=1&rel=0"
        guard let url = URL(string: value) else { return }
        var request = URLRequest(url: url)
        request.setValue("https://www.youtube.com/", forHTTPHeaderField: "Referer")
        request.setValue("https://www.youtube.com", forHTTPHeaderField: "Origin")
        webView.load(request)
    }

    public final class Coordinator: NSObject, WKNavigationDelegate {
        var state: Binding<YouTubeLoadState>
        var videoID: String?
        init(state: Binding<YouTubeLoadState>) { self.state = state }

        public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            state.wrappedValue = .ready
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self, weak webView] in
                webView?.evaluateJavaScript("document.body.innerText") { value, _ in
                    let text = value as? String ?? ""
                    if text.localizedCaseInsensitiveContains("error 152") ||
                        text.localizedCaseInsensitiveContains("video unavailable") {
                        self?.state.wrappedValue = .failed
                    }
                }
            }
        }

        public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            state.wrappedValue = .failed
        }

        public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            state.wrappedValue = .failed
        }

        public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
            state.wrappedValue = .failed
        }
    }
}
