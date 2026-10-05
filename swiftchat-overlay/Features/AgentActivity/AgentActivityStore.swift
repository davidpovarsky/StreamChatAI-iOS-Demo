//
//  AgentActivityStore.swift
//  SwiftChat
//
//  Compatibility alias forwarding to AgentUI.
//

@_exported import AgentUI
import Combine
import Foundation

typealias AgentActivityStore = AgentUI.AgentActivityStore

extension AgentActivityStore {
    func addSearchSource(messageID: String, source: SwiftChat.WebSearchSource) {
        addSearchSource(messageID: messageID, source: AgentUI.WebSearchSource(id: source.id, title: source.title, url: source.url))
    }
}
