// Sources/AgentUI/Localization/AgentLocalization.swift
import Foundation

public enum AgentLocalization {
    public static func string(_ key: String, comment: String = "") -> String {
        Bundle.module.localizedString(forKey: key, value: key, table: nil)
    }

    public static func formatted(_ key: String, _ arguments: CVarArg...) -> String {
        let format = string(key)
        return String(format: format, arguments: arguments)
    }
}
