#if canImport(AgentChatCore)
import AgentChatCore
#endif
import Foundation

public struct StreamChatAIAdapter: Sendable {
    public init() {}

    public func createAssistantMessage(from streamContent: String, isGenerating: Bool = false) -> AgentMessage {
        AgentMessage(
            role: .assistant,
            blocks: [.markdown(id: UUID().uuidString, text: streamContent)],
            rawText: streamContent,
            generationState: isGenerating ? .streaming : .completed
        )
    }

    public func createUserMessage(from text: String) -> AgentMessage {
        AgentMessage(
            role: .user,
            blocks: [.markdown(id: UUID().uuidString, text: text)],
            rawText: text,
            generationState: .completed
        )
    }
}
