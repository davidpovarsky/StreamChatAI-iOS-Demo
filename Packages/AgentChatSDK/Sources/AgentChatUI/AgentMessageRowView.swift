#if canImport(SwiftUI)
import AgentChatActivity
import AgentChatCore
import AgentChatMedia
import AgentChatRendering
import AgentChatRichResults
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

public struct AgentMessageRowView: View {
    public let message: AgentMessage
    public let activitySession: AgentActivitySession?
    public var configuration: AgentChatConfiguration
    public var onRetry: (() -> Void)?

    @State private var copied = false
    @Environment(\.layoutDirection) private var layoutDirection

    public init(
        message: AgentMessage,
        activitySession: AgentActivitySession? = nil,
        configuration: AgentChatConfiguration = AgentChatConfiguration(),
        onRetry: (() -> Void)? = nil
    ) {
        self.message = message
        self.activitySession = activitySession
        self.configuration = configuration
        self.onRetry = onRetry
    }

    public var body: some View {
        if message.role == .user {
            userRow
        } else {
            assistantRow
        }
    }

    private var userRow: some View {
        HStack {
            Spacer(minLength: 48)

            Text(message.rawText)
                .font(.system(size: 15))
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color.blue.opacity(0.12), in: RoundedRectangle(cornerRadius: configuration.appearance.userBubbleCornerRadius))
                .foregroundStyle(.primary)
                .textSelection(.enabled)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }

    private var assistantRow: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: configuration.appearance.assistantAvatarSystemName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.blue)
                .frame(width: 28, height: 28)
                .background(Color.blue.opacity(0.1), in: Circle())
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 10) {
                // Activity timeline
                if let activity = activitySession, !activity.items.isEmpty {
                    AgentActivityTimelineView(session: activity)
                }

                // Blocks
                ForEach(message.blocks) { block in
                    renderBlock(block)
                }

                // If no blocks parsed but raw text exists
                if message.blocks.isEmpty && !message.rawText.isEmpty {
                    AgentMarkdownView(text: message.rawText)
                }

                // Generating typing indicator
                if message.isGenerating && message.rawText.isEmpty && (activitySession == nil || activitySession!.items.isEmpty) {
                    HStack(spacing: 6) {
                        ProgressView().controlSize(.mini)
                        Text("Thinking...")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }

                // Failure banner
                if case .failed(let error) = message.generationState {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        if let onRetry = onRetry {
                            Button("Retry", action: onRetry)
                                .font(.caption.bold())
                                .foregroundStyle(.blue)
                        }
                    }
                    .padding(8)
                    .background(Color.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                }

                // Action bar
                if !message.isGenerating {
                    HStack(spacing: 12) {
                        Button {
                            copyText()
                        } label: {
                            Image(systemName: copied ? "checkmark" : "doc.on.doc")
                                .font(.system(size: 12))
                                .foregroundStyle(copied ? .green : .secondary)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Copy response")

                        if let onRetry = onRetry {
                            Button(action: onRetry) {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 12))
                                    .foregroundStyle(.secondary)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Retry generation")
                        }

                        Spacer()
                    }
                    .padding(.top, 2)
                }
            }

            Spacer(minLength: 8)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
    }

    @ViewBuilder
    private func renderBlock(_ block: AgentMessageBlock) -> some View {
        switch block {
        case .markdown(_, let text):
            if configuration.capabilities.supportsMarkdown {
                AgentMarkdownView(text: text)
            } else {
                Text(text)
            }

        case .code(_, let code, let language):
            if configuration.capabilities.supportsCodeHighlighting {
                AgentCodeBlockView(
                    code: code,
                    language: language,
                    lineWrapping: configuration.rendering.codeLineWrapping
                )
            } else {
                Text(code)
                    .font(.system(size: 13, design: .monospaced))
            }

        case .math(_, let formula, let displayMode):
            if configuration.capabilities.supportsLaTeXMath {
                AgentMathView(formula: formula, displayMode: displayMode)
            } else {
                Text(formula).font(.system(size: 14, design: .serif).italic())
            }

        case .image(_, let content):
            if configuration.capabilities.supportsRemoteImages {
                AgentRemoteImageView(content: content)
            }

        case .imageGallery(_, let images):
            if configuration.capabilities.supportsRemoteImages {
                AgentImageGalleryView(images: images)
            }

        case .svg(_, let content):
            if configuration.capabilities.supportsSVG {
                AgentSVGView(content: content)
            }

        case .video(_, let content):
            AgentVideoMediaView(content: content)

        case .sources(_, let items):
            if configuration.capabilities.supportsCitations {
                InlineSectionSourcesView(sources: items)
            }

        case .tool(_, let call, let result):
            if configuration.capabilities.supportsToolExecution {
                AgentRichResultView(call: call, result: result)
            }

        case .richResult(_, let content):
            if configuration.capabilities.supportsRichResults {
                HStack(spacing: 10) {
                    Image(systemName: "sparkles.rectangle.stack.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.blue)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(content.title)
                            .font(.system(size: 14, weight: .semibold))
                        if let sub = content.subtitle {
                            Text(sub).font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(10)
                .background(Color.blue.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
            }

        case .custom(_, let type, let payload):
            Text("[\(type): \(payload)]")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func copyText() {
        #if canImport(UIKit)
        UIPasteboard.general.string = message.rawText
        #endif
        copied = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            copied = false
        }
    }
}
#endif
