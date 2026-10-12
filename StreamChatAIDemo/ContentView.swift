import SwiftUI
import AgentChatSDK

struct ContentView: View {
    @StateObject private var session: AgentChatSession
    @StateObject private var demoDriver: DeterministicDemoDriver
    @State private var selectedTab = 0
    @State private var showingSettings = false

    init() {
        let newSession = AgentChatSession()
        _session = StateObject(wrappedValue: newSession)
        _demoDriver = StateObject(wrappedValue: DeterministicDemoDriver(session: newSession))
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: Chat Playground
            chatPlaygroundTab
                .tabItem {
                    Label("Playground", systemImage: "message.fill")
                }
                .tag(0)

            // Tab 2: Agent Scenarios
            scenariosCatalogTab
                .tabItem {
                    Label("Scenarios (26)", systemImage: "play.circle.fill")
                }
                .tag(1)

            // Tab 3: Component Gallery
            ComponentGalleryView()
                .tabItem {
                    Label("Gallery", systemImage: "square.grid.2x2.fill")
                }
                .tag(2)

            // Tab 4: Motion Lab
            MotionLabView()
                .tabItem {
                    Label("Motion Lab", systemImage: "sparkles")
                }
                .tag(3)
        }
    }

    // MARK: - Tab 1: Chat Playground

    private var chatPlaygroundTab: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Playback Controls Bar if running scenario
                if demoDriver.isRunning || demoDriver.isPaused {
                    HStack(spacing: 12) {
                        Image(systemName: "play.circle.fill")
                            .foregroundColor(.blue)
                        Text(demoDriver.currentScenarioId ?? "Running Scenario")
                            .font(.system(size: 12, weight: .semibold))
                            .lineLimit(1)

                        Spacer()

                        Button(action: {
                            if demoDriver.isPaused {
                                demoDriver.resume()
                            } else {
                                demoDriver.pause()
                            }
                        }) {
                            Image(systemName: demoDriver.isPaused ? "play.fill" : "pause.fill")
                                .font(.system(size: 14))
                        }

                        Button(action: { demoDriver.step() }) {
                            Image(systemName: "forward.frame.fill")
                                .font(.system(size: 14))
                        }

                        Button(action: { demoDriver.reset() }) {
                            Image(systemName: "stop.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                        }

                        Menu {
                            Button("0.5x", action: { demoDriver.playbackSpeed = 0.5 })
                            Button("1.0x", action: { demoDriver.playbackSpeed = 1.0 })
                            Button("2.0x", action: { demoDriver.playbackSpeed = 2.0 })
                            Button("4.0x", action: { demoDriver.playbackSpeed = 4.0 })
                        } label: {
                            Text("\(String(format: "%.1fx", demoDriver.playbackSpeed))")
                                .font(.system(size: 11, weight: .bold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(Color.secondary.opacity(0.15)))
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Color.secondary.opacity(0.08))
                }

                // Public Native SDK View
                AgentChatView(
                    session: session,
                    configuration: session.configuration
                )
            }
            .navigationTitle("AgentChat SDK")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Section("Popular Scenarios") {
                            Button {
                                demoDriver.runScenario(id: "02_web_research")
                            } label: {
                                Label("02. Web Research (8 Sources)", systemImage: "globe")
                            }

                            Button {
                                demoDriver.runScenario(id: "06_approval_accept")
                            } label: {
                                Label("06. Calendar Approval", systemImage: "calendar.badge.plus")
                            }

                            Button {
                                demoDriver.runScenario(id: "15_chart_interactions")
                            } label: {
                                Label("15. Swift Charts", systemImage: "chart.bar")
                            }

                            Button {
                                demoDriver.runScenario(id: "16_map_route")
                            } label: {
                                Label("16. MapKit Route", systemImage: "map")
                            }

                            Button {
                                demoDriver.runScenario(id: "17_native_form")
                            } label: {
                                Label("17. Interactive Form", systemImage: "slider.horizontal.3")
                            }
                        }

                        Divider()

                        Button(role: .destructive) {
                            session.clearMessages()
                        } label: {
                            Label("Clear Chat", systemImage: "trash")
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "play.circle.fill")
                            Text("Quick Run")
                                .font(.system(size: 13, weight: .medium))
                        }
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                    .accessibilityLabel("SDK Settings")
                }
            }
            .sheet(isPresented: $showingSettings) {
                SDKConfigurationSheet(configuration: $session.configuration)
            }
        }
    }

    // MARK: - Tab 2: All 26 Scenarios Catalog

    private var scenariosCatalogTab: some View {
        NavigationStack {
            List {
                Section("Deterministic Scenarios Catalog (26)") {
                    ForEach(demoDriver.allScenarios) { scenario in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(scenario.title)
                                    .font(.system(size: 15, weight: .semibold))
                                Spacer()
                                Button("Run") {
                                    demoDriver.runScenario(id: scenario.id)
                                    selectedTab = 0 // Switch to playground
                                }
                                .font(.system(size: 12, weight: .semibold))
                                .buttonStyle(.borderedProminent)
                            }

                            Text(scenario.summary)
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)

                            Text("Prompt: \"\(scenario.userPrompt)\"")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(.secondary.opacity(0.8))
                                .padding(4)
                                .background(RoundedRectangle(cornerRadius: 4).fill(Color.secondary.opacity(0.06)))
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Agent Scenarios")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SDKConfigurationSheet: View {
    @Binding var configuration: AgentChatConfiguration
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("SDK Capabilities") {
                    Toggle("Markdown Rendering", isOn: $configuration.capabilities.supportsMarkdown)
                    Toggle("Syntax Highlighting", isOn: $configuration.capabilities.supportsCodeHighlighting)
                    Toggle("LaTeX Math (SwiftMath)", isOn: $configuration.capabilities.supportsLaTeXMath)
                    Toggle("Remote Images (Kingfisher)", isOn: $configuration.capabilities.supportsRemoteImages)
                    Toggle("Vector SVG (SVGView)", isOn: $configuration.capabilities.supportsSVG)
                    Toggle("Source Citations", isOn: $configuration.capabilities.supportsCitations)
                    Toggle("Tool Disclosures", isOn: $configuration.capabilities.supportsToolExecution)
                    Toggle("Voice Mode", isOn: $configuration.capabilities.supportsVoice)
                    Toggle("Attachments", isOn: $configuration.capabilities.supportsAttachments)
                }

                Section("Appearance & Layout") {
                    LabeledContent("Adaptive Max Width", value: "\(Int(configuration.appearance.adaptiveMaxWidth)) pt")
                    LabeledContent("User Bubble Radius", value: "\(Int(configuration.appearance.userBubbleCornerRadius)) pt")
                    Toggle("Show Bottom Divider", isOn: $configuration.appearance.showDividers)
                }

                Section("Rendering Options") {
                    Toggle("Code Line Wrapping", isOn: $configuration.rendering.codeLineWrapping)
                    Toggle("Enable Animations", isOn: $configuration.rendering.enableAnimations)
                    Toggle("Respect Reduce Motion", isOn: $configuration.rendering.respectReduceMotion)
                }

                Section("About AgentChatSDK") {
                    LabeledContent("Version", value: AgentChatSDKInfo.version)
                    LabeledContent("Target OS", value: "iOS " + AgentChatSDKInfo.targetIOSVersion)
                    LabeledContent("Package", value: AgentChatSDKInfo.identifier)
                }
            }
            .navigationTitle("SDK Capabilities")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
