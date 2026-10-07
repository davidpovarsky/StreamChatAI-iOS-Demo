import Foundation
#if canImport(CoreGraphics)
import CoreGraphics
#endif

/// Application-wide constants
public enum Constants {
    public enum UI {
        public static let scrollToBottomButtonSize: CGFloat = 27
        public static let scrollToBottomIconSize: CGFloat = 16
        public static let tableMaxColumnWidth: CGFloat = 300
        public static let tableFontSize: CGFloat = 16
        public static let tableCellHorizontalPadding: CGFloat = 12
        public static let actionButtonCornerRadius: CGFloat = 6
    }

    public enum Rendering {
        public static let maxSyntaxHighlightCharacters = 15_000
        public static let maxFullParsingCharacters = 50_000
        public static let maxMarkdownSegmentCharacters = 8_000
    }

    public enum StreamingBuffer {
        public static let initialMultiplier: CGFloat = 50.0
        public static let multiplierIncrement: CGFloat = 10.0
        public static let maxMultiplier: CGFloat = 200.0
        public static let defaultMultiplier: CGFloat = 100.0
    }

    public enum Audio {
        public static let maxRecordingDuration: TimeInterval = 60.0
    }

    public enum Formatting {
        public static let defaultCornerRadius: CGFloat = 16
        public static let messageHorizontalPadding: CGFloat = 16
    }
}
