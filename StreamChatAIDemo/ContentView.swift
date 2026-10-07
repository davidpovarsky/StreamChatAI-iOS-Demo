import AgentChatSDK
import StreamChatAI
import SwiftUI

struct ContentView: View {
    @StateObject private var session: AgentChatSession
    @StateObject private var demoDriver: DeterministicDemoDriver
    @State private var showingSettings = false
    @State private var showingScenarios = false

    init() {
        let newSession = AgentChatSession()
        _session = StateObject(wrappedValue: newSession)
        _demoDriver = StateObject(wrappedValue: DeterministicDemoDriver(session: newSession))
    }

    var body: some View {
        NavigationStack {
            AgentChatView(
                session: session,
                configuration: session.configuration
            )
            .navigationTitle("AgentChat SDK")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button {
                            demoDriver.startWebResearchScenario()
                        } label: {
                            Label("Scenario A: Web Research", systemImage: "magnifyingglass")
                        }

                        Button {
                            demoDriver.startToolExecutionScenario()
                        } label: {
                            Label("Scenario B: Tool Execution", systemImage: "wrench.and.screwdriver")
                        }

                        Button {
                            demoDriver.startRichContentScenario()
                        } label: {
                            Label("Scenario C: Multimodal Rich Content", systemImage: "sparkles.rectangle.stack")
                        }

                        Button {
                            demoDriver.startVoiceScenario()
                        } label: {
                            Label("Scenario D: Realtime Voice", systemImage: "waveform")
                        }

                        Button {
                            demoDriver.startFailureRetryScenario()
                        } label: {
                            Label("Scenario E: Failure & Retry", systemImage: "arrow.clockwise")
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
                            Text("Scenarios")
                                .font(.system(size: 14, weight: .medium))
                        }
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
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
                    Toggle("Emoji Picker (EmojiKit)", isOn: $configuration.capabilities.supportsEmoji)
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
