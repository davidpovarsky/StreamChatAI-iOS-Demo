import Foundation

// MARK: - Voice Session State

public enum AgentVoiceSessionState: String, Sendable, Equatable {
    case disconnected
    case connecting
    case connected
    case listening
    case thinking
    case speaking
    case error
}

// MARK: - Voice Session Provider

public protocol AgentVoiceSessionProvider: AnyObject, Sendable {
    var state: AgentVoiceSessionState { get }
    var audioLevel: Float { get }
    var statePublisher: AsyncStream<AgentVoiceSessionState> { get }

    func startSession() async throws
    func endSession() async
}

// MARK: - Optional Voice Activity Detecting

public protocol AgentVoiceActivityDetecting: Sendable {
    func processAudioBuffer(_ buffer: Data) -> Bool
}
