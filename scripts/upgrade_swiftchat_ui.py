from pathlib import Path

root = Path("upstream/SwiftChat")

# Composer: replace the + sheet with a compact anchored popover.
p = root / "SwiftChat/Views/MessageInputView.swift"
s = p.read_text(encoding="utf-8")
s = s.replace("@State private var showAddSheet = false", "@State private var showAddPopover = false")
s = s.replace("showAddSheet = true", "showAddPopover = true")
old = """            .sheet(isPresented: $showAddSheet, onDismiss: {
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
new = """            .popover(isPresented: $showAddPopover, attachmentAnchor: .rect(.bounds), arrowEdge: .bottom) {
                AddToPopoverView(
                    viewModel: viewModel,
                    isDarkMode: isDarkMode,
                    onCamera: {
                        showAddPopover = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { showCamera = true }
                    },
                    onPhotos: {
                        showAddPopover = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { showPhotoPicker = true }
                    },
                    onFiles: {
                        showAddPopover = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { showDocumentPicker = true }
                    }
                )
                .frame(width: 300)
                .presentationCompactAdaptation(.popover)
            }"""
if old not in s:
    raise SystemExit("attachment sheet block not found")
s = s.replace(old, new, 1)

start = s.find("struct AddToSheetView: View {")
end = s.find("/// Simple model card for the model selector", start)
if start < 0 or end < 0:
    raise SystemExit("AddToSheetView block not found")
compact = """struct AddToPopoverView: View {
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

# Message citations: tapping any inline citation/source control expands sources directly below the message.
p = root / "SwiftChat/Views/MessageView.swift"
s = p.read_text(encoding="utf-8")
s = s.replace("@State private var showSourcesSheet = false", "@State private var showSourcesSheet = false\n    @State private var showInlineSources = false")
s = s.replace("onTap: { showSourcesSheet = true }", "onTap: { withAnimation { showInlineSources.toggle() } }")
s = s.replace("showSourcesSheet = true", "withAnimation { showInlineSources.toggle() }")

anchor = """                // Show error box with regenerate button if stream failed
                if message.streamError != nil && message.role == .assistant {"""
inline = """                if message.role == .assistant,
                   showInlineSources,
                   let sources = message.webSearchState?.sources,
                   !sources.isEmpty {
                    InlineSourcesView(sources: sources, isDarkMode: isDarkMode)
                        .padding(.top, 8)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }

                // Show error box with regenerate button if stream failed
                if message.streamError != nil && message.role == .assistant {"""
if anchor not in s:
    raise SystemExit("inline sources anchor not found")
s = s.replace(anchor, inline, 1)

handler_start = s.find('            if url.scheme == "cite" {')
handler_end = s.find('            return .systemAction', handler_start)
if handler_start < 0 or handler_end < 0:
    raise SystemExit("citation handler not found")
s = s[:handler_start] + """            if url.scheme == "cite" {
                withAnimation { showInlineSources.toggle() }
                return .handled
            }
""" + s[handler_end:]

sheet = """        .sheet(isPresented: $showSourcesSheet) {
            if let sources = message.webSearchState?.sources {
                SourcesSheetView(sources: sources, isDarkMode: isDarkMode)
                    .presentationDetents([.medium, .large])
            }
        }
"""
s = s.replace(sheet, "")

source_anchor = "/// Sheet view showing all sources\nprivate struct SourcesSheetView: View {"
inline_type = """private struct InlineSourcesView: View {
    let sources: [WebSearchSource]
    let isDarkMode: Bool

    private func domain(_ value: String) -> String {
        guard let url = URL(string: value), let host = url.host else { return value }
        return host.hasPrefix("www.") ? String(host.dropFirst(4)) : host
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Sources").font(.system(size: 13, weight: .semibold))
                Text("\\(sources.count)").font(.caption).foregroundStyle(.secondary)
                Spacer()
            }
            ForEach(sources) { source in
                Button {
                    if let url = URL(string: source.url) { UIApplication.shared.open(url) }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "globe").frame(width: 22).foregroundStyle(.secondary)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(source.title).font(.system(size: 13, weight: .medium)).lineLimit(2)
                            Text(domain(source.url)).font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "arrow.up.right").font(.caption).foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 14).fill(isDarkMode ? Color.white.opacity(0.06) : Color.black.opacity(0.045)))
    }
}

/// Sheet view showing all sources
private struct SourcesSheetView: View {"""
if source_anchor not in s:
    raise SystemExit("source type anchor not found")
s = s.replace(source_anchor, inline_type, 1)
p.write_text(s, encoding="utf-8")

# Keep inline citation markdown links visible after generation instead of stripping them.
p = root / "SwiftChat/Views/LaTeXMarkdownView.swift"
s = p.read_text(encoding="utf-8")
s = s.replace("let strippedText = isStreaming ? text : LaTeXMarkdownView.stripCitations(from: text)", "let strippedText = text")
s = s.replace("let strippedText = LaTeXMarkdownView.stripCitations(from: content)", "let strippedText = content")
p.write_text(s, encoding="utf-8")

print("Applied SwiftChat inline sources and anchored composer popover")
