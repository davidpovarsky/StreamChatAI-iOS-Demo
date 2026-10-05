// Sources/AgentUI/Media/AgentVideoView.swift
#if canImport(SwiftUI)
import SwiftUI

#if canImport(AVKit)
import AVKit
#endif

public struct AgentVideoView: View {
    public let url: URL?
    public let title: String?
    public let caption: String?

    @Environment(\.agentUIDesignTokens) private var tokens

    public init(url: URL?, title: String? = nil, caption: String? = nil) {
        self.url = url
        self.title = title
        self.caption = caption
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            #if canImport(AVKit)
            if let url {
                VideoPlayer(player: AVPlayer(url: url))
                    .aspectRatio(16 / 9, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: tokens.mediaCornerRadius))
            } else {
                AgentMediaFallbackView(icon: "video.slash", title: "Video unavailable")
            }
            #else
            AgentMediaFallbackView(icon: "video.slash", title: "Video player not supported on this platform")
            #endif

            if let displayCaption = caption ?? title, !displayCaption.isEmpty {
                Text(displayCaption)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.leading, 4)
            }
        }
        .padding(.vertical, 4)
    }
}
#endif
