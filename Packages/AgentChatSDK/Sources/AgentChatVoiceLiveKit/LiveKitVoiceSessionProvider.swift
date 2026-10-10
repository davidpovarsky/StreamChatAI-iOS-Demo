import Foundation
import AgentChatCore
#if canImport(LiveKit)
import LiveKit
#endif
#if canImport(os)
import os
#endif

/// Actor managing thread-safe voice session state in Swift 6 concurrency.
public actor LiveKitVoiceState {
    public private(set) var state: AgentVoiceSessionState = .disconnected
    public private(set) var audioLevel: Float = 0.0
    private var continuation: AsyncStream<AgentVoiceSessionState>.Continuation?

    public init() {}

    public func setContinuation(_ continuation: AsyncStream<AgentVoiceSessionState>.Continuation) {
        self.continuation = continuation
        continuation.yield(state)
    }

    public func updateState(_ newState: AgentVoiceSessionState) {
        self.state = newState
        continuation?.yield(newState)
    }

    public func updateAudioLevel(_ newLevel: Float) {
        self.audioLevel = newLevel
    }

    public func reset() {
        self.state = .disconnected
        self.audioLevel = 0.0
        continuation?.yield(.disconnected)
    }
}

/// Foundation provider for LiveKit room and session lifecycle management.
/// Conforms to `AgentVoiceSessionProvider` using Swift 6 async-safe actor state
/// and atomic lock synchronization without blocking locks in async contexts.
public final class LiveKitVoiceSessionProvider: AgentVoiceSessionProvider, @unchecked Sendable {
    private let url: String
    private let token: String
    private let voiceState = LiveKitVoiceState()

    private struct StateSnapshot: Sendable {
        var state: AgentVoiceSessionState = .disconnected
        var audioLevel: Float = 0.0
    }

#if canImport(os)
    private let snapshotLock = OSAllocatedUnfairLock(initialState: StateSnapshot())
#endif

#if canImport(LiveKit)
    private var room: Room?
#endif

    public var state: AgentVoiceSessionState {
#if canImport(os)
        snapshotLock.withLock { $0.state }
#else
        .disconnected
#endif
    }

    public var audioLevel: Float {
#if canImport(os)
        snapshotLock.withLock { $0.audioLevel }
#else
        0.0
#endif
    }

    public lazy var statePublisher: AsyncStream<AgentVoiceSessionState> = {
        AsyncStream { [weak self] cont in
            guard let self = self else { return }
            Task {
                await self.voiceState.setContinuation(cont)
            }
        }
    }()

    public init(url: String, token: String) {
        self.url = url
        self.token = token
    }

    public func startSession() async throws {
        await voiceState.updateState(.connecting)
#if canImport(os)
        snapshotLock.withLock { $0.state = .connecting }
#endif

#if canImport(LiveKit)
        let room = Room()
        self.room = room
        do {
            try await room.connect(url: url, token: token)
            await voiceState.updateState(.connected)
            await voiceState.updateState(.listening)
#if canImport(os)
            snapshotLock.withLock { $0.state = .listening }
#endif
        } catch {
            await voiceState.updateState(.error)
#if canImport(os)
            snapshotLock.withLock { $0.state = .error }
#endif
            throw error
        }
#else
        await voiceState.updateState(.connected)
        await voiceState.updateState(.listening)
#if canImport(os)
        snapshotLock.withLock { $0.state = .listening }
#endif
#endif
    }

    public func endSession() async {
#if canImport(LiveKit)
        if let room = self.room {
            await room.disconnect()
            self.room = nil
        }
#endif
        await voiceState.reset()
#if canImport(os)
        snapshotLock.withLock {
            $0.state = .disconnected
            $0.audioLevel = 0.0
        }
#endif
    }
}
