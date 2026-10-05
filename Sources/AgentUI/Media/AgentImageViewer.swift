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
    @State private var dragOffset: CGSize = .zero
    @State private var dragOpacity: Double = 1.0

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(imageURL: URL?, altText: String? = nil, onClose: @escaping () -> Void) {
        self.imageURL = imageURL
        self.altText = altText
        self.onClose = onClose
    }

    public var body: some View {
        ZStack {
            Color.black
                .opacity(dragOpacity)
                .ignoresSafeArea()

            if let imageURL {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .scaleEffect(scale)
                            .offset(scale > 1.0 ? offset : dragOffset)
                            .gesture(magnificationGesture)
                            .simultaneousGesture(doubleTapGesture)
                            .simultaneousGesture(panOrDismissGesture)
                    case .failure:
                        VStack(spacing: 8) {
                            Image(systemName: "photo.badge.exclamationmark")
                                .font(.system(size: 32))
                                .foregroundStyle(.white.opacity(0.7))
                            Text(AgentLocalization.string("Failed to load image"))
                                .foregroundStyle(.white)
                        }
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
                    Button(action: handleClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(12)
                            .background(Color.white.opacity(0.2), in: Circle())
                    }
                    .padding()
                    .accessibilityIdentifier("agentui_image_viewer_close")
                    .accessibilityLabel("Close image viewer")
                }
                Spacer()
            }
        }
        .accessibilityIdentifier("agentui_image_viewer")
        .accessibilityLabel(altText ?? "Full screen image")
    }

    private var magnificationGesture: some Gesture {
        MagnifyGesture()
            .onChanged { val in
                let newScale = lastScale * val.magnification
                scale = max(0.8, min(newScale, 5.0))
            }
            .onEnded { _ in
                if scale < 1.0 {
                    let animation: Animation? = reduceMotion ? nil : .spring(response: 0.3)
                    withAnimation(animation) {
                        scale = 1.0
                        offset = .zero
                    }
                }
                lastScale = scale
            }
    }

    private var doubleTapGesture: some Gesture {
        TapGesture(count: 2)
            .onEnded {
                let animation: Animation? = reduceMotion ? nil : .spring(response: 0.3)
                withAnimation(animation) {
                    if scale > 1.0 {
                        scale = 1.0
                        offset = .zero
                    } else {
                        scale = 2.5
                    }
                    lastScale = scale
                }
            }
    }

    private var panOrDismissGesture: some Gesture {
        DragGesture()
            .onChanged { val in
                if scale > 1.0 {
                    offset = CGSize(
                        width: lastOffset.width + val.translation.width,
                        height: lastOffset.height + val.translation.height
                    )
                } else {
                    if val.translation.height > 0 {
                        dragOffset = val.translation
                        let progress = min(val.translation.height / 300.0, 1.0)
                        dragOpacity = max(0.3, 1.0 - (progress * 0.7))
                    }
                }
            }
            .onEnded { val in
                if scale > 1.0 {
                    lastOffset = offset
                } else {
                    let distance = val.translation.height
                    let velocity = val.velocity.height
                    if distance > 150 || velocity > 350 {
                        handleClose()
                    } else {
                        let animation: Animation? = reduceMotion ? nil : .spring(response: 0.3)
                        withAnimation(animation) {
                            dragOffset = .zero
                            dragOpacity = 1.0
                        }
                    }
                }
            }
    }

    private func handleClose() {
        scale = 1.0
        lastScale = 1.0
        offset = .zero
        lastOffset = .zero
        dragOffset = .zero
        dragOpacity = 1.0
        onClose()
    }
}
#endif
