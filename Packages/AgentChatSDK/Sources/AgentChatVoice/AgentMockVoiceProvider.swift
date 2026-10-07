import Foundation
import AgentChatCore

public final class AgentMockVoiceProvider: AgentVoiceSessionProvider, @unchecked Sendable {
    private let lock = NSLock()
    private var _state: AgentVoiceSessionState = .disconnected
    private var _audioLevel: Float = 0.0
    private var simulationTask: Task<Void, Never>?
    private var continuation: AsyncStream<AgentVoiceSessionState>.Continuation?

    public var state: AgentVoiceSessionState {
        lock.lock()
        defer { lock.unlock() }
        return _state
    }

    public var audioLevel: Float {
        lock.lock()
        defer { lock.unlock() }
        return _audioLevel
    }

    public lazy var statePublisher: AsyncStream<AgentVoiceSessionState> = {
        AsyncStream { [weak self] cont in
            self?.lock.lock()
            self?.continuation = cont
            cont.yield(self?._state ?? .disconnected)
            self?.lock.unlock()
        }
    }()

    public init() {}

    public func startSession() async throws {
        simulationTask?.cancel()
        updateState(.connecting)
        try? await Task.sleep(nanoseconds: 200_000_000)
        updateState(.listening)

        simulationTask = Task { [weak self] in
            guard let self = self else { return }

            while !Task.isCancelled {
                // Listening with mild ambient level
                for _ in 0..<15 {
                    guard !Task.isCancelled else { return }
                    self.setLevel(Float.random(in: 0.05...0.25))
                    try? await Task.sleep(nanoseconds: 100_000_000)
                }

                // Speaking detected
                guard !Task.isCancelled else { return }
                self.updateState(.thinking)
                self.setLevel(0.0)
                try? await Task.sleep(nanoseconds: 800_000_000)

                // Assistant speaking
                guard !Task.isCancelled else { return }
                self.updateState(.speaking)
                for _ in 0..<25 {
                    guard !Task.isCancelled else { return }
                    self.setLevel(Float.random(in: 0.3...0.85))
                    try? await Task.sleep(nanoseconds: 100_000_000)
                }

                // Return to listening
                guard !Task.isCancelled else { return }
                self.updateState(.listening)
                self.setLevel(0.0)
            }
        }
    }

    public func endSession() async {
        simulationTask?.cancel()
        simulationTask = nil
        updateState(.disconnected)
        setLevel(0.0)
    }

    private func updateState(_ newState: AgentVoiceSessionState) {
        lock.lock()
        _state = newState
        continuation?.yield(newState)
        lock.unlock()
    }

    private func setLevel(_ level: Float) {
        lock.lock()
        _audioLevel = level
        lock.unlock()
    }
}
