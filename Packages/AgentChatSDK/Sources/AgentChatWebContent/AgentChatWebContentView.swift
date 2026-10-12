#if canImport(SwiftUI) && canImport(WebKit)
import SwiftUI
import WebKit
import AgentChatCore

public struct AgentChatWebContentView: View {
    public let htmlString: String?
    public let url: URL?
    public let isDarkMode: Bool

    @State private var isLoading = true

    public init(htmlString: String? = nil, url: URL? = nil, isDarkMode: Bool = false) {
        self.htmlString = htmlString
        self.url = url
        self.isDarkMode = isDarkMode
    }

    public var body: some View {
        ZStack {
            SandboxedWKWebView(htmlString: htmlString, url: url, isLoading: $isLoading)
            if isLoading {
                ProgressView()
                    .tint(.secondary)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        )
    }
}

#if os(iOS)
private struct SandboxedWKWebView: UIViewRepresentable {
    let htmlString: String?
    let url: URL?
    @Binding var isLoading: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.isOpaque = false
        webView.backgroundColor = .clear

        if let html = htmlString {
            webView.loadHTMLString(html, baseURL: nil)
        } else if let u = url {
            webView.load(URLRequest(url: u))
        }

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    final class Coordinator: NSObject, WKNavigationDelegate {
        let parent: SandboxedWKWebView
        init(_ parent: SandboxedWKWebView) { self.parent = parent }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.async { self.parent.isLoading = false }
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async { self.parent.isLoading = false }
        }
    }
}
#endif
#endif
