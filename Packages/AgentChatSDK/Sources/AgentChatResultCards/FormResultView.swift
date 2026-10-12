import SwiftUI
import AgentChatCore

public struct FormResultView: View {
    public let result: AgentResult
    public let onAction: (AgentChatUserAction) -> Void

    @State private var planIndex: Int = 1
    @State private var teamMembers: Double = 5
    @State private var includeSupport: Bool = true
    @State private var selectedDate = Date()
    @State private var isSubmitted = false

    private let plans = ["Basic", "Professional", "Enterprise"]

    public init(result: AgentResult, onAction: @escaping (AgentChatUserAction) -> Void) {
        self.result = result
        self.onAction = onAction
    }

    private var calculatedTotal: Double {
        let baseRate: Double = planIndex == 0 ? 19.0 : (planIndex == 1 ? 49.0 : 99.0)
        let supportAddon: Double = includeSupport ? 25.0 : 0.0
        return (baseRate * teamMembers) + supportAddon
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "slider.horizontal.3")
                    .foregroundColor(.blue)
                Text(result.title ?? "Interactive Budget Calculator")
                    .font(.system(size: 15, weight: .semibold))
                Spacer()
                Text("Form UI")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(Color.secondary.opacity(0.12)))
            }

            VStack(alignment: .leading, spacing: 12) {
                // Plan Picker
                VStack(alignment: .leading, spacing: 4) {
                    Text("Selected Tier")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Picker("Tier", selection: $planIndex) {
                        ForEach(plans.indices, id: \.self) { idx in
                            Text(plans[idx]).tag(idx)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // Team Members Slider
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Team Seats")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(Int(teamMembers)) seats")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    Slider(value: $teamMembers, in: 1...50, step: 1)
                }

                // Support Toggle
                Toggle("Priority 24/7 Support", isOn: $includeSupport)
                    .font(.system(size: 13))

                Divider()

                // Dynamic Total
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Estimated Total")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(String(format: "$%.2f / month", calculatedTotal))
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.blue)
                    }

                    Spacer()

                    Button {
                        isSubmitted = true
                        let values: [String: AnySendable] = [
                            "plan": .string(plans[planIndex]),
                            "seats": .int(Int(teamMembers)),
                            "support": .bool(includeSupport),
                            "total": .double(calculatedTotal)
                        ]
                        let action = AgentChatUserAction(
                            kind: .submit(values: values),
                            context: AgentResultActionContext(
                                conversationId: "demo",
                                messageId: result.messageId,
                                resultId: result.id
                            )
                        )
                        onAction(action)
                    } label: {
                        HStack(spacing: 6) {
                            if isSubmitted {
                                Image(systemName: "checkmark")
                            }
                            Text(isSubmitted ? "Submitted" : "Submit Quote")
                        }
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(isSubmitted ? Color.green : Color.blue)
                        )
                    }
                    .buttonStyle(.plain)
                }
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
