#if canImport(AgentChatCore)
import AgentChatCore
#endif
#if canImport(AgentChatVoice)
import AgentChatVoice
#endif
#if canImport(Combine)
import Combine
#endif
import Foundation
#if canImport(LiveKit)
import LiveKit
#endif

public final class LiveKitVoiceSessionProvider: AgentVoiceSessionProvider, @unchecked Sendable {
    #if canImport(Combine)
    private let stateSubject = CurrentValueSubject<AgentVoiceSessionState, Never>(.idle)
    private let audioLevelSubject = PassthroughSubject<Float, Never>()
    #endif
    private let url: String
    private let token: String
    private var stateValue: AgentVoiceSessionState = .idle

    #if canImport(Combine)
    public var statePublisher: AnyPublisher<AgentVoiceSessionState, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    public var audioLevelPublisher: AnyPublisher<Float, Never> {
        audioLevelSubject.eraseToAnyPublisher()
    }
    #endif

    public var currentState: AgentVoiceSessionState {
        #if canImport(Combine)
        return stateSubject.value
        #else
        return stateValue
        #endif
    }

    public init(url: String, token: String) {
        self.url = url
        self.token = token
    }

    public func startSession() async throws {
        sendState(.listening)
        #if canImport(LiveKit)
        // Production LiveKit connection entry point
        // Room().connect(url: url, token: token)
        #endif
    }

    public func stopSession() async {
        sendState(.idle)
        sendAudioLevel(0.0)
    }

    public func sendAudio(data: Data) async throws {
        // Feed audio data into LiveKit local audio track
    }

    private func sendState(_ state: AgentVoiceSessionState) {
        stateValue = state
        #if canImport(Combine)
        stateSubject.send(state)
        #endif
    }

    private func sendAudioLevel(_ level: Float) {
        #if canImport(Combine)
        audioLevelSubject.send(level)
        #endif
    }
}
