//
//  InlineSectionSourcesView.swift
//  AgentUI
//

import SwiftUI
import UIKit

public struct AgentInlineSectionSourcesView<MarkdownContent: View>: View {
    public let markdown: String
    public let sources: [WebSearchSource]
    public let isDarkMode: Bool
    public let markdownView: (String) -> MarkdownContent

    @State private var showSources = false
    @State private var textHeight: CGFloat = 22
    @StateObject private var renderer: SectionSourceClusterRenderer

    public init(
        markdown: String,
        sources: [WebSearchSource],
        isDarkMode: Bool,
        @ViewBuilder markdownView: @escaping (String) -> MarkdownContent
    ) {
        self.markdown = markdown
        self.sources = sources
        self.isDarkMode = isDarkMode
        self.markdownView = markdownView
        _renderer = StateObject(wrappedValue: SectionSourceClusterRenderer(sources: sources, isDarkMode: isDarkMode))
    }

    public var body: some View {
        Group {
            if let presentation = SectionSourcesPresentation.parse(markdown) {
                VStack(alignment: .leading, spacing: 0) {
                    if let leading = presentation.leadingMarkdown {
                        markdownView(leading)
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
                    markdownView(markdown)
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

public struct SectionSourcesTextView: UIViewRepresentable {
    public let markdown: String
    public let clusterImage: UIImage
    public let isDarkMode: Bool
    @Binding public var height: CGFloat
    public let onOpenSources: () -> Void

    public init(
        markdown: String,
        clusterImage: UIImage,
        isDarkMode: Bool,
        height: Binding<CGFloat>,
        onOpenSources: @escaping () -> Void
    ) {
        self.markdown = markdown
        self.clusterImage = clusterImage
        self.isDarkMode = isDarkMode
        self._height = height
        self.onOpenSources = onOpenSources
    }

    public func makeCoordinator() -> Coordinator { Coordinator(onOpenSources: onOpenSources) }

    public func makeUIView(context: Context) -> UITextView {
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

    public func updateUIView(_ view: UITextView, context: Context) {
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

    public final class Coordinator: NSObject, UITextViewDelegate {
        public var onOpenSources: () -> Void
        public init(onOpenSources: @escaping () -> Void) { self.onOpenSources = onOpenSources }

        public func textView(
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
