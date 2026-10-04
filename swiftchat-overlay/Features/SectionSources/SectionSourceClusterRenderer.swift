import SwiftUI
import UIKit

@MainActor
final class SectionSourceClusterRenderer: ObservableObject {
    @Published private(set) var image: UIImage

    private let sources: [WebSearchSource]
    private let isDarkMode: Bool

    init(sources: [WebSearchSource], isDarkMode: Bool) {
        self.sources = sources
        self.isDarkMode = isDarkMode
        self.image = Self.drawCluster(icons: [], count: min(sources.count, 4), isDarkMode: isDarkMode)
    }

    func load() async {
        var icons: [UIImage] = []
        for domain in uniqueDomains {
            let url = URL(string: "https://icons.duckduckgo.com/ip3/\(domain).ico")
            if let url,
               let (data, _) = try? await URLSession.shared.data(from: url),
               let icon = UIImage(data: data) {
                icons.append(icon)
            } else if let fallback = UIImage(systemName: "globe") {
                icons.append(fallback)
            }
        }
        image = Self.drawCluster(icons: icons, count: uniqueDomains.count, isDarkMode: isDarkMode)
    }

    private var uniqueDomains: [String] {
        var seen = Set<String>()
        return sources.compactMap { source in
            guard let host = URL(string: source.url)?.host else { return nil }
            let domain = host.hasPrefix("www.") ? String(host.dropFirst(4)) : host
            return seen.insert(domain).inserted ? domain : nil
        }.prefix(4).map { $0 }
    }

    private static func drawCluster(icons: [UIImage], count: Int, isDarkMode: Bool) -> UIImage {
        let iconSize: CGFloat = 15
        let overlap: CGFloat = 5
        let displayedCount = max(1, count)
        let contentWidth = iconSize + CGFloat(displayedCount - 1) * (iconSize - overlap)
        let size = CGSize(width: contentWidth + 12, height: 23)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 3
        format.opaque = false

        return UIGraphicsImageRenderer(size: size, format: format).image { context in
            let capsule = UIBezierPath(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: size.height / 2)
            (isDarkMode ? UIColor.white.withAlphaComponent(0.10) : UIColor.black.withAlphaComponent(0.05)).setFill()
            capsule.fill()

            for index in 0..<displayedCount {
                let rect = CGRect(x: 6 + CGFloat(index) * (iconSize - overlap), y: 4, width: iconSize, height: iconSize)
                context.cgContext.saveGState()
                context.cgContext.addEllipse(in: rect)
                context.cgContext.clip()
                let icon = index < icons.count ? icons[index] : UIImage(systemName: "globe")
                UIColor.systemGray5.setFill()
                context.cgContext.fill(rect)
                icon?.draw(in: rect.insetBy(dx: 1, dy: 1))
                context.cgContext.restoreGState()
                (isDarkMode ? UIColor.white.withAlphaComponent(0.2) : UIColor.black.withAlphaComponent(0.1)).setStroke()
                UIBezierPath(ovalIn: rect).stroke()
            }
        }
    }
}
