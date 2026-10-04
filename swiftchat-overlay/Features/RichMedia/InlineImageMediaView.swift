import SwiftUI
import UIKit

struct SafeInlineImageMediaView: View {
    let part: MessageContentPart
    let isDarkMode: Bool

    var body: some View {
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
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(isDarkMode ? Color.white.opacity(0.06) : Color.black.opacity(0.04))
                        ProgressView()
                    }
                    .aspectRatio(16 / 9, contentMode: .fit)
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
        } else {
            fallback
        }
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
