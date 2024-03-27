import Foundation

struct RoomSensorsHistory: Equatable, Identifiable {
    let id = UUID()
    let room: Room
    let records: [SensorsRecord]
}

extension RoomSensorsHistory {
    static let mockLiving = RoomSensorsHistory(room: .living, records: mockRecords)
    static let mockBedroom = RoomSensorsHistory(room: .bedroom, records: mockRecords)
    static let mockStudy = RoomSensorsHistory(room: .study, records: mockRecords)

    static let mockHistories : [RoomSensorsHistory] = [
        .mockLiving,
        .mockBedroom,
        .mockStudy,
    ]
}

private let mockRecords = [
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_727_895), temperature: 23.9, humidity: 43.0, co2: 545.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_727_295), temperature: 23.9, humidity: 43.0, co2: 534.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_726_695), temperature: 23.9, humidity: 43.0, co2: 539.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_726_095), temperature: 23.9, humidity: 43.0, co2: 531.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_725_495), temperature: 23.9, humidity: 43.0, co2: 565.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_724_895), temperature: 24.0, humidity: 44.0, co2: 601.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_724_295), temperature: 24.0, humidity: 45.0, co2: 629.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_723_695), temperature: 24.1, humidity: 45.0, co2: 621.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_723_095), temperature: 24.0, humidity: 45.0, co2: 601.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_722_495), temperature: 24.1, humidity: 45.0, co2: 601.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_721_895), temperature: 24.0, humidity: 45.0, co2: 622.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_721_295), temperature: 24.0, humidity: 45.0, co2: 624.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_720_695), temperature: 24.0, humidity: 46.0, co2: 680.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_720_095), temperature: 23.8, humidity: 48.0, co2: 665.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_719_495), temperature: 23.8, humidity: 48.0, co2: 629.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_718_895), temperature: 23.4, humidity: 45.0, co2: 686.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_718_295), temperature: 23.2, humidity: 47.0, co2: 771.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_717_695), temperature: 23.1, humidity: 47.0, co2: 744.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_717_095), temperature: 22.9, humidity: 47.0, co2: 747.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_716_495), temperature: 22.9, humidity: 48.0, co2: 785.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_715_895), temperature: 22.8, humidity: 49.0, co2: 793.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_715_295), temperature: 22.7, humidity: 48.0, co2: 772.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_714_695), temperature: 22.6, humidity: 47.0, co2: 752.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_714_095), temperature: 22.5, humidity: 48.0, co2: 758.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_713_495), temperature: 22.5, humidity: 49.0, co2: 816.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_712_895), temperature: 22.5, humidity: 49.0, co2: 854.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_712_295), temperature: 22.4, humidity: 50.0, co2: 860.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_711_695), temperature: 22.3, humidity: 49.0, co2: 871.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_711_095), temperature: 22.2, humidity: 49.0, co2: 913.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_710_495), temperature: 22.1, humidity: 50.0, co2: 903.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_709_895), temperature: 21.9, humidity: 49.0, co2: 851.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_709_295), temperature: 21.8, humidity: 48.0, co2: 950.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_708_695), temperature: 21.8, humidity: 49.0, co2: 903.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_708_095), temperature: 21.7, humidity: 49.0, co2: 778.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_707_495), temperature: 21.5, humidity: 49.0, co2: 476.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_706_895), temperature: 21.5, humidity: 48.0, co2: 472.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_706_295), temperature: 21.5, humidity: 48.0, co2: 472.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_705_695), temperature: 21.5, humidity: 49.0, co2: 485.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_705_095), temperature: 21.5, humidity: 49.0, co2: 466.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_704_495), temperature: 21.5, humidity: 49.0, co2: 476.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_703_895), temperature: 21.4, humidity: 49.0, co2: 477.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_703_295), temperature: 21.5, humidity: 49.0, co2: 487.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_702_694), temperature: 21.4, humidity: 49.0, co2: 481.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_702_094), temperature: 21.4, humidity: 49.0, co2: 479.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_701_494), temperature: 21.5, humidity: 49.0, co2: 474.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_700_894), temperature: 21.4, humidity: 49.0, co2: 476.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_700_294), temperature: 21.4, humidity: 49.0, co2: 473.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_699_694), temperature: 21.5, humidity: 49.0, co2: 467.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_699_094), temperature: 21.5, humidity: 48.0, co2: 472.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_698_497), temperature: 21.5, humidity: 48.0, co2: 483.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_697_894), temperature: 21.5, humidity: 48.0, co2: 480.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_697_294), temperature: 21.5, humidity: 48.0, co2: 478.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_696_694), temperature: 21.5, humidity: 48.0, co2: 489.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_696_094), temperature: 21.5, humidity: 48.0, co2: 488.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_695_494), temperature: 21.6, humidity: 48.0, co2: 495.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_694_894), temperature: 21.6, humidity: 48.0, co2: 487.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_694_294), temperature: 21.6, humidity: 48.0, co2: 491.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_693_694), temperature: 21.7, humidity: 48.0, co2: 493.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_693_094), temperature: 21.7, humidity: 48.0, co2: 479.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_692_494), temperature: 21.7, humidity: 48.0, co2: 495.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_691_894), temperature: 21.8, humidity: 49.0, co2: 504.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_691_294), temperature: 21.8, humidity: 49.0, co2: 497.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_690_694), temperature: 21.8, humidity: 49.0, co2: 517.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_690_094), temperature: 21.9, humidity: 49.0, co2: 513.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_689_494), temperature: 21.9, humidity: 49.0, co2: 521.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_688_894), temperature: 21.9, humidity: 49.0, co2: 523.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_688_294), temperature: 21.9, humidity: 49.0, co2: 530.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_687_694), temperature: 22.0, humidity: 49.0, co2: 534.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_687_094), temperature: 22.0, humidity: 49.0, co2: 544.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_686_494), temperature: 22.1, humidity: 49.0, co2: 560.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_685_894), temperature: 22.1, humidity: 49.0, co2: 568.0),
    SensorsRecord(date: Date(timeIntervalSince1970: 1_651_685_294), temperature: 22.2, humidity: 49.0, co2: 562.0),
]
