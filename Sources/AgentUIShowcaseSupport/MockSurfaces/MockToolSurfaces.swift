// Sources/AgentUIShowcaseSupport/MockSurfaces/MockToolSurfaces.swift
#if canImport(SwiftUI)
import SwiftUI
import AgentUI

public enum MockToolSurfaces {
    @MainActor
    public static func registerAll(in registry: AgentToolSurfaceRegistry) {
        registry.registerToolHandler("github.search") { context in
            HStack(spacing: 8) {
                Image(systemName: "chevron.left.forwardslash.chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 22, height: 22)
                    .background(Color.primary.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 6))

                VStack(alignment: .leading, spacing: 1) {
                    Text("GitHub Code Search")
                        .font(.system(size: 13, weight: .medium))
                    Text("Found matching symbols in repository")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }

        registry.registerToolHandler("web_search") { context in
            HStack(spacing: 8) {
                Image(systemName: "globe")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.blue)
                    .frame(width: 22, height: 22)
                    .background(Color.blue.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 6))

                VStack(alignment: .leading, spacing: 1) {
                    Text("Web Search")
                        .font(.system(size: 13, weight: .medium))
                    Text(context.execution.inspection.arguments)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }

        registry.registerToolHandler("file_operation") { context in
            HStack(spacing: 8) {
                Image(systemName: "doc.text")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.indigo)
                    .frame(width: 22, height: 22)
                    .background(Color.indigo.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 6))

                VStack(alignment: .leading, spacing: 1) {
                    Text("File Operation")
                        .font(.system(size: 13, weight: .medium))
                    Text(context.execution.inspection.toolName)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }

        registry.registerToolHandler("command_exec") { context in
            HStack(spacing: 8) {
                Image(systemName: "terminal")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.green)
                    .frame(width: 22, height: 22)
                    .background(Color.green.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 6))

                VStack(alignment: .leading, spacing: 1) {
                    Text("Terminal Command")
                        .font(.system(size: 13, weight: .medium))
                    Text(context.execution.inspection.arguments)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }

        registry.registerToolHandler("map_lookup") { context in
            HStack(spacing: 8) {
                Image(systemName: "map")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.orange)
                    .frame(width: 22, height: 22)
                    .background(Color.orange.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 6))

                VStack(alignment: .leading, spacing: 1) {
                    Text("Map Location")
                        .font(.system(size: 13, weight: .medium))
                    Text("Retrieved coordinates and place info")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }

        registry.registerToolHandler("calendar.events") { context in
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.red)
                    .frame(width: 22, height: 22)
                    .background(Color.red.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 6))

                VStack(alignment: .leading, spacing: 1) {
                    Text("Calendar Query")
                        .font(.system(size: 13, weight: .medium))
                    Text("Retrieved upcoming events")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }

        registry.registerToolHandler("image_gen") { context in
            HStack(spacing: 8) {
                Image(systemName: "paintpalette")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.purple)
                    .frame(width: 22, height: 22)
                    .background(Color.purple.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 6))

                VStack(alignment: .leading, spacing: 1) {
                    Text("Image Generation")
                        .font(.system(size: 13, weight: .medium))
                    Text("Rendered generative visual asset")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
#endif
