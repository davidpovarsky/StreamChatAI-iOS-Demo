//
//  ToolExecutionDemoViews.swift
//  SwiftChat
//
//  Distinct mock tool-provided UI presentations demonstrating UI flexibility.
//
#if canImport(SwiftUI)
import SwiftUI

struct GitHubToolPresentationView: View {
    let repository: String
    let resultCount: Int

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "chevron.left.forwardslash.chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.primary)
                .frame(width: 22, height: 22)
                .background(Color.primary.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 6))

            VStack(alignment: .leading, spacing: 1) {
                Text("Searched \(repository)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                Text("\(resultCount) matching files")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct WebSearchToolPresentationView: View {
    let siteCount: Int
    let query: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "globe")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.blue)
                .frame(width: 22, height: 22)
                .background(Color.blue.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 6))

            VStack(alignment: .leading, spacing: 1) {
                Text("Searched \(siteCount) websites")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                Text(query)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
    }
}

struct FileReadToolPresentationView: View {
    let fileName: String
    let lineRange: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "doc.text")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.indigo)
                .frame(width: 22, height: 22)
                .background(Color.indigo.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 6))

            VStack(alignment: .leading, spacing: 1) {
                Text("Read \(fileName)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                Text(lineRange)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct CalendarToolPresentationView: View {
    let eventCount: Int
    let timeframe: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "calendar")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.red)
                .frame(width: 22, height: 22)
                .background(Color.red.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 6))

            VStack(alignment: .leading, spacing: 1) {
                Text("Found \(eventCount) events")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                Text(timeframe)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct GenericAppToolPresentationView: View {
    let icon: String
    let title: String
    let subtitle: String
    var tintColor: Color = .primary

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(tintColor)
                .frame(width: 22, height: 22)
                .background(tintColor.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 6))

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
    }
}
#endif
