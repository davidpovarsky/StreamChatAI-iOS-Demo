//
//  ToolExecutionDemoViews.swift
//  SwiftChat
//
//  Distinct mock tool-provided UI presentations demonstrating UI flexibility.
//

import SwiftUI

public struct GitHubToolPresentationView: View {
    public let repository: String
    public let resultCount: Int

    public init(repository: String, resultCount: Int) {
        self.repository = repository
        self.resultCount = resultCount
    }

    public var body: some View {
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

public struct WebSearchToolPresentationView: View {
    public let siteCount: Int
    public let query: String

    public init(siteCount: Int, query: String) {
        self.siteCount = siteCount
        self.query = query
    }

    public var body: some View {
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

public struct FileReadToolPresentationView: View {
    public let fileName: String
    public let lineRange: String

    public init(fileName: String, lineRange: String) {
        self.fileName = fileName
        self.lineRange = lineRange
    }

    public var body: some View {
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

public struct CalendarToolPresentationView: View {
    public let eventCount: Int
    public let timeframe: String

    public init(eventCount: Int, timeframe: String) {
        self.eventCount = eventCount
        self.timeframe = timeframe
    }

    public var body: some View {
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

public struct GenericAppToolPresentationView: View {
    public let icon: String
    public let title: String
    public let subtitle: String
    public var tintColor: Color

    public init(icon: String, title: String, subtitle: String, tintColor: Color = .primary) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.tintColor = tintColor
    }

    public var body: some View {
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
