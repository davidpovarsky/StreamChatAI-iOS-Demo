import SwiftUI
import AgentChatSDK

public struct ComponentGalleryView: View {
    @State private var colorScheme: ColorScheme = .light
    @State private var layoutDirection: LayoutDirection = .leftToRight
    @State private var selectedTab: Int = 0

    public init() {}

    private let s1 = WebSearchSource(title: "Apple HIG", url: "https://developer.apple.com")
    private let s2 = WebSearchSource(title: "Swift.org", url: "https://swift.org")

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Controls Bar
                HStack {
                    Picker("Category", selection: $selectedTab) {
                        Text("Activity").tag(0)
                        Text("Cards").tag(1)
                        Text("Input").tag(2)
                    }
                    .pickerStyle(.segmented)

                    Spacer()

                    Button {
                        colorScheme = colorScheme == .light ? .dark : .light
                    } label: {
                        Image(systemName: colorScheme == .light ? "moon.fill" : "sun.max.fill")
                    }

                    Button {
                        layoutDirection = layoutDirection == .leftToRight ? .rightToLeft : .leftToRight
                    } label: {
                        Image(systemName: "character.ar")
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.secondary.opacity(0.08))

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        if selectedTab == 0 {
                            activitySection
                        } else if selectedTab == 1 {
                            cardsSection
                        } else {
                            inputSection
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Component Gallery")
            .navigationBarTitleDisplayMode(.inline)
            .environment(\.colorScheme, colorScheme)
            .environment(\.layoutDirection, layoutDirection)
        }
    }

    // MARK: - Activity Section

    private var activitySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("1. Run Disclosure (Collapsed by Default)")
                .font(.headline)

            let runRunning = AgentRun(id: "r1", messageId: "m1", status: .running, startedAt: Date(timeIntervalSinceNow: -42))
            AgentRunDisclosureHeader(run: runRunning, isExpanded: false) {}
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.secondary.opacity(0.06)))

            let runCompleted = AgentRun(id: "r2", messageId: "m2", status: .completed, startedAt: Date(timeIntervalSinceNow: -171), completedAt: Date())
            AgentRunDisclosureHeader(run: runCompleted, isExpanded: false) {}
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.secondary.opacity(0.06)))

            Text("2. Expanded Activity Tree")
                .font(.headline)
                .padding(.top, 8)

            let group = ActivityGroup(id: "g1", stage: .research, title: "Research Phase", operations: [
                ActivityOperation(id: "op1", toolName: "web_search", title: "Searched 8 websites", status: .completed, sources: [s1, s2]),
                ActivityOperation(id: "op2", toolName: "github_api", title: "Scanning commits", status: .running)
            ], isExpanded: true)
            let expandedRun = AgentRun(
                id: "r2",
                messageId: "m2",
                status: .completed,
                startedAt: Date(timeIntervalSinceNow: -171),
                completedAt: Date(),
                groups: [group],
                isExpanded: true
            )
            AgentHierarchicalActivityView(
                run: expandedRun,
                onToggleRun: {},
                onToggleGroup: { _ in },
                onToggleOperation: { _ in },
                onSelectInspector: { _ in }
            )
            .padding(10)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.secondary.opacity(0.06)))

            Text("3. Action-Required Approval Card")
                .font(.headline)
                .padding(.top, 8)

            let approval = ApprovalRequest(runId: "r1", title: "Create Calendar Event", descriptionText: "Add Design Review on Tuesday at 10:30 AM", provider: "EventKit")
            AgentApprovalRequestCard(approval: approval) { _ in }
        }
    }

    // MARK: - Cards Section

    private var cardsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("1. Swift Charts Result")
                .font(.headline)
            ChartResultView(
                result: AgentResult(messageId: "m1", kind: .chart, title: "Monthly Throughput", payload: AgentResultPayload()),
                onAction: { _ in }
            )

            Text("2. MapKit Route Result")
                .font(.headline)
                .padding(.top, 8)
            MapResultView(
                result: AgentResult(messageId: "m2", kind: .map, title: "Campus Route", payload: AgentResultPayload()),
                onAction: { _ in }
            )

            Text("3. Interactive Form Result")
                .font(.headline)
                .padding(.top, 8)
            FormResultView(
                result: AgentResult(messageId: "m3", kind: .form, title: "Pricing Calculator", payload: AgentResultPayload()),
                onAction: { _ in }
            )

            Text("4. Canvas Document Diff")
                .font(.headline)
                .padding(.top, 8)
            CanvasDocumentResultView(
                result: AgentResult(messageId: "m4", kind: .canvasDocument, title: "Document Review", payload: AgentResultPayload()),
                onAction: { _ in }
            )

            Text("5. Declarative MiniApp")
                .font(.headline)
                .padding(.top, 8)
            NativeMiniAppResultView(
                result: AgentResult(messageId: "m5", kind: .miniApp, title: "System Health", payload: AgentResultPayload()),
                onAction: { _ in }
            )
        }
    }

    // MARK: - Input Section

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("1. Native Composer (Standard)")
                .font(.headline)
            AgentComposerView(
                text: .constant("What is the memory footprint on iOS 27?"),
                attachments: .constant([]),
                isStreaming: false,
                selectedModel: .constant(.gpt4o),
                onSend: { _, _, _ in },
                onStop: {}
            )

            Text("2. Native Composer (Streaming State with Stop Button)")
                .font(.headline)
                .padding(.top, 8)
            AgentComposerView(
                text: .constant("Streaming active response..."),
                attachments: .constant([]),
                isStreaming: true,
                selectedModel: .constant(.gpt4o),
                onSend: { _, _, _ in },
                onStop: {}
            )

            Text("3. Source Chips Strip")
                .font(.headline)
                .padding(.top, 8)
            AgentSourceChipsView(sources: [s1, s2])
        }
    }
}
