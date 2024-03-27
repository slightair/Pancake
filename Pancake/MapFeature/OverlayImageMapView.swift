import MapKit
import SwiftUI

@MainActor
struct OverlayImageMapView: UIViewRepresentable {
    let coordinateRegion: MKCoordinateRegion
    let overlayImage: OverlayImage?
    let delegate = MapViewDelegate()

    func makeUIView(context: Context) -> MKMapView {
        MKMapView(frame: .zero)
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.region = coordinateRegion
        uiView.delegate = delegate
        uiView.isUserInteractionEnabled = false

        let configuration = MKStandardMapConfiguration(emphasisStyle: .muted)
        uiView.preferredConfiguration = configuration

        addOverlayImage(to: uiView)
    }

    private func addOverlayImage(to view: MKMapView) {
        if !view.overlays.isEmpty {
            view.removeOverlays(view.overlays)
        }
        guard let overlayImage else {
            return
        }
        view.addOverlay(overlayImage)
    }
}

final class MapViewDelegate: NSObject, MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let overlayImage = overlay as? OverlayImage else {
            fatalError("Unsupported overlay")
        }
        let renderer = OverlayImageRenderer(overlay: overlayImage)
        renderer.alpha = 0.7
        return renderer
    }
}

final class OverlayImage: NSObject, MKOverlay {
    let coordinate = CLLocationCoordinate2D(latitude: 35.670000, longitude: 139.475000)
    let image: UIImage

    init(image: UIImage) {
        self.image = image
    }

    var boundingMapRect: MKMapRect {
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 124000, longitudinalMeters: 196000)
        let topLeft = MKMapPoint(
            CLLocationCoordinate2D(
                latitude: region.center.latitude + region.span.latitudeDelta * 0.5,
                longitude: region.center.longitude - region.span.longitudeDelta * 0.5
            )
        )
        let bottomRight = MKMapPoint(
            CLLocationCoordinate2D(
                latitude: region.center.latitude - region.span.latitudeDelta * 0.5,
                longitude: region.center.longitude + region.span.longitudeDelta * 0.5
            )
        )
        return MKMapRect(
            x: min(topLeft.x, bottomRight.x),
            y: min(topLeft.y, bottomRight.y),
            width: abs(bottomRight.x - topLeft.x),
            height: abs(bottomRight.y - topLeft.y)
        )
    }
}


final class OverlayImageRenderer: MKOverlayRenderer {
    private var image: UIImage? {
        (overlay as? OverlayImage)?.image
    }

    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        guard let cgImage = image?.cgImage else {
            return
        }
        let rect = rect(for: overlay.boundingMapRect)
        context.interpolationQuality = .none
        context.scaleBy(x: 1, y: -1)
        context.translateBy(x: 0, y: -rect.height)
        context.draw(cgImage, in: rect)
    }
}
