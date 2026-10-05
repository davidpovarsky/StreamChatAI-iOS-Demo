// Showcase/Sources/ScenarioSidebarView.swift
import SwiftUI
import AgentUI
import AgentUIShowcaseSupport

struct ScenarioSidebarView: View {
    @Binding var selectedScenarioID: String?
    let onSelect: (ShowcaseScenario) -> Void

    private var groupedScenarios: [String: [ShowcaseScenario]] {
        Dictionary(grouping: ShowcaseCatalog.allScenarios, by: { $0.category })
    }

    private var categories: [String] {
        ["Chat Basics", "Sources", "Activity", "Tool Execution", "Embedded Results", "Media", "Native Blocks"]
    }

    var body: some View {
        List {
            ForEach(categories, id: \.self) { category in
                if let scenarios = groupedScenarios[category] {
                    Section(category) {
                        ForEach(scenarios) { scenario in
                            Button {
                                selectedScenarioID = scenario.id
                                onSelect(scenario)
                            } label: {
                                VStack(alignment: .leading, spacing: 3) {
                                    HStack {
                                        Text(scenario.title)
                                            .font(.subheadline.weight(.medium))
                                            .foregroundStyle(selectedScenarioID == scenario.id ? Color.accentColor : Color.primary)
                                        Spacer()
                                        if selectedScenarioID == scenario.id {
                                            Image(systemName: "checkmark")
                                                .font(.caption)
                                                .foregroundStyle(Color.accentColor)
                                        }
                                    }
                                    Text(scenario.description)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(2)
                                }
                                .padding(.vertical, 3)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
        .navigationTitle("Scenarios")
    }
}
