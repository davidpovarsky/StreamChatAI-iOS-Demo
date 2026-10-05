// Sources/AgentUI/Embedded/AgentEmbeddedSession.swift
import Foundation

#if canImport(SwiftUI)
import SwiftUI

@MainActor
public protocol AgentEmbeddedResultSession: AnyObject, Identifiable {
    var id: UUID { get }
    var rootView: AnyView { get }
    func tearDown()
}

@MainActor
public final class AnyAgentEmbeddedResultSession: AgentEmbeddedResultSession {
    public let id: UUID
    private let _rootView: @MainActor () -> AnyView
    private let _tearDown: @MainActor () -> Void
    private var hasTornDown = false

    public init<S: AgentEmbeddedResultSession>(_ session: S) {
        self.id = session.id
        self._rootView = { session.rootView }
        self._tearDown = { session.tearDown() }
    }

    public init(
        id: UUID = UUID(),
        rootView: @escaping @MainActor () -> AnyView,
        tearDown: @escaping @MainActor () -> Void = {}
    ) {
        self.id = id
        self._rootView = rootView
        self._tearDown = tearDown
    }

    public var rootView: AnyView {
        _rootView()
    }

    public func tearDown() {
        guard !hasTornDown else { return }
        hasTornDown = true
        _tearDown()
    }
}
#else
@MainActor
public protocol AgentEmbeddedResultSession: AnyObject, Identifiable {
    var id: UUID { get }
    func tearDown()
}

@MainActor
public final class AnyAgentEmbeddedResultSession: AgentEmbeddedResultSession {
    public let id: UUID
    private let _tearDown: @MainActor () -> Void
    private var hasTornDown = false

    public init<S: AgentEmbeddedResultSession>(_ session: S) {
        self.id = session.id
        self._tearDown = { session.tearDown() }
    }

    public init(
        id: UUID = UUID(),
        tearDown: @escaping @MainActor () -> Void = {}
    ) {
        self.id = id
        self._tearDown = tearDown
    }

    public func tearDown() {
        guard !hasTornDown else { return }
        hasTornDown = true
        _tearDown()
    }
}
#endif
