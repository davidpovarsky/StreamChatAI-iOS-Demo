#if canImport(SwiftUI)
import AgentChatCore
import SwiftUI

public protocol AnyAgentToolRenderer: Sendable {
    var supportedToolIDs: Set<String> { get }
    @MainActor func render(call: AgentToolCall, result: AgentToolResult?) -> AnyView
}

public final class AgentToolRendererRegistry: @unchecked Sendable {
    public static let shared = AgentToolRendererRegistry()

    private var renderers: [String: AnyAgentToolRenderer] = [:]
    private let lock = NSLock()

    public init() {
        registerDefaultRenderers()
    }

    public func register(_ renderer: AnyAgentToolRenderer) {
        lock.lock()
        defer { lock.unlock() }
        for toolID in renderer.supportedToolIDs {
            renderers[toolID] = renderer
        }
    }

    public func renderer(for toolName: String) -> AnyAgentToolRenderer? {
        lock.lock()
        defer { lock.unlock() }
        return renderers[toolName]
    }

    private func registerDefaultRenderers() {
        register(WeatherToolRenderer())
        register(StockToolRenderer())
        register(CalculatorToolRenderer())
    }
}

public struct WeatherToolRenderer: AnyAgentToolRenderer {
    public var supportedToolIDs: Set<String> { ["weather_lookup", "get_weather", "current_weather"] }

    public init() {}

    @MainActor
    public func render(call: AgentToolCall, result: AgentToolResult?) -> AnyView {
        AnyView(WeatherCardView(call: call, result: result))
    }
}

public struct StockToolRenderer: AnyAgentToolRenderer {
    public var supportedToolIDs: Set<String> { ["stock_quote", "financial_data", "market_ticker"] }

    public init() {}

    @MainActor
    public func render(call: AgentToolCall, result: AgentToolResult?) -> AnyView {
        AnyView(StockCardView(call: call, result: result))
    }
}

public struct CalculatorToolRenderer: AnyAgentToolRenderer {
    public var supportedToolIDs: Set<String> { ["calculator", "math_eval", "compute"] }

    public init() {}

    @MainActor
    public func render(call: AgentToolCall, result: AgentToolResult?) -> AnyView {
        AnyView(CalculatorCardView(call: call, result: result))
    }
}

public struct WeatherCardView: View {
    public let call: AgentToolCall
    public let result: AgentToolResult?

    public init(call: AgentToolCall, result: AgentToolResult?) {
        self.call = call
        self.result = result
    }

    public var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "sun.max.fill")
                .font(.system(size: 24))
                .foregroundStyle(.yellow)

            VStack(alignment: .leading, spacing: 2) {
                Text(result?.outputSummary ?? "Fetching weather...")
                    .font(.system(size: 14, weight: .semibold))
                Text(locationText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if result == nil {
                ProgressView().controlSize(.small)
            }
        }
        .padding(10)
        .background(Color.blue.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
    }

    private var locationText: String {
        if call.arguments.contains("Tel Aviv") {
            return "Tel Aviv, Israel"
        } else if call.arguments.contains("location") {
            return "Requested Location"
        }
        return "Local Forecast"
    }
}

public struct StockCardView: View {
    public let call: AgentToolCall
    public let result: AgentToolResult?

    public init(call: AgentToolCall, result: AgentToolResult?) {
        self.call = call
        self.result = result
    }

    public var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 22))
                .foregroundStyle(.green)

            VStack(alignment: .leading, spacing: 2) {
                Text(result?.outputSummary ?? "Fetching quote...")
                    .font(.system(size: 14, weight: .semibold))
                Text(call.name)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if result == nil {
                ProgressView().controlSize(.small)
            }
        }
        .padding(10)
        .background(Color.green.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
    }
}

public struct CalculatorCardView: View {
    public let call: AgentToolCall
    public let result: AgentToolResult?

    public init(call: AgentToolCall, result: AgentToolResult?) {
        self.call = call
        self.result = result
    }

    public var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "equal.circle.fill")
                .font(.system(size: 22))
                .foregroundStyle(.purple)

            VStack(alignment: .leading, spacing: 2) {
                Text(result?.outputSummary ?? "Computing expression...")
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                Text(call.arguments)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if result == nil {
                ProgressView().controlSize(.small)
            }
        }
        .padding(10)
        .background(Color.purple.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
    }
}
#endif
