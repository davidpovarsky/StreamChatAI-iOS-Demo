//
//  ToolExecutionStatus.swift
//  SwiftChat
//
//  Presentation status for a single tool execution.
//

import Foundation

public enum ToolExecutionStatus: String, Codable, Equatable, Sendable {
    case pending
    case running
    case completed
    case failed
}
