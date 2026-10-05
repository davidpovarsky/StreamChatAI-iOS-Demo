// Sources/AgentUI/Session/AgentUIRuntimeAdapter.swift
import Foundation

@MainActor
public protocol AgentUIRuntimeAdapter: AnyObject, Sendable {
    func send(_ request: AgentSendRequest) -> AsyncThrowingStream<AgentUIEvent, Error>
    func cancel(requestID: AgentRequestID) async
}
