import Foundation
import SwiftData

@Model
final class HostedGiftEvent {
    @Attribute(.unique) var id: UUID
    var title: String
    var eventTypeRawValue: String
    var date: Date
    var note: String
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        eventType: GiftEventType,
        date: Date = .now,
        note: String = "",
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.eventTypeRawValue = eventType.rawValue
        self.date = date
        self.note = note
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var eventType: GiftEventType {
        get { GiftEventType(rawValue: eventTypeRawValue) ?? .other }
        set { eventTypeRawValue = newValue.rawValue }
    }
}

struct GiftEvent: Identifiable {
    var id: String { hostedEventID?.uuidString ?? "\(title)-\(monthKey)" }
    let title: String
    let monthKey: String
    let eventType: GiftEventType?
    let date: Date?
    let records: [GiftRecord]
    let hostedEventID: UUID?
    let hostedEvent: HostedGiftEvent?

    init(
        title: String,
        monthKey: String,
        eventType: GiftEventType? = nil,
        date: Date? = nil,
        records: [GiftRecord],
        hostedEventID: UUID? = nil,
        hostedEvent: HostedGiftEvent? = nil
    ) {
        self.title = title
        self.monthKey = monthKey
        self.eventType = eventType
        self.date = date
        self.records = records
        self.hostedEventID = hostedEventID
        self.hostedEvent = hostedEvent
    }

    var totalAmount: Int {
        records.reduce(0) { $0 + $1.amountYuan }
    }
}
