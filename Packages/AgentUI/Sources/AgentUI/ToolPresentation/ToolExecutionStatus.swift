//
//  ToolExecutionStatus.swift
//  AgentUI
//
//  High-level lifecycle status for presentation-layer tool representations.
//

import Foundation

public enum ToolExecutionStatus: String, Codable, Equatable, Hashable, CaseIterable, Sendable {
    case pending
    case running
    case completed
    case succeeded
    case failed

    public var label: String {
        switch self {
        case .pending: return "Pending"
        case .running: return "Running"
        case .completed, .succeeded: return "Completed"
        case .failed: return "Failed"
        }
    }
}
