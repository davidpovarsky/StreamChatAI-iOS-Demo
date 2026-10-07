#if canImport(SwiftUI)
import AgentChatCore
import Combine
import SwiftUI

public struct AgentVoiceOrbView: View {
    public let state: AgentVoiceSessionState
    public let audioLevel: Float

    @State private var pulseScale: CGFloat = 1.0

    public init(state: AgentVoiceSessionState, audioLevel: Float = 0.0) {
        self.state = state
        self.audioLevel = audioLevel
    }

    public var body: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(orbColor.opacity(0.2))
                .frame(width: 140, height: 140)
                .scaleEffect(1.0 + CGFloat(audioLevel) * 0.4)
                .blur(radius: 12)

            // Mid circle
            Circle()
                .fill(orbColor.opacity(0.5))
                .frame(width: 100, height: 100)
                .scaleEffect(1.0 + CGFloat(audioLevel) * 0.25)

            // Core circle
            Circle()
                .fill(orbColor)
                .frame(width: 76, height: 76)
                .overlay(
                    Image(systemName: iconName)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)
                )
                .shadow(color: orbColor.opacity(0.6), radius: 10)
        }
        .animation(.spring(response: 0.25, dampingFraction: 0.6), value: audioLevel)
    }

    private var orbColor: Color {
        switch state {
        case .idle:
            return .gray
        case .listening:
            return .blue
        case .speechDetected:
            return .teal
        case .processing:
            return .purple
        case .speaking:
            return .cyan
        case .failed:
            return .red
        }
    }

    private var iconName: String {
        switch state {
        case .idle:
            return "mic"
        case .listening, .speechDetected:
            return "waveform"
        case .processing:
            return "sparkles"
        case .speaking:
            return "speaker.wave.2.fill"
        case .failed:
            return "exclamationmark.triangle"
        }
    }
}

public struct AgentVoiceOverlayView: View {
    @ObservedObject private var viewModel: VoiceOverlayViewModel
    @Environment(\.dismiss) private var dismiss

    public init(provider: AgentVoiceSessionProvider) {
        self.viewModel = VoiceOverlayViewModel(provider: provider)
    }

    public var body: some View {
        ZStack {
            Color.black.opacity(0.92)
                .ignoresSafeArea()

            VStack(spacing: 36) {
                HStack {
                    Spacer()
                    Button {
                        Task {
                            await viewModel.stop()
                            dismiss()
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    .buttonStyle(.plain)
                    .padding()
                }

                Spacer()

                AgentVoiceOrbView(state: viewModel.state, audioLevel: viewModel.audioLevel)

                VStack(spacing: 8) {
                    Text(statusTitle)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.white)

                    Text(statusSubtitle)
                        .font(.system(size: 14))
                        .foregroundStyle(.white.opacity(0.6))
                }

                Spacer()

                HStack(spacing: 32) {
                    Button {
                        Task {
                            if viewModel.state == .idle {
                                try? await viewModel.start()
                            } else {
                                await viewModel.stop()
                            }
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.15))
                                .frame(width: 64, height: 64)
                            Image(systemName: viewModel.state == .idle ? "play.fill" : "stop.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(.white)
                        }
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 48)
            }
        }
        .task {
            try? await viewModel.start()
        }
    }

    private var statusTitle: String {
        switch viewModel.state {
        case .idle: return "Ready"
        case .listening: return "Listening..."
        case .speechDetected: return "Hearing you..."
        case .processing: return "Thinking..."
        case .speaking: return "Speaking..."
        case .failed(let msg): return "Error: \(msg)"
        }
    }

    private var statusSubtitle: String {
        switch viewModel.state {
        case .idle: return "Tap play to start speaking"
        case .listening, .speechDetected: return "Speak naturally to the assistant"
        case .processing: return "Synthesizing answer"
        case .speaking: return "Tap orb or stop to interrupt"
        case .failed: return "Please retry"
        }
    }
}

@MainActor
private final class VoiceOverlayViewModel: ObservableObject {
    @Published var state: AgentVoiceSessionState = .idle
    @Published var audioLevel: Float = 0.0

    private let provider: AgentVoiceSessionProvider
    private var cancellables = Set<AnyCancellable>()

    init(provider: AgentVoiceSessionProvider) {
        self.provider = provider
        self.state = provider.currentState

        provider.statePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newState in
                self?.state = newState
            }
            .store(in: &cancellables)

        provider.audioLevelPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] level in
                self?.audioLevel = level
            }
            .store(in: &cancellables)
    }

    func start() async throws {
        try await provider.startSession()
    }

    func stop() async {
        await provider.stopSession()
    }
}
#endif
