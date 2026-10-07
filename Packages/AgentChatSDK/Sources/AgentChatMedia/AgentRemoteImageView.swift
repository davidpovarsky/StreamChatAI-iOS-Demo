#if canImport(SwiftUI)
import AgentChatCore
import SwiftUI
#if canImport(Kingfisher)
import Kingfisher
#endif
#if canImport(UIKit)
import UIKit
#endif

public enum AgentImageLoadingState: Equatable, Sendable {
    case empty
    case loading
    case success
    case failure(String)
}

public struct AgentRemoteImageView: View {
    public let content: AgentImageContent
    @State private var showingPreview = false

    public init(content: AgentImageContent) {
        self.content = content
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            imageContainer
                .aspectRatio(content.aspectRatio ?? (16.0 / 9.0), contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.5)
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    showingPreview = true
                }

            if let caption = content.caption, !caption.isEmpty {
                Text(caption)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.leading, 2)
            }
        }
        .padding(.vertical, 4)
        .sheet(isPresented: $showingPreview) {
            AgentImagePreviewSheet(content: content)
        }
    }

    @ViewBuilder
    private var imageContainer: some View {
        #if canImport(Kingfisher)
        if let urlString = content.url, let url = URL(string: urlString) {
            KFImage(url)
                .placeholder {
                    placeholderView
                }
                .fade(duration: 0.25)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else if let localName = content.localBundleName {
            #if canImport(UIKit)
            if let uiImage = UIImage(named: localName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                fallbackView
            }
            #else
            fallbackView
            #endif
        } else {
            fallbackView
        }
        #else
        if let urlString = content.url, let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    placeholderView
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fit)
                case .failure:
                    fallbackView
                @unknown default:
                    fallbackView
                }
            }
        } else {
            fallbackView
        }
        #endif
    }

    private var placeholderView: some View {
        ZStack {
            Color.secondary.opacity(0.12)
            ProgressView()
                .controlSize(.small)
        }
    }

    private var fallbackView: some View {
        AgentMediaFallbackView(
            icon: "photo",
            title: content.altText ?? "Image unavailable"
        )
    }
}

public struct AgentImageGalleryView: View {
    public let images: [AgentImageContent]

    public init(images: [AgentImageContent]) {
        self.images = images
    }

    public var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 140, maximum: 200), spacing: 8)], spacing: 8) {
            ForEach(images) { image in
                AgentRemoteImageView(content: image)
            }
        }
        .padding(.vertical, 4)
    }
}

public struct AgentImagePreviewSheet: View {
    public let content: AgentImageContent
    @Environment(\.dismiss) private var dismiss

    public init(content: AgentImageContent) {
        self.content = content
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                AgentRemoteImageView(content: content)
                    .padding()
            }
            .navigationTitle(content.caption ?? "Preview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(.white)
                }
            }
        }
    }
}
#endif
