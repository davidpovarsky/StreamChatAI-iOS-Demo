// Sources/AgentUI/Media/AgentImageView.swift
#if canImport(SwiftUI)
import SwiftUI

public struct AgentImageView: View {
    public let id: String
    public let url: URL?
    public let altText: String?
    public let caption: String?

    @State private var isViewerPresented = false
    @Environment(\.agentUIDesignTokens) private var tokens
    @Environment(\.agentMediaCoordinator) private var coordinator
    @Environment(\.agentImageZoomNamespace) private var zoomNamespace

    public init(id: String = UUID().uuidString, url: URL?, altText: String? = nil, caption: String? = nil) {
        self.id = id
        self.url = url
        self.altText = altText
        self.caption = caption
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Button {
                if let coordinator {
                    coordinator.openImage(id: id, url: url, altText: altText, caption: caption)
                } else {
                    isViewerPresented = true
                }
            } label: {
                matchedImageContent
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("agentui_image_\(id)")
            .accessibilityLabel(altText ?? caption ?? "Image")

            if let caption, !caption.isEmpty {
                Text(caption)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.leading, 4)
            }
        }
        #if os(iOS)
        .fullScreenCover(isPresented: Binding(
            get: { coordinator == nil && isViewerPresented },
            set: { isViewerPresented = $0 }
        )) {
            AgentImageViewer(imageURL: url, altText: altText) {
                isViewerPresented = false
            }
        }
        #else
        .sheet(isPresented: Binding(
            get: { coordinator == nil && isViewerPresented },
            set: { isViewerPresented = $0 }
        )) {
            AgentImageViewer(imageURL: url, altText: altText) {
                isViewerPresented = false
            }
        }
        #endif
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var matchedImageContent: some View {
        #if os(iOS)
        if #available(iOS 18.0, *), let zoomNamespace {
            imageContent
                .matchedTransitionSource(id: id, in: zoomNamespace)
        } else {
            imageContent
        }
        #else
        imageContent
        #endif
    }

    @ViewBuilder
    private var imageContent: some View {
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
                    AgentMediaFallbackView(icon: "photo", title: AgentLocalization.string("Failed to load image"))
                @unknown default:
                    EmptyView()
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: tokens.mediaCornerRadius))
        } else {
            AgentMediaFallbackView(icon: "photo", title: AgentLocalization.string("Image not available"))
        }
    }
}
#endif
