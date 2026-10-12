import SwiftUI
import AgentChatCore
import AgentChatSources
import AgentChatMotion

// MARK: - Format Elapsed Time Helper

public func formatAgentElapsed(seconds: TimeInterval) -> String {
    let total = max(0, Int(seconds.rounded()))
    let minutes = total / 60
    let remSeconds = total % 60
    if minutes > 0 {
        return "\(minutes)m \(remSeconds)s"
    } else {
        return "\(remSeconds)s"
    }
}

// MARK: - Root Run Disclosure Header

public struct AgentRunDisclosureHeader: View {
    public let run: AgentRun
    public let isExpanded: Bool
    public let onToggle: () -> Void

    public init(run: AgentRun, isExpanded: Bool, onToggle: @escaping () -> Void) {
        self.run = run
        self.isExpanded = isExpanded
        self.onToggle = onToggle
    }

    private var isCompleted: Bool {
        run.status == .completed || run.status == .failed || run.status == .cancelled
    }

    public var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 6) {
                if isCompleted {
                    Image(systemName: run.status == .failed ? "exclamationmark.circle.fill" : "clock")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(run.status == .failed ? .red : .secondary)
                } else {
                    ProgressView()
                        .scaleEffect(0.65)
                        .frame(width: 14, height: 14)
                }

                Text(headerTitle)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)

                Image(systemName: "chevron.right")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(.secondary.opacity(0.7))
                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
                    .animation(AgentMotionTokens.standardSpring, value: isExpanded)

                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(headerTitle), \(isExpanded ? "expanded" : "collapsed")")
    }

    private var headerTitle: String {
        let elapsed = formatAgentElapsed(seconds: run.elapsedSeconds)
        switch run.status {
        case .running:
            return "Working for \(elapsed)"
        case .completed:
            return "Worked for \(elapsed)"
        case .failed:
            return "Failed after \(elapsed)"
        case .cancelled:
            return "Cancelled after \(elapsed)"
        }
    }
}

// MARK: - Level 1 Group Row

public struct AgentActivityGroupRow: View {
    public let group: ActivityGroup
    public let onToggle: () -> Void
    public let onToggleOperation: (OperationID) -> Void
    public let onSelectInspector: (ActivityOperation) -> Void

    public init(
        group: ActivityGroup,
        onToggle: @escaping () -> Void,
        onToggleOperation: @escaping (OperationID) -> Void,
        onSelectInspector: @escaping (ActivityOperation) -> Void
    ) {
        self.group = group
        self.onToggle = onToggle
        self.onToggleOperation = onToggleOperation
        self.onSelectInspector = onSelectInspector
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Button(action: onToggle) {
                HStack(spacing: 8) {
                    Image(systemName: group.stage.iconSystemName)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.primary)
                        .frame(width: 16)

                    Text(group.title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.primary)

                    if !group.operations.isEmpty {
                        Text("(\(group.operations.count))")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    if group.isRunning {
                        ProgressView()
                            .scaleEffect(0.55)
                            .frame(width: 12, height: 12)
                    }

                    Image(systemName: "chevron.right")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.secondary.opacity(0.6))
                        .rotationEffect(.degrees(group.isExpanded ? 90 : 0))
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if group.isExpanded {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(group.operations) { op in
                        AgentActivityOperationRow(
                            operation: op,
                            onToggle: { onToggleOperation(op.id) },
                            onSelectInspector: { onSelectInspector(op) }
                        )
                    }
                }
                .padding(.leading, 18)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

// MARK: - Level 2 Operation Row

public struct AgentActivityOperationRow: View {
    public let operation: ActivityOperation
    public let onToggle: () -> Void
    public let onSelectInspector: () -> Void

    public init(
        operation: ActivityOperation,
        onToggle: @escaping () -> Void,
        onSelectInspector: @escaping () -> Void
    ) {
        self.operation = operation
        self.onToggle = onToggle
        self.onSelectInspector = onSelectInspector
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                statusIcon

                Text(operation.title)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                Spacer()

                if let dur = operation.duration {
                    Text(formatAgentElapsed(seconds: dur))
                        .font(.system(size: 10))
                        .foregroundColor(.secondary.opacity(0.7))
                }

                Button(action: onSelectInspector) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Inspect \(operation.title)")
            }

            if !operation.sources.isEmpty {
                AgentSourceChipsView(sources: operation.sources)
                    .padding(.top, 2)
            }
        }
        .padding(.vertical, 2)
    }

    @ViewBuilder
    private var statusIcon: some View {
        switch operation.status {
        case .pending:
            Circle()
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 6, height: 6)
        case .running:
            ProgressView()
                .scaleEffect(0.5)
                .frame(width: 12, height: 12)
        case .completed:
            Image(systemName: "checkmark")
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(.green)
        case .failed:
            Image(systemName: "xmark")
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(.red)
        case .cancelled:
            Image(systemName: "minus")
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Complete Hierarchical Activity Tree View

public struct AgentHierarchicalActivityView: View {
    public let run: AgentRun
    public let onToggleRun: () -> Void
    public let onToggleGroup: (ActivityGroupID) -> Void
    public let onToggleOperation: (OperationID) -> Void
    public let onSelectInspector: (ActivityOperation) -> Void

    public init(
        run: AgentRun,
        onToggleRun: @escaping () -> Void,
        onToggleGroup: @escaping (ActivityGroupID) -> Void,
        onToggleOperation: @escaping (OperationID) -> Void,
        onSelectInspector: @escaping (ActivityOperation) -> Void
    ) {
        self.run = run
        self.onToggleRun = onToggleRun
        self.onToggleGroup = onToggleGroup
        self.onToggleOperation = onToggleOperation
        self.onSelectInspector = onSelectInspector
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AgentRunDisclosureHeader(
                run: run,
                isExpanded: run.isExpanded,
                onToggle: onToggleRun
            )

            if run.isExpanded {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(run.groups) { group in
                        AgentActivityGroupRow(
                            group: group,
                            onToggle: { onToggleGroup(group.id) },
                            onToggleOperation: onToggleOperation,
                            onSelectInspector: onSelectInspector
                        )
                    }
                }
                .padding(.leading, 12)
                .padding(.vertical, 4)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
