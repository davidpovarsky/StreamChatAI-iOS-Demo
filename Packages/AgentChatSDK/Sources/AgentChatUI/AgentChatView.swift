#if canImport(SwiftUI)
import AgentChatActivity
import AgentChatCore
import AgentChatVoice
import SwiftUI

public struct AgentChatView: View {
    @ObservedObject public var session: AgentChatSession
    public var configuration: AgentChatConfiguration

    @State private var composerText: String = ""
    @State private var showingVoiceOverlay = false
    @State private var voiceProvider: AgentVoiceSessionProvider = AgentMockVoiceProvider()

    public init(
        session: AgentChatSession,
        configuration: AgentChatConfiguration = AgentChatConfiguration()
    ) {
        self.session = session
        self.configuration = configuration
    }

    public var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 14) {
                        ForEach(session.messages) { message in
                            AgentMessageRowView(
                                message: message,
                                activitySession: session.currentActivity?.messageID == message.id ? session.currentActivity : nil,
                                configuration: configuration,
                                onRetry: {
                                    session.retryLastAssistantMessage()
                                }
                            )
                            .id(message.id)
                        }

                        // Floating typing indicator if user sent and assistant hasn't started streaming
                        if session.isGenerating && session.messages.last?.role == .user {
                            HStack(spacing: 8) {
                                Image(systemName: configuration.appearance.assistantAvatarSystemName)
                                    .foregroundStyle(.blue)
                                ProgressView()
                                    .controlSize(.mini)
                                Text("Thinking...")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.secondary)
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                        }
                    }
                    .padding(.vertical, 12)
                    .frame(maxWidth: CGFloat(configuration.appearance.adaptiveMaxWidth))
                    .frame(maxWidth: .infinity)
                }
                .onChange(of: session.messages.count) { _ in
                    scrollToBottom(proxy: proxy)
                }
                .onChange(of: session.messages.last?.rawText) { _ in
                    scrollToBottom(proxy: proxy)
                }
            }

            if configuration.appearance.showDividers {
                Divider()
            }

            // Composer
            AgentComposerView(
                text: $composerText,
                isGenerating: session.isGenerating,
                configuration: configuration.composer,
                onSend: { text, attachments in
                    session.appendUserMessage(text: text, attachments: attachments)
                },
                onStop: {
                    session.stopGeneration()
                },
                onVoiceTap: {
                    showingVoiceOverlay = true
                }
            )
            .frame(maxWidth: CGFloat(configuration.appearance.adaptiveMaxWidth))
            .frame(maxWidth: .infinity)
            .padding(.top, 4)
        }
        .sheet(isPresented: $showingVoiceOverlay) {
            AgentVoiceOverlayView(provider: voiceProvider)
        }
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        if let lastID = session.messages.last?.id {
            withAnimation(.easeOut(duration: 0.15)) {
                proxy.scrollTo(lastID, anchor: .bottom)
            }
        }
    }
}
#endif
