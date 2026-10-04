import SwiftUI
import UIKit

struct InlineSectionSourcesView: View {
    let markdown: String
    let sources: [WebSearchSource]
    let isDarkMode: Bool

    @State private var showSources = false
    @State private var textHeight: CGFloat = 22
    @StateObject private var renderer: SectionSourceClusterRenderer

    init(markdown: String, sources: [WebSearchSource], isDarkMode: Bool) {
        self.markdown = markdown
        self.sources = sources
        self.isDarkMode = isDarkMode
        _renderer = StateObject(wrappedValue: SectionSourceClusterRenderer(sources: sources, isDarkMode: isDarkMode))
    }

    var body: some View {
        Group {
            if let presentation = SectionSourcesPresentation.parse(markdown) {
                VStack(alignment: .leading, spacing: 0) {
                    if let leading = presentation.leadingMarkdown {
                        LaTeXMarkdownView(content: leading, isDarkMode: isDarkMode, isStreaming: false)
                            .equatable()
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
                    LaTeXMarkdownView(content: markdown, isDarkMode: isDarkMode, isStreaming: false)
                        .equatable()
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

private struct SectionSourcesTextView: UIViewRepresentable {
    let markdown: String
    let clusterImage: UIImage
    let isDarkMode: Bool
    @Binding var height: CGFloat
    let onOpenSources: () -> Void

    func makeCoordinator() -> Coordinator { Coordinator(onOpenSources: onOpenSources) }

    func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
        view.delegate = context.coordinator
        view.isEditable = false
        view.isScrollEnabled = false
        view.isSelectable = true
        view.backgroundColor = .clear
        view.textContainerInset = .zero
        view.textContainer.lineFragmentPadding = 0
        view.adjustsFontForContentSizeCategory = true
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return view
    }

    func updateUIView(_ view: UITextView, context: Context) {
        context.coordinator.onOpenSources = onOpenSources
        view.attributedText = attributedText
        view.tintColor = .clear
        let width = max(view.bounds.width, 1)
        let measured = view.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude)).height
        if abs(height - measured) > 0.5 {
            DispatchQueue.main.async { height = measured }
        }
    }

    private var attributedText: NSAttributedString {
        let output = NSMutableAttributedString(string: markdown, attributes: [
            .font: UIFont.preferredFont(forTextStyle: .body),
            .foregroundColor: isDarkMode ? UIColor.white : UIColor.label
        ])
        output.append(NSAttributedString(string: " "))
        let attachment = NSTextAttachment(image: clusterImage)
        attachment.bounds = CGRect(x: 0, y: -5, width: clusterImage.size.width, height: clusterImage.size.height)
        let start = output.length
        output.append(NSAttributedString(attachment: attachment))
        output.addAttribute(.link, value: URL(string: "swiftchat-section-sources://open")!, range: NSRange(location: start, length: 1))
        return output
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        var onOpenSources: () -> Void
        init(onOpenSources: @escaping () -> Void) { self.onOpenSources = onOpenSources }

        func textView(
            _ textView: UITextView,
            shouldInteractWith URL: URL,
            in characterRange: NSRange,
            interaction: UITextItemInteraction
        ) -> Bool {
            guard URL.scheme == "swiftchat-section-sources" else { return true }
            onOpenSources()
            return false
        }
    }
}
