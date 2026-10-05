//
//  FaviconView.swift
//  AgentUI
//
//  Favicon view that displays a website icon.
//

import SwiftUI

public struct FaviconView: View {
    public let url: String
    public let isDarkMode: Bool

    public init(url: String, isDarkMode: Bool) {
        self.url = url
        self.isDarkMode = isDarkMode
    }

    private var faviconURL: URL? {
        guard let urlObj = URL(string: url),
              let host = urlObj.host else { return nil }
        return URL(string: "https://icons.duckduckgo.com/ip3/\(host).ico")
    }

    public var body: some View {
        AsyncImage(url: faviconURL) { phase in
            switch phase {
            case .empty:
                placeholderIcon
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            case .failure:
                placeholderIcon
            @unknown default:
                placeholderIcon
            }
        }
        .frame(width: 16, height: 16)
        .background(isDarkMode ? Color.white.opacity(0.1) : Color.black.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(isDarkMode ? Color.white.opacity(0.2) : Color.black.opacity(0.1), lineWidth: 0.5)
        )
    }

    private var placeholderIcon: some View {
        Image(systemName: "globe")
            .font(.system(size: 10))
            .foregroundColor(.secondary)
    }
}
