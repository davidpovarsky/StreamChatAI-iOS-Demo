#if canImport(SwiftUI)
import AgentChatCore
import SwiftUI
#if canImport(SVGView)
import SVGView
#endif

public struct AgentSVGView: View {
    public let content: AgentSVGContent
    @State private var isExpanded = false

    public init(content: AgentSVGContent) {
        self.content = content
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            svgBody
                .frame(maxWidth: content.width != nil ? CGFloat(content.width!) : 320)
                .frame(maxHeight: content.height != nil ? CGFloat(content.height!) : 240)
                .padding(8)
                .background(Color.secondary.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
                .onTapGesture {
                    isExpanded = true
                }

            if let title = content.title, !title.isEmpty {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .sheet(isPresented: $isExpanded) {
            NavigationStack {
                VStack {
                    Spacer()
                    svgBody
                        .padding()
                    Spacer()
                }
                .navigationTitle(content.title ?? "Vector Graphic")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Done") { isExpanded = false }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var svgBody: some View {
        #if canImport(SVGView)
        if let raw = content.rawSVG, !raw.isEmpty {
            SVGView(string: raw)
        } else if let name = content.bundleName,
                  let url = Bundle.main.url(forResource: name, withExtension: "svg") {
            SVGView(contentsOf: url)
        } else {
            fallbackView
        }
        #else
        fallbackView
        #endif
    }

    private var fallbackView: some View {
        HStack(spacing: 8) {
            Image(systemName: "square.slash")
                .font(.system(size: 20))
                .foregroundStyle(.secondary)
            Text(content.title ?? "Vector Graphic (SVG)")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .padding(16)
    }
}
#endif
