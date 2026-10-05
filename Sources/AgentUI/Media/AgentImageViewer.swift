// Sources/AgentUI/Media/AgentImageViewer.swift
#if canImport(SwiftUI)
import SwiftUI

public struct AgentImageViewer: View {
    public let imageURL: URL?
    public let altText: String?
    public let onClose: () -> Void

    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    public init(imageURL: URL?, altText: String? = nil, onClose: @escaping () -> Void) {
        self.imageURL = imageURL
        self.altText = altText
        self.onClose = onClose
    }

    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let imageURL {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .scaleEffect(scale)
                            .offset(offset)
                            .gesture(
                                MagnificationGesture()
                                    .onChanged { val in
                                        scale = lastScale * val
                                    }
                                    .onEnded { _ in
                                        if scale < 1.0 {
                                            withAnimation { scale = 1.0; offset = .zero }
                                        }
                                        lastScale = scale
                                    }
                            )
                            .simultaneousGesture(
                                TapGesture(count: 2).onEnded {
                                    withAnimation {
                                        if scale > 1.0 {
                                            scale = 1.0
                                            offset = .zero
                                        } else {
                                            scale = 2.5
                                        }
                                        lastScale = scale
                                    }
                                }
                            )
                            .simultaneousGesture(
                                DragGesture()
                                    .onChanged { val in
                                        if scale > 1.0 {
                                            offset = CGSize(
                                                width: lastOffset.width + val.translation.width,
                                                height: lastOffset.height + val.translation.height
                                            )
                                        } else if val.translation.height > 100 {
                                            onClose()
                                        }
                                    }
                                    .onEnded { _ in
                                        lastOffset = offset
                                    }
                            )
                    case .failure:
                        Text("Failed to load image")
                            .foregroundStyle(.white)
                    case .empty:
                        ProgressView().tint(.white)
                    @unknown default:
                        EmptyView()
                    }
                }
            }

            // Close button top-right
            VStack {
                HStack {
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(12)
                            .background(Color.white.opacity(0.2), in: Circle())
                    }
                    .padding()
                }
                Spacer()
            }
        }
    }
}
#endif
