#if canImport(SwiftUI)
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif
import AgentChatCore

public struct InlineSectionSourcesView<MarkdownContent: View>: View {
    public let markdown: String
    public let sources: [WebSearchSource]
    public let isDarkMode: Bool
    private let markdownRenderer: (String) -> MarkdownContent

    @State private var showSources = false
    @State private var textHeight: CGFloat = 22
    @StateObject private var renderer: SectionSourceClusterRenderer

    public init(
        markdown: String,
        sources: [WebSearchSource],
        isDarkMode: Bool,
        @ViewBuilder markdownRenderer: @escaping (String) -> MarkdownContent
    ) {
        self.markdown = markdown
        self.sources = sources
        self.isDarkMode = isDarkMode
        self.markdownRenderer = markdownRenderer
        _renderer = StateObject(wrappedValue: SectionSourceClusterRenderer(sources: sources, isDarkMode: isDarkMode))
    }

    public var body: some View {
        Group {
            if let presentation = SectionSourcesPresentation.parse(markdown) {
                VStack(alignment: .leading, spacing: 0) {
                    if let leading = presentation.leadingMarkdown {
                        markdownRenderer(leading)
                    }
                    SectionSourcesTextView(
                        markdown: presentation.paragraphMarkdown,
                        clusterImage: renderer.image,
                        isDarkMode: isDarkMode,
                        height: $textHeight,
                        onOpenSources: { showSources = true }
                    )
                    .frame(height: textHeight)
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    markdownRenderer(markdown)
                    Button { showSources = true } label: {
                        Image(uiImage: renderer.image)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .task { await renderer.load() }
        .sheet(isPresented: $showSources) {
            SourcesSheetView(sources: sources, isDarkMode: isDarkMode)
                .presentationDetents([.medium, .large])
        }
    }
}

extension InlineSectionSourcesView where MarkdownContent == Text {
    public init(
        markdown: String,
        sources: [WebSearchSource],
        isDarkMode: Bool
    ) {
        self.init(markdown: markdown, sources: sources, isDarkMode: isDarkMode) { text in
            Text(text)
        }
    }
}

#if canImport(UIKit)
private struct SectionSourcesTextView: UIViewRepresentable {
    let markdown: String
    let clusterImage: UIImage
    let isDarkMode: Bool
    @Binding var height: CGFloat
    let onOpenSources: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onOpenSources: onOpenSources)
    }

    func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
        view.isEditable = false
        view.isScrollEnabled = false
        view.backgroundColor = .clear
        view.textContainerInset = .zero
        view.textContainer.lineFragmentPadding = 0
        view.delegate = context.coordinator
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return view
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        context.coordinator.onOpenSources = onOpenSources
        uiView.attributedText = makeAttributedText()
        DispatchQueue.main.async {
            let targetSize = CGSize(width: uiView.bounds.width > 0 ? uiView.bounds.width : 320, height: .greatestFiniteMagnitude)
            let calculated = uiView.sizeThatFits(targetSize).height
            if abs(self.height - calculated) > 1 {
                self.height = calculated
            }
        }
    }

    private func makeAttributedText() -> NSAttributedString {
        let text = NSMutableAttributedString(
            string: markdown + " ",
            attributes: [
                .font: UIFont.systemFont(ofSize: 15),
                .foregroundColor: isDarkMode ? UIColor.white : UIColor.black
            ]
        )
        let attachment = NSTextAttachment(image: clusterImage)
        attachment.bounds = CGRect(x: 0, y: -3, width: clusterImage.size.width, height: clusterImage.size.height)
        let imageString = NSMutableAttributedString(attachment: attachment)
        imageString.addAttribute(.link, value: "swiftchat://sources", range: NSRange(location: 0, length: imageString.length))
        text.append(imageString)
        return text
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        var onOpenSources: () -> Void

        init(onOpenSources: @escaping () -> Void) {
            self.onOpenSources = onOpenSources
        }

        func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
            if URL.absoluteString == "swiftchat://sources" {
                onOpenSources()
                return false
            }
            return true
        }
    }
}
#else
private struct SectionSourcesTextView: View {
    let markdown: String
    let clusterImage: Any
    let isDarkMode: Bool
    @Binding var height: CGFloat
    let onOpenSources: () -> Void

    var body: some View {
        Text(markdown)
    }
}
#endif
#endif
