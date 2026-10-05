// Sources/AgentUI/Theme/AgentUIDesignTokens.swift
import Foundation
#if canImport(SwiftUI)
import SwiftUI
#endif

#if !canImport(CoreGraphics)
public typealias CGFloat = Double
#endif

public struct AgentUIDesignTokens: Sendable, Equatable {
    // Spacing
    public var messageSpacing: CGFloat
    public var bubblePaddingHorizontal: CGFloat
    public var bubblePaddingVertical: CGFloat
    public var composerPaddingHorizontal: CGFloat
    public var composerPaddingVertical: CGFloat
    public var timelineItemSpacing: CGFloat
    public var toolDisclosureSpacing: CGFloat

    // Corner Radii
    public var bubbleCornerRadius: CGFloat
    public var composerCornerRadius: CGFloat
    public var toolDisclosureCornerRadius: CGFloat
    public var mediaCornerRadius: CGFloat
    public var embeddedResultCornerRadius: CGFloat
    public var cardCornerRadius: CGFloat

    // Control & Icon Sizes
    public var controlButtonSize: CGFloat
    public var sourceFaviconSize: CGFloat
    public var modelBadgeHeight: CGFloat
    public var timelineIconSize: CGFloat

    // Borders & Glass
    public var borderWidth: CGFloat
    public var borderOpacity: Double
    public var glassOpacity: Double

    public init(
        messageSpacing: CGFloat = 16,
        bubblePaddingHorizontal: CGFloat = 14,
        bubblePaddingVertical: CGFloat = 10,
        composerPaddingHorizontal: CGFloat = 12,
        composerPaddingVertical: CGFloat = 10,
        timelineItemSpacing: CGFloat = 8,
        toolDisclosureSpacing: CGFloat = 8,
        bubbleCornerRadius: CGFloat = 18,
        composerCornerRadius: CGFloat = 26,
        toolDisclosureCornerRadius: CGFloat = 14,
        mediaCornerRadius: CGFloat = 16,
        embeddedResultCornerRadius: CGFloat = 14,
        cardCornerRadius: CGFloat = 12,
        controlButtonSize: CGFloat = 34,
        sourceFaviconSize: CGFloat = 16,
        modelBadgeHeight: CGFloat = 30,
        timelineIconSize: CGFloat = 20,
        borderWidth: CGFloat = 0.5,
        borderOpacity: Double = 0.12,
        glassOpacity: Double = 0.8
    ) {
        self.messageSpacing = messageSpacing
        self.bubblePaddingHorizontal = bubblePaddingHorizontal
        self.bubblePaddingVertical = bubblePaddingVertical
        self.composerPaddingHorizontal = composerPaddingHorizontal
        self.composerPaddingVertical = composerPaddingVertical
        self.timelineItemSpacing = timelineItemSpacing
        self.toolDisclosureSpacing = toolDisclosureSpacing
        self.bubbleCornerRadius = bubbleCornerRadius
        self.composerCornerRadius = composerCornerRadius
        self.toolDisclosureCornerRadius = toolDisclosureCornerRadius
        self.mediaCornerRadius = mediaCornerRadius
        self.embeddedResultCornerRadius = embeddedResultCornerRadius
        self.cardCornerRadius = cardCornerRadius
        self.controlButtonSize = controlButtonSize
        self.sourceFaviconSize = sourceFaviconSize
        self.modelBadgeHeight = modelBadgeHeight
        self.timelineIconSize = timelineIconSize
        self.borderWidth = borderWidth
        self.borderOpacity = borderOpacity
        self.glassOpacity = glassOpacity
    }

    public static let `default` = AgentUIDesignTokens()
}
