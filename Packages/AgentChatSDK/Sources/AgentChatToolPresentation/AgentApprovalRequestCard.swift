import SwiftUI
import AgentChatCore
import AgentChatMotion

public struct AgentApprovalRequestCard: View {
    public let approval: ApprovalRequest
    public let onAction: (AgentChatUserAction) -> Void
    @State private var showingDetails = false

    public init(approval: ApprovalRequest, onAction: @escaping (AgentChatUserAction) -> Void) {
        self.approval = approval
        self.onAction = onAction
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "shield.lefthalf.filled")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.orange)

                Text("Permission Required")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)

                Spacer()

                Text("Demo")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule().fill(Color.secondary.opacity(0.12))
                    )
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(approval.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)

                Text(approval.descriptionText)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)

                Text("Provider: \(approval.provider)")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary.opacity(0.8))
                    .padding(.top, 2)
            }

            if approval.status == .requested {
                HStack(spacing: 10) {
                    Button {
                        let action = AgentChatUserAction(
                            kind: .approve(requestId: approval.id),
                            context: AgentResultActionContext(
                                conversationId: "demo",
                                messageId: "approval",
                                runId: approval.runId
                            )
                        )
                        onAction(action)
                    } label: {
                        Text("Approve")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 7)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.blue)
                            )
                    }
                    .buttonStyle(.plain)

                    Button {
                        let action = AgentChatUserAction(
                            kind: .deny(requestId: approval.id),
                            context: AgentResultActionContext(
                                conversationId: "demo",
                                messageId: "approval",
                                runId: approval.runId
                            )
                        )
                        onAction(action)
                    } label: {
                        Text("Deny")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.secondary.opacity(0.12))
                            )
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Button {
                        showingDetails = true
                    } label: {
                        Text("Details")
                            .font(.system(size: 12))
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(.plain)
                }
            } else {
                HStack(spacing: 6) {
                    Image(systemName: approval.status == .approved ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(approval.status == .approved ? .green : .red)
                    Text(approval.status == .approved ? "Approved (simulated — no real external write performed)" : "Permission Denied")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(.top, 2)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.secondary.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
        .agentCardEntrance()
        .sheet(isPresented: $showingDetails) {
            NavigationStack {
                List {
                    Section("Request") {
                        LabeledContent("Title", value: approval.title)
                        LabeledContent("Provider", value: approval.provider)
                        LabeledContent("Run ID", value: approval.runId)
                        LabeledContent("Status", value: approval.status.rawValue)
                    }
                    Section("Description") {
                        Text(approval.descriptionText)
                    }
                }
                .navigationTitle("Approval Details")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { showingDetails = false }
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }
}
