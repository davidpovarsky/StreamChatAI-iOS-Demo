// Sources/AgentUI/Rendering/AgentContentRenderer.swift
#if canImport(SwiftUI)
import SwiftUI

public struct AgentContentRenderer: View {
    public let block: AgentContentBlock

    public init(block: AgentContentBlock) {
        self.block = block
    }

    public var body: some View {
        switch block {
        case .markdown(_, let content):
            AgentMarkdownView(content: content)

        case .linkPreview(_, let url, let title, let description, let iconURL):
            AgentLinkPreviewView(
                url: url,
                title: title,
                descriptionText: description,
                iconURL: iconURL
            )

        case .attachment(_, let att):
            HStack(spacing: 8) {
                Image(systemName: att.isImage ? "photo" : "doc")
                Text(att.filename)
                    .font(.subheadline)
            }
            .padding(10)
            .background(Color.secondary.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 10))

        case .toolExecution(_, let execution):
            // ToolExecutionDisclosure will render this
            ToolExecutionDisclosure(execution: execution)

        case .embeddedResult(_, let descriptor):
            // AgentEmbeddedResultHost will render this
            AgentEmbeddedResultHost(descriptor: descriptor)

        case .nativeUI(_, let block):
            AgentNativeBlockRenderer(block: block)

        case .image(_, let url, _, let caption):
            AgentImageView(url: url, caption: caption)

        case .video(_, let url, let title, let caption):
            AgentVideoView(url: url, title: title, caption: caption)

        case .youtube(_, let videoID, let title, let subtitle):
            AgentYouTubeView(videoID: videoID, title: title, subtitle: subtitle)

        case .customSurface(_, let handlerID, _):
            Text("Surface: \(handlerID)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
#endif
