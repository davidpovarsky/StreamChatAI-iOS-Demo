// Showcase/Sources/ShowcaseRootView.swift
import SwiftUI
import AgentUI
import AgentUIShowcaseSupport

struct ShowcaseRootView: View {
    @State private var session: AgentUISession
    @State private var selectedScenarioID: String?
    @State private var isRTL: Bool
    @State private var mockRuntime = MockAgentRuntime()
    @State private var toolRegistry: AgentToolSurfaceRegistry
    @State private var embeddedRegistry: AgentEmbeddedSurfaceRegistry
    @State private var hostActions = ShowcaseHostActions()
    @State private var mediaCoordinator = AgentMediaNavigationCoordinator()
    @Namespace private var zoomNamespace

    init() {
        let tools = AgentToolSurfaceRegistry()
        let embedded = AgentEmbeddedSurfaceRegistry()
        MockToolSurfaces.registerAll(in: tools)
        MockEmbeddedSessions.registerAll(in: embedded)
        _toolRegistry = State(initialValue: tools)
        _embeddedRegistry = State(initialValue: embedded)

        var scenarioID = "chat.plain"
        let args = ProcessInfo.processInfo.arguments
        if let idx = args.firstIndex(of: "--agentui-scenario"), idx + 1 < args.count {
            scenarioID = args[idx + 1]
        } else if let envID = ProcessInfo.processInfo.environment["AGENTUI_SCENARIO"] {
            scenarioID = envID
        }

        let selectedScenario = ShowcaseCatalog.allScenarios.first(where: { $0.id == scenarioID }) ?? ShowcaseCatalog.allScenarios.first!
        _selectedScenarioID = State(initialValue: selectedScenario.id)
        _isRTL = State(initialValue: selectedScenario.id == "chat.hebrew")

        let initialSession = AgentUISession(
            runtime: MockAgentRuntime(),
            models: [
                AgentModelDescriptor(id: "gpt-4o", displayName: "GPT-4o", iconSystemName: "sparkles"),
                AgentModelDescriptor(id: "claude-3-5", displayName: "Claude 3.5 Sonnet", iconSystemName: "bolt"),
                AgentModelDescriptor(id: "gemini-pro", displayName: "Gemini 1.5 Pro", iconSystemName: "cpu")
            ],
            messages: selectedScenario.initialMessages
        )
        initialSession.activitySessions = selectedScenario.initialActivities
        _session = State(initialValue: initialSession)
    }

    var body: some View {
        NavigationSplitView {
            ScenarioSidebarView(selectedScenarioID: $selectedScenarioID) { scenario in
                loadScenario(scenario)
            }
        } detail: {
            NavigationStack {
                AgentChatView(
                    session: session,
                    configuration: .init(title: currentScenarioTitle, showHeader: true),
                    surfaces: toolRegistry,
                    embeddedSurfaces: embeddedRegistry,
                    hostActions: hostActions
                )
                .environment(\.agentMediaCoordinator, mediaCoordinator)
                .environment(\.agentImageZoomNamespace, zoomNamespace)
                .navigationDestination(isPresented: Binding(
                    get: { mediaCoordinator.activeZoomImageID != nil },
                    set: { if !$0 { mediaCoordinator.dismiss() } }
                )) {
                    if let imageID = mediaCoordinator.activeZoomImageID {
                        AgentImageViewer(
                            imageURL: mediaCoordinator.activeImageURL,
                            altText: mediaCoordinator.activeAltText,
                            onClose: { mediaCoordinator.dismiss() }
                        )
                        #if os(iOS)
                        .navigationTransition(.zoom(sourceID: imageID, in: zoomNamespace))
                        #endif
                    }
                }
                .environment(\.layoutDirection, isRTL ? .rightToLeft : .leftToRight)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            isRTL.toggle()
                        } label: {
                            Image(systemName: isRTL ? "character.ar" : "globe")
                        }
                        .accessibilityLabel(isRTL ? "Switch to LTR" : "Switch to RTL")
                    }

                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            if let current = ShowcaseCatalog.allScenarios.first(where: { $0.id == selectedScenarioID }) {
                                loadScenario(current)
                            }
                        } label: {
                            Image(systemName: "arrow.counterclockwise")
                        }
                        .accessibilityLabel("Reset scenario")
                    }
                }
            }
        }
    }

    private var currentScenarioTitle: String {
        ShowcaseCatalog.allScenarios.first(where: { $0.id == selectedScenarioID })?.title ?? "AgentUI Showcase"
    }

    private func loadScenario(_ scenario: ShowcaseScenario) {
        session.messages = scenario.initialMessages
        session.activitySessions = scenario.initialActivities
        session.currentDraft.clear()
        session.runtime = mockRuntime
        if scenario.id == "chat.hebrew" {
            isRTL = true
        } else {
            isRTL = false
        }
    }
}
