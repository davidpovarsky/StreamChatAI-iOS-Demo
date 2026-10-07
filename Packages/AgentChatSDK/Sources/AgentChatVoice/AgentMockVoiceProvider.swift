#if canImport(AgentChatCore)
import AgentChatCore
#endif
#if canImport(Combine)
import Combine
#endif
import Foundation

public final class AgentMockVoiceProvider: AgentVoiceSessionProvider, @unchecked Sendable {
    #if canImport(Combine)
    private let stateSubject = CurrentValueSubject<AgentVoiceSessionState, Never>(.idle)
    private let audioLevelSubject = PassthroughSubject<Float, Never>()
    #endif
    private var simulationTask: Task<Void, Never>?
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

    public init() {}

    public func startSession() async throws {
        simulationTask?.cancel()
        sendState(.listening)

        simulationTask = Task { [weak self] in
            guard let self = self else { return }

            // Phase 1: Listening
            for _ in 0..<8 {
                guard !Task.isCancelled else { return }
                self.sendAudioLevel(Float.random(in: 0.1...0.3))
                try? await Task.sleep(nanoseconds: 100_000_000)
            }

            // Phase 2: Speech detected
            guard !Task.isCancelled else { return }
            self.sendState(.speechDetected)
            for _ in 0..<12 {
                guard !Task.isCancelled else { return }
                self.sendAudioLevel(Float.random(in: 0.4...0.9))
                try? await Task.sleep(nanoseconds: 100_000_000)
            }

            // Phase 3: Processing
            guard !Task.isCancelled else { return }
            self.sendState(.processing)
            for _ in 0..<8 {
                guard !Task.isCancelled else { return }
                self.sendAudioLevel(0.15)
                try? await Task.sleep(nanoseconds: 100_000_000)
            }

            // Phase 4: Speaking
            guard !Task.isCancelled else { return }
            self.sendState(.speaking)
            for _ in 0..<20 {
                guard !Task.isCancelled else { return }
                self.sendAudioLevel(Float.random(in: 0.3...0.85))
                try? await Task.sleep(nanoseconds: 100_000_000)
            }

            // Phase 5: Back to idle
            guard !Task.isCancelled else { return }
            self.sendState(.idle)
        }
    }

    public func stopSession() async {
        simulationTask?.cancel()
        simulationTask = nil
        sendState(.idle)
        sendAudioLevel(0.0)
    }

    public func sendAudio(data: Data) async throws {
        // mock accepts audio data
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

public struct MockVoiceActivityDetector: AgentVoiceActivityDetecting, Sendable {
    public init() {}

    public func isSpeech(buffer: Data) -> Bool {
        return buffer.count > 100
    }
}
