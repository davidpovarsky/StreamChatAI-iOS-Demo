#if canImport(SwiftUI)
import SwiftUI
#if canImport(SVGView)
import SVGView
#endif
import AgentChatCore

/// Additive inline SVG renderer backed by Exyte's `SVGView`.
/// Handles raw SVG strings or remote SVG URLs with stable aspect ratio sizing and dark mode fallback.
public struct InlineSVGMediaView: View {
    public let part: MessageContentPart
    public let isDarkMode: Bool

    public init(part: MessageContentPart, isDarkMode: Bool) {
        self.part = part
        self.isDarkMode = isDarkMode
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            svgContent
                .frame(maxWidth: 480)
                .background(isDarkMode ? Color.white.opacity(0.04) : Color.black.opacity(0.02))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(isDarkMode ? Color.white.opacity(0.12) : Color.black.opacity(0.08), lineWidth: 0.5)
                )

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
    private var svgContent: some View {
#if canImport(SVGView)
        if let svgString = part.svgString, !svgString.isEmpty {
            SVGView(string: svgString)
                .aspectRatio(contentMode: .fit)
                .frame(minHeight: 180, maxHeight: 320)
                .padding(8)
        } else if let urlString = part.url, let url = URL(string: urlString) {
            SVGView(contentsOf: url)
                .aspectRatio(contentMode: .fit)
                .frame(minHeight: 180, maxHeight: 320)
                .padding(8)
        } else {
            fallback
        }
#else
        fallback
#endif
    }

    private var fallback: some View {
        RichMediaFallbackView(
            icon: "paintbrush.fill",
            title: part.title ?? "Vector Graphic",
            isDarkMode: isDarkMode
        )
    }
}
#endif
