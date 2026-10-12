import Foundation

// MARK: - Virtual Clock Protocol

public protocol AgentClock: Sendable {
    var now: Date { get }
}

public struct SystemClock: AgentClock {
    public init() {}
    public var now: Date { Date() }
}

public final class VirtualClock: AgentClock, @unchecked Sendable {
    private let lock = NSLock()
    private var currentTime: Date

    public init(initialTime: Date = Date(timeIntervalSince1970: 1776000000)) {
        self.currentTime = initialTime
    }

    public var now: Date {
        lock.lock()
        defer { lock.unlock() }
        return currentTime
    }

    public func advance(by seconds: TimeInterval) {
        lock.lock()
        defer { lock.unlock() }
        currentTime = currentTime.addingTimeInterval(seconds)
    }

    public func setTime(_ time: Date) {
        lock.lock()
        defer { lock.unlock() }
        currentTime = time
    }
}

// MARK: - Demo Scenario Types

public struct DemoScenarioEvent: Codable, Equatable, Sendable {
    public let atMs: Int
    public let event: AgentChatStreamEvent

    public init(atMs: Int, event: AgentChatStreamEvent) {
        self.atMs = atMs
        self.event = event
    }
}

public struct DemoScenario: Identifiable, Sendable {
    public let id: String
    public let title: String
    public let summary: String
    public let userPrompt: String
    public let events: [DemoScenarioEvent]

    public init(
        id: String,
        title: String,
        summary: String,
        userPrompt: String,
        events: [DemoScenarioEvent]
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.userPrompt = userPrompt
        self.events = events
    }
}
