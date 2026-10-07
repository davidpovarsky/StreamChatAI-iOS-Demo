import Foundation
import Combine
import AgentChatCore
import AgentChatSwiftChat
import AgentChatActivity
import AgentChatToolPresentation
import AgentChatVoice

@MainActor
public final class AgentChatSession: ObservableObject {
    @Published public var viewModel: ChatViewModel
    @Published public var configuration: AgentChatConfiguration
    public let activityStore: AgentActivityStore
    public let toolStore: ToolExecutionDemoStore
    @Published public var voiceProvider: AgentVoiceSessionProvider
    public var runtimeProvider: AgentChatRuntimeProvider?

    public init(
        configuration: AgentChatConfiguration = AgentChatConfiguration(),
        runtimeProvider: AgentChatRuntimeProvider? = nil,
        voiceProvider: AgentVoiceSessionProvider? = nil
    ) {
        self.configuration = configuration
        self.viewModel = ChatViewModel()
        self.activityStore = AgentActivityStore.shared
        self.toolStore = ToolExecutionDemoStore.shared
        self.runtimeProvider = runtimeProvider
        self.voiceProvider = voiceProvider ?? AgentMockVoiceProvider()

        if let runtimeProvider {
            self.viewModel.runtimeProvider = runtimeProvider
        }
    }

    public func sendMessage(_ content: String) {
        viewModel.sendMessage(content)
    }

    public func clearMessages() {
        if var current = viewModel.currentChat {
            current.messages.removeAll()
            viewModel.currentChat = current
        }
    }

    public var messages: [Message] {
        viewModel.messages
    }

    public var currentChat: Chat? {
        viewModel.currentChat
    }

    public var isLoading: Bool {
        viewModel.isLoading
    }

    // MARK: - Deterministic Scenarios

    public func startWebResearchScenario() {
        let msgID = UUID().uuidString
        AgentActivityDemoDriver.start(messageID: msgID)
    }

    public func startToolExecutionScenario() {
        toolStore.status = .running
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 800_000_000)
            toolStore.status = .completed
        }
    }

    public func startRichContentScenario() {
        // Triggers display of rich parts already supported by SwiftChat
        if var current = viewModel.currentChat {
            let richMessage = Message(
                role: .assistant,
                content: """
                Here is a demonstration of multimodal mathematical and vector rendering:

                Euler's Identity:
                $$e^{i\\pi} + 1 = 0$$

                Code block:
                ```swift
                func greet(agent: String) -> String {
                    return "Hello, \\(agent)!"
                }
                ```
                """
            )
            current.messages.append(richMessage)
            viewModel.currentChat = current
        }
    }

    public func startVoiceScenario() {
        Task { @MainActor in
            try? await voiceProvider.startSession()
        }
    }

    public func startFailureRetryScenario() {
        toolStore.status = .failed
    }
}

/// Convenience demo driver for host applications and previews
@MainActor
public final class DeterministicDemoDriver: ObservableObject {
    public let session: AgentChatSession

    public init(session: AgentChatSession) {
        self.session = session
    }

    public func startWebResearchScenario() {
        session.startWebResearchScenario()
    }

    public func startToolExecutionScenario() {
        session.startToolExecutionScenario()
    }

    public func startRichContentScenario() {
        session.startRichContentScenario()
    }

    public func startVoiceScenario() {
        session.startVoiceScenario()
    }

    public func startFailureRetryScenario() {
        session.startFailureRetryScenario()
    }
}
