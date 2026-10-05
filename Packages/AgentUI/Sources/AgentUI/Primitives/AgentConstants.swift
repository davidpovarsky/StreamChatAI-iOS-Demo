//
//  AgentConstants.swift
//  AgentUI
//

import Foundation
import CoreGraphics

public enum AgentConstants {
    public enum Rendering {
        public static let maxFullParsingCharacters = 20000
        public static let maxMarkdownSegmentCharacters = 4000
    }

    public enum UI {
        public static let scrollToBottomButtonSize: CGFloat = 27
        public static let scrollToBottomIconSize: CGFloat = 16
        public static let tableMaxColumnWidth: CGFloat = 300
        public static let tableFontSize: CGFloat = 16
        public static let tableCellHorizontalPadding: CGFloat = 12
        public static let actionButtonCornerRadius: CGFloat = 6
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
}

public typealias Constants = AgentConstants
