import ComposableArchitecture
import Foundation
import MapKit
import SwiftUI

struct Map: ReducerProtocol {
    struct State: Equatable {
        private static let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            formatter.locale = Locale(identifier: "ja_JP")
            return formatter
        }()

        var date = Date()
        var region = MKCoordinateRegion(
            center : CLLocationCoordinate2D(
                latitude: 35.702694,
                longitude: 139.560833
            ),
            latitudinalMeters: 16_000.0,
            longitudinalMeters: 16_000.0
        )
        var overlayImage: OverlayImage?
        var keyTime: KeyTime?

        var lastUpdated: String {
            keyTime.map {
                Self.dateFormatter.string(from: $0.date)
            } ?? "--:--"
        }
    }

    enum Action {
        case mapUpdate
        case regionChanged(MKCoordinateRegion)
        case mapOverlayResponse(TaskResult<(UIImage, KeyTime)>)
    }

    @Dependency(\.date) var date
    @Dependency(\.settings.api) var settings
    @Dependency(\.mapOverlayClient) var mapOverlayClient

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .mapUpdate:
            let now = date.now
            state.date = now
            return .task {
                await .mapOverlayResponse(TaskResult { try await mapOverlayClient.overlayImage(settings.overlayImageProviderURLTemplate, now) })
            }
        case let .regionChanged(region):
            state.region = region
            return .none
        case let .mapOverlayResponse(.success((image, keyTime))):
            state.overlayImage = OverlayImage(image: image)
            state.keyTime = keyTime
            return .none
        case let .mapOverlayResponse(.failure(error)):
            print(error)
            state.overlayImage = nil
            return .none
        }
    }
}

struct MapView: View {
    let store: StoreOf<Map>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack(alignment: .topTrailing) {
                OverlayImageMapView(
                    coordinateRegion: viewStore.region,
                    overlayImage: viewStore.overlayImage
                )
                Text("最終更新: \(viewStore.lastUpdated)")
                    .padding(4)
                    .foregroundColor(AppTheme.headerColor.opacity(0.7))
                    .font(AppTheme.headerFont)
                    .offset(x: -4, y: 4)
            }
            .cornerRadius(8)
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(
            store: Store(
                initialState: Map.State(),
                reducer: Map()
            )
        )
        .previewDevice(PreviewDevice(rawValue: "iPad Pro (10.5-inch)"))
    }
}

extension MKCoordinateRegion: Equatable {
    public static func == (lhs: MKCoordinateRegion, rhs: MKCoordinateRegion) -> Bool {
        guard lhs.center.latitude == rhs.center.latitude,
              lhs.center.longitude == rhs.center.longitude,
              lhs.span.latitudeDelta == rhs.span.latitudeDelta,
              lhs.span.longitudeDelta == rhs.span.longitudeDelta else {
            return false
        }
        return true
    }
}
