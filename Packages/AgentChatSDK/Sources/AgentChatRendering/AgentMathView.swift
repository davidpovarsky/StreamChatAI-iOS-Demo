#if canImport(SwiftUI)
import AgentChatCore
import SwiftUI
#if canImport(iosMath)
import iosMath
#endif
#if canImport(UIKit)
import UIKit
#endif

public struct AgentMathView: View {
    public let formula: String
    public let displayMode: Bool
    public var fontSize: CGFloat

    @State private var isCopied = false
    @Environment(\.colorScheme) private var colorScheme

    public init(formula: String, displayMode: Bool = true, fontSize: CGFloat = 18) {
        self.formula = formula
        self.displayMode = displayMode
        self.fontSize = fontSize
    }

    public var body: some View {
        HStack {
            if displayMode {
                Spacer()
            }

            ZStack(alignment: .topTrailing) {
                #if canImport(iosMath) && canImport(UIKit)
                IOSMathUIView(
                    latex: formula,
                    displayMode: displayMode,
                    fontSize: fontSize,
                    textColor: colorScheme == .dark ? .white : .black
                )
                .frame(minHeight: displayMode ? 44 : 24)
                #else
                fallbackMathView
                #endif
            }
            .padding(displayMode ? 12 : 2)
            .background(displayMode ? Color.secondary.opacity(0.08) : Color.clear, in: RoundedRectangle(cornerRadius: 10))
            .contextMenu {
                Button {
                    copyLaTeX()
                } label: {
                    Label("Copy LaTeX", systemImage: "doc.on.doc")
                }
            }

            if displayMode {
                Spacer()
            }
        }
    }

    private var fallbackMathView: some View {
        Text(formula)
            .font(.system(size: fontSize, design: .serif).italic())
            .textSelection(.enabled)
    }

    private func copyLaTeX() {
        #if canImport(UIKit)
        UIPasteboard.general.string = formula
        #endif
        isCopied = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isCopied = false
        }
    }
}

#if canImport(iosMath) && canImport(UIKit)
private struct IOSMathUIView: UIViewRepresentable {
    let latex: String
    let displayMode: Bool
    let fontSize: CGFloat
    let textColor: UIColor

    func makeUIView(context: Context) -> MTMathUILabel {
        let label = MTMathUILabel()
        label.latex = latex
        label.labelMode = displayMode ? .display : .text
        label.fontSize = fontSize
        label.textColor = textColor
        label.textAlignment = displayMode ? .center : .left
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return label
    }

    func updateUIView(_ uiView: MTMathUILabel, context: Context) {
        uiView.latex = latex
        uiView.labelMode = displayMode ? .display : .text
        uiView.fontSize = fontSize
        uiView.textColor = textColor
        uiView.textAlignment = displayMode ? .center : .left
    }
}
#endif
#endif
