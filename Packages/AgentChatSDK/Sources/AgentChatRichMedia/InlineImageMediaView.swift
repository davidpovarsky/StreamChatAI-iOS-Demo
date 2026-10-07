#if canImport(SwiftUI)
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif
#if canImport(Kingfisher)
import Kingfisher
#endif
import AgentChatCore

public struct SafeInlineImageMediaView: View {
    public let part: MessageContentPart
    public let isDarkMode: Bool

    public init(part: MessageContentPart, isDarkMode: Bool) {
        self.part = part
        self.isDarkMode = isDarkMode
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            media
                .frame(maxWidth: 480)
            if let caption = part.caption, !caption.isEmpty {
                Text(caption)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.leading, 4)
            }
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var media: some View {
#if canImport(UIKit)
        if let name = bundledImageName,
           let image = UIImage(named: name) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .accessibilityLabel(part.title ?? "Inline image")
        } else if let urlString = part.url,
                  let url = URL(string: urlString),
                  url.scheme == "https" {
            remoteImageView(url: url)
        } else {
            fallback
        }
#else
        if let urlString = part.url,
           let url = URL(string: urlString) {
            remoteImageView(url: url)
        } else {
            fallback
        }
#endif
    }

    @ViewBuilder
    private func remoteImageView(url: URL) -> some View {
#if canImport(Kingfisher)
        KFImage(url)
            .placeholder {
                placeholderView
            }
            .retry(maxCount: 2, interval: .seconds(2))
            .fade(duration: 0.2)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 16))
#else
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                placeholderView
            case .success(let image):
                image.resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            case .failure:
                fallback
            @unknown default:
                fallback
            }
        }
#endif
    }

    private var placeholderView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(isDarkMode ? Color.white.opacity(0.06) : Color.black.opacity(0.04))
            ProgressView()
        }
        .aspectRatio(16 / 9, contentMode: .fit)
    }

    private var bundledImageName: String? {
        guard let value = part.url, value.hasPrefix("bundle://") else { return nil }
        return String(value.dropFirst("bundle://".count))
    }

    private var fallback: some View {
        RichMediaFallbackView(
            icon: "photo",
            title: part.title ?? "Image unavailable",
            isDarkMode: isDarkMode
        )
    }
}
#endif
