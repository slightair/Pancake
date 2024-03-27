import Foundation

struct HomeSection: Equatable, Identifiable {
    let room: Room
    let roomStatuses: [RoomStatus]

    var id: String {
        room.rawValue
    }
}
