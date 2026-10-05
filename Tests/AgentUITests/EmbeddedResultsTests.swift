// Tests/AgentUITests/EmbeddedResultsTests.swift
import Testing
import Foundation
#if canImport(SwiftUI)
import SwiftUI
#endif
@testable import AgentUI

@MainActor
final class TestEmbeddedSession: AgentEmbeddedResultSession {
    let id: UUID
    static var createdCount = 0
    static var teardownCount = 0

    init(id: UUID = UUID()) {
        self.id = id
        Self.createdCount += 1
    }

    func tearDown() {
        Self.teardownCount += 1
    }

    #if canImport(SwiftUI)
    var rootView: AnyView {
        AnyView(EmptyView())
    }
    #endif
}

@Suite("Embedded Results Sizing, Expansion and Lifecycle Tests")
struct EmbeddedResultsTests {
    @Test("Verify preset sizing heights")
    func testPresetHeights() {
        #expect(AgentEmbeddedSizePreset.compact.defaultHeight == 140)
        #expect(AgentEmbeddedSizePreset.regular.defaultHeight == 240)
        #expect(AgentEmbeddedSizePreset.large.defaultHeight == 380)
        #expect(AgentEmbeddedSizePreset.automatic.defaultHeight == 220)
    }

    @Test("Verify expansion descriptor modes")
    func testExpansionModes() {
        let descriptor = AgentExpansionDescriptor(
            allowedModes: [.sheet, .fullScreen],
            preferredMode: .sheet,
            supportsInlineCollapse: true
        )

        #expect(descriptor.allowedModes.contains(.sheet))
        #expect(descriptor.allowedModes.contains(.fullScreen))
        #expect(descriptor.preferredMode == .sheet)
        #expect(descriptor.supportsInlineCollapse == true)
    }

    @Test("Verify embedded session lifecycle created and teardown counts")
    @MainActor
    func testEmbeddedSessionLifecycle() {
        TestEmbeddedSession.createdCount = 0
        TestEmbeddedSession.teardownCount = 0

        let descriptor = AgentEmbeddedPresentationDescriptor(
            handlerID: "test.lifecycle",
            title: "Lifecycle Test",
            sizing: AgentEmbeddedSizingPreference(preset: .regular),
            expansion: AgentExpansionDescriptor(allowedModes: [.sheet, .fullScreen], preferredMode: .sheet),
            payload: AgentEmbeddedPayload(jsonString: "{}")
        )

        let coordinator = AgentExpansionCoordinator()
        let session = TestEmbeddedSession()
        #expect(TestEmbeddedSession.createdCount == 1)
        #expect(TestEmbeddedSession.teardownCount == 0)

        // Expand to sheet
        coordinator.presentSheet(descriptor: descriptor, session: session)
        #expect(coordinator.isSheetPresented == true)
        #expect(coordinator.isFullScreenPresented == false)
        #expect(coordinator.activeSession === session)
        #expect(coordinator.isPresenting(descriptor: descriptor) == true)
        #expect(TestEmbeddedSession.teardownCount == 0)

        // Dismiss sheet - logical session remains alive
        coordinator.dismiss()
        #expect(coordinator.isSheetPresented == false)
        #expect(coordinator.activeSession == nil)
        #expect(TestEmbeddedSession.teardownCount == 0)

        // Complete full lifecycle with teardown
        session.tearDown()
        #expect(TestEmbeddedSession.teardownCount == 1)

        // Ensure double teardown is prevented on wrapped session
        let wrapped = AnyAgentEmbeddedResultSession(session)
        wrapped.tearDown()
        wrapped.tearDown()
        #expect(TestEmbeddedSession.teardownCount == 2)
    }
}
