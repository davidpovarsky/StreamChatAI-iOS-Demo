#if canImport(Combine)
import Combine
#else
public protocol ObservableObject: AnyObject {}
#endif
import Foundation

public enum AgentVoiceSessionState: Equatable, Sendable {
    case idle
    case listening
    case speechDetected
    case processing
    case speaking
    case failed(String)
}

#if canImport(Combine)
public protocol AgentVoiceSessionProvider: AnyObject, Sendable {
    var statePublisher: AnyPublisher<AgentVoiceSessionState, Never> { get }
    var audioLevelPublisher: AnyPublisher<Float, Never> { get }
    var currentState: AgentVoiceSessionState { get }

    func startSession() async throws
    func stopSession() async
    func sendAudio(data: Data) async throws
}
#else
public protocol AgentVoiceSessionProvider: AnyObject, Sendable {
    var currentState: AgentVoiceSessionState { get }

    func startSession() async throws
    func stopSession() async
    func sendAudio(data: Data) async throws
}
#endif

public protocol AgentVoiceActivityDetecting: Sendable {
    func isSpeech(buffer: Data) -> Bool
}

public protocol AgentMarkdownParsing: Sendable {
    func parse(markdown: String) -> [AgentMessageBlock]
}

public protocol AgentToolResultRenderer: Sendable {
    static var supportedToolIDs: Set<String> { get }
    var toolID: String { get }
}
