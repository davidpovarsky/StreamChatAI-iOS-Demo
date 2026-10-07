import Foundation
import AgentChatCore
#if canImport(LiveKit)
import LiveKit
#endif

public final class LiveKitVoiceSessionProvider: AgentVoiceSessionProvider, @unchecked Sendable {
    private let url: String
    private let token: String
    private let lock = NSLock()
    private var _state: AgentVoiceSessionState = .disconnected
    private var _audioLevel: Float = 0.0
    private var continuation: AsyncStream<AgentVoiceSessionState>.Continuation?

#if canImport(LiveKit)
    private var room: Room?
#endif

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

    public init(url: String, token: String) {
        self.url = url
        self.token = token
    }

    public func startSession() async throws {
        updateState(.connecting)
#if canImport(LiveKit)
        let room = Room()
        self.room = room
        try await room.connect(url: url, token: token)
        updateState(.connected)
        updateState(.listening)
#else
        // If LiveKit SDK is not linked, transition to error or simulate
        updateState(.connected)
        updateState(.listening)
#endif
    }

    public func endSession() async {
#if canImport(LiveKit)
        if let room = self.room {
            await room.disconnect()
            self.room = nil
        }
#endif
        updateState(.disconnected)
        lock.lock()
        _audioLevel = 0.0
        lock.unlock()
    }

    private func updateState(_ newState: AgentVoiceSessionState) {
        lock.lock()
        _state = newState
        continuation?.yield(newState)
        lock.unlock()
    }
}
