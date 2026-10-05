// Sources/AgentUIShowcaseSupport/MockSurfaces/MockMiniAppView.swift
#if canImport(SwiftUI)
import SwiftUI

public struct MockMiniAppFormView: View {
    @State private var textInput: String = ""
    @State private var sliderValue: Double = 50.0
    @State private var toggleValue: Bool = true
    @State private var counter: Int = 0

    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 14))
                Text("Interactive Swift Mini App")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text("Tap count: \(counter)")
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
            }

            TextField("Interactive input...", text: $textInput)
                .textFieldStyle(.roundedBorder)

            HStack {
                Text("Value: \(Int(sliderValue))")
                    .font(.caption)
                Slider(value: $sliderValue, in: 0...100)
            }

            HStack {
                Toggle("Auto-sync", isOn: $toggleValue)
                    .font(.caption)

                Spacer()

                Button("Increment") {
                    counter += 1
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
        }
        .padding(12)
        .background(Color.secondary.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

public struct MockSefariaSourceCardView: View {
    public let ref: String
    public let hebrew: String
    public let english: String

    public init(
        ref: String = "Genesis 1:1",
        hebrew: String = "בְּרֵאשִׁית בָּרָא אֱלֹהִים אֵת הַשָּׁמַיִם וְאֵת הָאָרֶץ׃",
        english: String = "In the beginning God created the heaven and the earth."
    ) {
        self.ref = ref
        self.hebrew = hebrew
        self.english = english
    }

    public var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            HStack {
                Text(ref)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                Spacer()
                Image(systemName: "book.closed.fill")
                    .font(.caption)
                    .foregroundStyle(.indigo)
            }

            Text(hebrew)
                .font(.body.weight(.medium))
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)

            Divider().opacity(0.3)

            Text(english)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .background(Color.indigo.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
#endif
