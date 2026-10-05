// Sources/AgentUI/Media/AgentMediaNavigationCoordinator.swift
import Foundation
import Observation

#if canImport(SwiftUI)
import SwiftUI

@MainActor
@Observable
public final class AgentMediaNavigationCoordinator {
    public var activeZoomImageID: String?
    public var activeImageURL: URL?
    public var activeAltText: String?
    public var activeCaption: String?

    public init() {}

    public func openImage(id: String, url: URL?, altText: String? = nil, caption: String? = nil) {
        self.activeZoomImageID = id
        self.activeImageURL = url
        self.activeAltText = altText
        self.activeCaption = caption
    }

    public func dismiss() {
        self.activeZoomImageID = nil
        self.activeImageURL = nil
        self.activeAltText = nil
        self.activeCaption = nil
    }
}

extension EnvironmentValues {
    @Entry public var agentMediaCoordinator: AgentMediaNavigationCoordinator? = nil
    @Entry public var agentImageZoomNamespace: Namespace.ID? = nil
}
#endif
