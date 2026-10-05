// Sources/AgentUI/Media/AgentImageView.swift
#if canImport(SwiftUI)
import SwiftUI

public struct AgentImageView: View {
    public let url: URL?
    public let caption: String?

    @State private var isViewerPresented = false
    @Environment(\.agentUIDesignTokens) private var tokens

    public init(url: URL?, caption: String? = nil) {
        self.url = url
        self.caption = caption
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Button {
                isViewerPresented = true
            } label: {
                if let url {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(height: 200)
                                .frame(maxWidth: .infinity)
                                .background(Color.secondary.opacity(0.1))
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        case .failure:
                            AgentMediaFallbackView(icon: "photo", title: "Image failed to load")
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: tokens.mediaCornerRadius))
                } else {
                    AgentMediaFallbackView(icon: "photo", title: "Image not available")
                }
            }
            .buttonStyle(.plain)

            if let caption, !caption.isEmpty {
                Text(caption)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.leading, 4)
            }
        }
        #if os(iOS)
        .fullScreenCover(isPresented: $isViewerPresented) {
            AgentImageViewer(imageURL: url) {
                isViewerPresented = false
            }
        }
        #else
        .sheet(isPresented: $isViewerPresented) {
            AgentImageViewer(imageURL: url) {
                isViewerPresented = false
            }
        }
        #endif
        .padding(.vertical, 4)
    }
}
#endif
