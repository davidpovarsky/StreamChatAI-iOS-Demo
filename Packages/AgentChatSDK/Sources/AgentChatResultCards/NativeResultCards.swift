import SwiftUI
#if canImport(Kingfisher)
import Kingfisher
#endif
#if canImport(SVGView)
import SVGView
#endif
#if canImport(AVKit)
import AVKit
#endif
import AgentChatCore
import AgentChatMarkdown
import AgentChatSources
import AgentChatRichMedia
import AgentChatMotion

// MARK: - Result Dispatcher

public struct AgentResultDispatcher: View {
    public let result: AgentResult
    public let onAction: (AgentChatUserAction) -> Void

    public init(result: AgentResult, onAction: @escaping (AgentChatUserAction) -> Void) {
        self.result = result
        self.onAction = onAction
    }

    public var body: some View {
        Group {
            switch result.kind {
            case .markdown:
                MarkdownResultView(result: result, onAction: onAction)
            case .code:
                CodeResultView(result: result, onAction: onAction)
            case .math:
                MathResultView(result: result, onAction: onAction)
            case .image:
                ImageResultView(result: result, onAction: onAction)
            case .svg:
                SVGResultView(result: result, onAction: onAction)
            case .video:
                VideoResultView(result: result, onAction: onAction)
            case .audio:
                AudioResultView(result: result, onAction: onAction)
            case .file:
                FileResultView(result: result, onAction: onAction)
            case .citation:
                CitationResultView(result: result, onAction: onAction)
            case .chart:
                ChartResultView(result: result, onAction: onAction)
            case .map:
                MapResultView(result: result, onAction: onAction)
            case .calendar:
                CalendarResultView(result: result, onAction: onAction)
            case .reminder:
                ReminderResultView(result: result, onAction: onAction)
            case .health:
                HealthResultView(result: result, onAction: onAction)
            case .knowledge:
                KnowledgeResultView(result: result, onAction: onAction)
            case .form:
                FormResultView(result: result, onAction: onAction)
            case .canvasDocument:
                CanvasDocumentResultView(result: result, onAction: onAction)
            case .canvasCode:
                CanvasCodeResultView(result: result, onAction: onAction)
            case .miniApp:
                NativeMiniAppResultView(result: result, onAction: onAction)
            case .artifact:
                ArtifactResultView(result: result, onAction: onAction)
            case .error:
                ErrorResultView(result: result, onAction: onAction)
            case .approval:
                ApprovalResultView(result: result, onAction: onAction)
            case .richLink:
                RichLinkPreviewView(result: result, onAction: onAction)
            case .webContentFallback:
                WebContentFallbackResultView(result: result, onAction: onAction)
            case .toolFallback:
                ToolResultFallbackView(result: result, onAction: onAction)
            }
        }
        .agentCardEntrance()
    }
}

// MARK: - Markdown & Math & Code

public struct MarkdownResultView: View {
    public let result: AgentResult
    public let onAction: (AgentChatUserAction) -> Void
    public var body: some View {
        AgentChatMarkdownView(content: result.payload.contentText ?? "")
    }
}

public struct CodeResultView: View {
    public let result: AgentResult
    public let onAction: (AgentChatUserAction) -> Void
    @State private var isCopied = false

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(result.payload.language ?? "Code")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Button {
                    #if canImport(UIKit)
                    UIPasteboard.general.string = result.payload.contentText ?? ""
                    #endif
                    isCopied = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { isCopied = false }
                } label: {
                    Label(isCopied ? "Copied" : "Copy", systemImage: isCopied ? "checkmark" : "doc.on.doc")
                        .font(.caption)
                }
                .buttonStyle(.plain)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                Text(result.payload.contentText ?? "")
                    .font(.system(size: 13, design: .monospaced))
                    .padding(8)
            }
            .background(RoundedRectangle(cornerRadius: 8).fill(Color.secondary.opacity(0.08)))
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 12).stroke(Color.secondary.opacity(0.15)))
    }
}

public struct MathResultView: View {
    public let result: AgentResult
    public let onAction: (AgentChatUserAction) -> Void
    public var body: some View {
        LaTeXView(latex: result.payload.contentText ?? "", isDisplay: true, isDarkMode: false)
    }
}

// MARK: - Media Cards (Image, SVG, Video, Audio)

public struct ImageResultView: View {
    public let result: AgentResult
    public let onAction: (AgentChatUserAction) -> Void
    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let urlStr = result.payload.urlString, let url = URL(string: urlStr) {
                #if canImport(Kingfisher)
                KFImage(url)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 280)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                #else
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image.resizable().aspectRatio(contentMode: .fit)
                    } else {
                        ProgressView()
                    }
                }
                .frame(maxHeight: 280)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                #endif
            }
            if let title = result.title {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

public struct SVGResultView: View {
    public let result: AgentResult
    public let onAction: (AgentChatUserAction) -> Void
    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let svg = result.payload.metadata["svgString"]?.stringValue {
                #if canImport(SVGView)
                SVGView(string: svg)
                    .frame(height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                #else
                Text("SVG Preview")
                #endif
            }
            if let title = result.title {
                Text(title).font(.caption).foregroundColor(.secondary)
            }
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.secondary.opacity(0.05)))
    }
}

public struct VideoResultView: View {
    public let result: AgentResult
    public let onAction: (AgentChatUserAction) -> Void
    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let urlStr = result.payload.urlString, let url = URL(string: urlStr) {
                #if canImport(AVKit)
                VideoPlayer(player: AVPlayer(url: url))
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                #else
                Text("Video not supported on platform")
                #endif
            }
            if let title = result.title {
                Text(title).font(.caption).foregroundColor(.secondary)
            }
        }
    }
}

public struct AudioResultView: View {
    public let result: AgentResult
    public let onAction: (AgentChatUserAction) -> Void
    @State private var isPlaying = false
    public var body: some View {
        HStack(spacing: 12) {
            Button {
                isPlaying.toggle()
            } label: {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.blue)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text(result.title ?? "Audio Recording")
                    .font(.system(size: 14, weight: .semibold))
                Text("02:45 • High Quality AAC")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.secondary.opacity(0.06)))
    }
}

// MARK: - File & Citations

public struct FileResultView: View {
    public let result: AgentResult
    public let onAction: (AgentChatUserAction) -> Void
    public var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "doc.fill")
                .font(.system(size: 28))
                .foregroundColor(.blue)
            VStack(alignment: .leading, spacing: 2) {
                Text(result.title ?? "Exported Document.pdf")
                    .font(.system(size: 14, weight: .medium))
                Text("2.4 MB • PDF Document")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Button {
                let action = AgentChatUserAction(
                    kind: .share(content: result.title ?? "file"),
                    context: AgentResultActionContext(conversationId: "demo", messageId: result.messageId, resultId: result.id)
                )
                onAction(action)
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 14))
                    .foregroundColor(.blue)
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.secondary.opacity(0.06)))
    }
}

public struct CitationResultView: View {
    public let result: AgentResult
    public let onAction: (AgentChatUserAction) -> Void
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(result.title ?? "Retrieved Citations")
                .font(.system(size: 14, weight: .semibold))
            AgentSourceChipsView(sources: result.payload.sources)
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.secondary.opacity(0.06)))
    }
}

// MARK: - Calendar & Reminders

public struct CalendarResultView: View {
    public let result: AgentResult
    public let onAction: (AgentChatUserAction) -> Void
    public var body: some View {
        HStack(spacing: 12) {
            VStack {
                Text("OCT")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.red)
                Text("14")
                    .font(.system(size: 18, weight: .bold))
            }
            .frame(width: 44, height: 44)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color.secondary.opacity(0.12)))

            VStack(alignment: .leading, spacing: 2) {
                Text(result.title ?? "Design Review with Team")
                    .font(.system(size: 14, weight: .semibold))
                Text("Tuesday, 10:30 AM – 11:30 AM • Cupertino Room")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("Demo — simulated calendar confirmation")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary.opacity(0.8))
            }
            Spacer()
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.secondary.opacity(0.06)))
    }
}

public struct ReminderResultView: View {
    public let result: AgentResult
    public let onAction: (AgentChatUserAction) -> Void
    @State private var isChecked = false
    public var body: some View {
        HStack(spacing: 10) {
            Button {
                isChecked.toggle()
                let action = AgentChatUserAction(
                    kind: .select(option: isChecked ? "completed" : "pending"),
                    context: AgentResultActionContext(conversationId: "demo", messageId: result.messageId, resultId: result.id)
                )
                onAction(action)
            } label: {
                Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(isChecked ? .green : .secondary)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text(result.title ?? "Finalize iOS 27 Architecture Spec")
                    .font(.system(size: 14, weight: .medium))
                    .strikethrough(isChecked)
                Text("Due Today, 5:00 PM • Priority High")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.secondary.opacity(0.06)))
    }
}

// MARK: - Health & Knowledge

public struct HealthResultView: View {
    public let result: AgentResult
    public let onAction: (AgentChatUserAction) -> Void
    public var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "heart.fill")
                .font(.system(size: 26))
                .foregroundColor(.red)
            VStack(alignment: .leading, spacing: 2) {
                Text(result.title ?? "Daily Health Activity")
                    .font(.system(size: 14, weight: .semibold))
                Text("8,420 steps • 420 active kcal • 72 bpm avg")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("Demo — Simulated HealthKit fixture data")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary.opacity(0.8))
            }
            Spacer()
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.secondary.opacity(0.06)))
    }
}

public struct KnowledgeResultView: View {
    public let result: AgentResult
    public let onAction: (AgentChatUserAction) -> Void
    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(.purple)
                Text(result.title ?? "Saved to Knowledge Base")
                    .font(.system(size: 14, weight: .semibold))
                Spacer()
                Text("Memory")
                    .font(.system(size: 10, weight: .bold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(Color.purple.opacity(0.12)))
            }
            Text(result.payload.contentText ?? "User prefers native SwiftUI components with zero webview overhead and pure Swift 6 concurrency.")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.secondary.opacity(0.06)))
    }
}

// MARK: - Native MiniApp & Artifacts

public struct NativeMiniAppResultView: View {
    public let result: AgentResult
    public let onAction: (AgentChatUserAction) -> Void
    @State private var activeTab = 0
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "square.grid.2x2.fill")
                    .foregroundColor(.blue)
                Text(result.title ?? "Interactive Project Status")
                    .font(.system(size: 15, weight: .semibold))
                Spacer()
                Text("MiniApp")
                    .font(.system(size: 10, weight: .bold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(Color.blue.opacity(0.12)))
            }
            Picker("Tabs", selection: $activeTab) {
                Text("Metrics").tag(0)
                Text("Tasks").tag(1)
            }
            .pickerStyle(.segmented)

            if activeTab == 0 {
                HStack(spacing: 12) {
                    VStack(alignment: .leading) {
                        Text("Accuracy")
                            .font(.caption).foregroundColor(.secondary)
                        Text("99.4%")
                            .font(.title3.bold()).foregroundColor(.green)
                    }
                    Divider()
                    VStack(alignment: .leading) {
                        Text("Latency")
                            .font(.caption).foregroundColor(.secondary)
                        Text("42 ms")
                            .font(.title3.bold()).foregroundColor(.blue)
                    }
                }
                .padding(8)
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text("✓ Phase 1 CI Verified").font(.system(size: 12))
                    Text("✓ iOS 27 SwiftUI Shell Built").font(.system(size: 12))
                    Text("✓ Hierarchical Activity Nested").font(.system(size: 12))
                }
                .padding(8)
            }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color.secondary.opacity(0.06)))
    }
}

public struct ArtifactResultView: View {
    public let result: AgentResult
    public let onAction: (AgentChatUserAction) -> Void
    public var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "cube.box.fill")
                .font(.system(size: 24))
                .foregroundColor(.orange)
            VStack(alignment: .leading, spacing: 2) {
                Text(result.title ?? "Compiled Artifact")
                    .font(.system(size: 14, weight: .semibold))
                Text("AgentChatSDK-Native-Demo-unsigned.ipa • 20.2 MB")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.secondary.opacity(0.06)))
    }
}

// MARK: - Fallback, Error, Approval, Link

public struct ToolResultFallbackView: View {
    public let result: AgentResult
    public let onAction: (AgentChatUserAction) -> Void
    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "wrench.and.screwdriver")
                    .foregroundColor(.secondary)
                Text(result.title ?? "Tool Result")
                    .font(.system(size: 14, weight: .semibold))
            }
            Text(result.payload.contentText ?? result.payload.subtitle ?? "Operation completed.")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.secondary.opacity(0.06)))
    }
}

public struct ErrorResultView: View {
    public let result: AgentResult
    public let onAction: (AgentChatUserAction) -> Void
    public var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
            VStack(alignment: .leading, spacing: 2) {
                Text(result.title ?? "Operation Encountered An Error")
                    .font(.system(size: 13, weight: .semibold))
                Text(result.payload.contentText ?? "Request timed out. Tap retry to attempt again.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Button {
                let action = AgentChatUserAction(
                    kind: .retry(operationId: nil),
                    context: AgentResultActionContext(conversationId: "demo", messageId: result.messageId, resultId: result.id)
                )
                onAction(action)
            } label: {
                Text("Retry")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(RoundedRectangle(cornerRadius: 6).fill(Color.blue))
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.red.opacity(0.08)))
    }
}

public struct ApprovalResultView: View {
    public let result: AgentResult
    public let onAction: (AgentChatUserAction) -> Void
    public var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.shield.fill")
                .foregroundColor(.green)
            Text(result.title ?? "Action Confirmed")
                .font(.system(size: 13, weight: .medium))
            Spacer()
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.green.opacity(0.08)))
    }
}

public struct RichLinkPreviewView: View {
    public let result: AgentResult
    public let onAction: (AgentChatUserAction) -> Void
    @Environment(\.openURL) private var openURL

    public var body: some View {
        Button {
            if let str = result.payload.urlString, let url = URL(string: str) {
                openURL(url)
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "link.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.blue)
                VStack(alignment: .leading, spacing: 2) {
                    Text(result.title ?? "Web Page Preview")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                    Text(result.payload.urlString ?? "")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.secondary.opacity(0.06)))
        }
        .buttonStyle(.plain)
    }
}

public struct WebContentFallbackResultView: View {
    public let result: AgentResult
    public let onAction: (AgentChatUserAction) -> Void
    @Environment(\.openURL) private var openURL

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "play.rectangle.fill")
                    .foregroundColor(.red)
                Text(result.title ?? "External Web Video")
                    .font(.system(size: 14, weight: .semibold))
                Spacer()
                Text("Native Preview")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.secondary)
            }

            Text("Embedded web content is isolated from the native SDK core. Open in browser to view full interactive playback.")
                .font(.caption)
                .foregroundColor(.secondary)

            if let urlStr = result.payload.urlString, let url = URL(string: urlStr) {
                Button {
                    openURL(url)
                } label: {
                    Label("Open in Browser", systemImage: "arrow.up.right.square")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.secondary.opacity(0.06)))
    }
}
