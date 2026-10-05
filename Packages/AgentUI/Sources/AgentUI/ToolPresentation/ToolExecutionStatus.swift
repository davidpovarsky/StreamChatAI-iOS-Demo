//
//  ToolExecutionStatus.swift
//  AgentUI
//
//  High-level lifecycle status for presentation-layer tool representations.
//

import Foundation

public enum ToolExecutionStatus: Sendable {
    case running
    case completed
    case failed
}
