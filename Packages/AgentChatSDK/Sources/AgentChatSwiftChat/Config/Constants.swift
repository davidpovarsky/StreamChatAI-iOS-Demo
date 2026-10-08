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
        public static let extensionThresholdRatio: CGFloat = 0.9
        public static let maxCellHeight: CGFloat = 200_000
    }

    public enum Pagination {
        public static let chatsPerPage = 20
    }

    public enum Context {
        public static let defaultMaxMessages = 75
        public static let maxMessagesLimit = 200
    }

    public enum ThinkingSummary {
        public static let minContentLength = 100
        public static let cooldownSeconds: TimeInterval = 3.0
        public static let tailWordCount = 200
    }

    public enum TitleGeneration {
        public static let wordThreshold = 100
        public static let systemPrompt = "Generate a concise, descriptive title of minimum 2 words, maximum 5 words for the following text. NEVER output markdown."
    }

    public enum Attachments {
        public static let maxImageDimension: CGFloat = 768
        public static let imageCompressionQuality: CGFloat = 0.85
        public static let maxFileSizeBytes: Int64 = 20 * 1024 * 1024
        public static let maxImageSizeBytes: Int64 = 10 * 1024 * 1024
        public static let previewThumbnailSize: CGFloat = 60
        public static let thumbnailMaxDimension: CGFloat = 300
        public static let previewMaxWidth: CGFloat = 200
        public static let messageThumbnailSize: CGFloat = 80
        public static let messageThumbnailColumns: Int = 3
        public static let supportedDocumentExtensions: Set<String> = ["pdf", "txt", "md", "csv", "html"]
        public static let supportedImageExtensions: Set<String> = ["jpg", "jpeg", "png", "gif", "webp", "heic"]
        public static let defaultImageMimeType = "image/jpeg"
    }

    public enum Audio {
        public static let sampleRate: Double = 44100
        public static let numberOfChannels: Int = 1
        public static let recordingTimeoutSeconds: TimeInterval = 120
        public static let transcriptionModel = "whisper-1"
        public static let maxRecordingDuration: TimeInterval = 60.0
    }

    public enum Formatting {
        public static let defaultCornerRadius: CGFloat = 16
        public static let messageHorizontalPadding: CGFloat = 16
    }
}
