#if canImport(SwiftUI)
import AgentChatCore
import SwiftUI
#if canImport(AVKit)
import AVKit
#endif
#if canImport(UIKit)
import UIKit
#endif

public struct AgentVideoMediaView: View {
    public let content: AgentVideoContent

    public init(content: AgentVideoContent) {
        self.content = content
    }

    public var body: some View {
        if content.isYouTube {
            AgentYouTubeMediaView(content: content)
        } else {
            nativeVideoPreview
        }
    }

    private var nativeVideoPreview: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack {
                Color.black.opacity(0.8)
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.white)
            }
            .aspectRatio(16 / 9, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .contentShape(Rectangle())
            .onTapGesture {
                if let url = URL(string: content.url) {
                    #if canImport(UIKit)
                    UIApplication.shared.open(url)
                    #endif
                }
            }

            if let title = content.title {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

public struct AgentYouTubeMediaView: View {
    public let content: AgentVideoContent

    public init(content: AgentVideoContent) {
        self.content = content
    }

    public var body: some View {
        Button {
            if let url = URL(string: content.url) {
                #if canImport(UIKit)
                UIApplication.shared.open(url)
                #endif
            }
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                ZStack {
                    Color.black
                    HStack(spacing: 8) {
                        Image(systemName: "play.rectangle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(.red)
                        Text("Watch on YouTube")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                }
                .aspectRatio(16 / 9, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 14))

                if let title = content.title {
                    Text(title)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .buttonStyle(.plain)
        .padding(.vertical, 4)
    }
}

public struct AgentMediaFallbackView: View {
    public let icon: String
    public let title: String

    public init(icon: String = "exclamationmark.triangle", title: String = "Media unavailable") {
        self.icon = icon
        self.title = title
    }

    public var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(.secondary)
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
    }
}
#endif
