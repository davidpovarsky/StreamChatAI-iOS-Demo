#if canImport(SwiftUI)
import SwiftUI
import AgentChatCore

public struct AgentVoiceOrbView: View {
    public let state: AgentVoiceSessionState
    public let audioLevel: Float
    public let size: CGFloat

    @State private var phase: Double = 0.0

    public init(
        state: AgentVoiceSessionState,
        audioLevel: Float = 0.0,
        size: CGFloat = 160
    ) {
        self.state = state
        self.audioLevel = audioLevel
        self.size = size
    }

    public var body: some View {
        ZStack {
            // Background glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [glowColor.opacity(0.4), Color.clear],
                        center: .center,
                        startRadius: size * 0.2,
                        endRadius: size * 0.65
                    )
                )
                .scaleEffect(1.0 + CGFloat(audioLevel) * 0.25)
                .animation(.easeInOut(duration: 0.15), value: audioLevel)

            // Inner core orb
            Circle()
                .fill(
                    LinearGradient(
                        colors: coreColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size * 0.7, height: size * 0.7)
                .scaleEffect(coreScale)
                .shadow(color: glowColor.opacity(0.5), radius: 20, x: 0, y: 0)
                .animation(.spring(response: 0.35, dampingFraction: 0.6), value: audioLevel)
        }
        .frame(width: size, height: size)
    }

    private var glowColor: Color {
        switch state {
        case .disconnected: return .gray
        case .connecting: return .orange
        case .connected, .listening: return .blue
        case .thinking: return .purple
        case .speaking: return .cyan
        case .error: return .red
        }
    }

    private var coreColors: [Color] {
        switch state {
        case .disconnected: return [.gray, .secondary]
        case .connecting: return [.orange, .yellow]
        case .connected, .listening: return [.blue, .indigo]
        case .thinking: return [.purple, .pink]
        case .speaking: return [.cyan, .blue]
        case .error: return [.red, .orange]
        }
    }

    private var coreScale: CGFloat {
        switch state {
        case .thinking:
            return 0.95
        case .speaking, .listening:
            return 1.0 + CGFloat(audioLevel) * 0.3
        default:
            return 1.0
        }
    }
}
#endif
