#if canImport(SwiftUI)
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif
import AgentChatCore

public struct SafeInlineYouTubeMediaView: View {
    public let part: MessageContentPart
    public let isDarkMode: Bool
    @Environment(\.openURL) private var openURL

    public init(part: MessageContentPart, isDarkMode: Bool) {
        self.part = part
        self.isDarkMode = isDarkMode
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Group {
                if let videoID {
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
            if let url = URL(string: "https://www.youtube.com/watch?v=\(videoID)") {
                openURL(url)
            }
        } label: {
            ZStack {
                AsyncImage(url: URL(string: "https://i.ytimg.com/vi/\(videoID)/hqdefault.jpg")) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.black.opacity(0.85)
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
#endif
