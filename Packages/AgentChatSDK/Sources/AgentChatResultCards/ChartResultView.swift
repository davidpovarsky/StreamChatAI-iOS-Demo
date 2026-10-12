import SwiftUI
#if canImport(Charts)
import Charts
#endif
import AgentChatCore

public struct ChartDataPoint: Identifiable, Sendable {
    public let id = UUID()
    public let category: String
    public let value: Double

    public init(category: String, value: Double) {
        self.category = category
        self.value = value
    }
}

public struct ChartResultView: View {
    public let result: AgentResult
    public let onAction: (AgentChatUserAction) -> Void

    @State private var chartType: Int = 0 // 0: Bar, 1: Line, 2: Area
    @State private var selectedCategory: String? = nil

    public init(result: AgentResult, onAction: @escaping (AgentChatUserAction) -> Void) {
        self.result = result
        self.onAction = onAction
    }

    private var sampleData: [ChartDataPoint] {
        if let raw = result.payload.metadata["points"]?.stringValue {
            // Parse point pairs "A:10,B:20"
            let pairs = raw.components(separatedBy: ",")
            return pairs.compactMap { pair in
                let parts = pair.components(separatedBy: ":")
                guard parts.count == 2, let v = Double(parts[1]) else { return nil }
                return ChartDataPoint(category: parts[0], value: v)
            }
        }
        return [
            ChartDataPoint(category: "Jan", value: 34),
            ChartDataPoint(category: "Feb", value: 52),
            ChartDataPoint(category: "Mar", value: 41),
            ChartDataPoint(category: "Apr", value: 68),
            ChartDataPoint(category: "May", value: 85),
            ChartDataPoint(category: "Jun", value: 94)
        ]
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(result.title ?? "Data Visualization")
                        .font(.system(size: 15, weight: .semibold))
                    if let sub = result.payload.subtitle {
                        Text(sub)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()

                Picker("Chart Type", selection: $chartType) {
                    Text("Bar").tag(0)
                    Text("Line").tag(1)
                    Text("Area").tag(2)
                }
                .pickerStyle(.segmented)
                .frame(width: 160)
            }

            #if canImport(Charts)
            Group {
                if chartType == 0 {
                    Chart(sampleData) { item in
                        BarMark(
                            x: .value("Category", item.category),
                            y: .value("Value", item.value)
                        )
                        .foregroundStyle(selectedCategory == item.category ? Color.blue : Color.blue.opacity(0.7))
                        .cornerRadius(4)
                    }
                } else if chartType == 1 {
                    Chart(sampleData) { item in
                        LineMark(
                            x: .value("Category", item.category),
                            y: .value("Value", item.value)
                        )
                        .foregroundStyle(Color.blue)
                        PointMark(
                            x: .value("Category", item.category),
                            y: .value("Value", item.value)
                        )
                        .foregroundStyle(Color.blue)
                    }
                } else {
                    Chart(sampleData) { item in
                        AreaMark(
                            x: .value("Category", item.category),
                            y: .value("Value", item.value)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.4), Color.blue.opacity(0.05)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        LineMark(
                            x: .value("Category", item.category),
                            y: .value("Value", item.value)
                        )
                        .foregroundStyle(Color.blue)
                    }
                }
            }
            .frame(height: 180)
            .chartXAxis {
                AxisMarks(values: .automatic)
            }
            .chartYAxis {
                AxisMarks(values: .automatic)
            }
            #else
            Text("Charts framework not available on this platform")
                .foregroundColor(.secondary)
            #endif

            HStack {
                Text("Total: \(Int(sampleData.reduce(0) { $0 + $1.value })) units")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)

                Spacer()

                Button {
                    let action = AgentChatUserAction(
                        kind: .select(option: "chart-exported"),
                        context: AgentResultActionContext(
                            conversationId: "demo",
                            messageId: result.messageId,
                            resultId: result.id
                        )
                    )
                    onAction(action)
                } label: {
                    Label("Export Data", systemImage: "square.and.arrow.up")
                        .font(.system(size: 11))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.secondary.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.secondary.opacity(0.15), lineWidth: 1)
        )
    }
}
