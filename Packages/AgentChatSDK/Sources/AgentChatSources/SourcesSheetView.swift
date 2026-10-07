#if canImport(SwiftUI)
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif
import AgentChatCore

public struct SourcesSheetView: View {
    public let sources: [WebSearchSource]
    public let isDarkMode: Bool
    @Environment(\.dismiss) private var dismiss

    public init(sources: [WebSearchSource], isDarkMode: Bool) {
        self.sources = sources
        self.isDarkMode = isDarkMode
    }

    private func getDomain(from urlString: String) -> String {
        guard let url = URL(string: urlString),
              let host = url.host else {
            return urlString
        }
        return host.hasPrefix("www.") ? String(host.dropFirst(4)) : host
    }

    private func faviconUrl(for domain: String) -> String {
        "https://icons.duckduckgo.com/ip3/\(domain).ico"
    }

    public var body: some View {
        NavigationStack {
            List {
                ForEach(sources) { source in
                    Button {
#if canImport(UIKit)
                        if let url = URL(string: source.url) {
                            UIApplication.shared.open(url)
                        }
#endif
                    } label: {
                        HStack(spacing: 12) {
                            AsyncImage(url: URL(string: faviconUrl(for: getDomain(from: source.url)))) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                case .failure, .empty:
                                    Image(systemName: "globe")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .foregroundColor(.gray)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .frame(width: 24, height: 24)
                            .clipShape(RoundedRectangle(cornerRadius: 4))

                            VStack(alignment: .leading, spacing: 2) {
                                Text(source.title)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(isDarkMode ? .white : .black)
                                    .lineLimit(2)

                                Text(getDomain(from: source.url))
                                    .font(.system(size: 13))
                                    .foregroundColor(.gray)
                            }

                            Spacer()

                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationTitle("Sources (\(sources.count))")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
#endif
