from pathlib import Path

root = Path("upstream/SwiftChat")

# ---------------------------------------------------------------------------
# 1. "+" menu: the presentation modifier belongs on the + BUTTON itself.
#    This makes iOS use that control as the popover source/anchor.
# ---------------------------------------------------------------------------
p = root / "SwiftChat/Views/MessageInputView.swift"
s = p.read_text(encoding="utf-8")

# Remove the old AddToChat sheet from the root input view.
old_sheet = """            .sheet(isPresented: $showAddSheet, onDismiss: {
                guard let action = pendingPickerAction else { return }
                pendingPickerAction = nil
                switch action {
                case .camera: showCamera = true
                case .photos: showPhotoPicker = true
                case .files: showDocumentPicker = true
                }
            }) {
                AddToSheetView(
                    viewModel: viewModel,
                    isDarkMode: isDarkMode,
                    onCamera: {
                        pendingPickerAction = .camera
                        showAddSheet = false
                    },
                    onPhotos: {
                        pendingPickerAction = .photos
                        showAddSheet = false
                    },
                    onFiles: {
                        pendingPickerAction = .files
                        showAddSheet = false
                    }
                )
                .presentationDetents([.height(340)])
                .presentationBackground(isDarkMode ? Color(hex: "161616") : Color(UIColor.systemGroupedBackground))
            }"""
if old_sheet not in s:
    raise SystemExit("Original AddToChat sheet not found")
s = s.replace(old_sheet, "", 1)

old_button = """    @ViewBuilder
    private var attachButton: some View {
        Button {
            showAddSheet = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 20))
                .foregroundColor(.secondary)
                .frame(width: 24, height: 24)
        }
        .disabled(viewModel.isLoading || viewModel.isProcessingAttachment)
        .padding(.leading, 8)
    }"""

new_button = """    @ViewBuilder
    private var attachButton: some View {
        Button {
            showAddSheet.toggle()
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 20))
                .foregroundColor(.secondary)
                .frame(width: 24, height: 24)
        }
        .disabled(viewModel.isLoading || viewModel.isProcessingAttachment)
        .padding(.leading, 8)
        .popover(
            isPresented: $showAddSheet,
            attachmentAnchor: .rect(.bounds),
            arrowEdge: .bottom
        ) {
            AddToSheetView(
                viewModel: viewModel,
                isDarkMode: isDarkMode,
                onCamera: {
                    showAddSheet = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { showCamera = true }
                },
                onPhotos: {
                    showAddSheet = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { showPhotoPicker = true }
                },
                onFiles: {
                    showAddSheet = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { showDocumentPicker = true }
                }
            )
            .frame(width: 310)
            .presentationCompactAdaptation(.popover)
        }
    }"""

if old_button not in s:
    raise SystemExit("attachButton not found")
s = s.replace(old_button, new_button, 1)

# Make the popover content compact rather than a bottom-sheet layout.
start = s.find("struct AddToSheetView: View {")
end = s.find("/// Simple model card for the model selector", start)
if start < 0 or end < 0:
    raise SystemExit("AddToSheetView range not found")

compact = """struct AddToSheetView: View {
    @ObservedObject var viewModel: SwiftChat.ChatViewModel
    let isDarkMode: Bool
    let onCamera: () -> Void
    let onPhotos: () -> Void
    let onFiles: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Add to chat")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 14)
                .padding(.top, 10)

            if viewModel.currentModel.isMultimodal {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    actionRow("camera", "Camera", onCamera)
                }
                actionRow("photo.on.rectangle", "Photos", onPhotos)
            }

            actionRow("doc.badge.arrow.up", "Files", onFiles)

            Divider().padding(.vertical, 3)

            Menu {
                ForEach(AppConfig.shared.filteredModelTypes()) { model in
                    Button {
                        viewModel.changeModel(to: model)
                    } label: {
                        if viewModel.currentModel.id == model.id {
                            Label(model.displayName, systemImage: "checkmark")
                        } else {
                            Text(model.displayName)
                        }
                    }
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "cpu").frame(width: 22)
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Model")
                        Text(viewModel.currentModel.displayName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 6)
        .background(isDarkMode ? Color(hex: "1C1C1E") : Color(UIColor.secondarySystemBackground))
    }

    private func actionRow(_ icon: String, _ title: String, _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon).frame(width: 22)
                Text(title)
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

"""
s = s[:start] + compact + s[end:]
p.write_text(s, encoding="utf-8")

# ---------------------------------------------------------------------------
# 2. Citations: keep the bottom WebSearchBox/SourcesButton behavior unchanged.
#    ONLY taps on citation links embedded in the answer reveal an inline card.
# ---------------------------------------------------------------------------
p = root / "SwiftChat/Views/MessageView.swift"
s = p.read_text(encoding="utf-8")

s = s.replace(
    "@State private var showSourcesSheet = false",
    "@State private var showSourcesSheet = false\n    @State private var expandedCitation: InlineCitation? = nil",
    1,
)

# Put the inline card directly after rendered assistant content, before errors/actions.
anchor = """                // Show error box with regenerate button if stream failed
                if message.streamError != nil && message.role == .assistant {"""
inline = """                if message.role == .assistant, let citation = expandedCitation {
                    InlineCitationCard(citation: citation, isDarkMode: isDarkMode)
                        .padding(.top, 6)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }

                // Show error box with regenerate button if stream failed
                if message.streamError != nil && message.role == .assistant {"""
if anchor not in s:
    raise SystemExit("MessageView inline insertion anchor not found")
s = s.replace(anchor, inline, 1)

old_handler = """            if url.scheme == "cite" {
                let path = url.absoluteString.dropFirst(5)
                if let tildeIndex = path.firstIndex(of: "~") {
                    let afterFirstTilde = path[path.index(after: tildeIndex)...]
                    if let secondTildeIndex = afterFirstTilde.firstIndex(of: "~") {
                        let encodedUrl = String(afterFirstTilde[..<secondTildeIndex])
                        if let decodedUrl = encodedUrl.removingPercentEncoding,
                           let sourceURL = URL(string: decodedUrl) {
                            UIApplication.shared.open(sourceURL)
                            return .handled
                        }
                    }
                }
                return .handled
            }"""

new_handler = """            if url.scheme == "cite" {
                if let citation = InlineCitation.parse(url) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        expandedCitation = expandedCitation?.url == citation.url ? nil : citation
                    }
                }
                return .handled
            }"""
if old_handler not in s:
    raise SystemExit("Original citation OpenURL handler not found")
s = s.replace(old_handler, new_handler, 1)

insert_before = "private struct LongMessageAttachmentView: View {"
citation_types = r'''private struct InlineCitation: Equatable {
    let number: String
    let url: String
    let title: String

    static func parse(_ url: URL) -> InlineCitation? {
        guard url.scheme == "cite" else { return nil }
        let raw = String(url.absoluteString.dropFirst("cite:".count))
        let pieces = raw.split(separator: "~", maxSplits: 2, omittingEmptySubsequences: false)
        guard pieces.count >= 2 else { return nil }

        let number = String(pieces[0]).replacingOccurrences(of: "#cite-", with: "")
        let decodedURL = String(pieces[1]).removingPercentEncoding ?? String(pieces[1])
        let decodedTitle: String
        if pieces.count > 2 {
            decodedTitle = String(pieces[2]).removingPercentEncoding ?? String(pieces[2])
        } else {
            decodedTitle = URL(string: decodedURL)?.host ?? decodedURL
        }

        return InlineCitation(number: number, url: decodedURL, title: decodedTitle)
    }

    var domain: String {
        guard let host = URL(string: url)?.host else { return url }
        return host.hasPrefix("www.") ? String(host.dropFirst(4)) : host
    }
}

private struct InlineCitationCard: View {
    let citation: InlineCitation
    let isDarkMode: Bool

    var body: some View {
        Button {
            if let url = URL(string: citation.url) {
                UIApplication.shared.open(url)
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "globe")
                    .font(.system(size: 14, weight: .semibold))
                    .frame(width: 26, height: 26)
                    .background(.secondary.opacity(0.10), in: Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(citation.title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    Text(citation.domain)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 13)
                    .fill(isDarkMode ? Color.white.opacity(0.06) : Color.black.opacity(0.045))
            )
        }
        .buttonStyle(.plain)
    }
}

'''
if insert_before not in s:
    raise SystemExit("MessageView type insertion anchor not found")
s = s.replace(insert_before, citation_types + insert_before, 1)
p.write_text(s, encoding="utf-8")

# ---------------------------------------------------------------------------
# 3. Renderer: preserve cite:// links as clickable inline citations.
#    The original renderer deliberately strips them after streaming.
# ---------------------------------------------------------------------------
p = root / "SwiftChat/Views/LaTeXMarkdownView.swift"
s = p.read_text(encoding="utf-8")
s = s.replace(
    "let strippedText = isStreaming ? text : LaTeXMarkdownView.stripCitations(from: text)",
    "let strippedText = text",
)
s = s.replace(
    "let strippedText = LaTeXMarkdownView.stripCitations(from: content)",
    "let strippedText = content",
)
p.write_text(s, encoding="utf-8")

print("SwiftChat UI upgraded: plus-anchored native popover + citation-only inline expansion")
