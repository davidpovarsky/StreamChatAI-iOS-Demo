// Tests/AgentUITests/SourcesTests.swift
import Testing
import Foundation
@testable import AgentUI

@Suite("AgentSource Deduplication and Section Sources Tests")
struct SourcesTests {
    @Test("Discovered sources are deduplicated by ID and URL")
    @MainActor
    func testSourceDeduplication() {
        let session = AgentUISession()
        let msgID = AgentMessageID("msg-1")
        session.apply(.assistantMessageStarted(messageID: msgID))

        let s1 = AgentSource(id: "s1", title: "Doc 1", url: "https://example.com/doc")
        let s2 = AgentSource(id: "s2", title: "Doc 1 duplicate", url: "https://example.com/doc")
        let s3 = AgentSource(id: "s3", title: "Doc 2", url: "https://example.com/doc2")

        session.apply(.sourceDiscovered(messageID: msgID, source: s1))
        session.apply(.sourceDiscovered(messageID: msgID, source: s2))
        session.apply(.sourceDiscovered(messageID: msgID, source: s3))

        let msg = session.messages.first(where: { $0.id == msgID })
        #expect(msg?.allSources.count == 2)
    }

    @Test("Section sources update maps correctly to message sections")
    @MainActor
    func testSectionSourcesMapping() {
        let session = AgentUISession()
        let msgID = AgentMessageID("msg-1")
        session.apply(.assistantMessageStarted(messageID: msgID))

        let secSources = [
            AgentSource(id: "sec-1", title: "Section Source", url: "https://example.com/section")
        ]

        session.apply(.sectionSourcesUpdated(messageID: msgID, sectionID: "p1", sources: secSources))

        let msg = session.messages.first(where: { $0.id == msgID })
        #expect(msg?.sectionSources["p1"]?.count == 1)
        #expect(msg?.allSources.contains(where: { $0.id == "sec-1" }) == true)
    }

    @Test("Source cluster preserves deterministic first-seen domain order")
    func testDeterministicSourceClusterOrder() {
        let sources = [
            AgentSource(title: "A", url: "https://zebra.com/1"),
            AgentSource(title: "B", url: "https://apple.com/2"),
            AgentSource(title: "C", url: "https://zebra.com/3"),
            AgentSource(title: "D", url: "https://banana.com/4"),
            AgentSource(title: "E", url: "https://apple.com/5")
        ]
        let cluster = AgentSourceClusterData(sources: sources)
        #expect(cluster.uniqueDomains == ["zebra.com", "apple.com", "banana.com"])
    }
}
