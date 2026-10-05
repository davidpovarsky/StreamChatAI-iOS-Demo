// Sources/AgentUIShowcaseSupport/MockRuntime/MockStreamEngine.swift
import Foundation
import AgentUI

public struct MockStreamEngine: Sendable {
    public static func makeStream(events: [AgentUIEvent], interval: Double = 0.05) -> AsyncThrowingStream<AgentUIEvent, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                for event in events {
                    if Task.isCancelled { break }
                    if interval > 0 {
                        try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
                    }
                    continuation.yield(event)
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}
