//
//  InlineVideoMediaView.swift
//  AgentUI
//

import AVKit
import Combine
import SwiftUI

@MainActor
public final class InlineVideoPlayerModel: ObservableObject {
    public enum State { case idle, loading, ready, failed }

    @Published public var state: State = .idle
    public let player = AVPlayer()
    private var observation: NSKeyValueObservation?
    private var loadedURL: URL?

    public init() {}

    public func prepare(url: URL) {
        guard loadedURL != url || state == .failed else { return }
        loadedURL = url
        state = .loading
        let item = AVPlayerItem(url: url)
        observation = item.observe(\.status, options: [.initial, .new]) { [weak self] item, _ in
            DispatchQueue.main.async {
                switch item.status {
                case .readyToPlay: self?.state = .ready
                case .failed: self?.state = .failed
                default: self?.state = .loading
                }
            }
        }
        player.replaceCurrentItem(with: item)
    }

    public func retry() {
        guard let loadedURL else { return }
        state = .idle
        prepare(url: loadedURL)
    }
}

public struct SafeInlineVideoMediaView: View {
    public let part: MessageContentPart
    public let isDarkMode: Bool
    @StateObject private var model = InlineVideoPlayerModel()

    public init(part: MessageContentPart, isDarkMode: Bool) {
        self.part = part
        self.isDarkMode = isDarkMode
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Group {
                if let url = videoURL {
                    ZStack {
                        VideoPlayer(player: model.player)
                        if model.state == .loading {
                            ProgressView()
                                .padding(12)
                                .background(.thinMaterial, in: Circle())
                        } else if model.state == .failed {
                            RichMediaFallbackView(
                                icon: "video.slash",
                                title: "Video unavailable",
                                isDarkMode: isDarkMode,
                                actionTitle: "Retry",
                                action: model.retry
                            )
                        }
                    }
                    .task(id: url) { model.prepare(url: url) }
                } else {
                    RichMediaFallbackView(
                        icon: "video.slash",
                        title: "Video unavailable",
                        isDarkMode: isDarkMode
                    )
                }
            }
            .aspectRatio(16 / 9, contentMode: .fit)
            .frame(maxWidth: 480)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .onDisappear { model.player.pause() }

            if let caption = part.caption ?? part.title, !caption.isEmpty {
                Text(caption)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.leading, 4)
            }
        }
        .padding(.vertical, 4)
    }

    private var videoURL: URL? {
        guard let value = part.url,
              let url = URL(string: value),
              url.scheme == "https" else { return nil }
        return url
    }
}
