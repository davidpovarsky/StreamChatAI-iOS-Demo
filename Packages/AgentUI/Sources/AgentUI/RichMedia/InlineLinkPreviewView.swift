//
//  InlineLinkPreviewView.swift
//  AgentUI
//
//  Rich link preview card displaying thumbnail, title, description, and host domain.
//

import SwiftUI
import UIKit

public struct InlineLinkPreviewView: View {
    public let part: MessageContentPart
    public let isDarkMode: Bool

    public init(part: MessageContentPart, isDarkMode: Bool) {
        self.part = part
        self.isDarkMode = isDarkMode
    }

    private var displayHost: String {
        guard let urlString = part.url, let url = URL(string: urlString), let host = url.host else {
            return part.url ?? ""
        }
        return host.hasPrefix("www.") ? String(host.dropFirst(4)) : host
    }

    public var body: some View {
        Button {
            if let urlString = part.url, let url = URL(string: urlString) {
                UIApplication.shared.open(url)
            }
        } label: {
            HStack(spacing: 12) {
                if let thumb = part.thumbnailURL, let thumbURL = URL(string: thumb) {
                    AsyncImage(url: thumbURL) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        default:
                            FaviconView(url: part.url ?? "", isDarkMode: isDarkMode)
                        }
                    }
                    .frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    FaviconView(url: part.url ?? "", isDarkMode: isDarkMode)
                        .frame(width: 22, height: 22)
                        .padding(8)
                        .background(isDarkMode ? Color.white.opacity(0.08) : Color.black.opacity(0.04))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(part.title ?? displayHost)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    if let subtitle = part.subtitle ?? part.caption, !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }

                    Text(displayHost)
                        .font(.system(size: 11))
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isDarkMode ? Color.white.opacity(0.06) : Color.black.opacity(0.045))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(isDarkMode ? Color.white.opacity(0.1) : Color.black.opacity(0.08), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
        .frame(maxWidth: 480)
        .padding(.vertical, 4)
    }
}
