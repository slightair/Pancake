import MapKit

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
