// Tests/AgentUITests/EmbeddedResultsTests.swift
import Testing
import Foundation
@testable import AgentUI

@Suite("Embedded Results Sizing and Expansion Tests")
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
}
