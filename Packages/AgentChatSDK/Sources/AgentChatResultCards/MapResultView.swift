import SwiftUI
#if canImport(MapKit)
import MapKit
#endif
import AgentChatCore

public struct MapLocationStop: Identifiable, Sendable {
    public let id = UUID()
    public let name: String
    public let latitude: Double
    public let longitude: Double

    public init(name: String, latitude: Double, longitude: Double) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }

    #if canImport(MapKit)
    public var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    #endif
}

public struct MapResultView: View {
    public let result: AgentResult
    public let onAction: (AgentChatUserAction) -> Void

    @State private var selectedStop: MapLocationStop? = nil

    private let stops: [MapLocationStop] = [
        MapLocationStop(name: "Apple Park Cupertino", latitude: 37.3349, longitude: -122.0090),
        MapLocationStop(name: "Infinite Loop", latitude: 37.3318, longitude: -122.0311),
        MapLocationStop(name: "San Jose Tech Museum", latitude: 37.3316, longitude: -121.8901)
    ]

    public init(result: AgentResult, onAction: @escaping (AgentChatUserAction) -> Void) {
        self.result = result
        self.onAction = onAction
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "map.fill")
                    .foregroundColor(.blue)
                Text(result.title ?? "Recommended Route")
                    .font(.system(size: 15, weight: .semibold))
                Spacer()
                Text("MapKit")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(Color.secondary.opacity(0.12)))
            }

            #if canImport(MapKit)
            Map {
                ForEach(stops) { stop in
                    Marker(stop.name, coordinate: stop.coordinate)
                        .tint(.blue)
                }
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            #else
            Text("MapKit is not supported on this platform")
                .frame(height: 200)
            #endif

            HStack(spacing: 8) {
                ForEach(stops) { stop in
                    Button {
                        selectedStop = stop
                        let action = AgentChatUserAction(
                            kind: .select(option: stop.name),
                            context: AgentResultActionContext(
                                conversationId: "demo",
                                messageId: result.messageId,
                                resultId: result.id
                            )
                        )
                        onAction(action)
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 11))
                                .foregroundColor(.blue)
                            Text(stop.name)
                                .font(.system(size: 11, weight: .medium))
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule().fill(selectedStop?.id == stop.id ? Color.blue.opacity(0.18) : Color.secondary.opacity(0.1))
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.secondary.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.secondary.opacity(0.15), lineWidth: 1)
        )
    }
}
