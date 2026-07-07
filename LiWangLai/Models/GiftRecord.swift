import Foundation
import SwiftData

@Model
final class GiftRecord {
    @Attribute(.unique) var id: UUID
    var personName: String
    var typeRawValue: String
    var amountYuan: Int
    var eventTypeRawValue: String
    var relationshipRawValue: String
    var date: Date
    var note: String
    var isReturned: Bool
    var returnReminderDate: Date?
    var location: String
    var giftName: String
   var contact: String
   var createdAt: Date
   var updatedAt: Date
    var hostedEventID: UUID?

   init(
       id: UUID = UUID(),
       personName: String,
       type: GiftRecordType,
       amountYuan: Int,
       eventType: GiftEventType,
       relationship: RelationshipType,
       date: Date = .now,
       note: String = "",
       isReturned: Bool = false,
       returnReminderDate: Date? = nil,
       location: String = "",
       giftName: String = "",
       contact: String = "",
       createdAt: Date = .now,
        updatedAt: Date = .now,
        hostedEventID: UUID? = nil
   ) {
       self.id = id
       self.personName = personName
       self.typeRawValue = type.rawValue
       self.amountYuan = amountYuan
       self.eventTypeRawValue = eventType.rawValue
       self.relationshipRawValue = relationship.rawValue
       self.date = date
       self.note = note
       self.isReturned = isReturned
       self.returnReminderDate = returnReminderDate
       self.location = location
       self.giftName = giftName
       self.contact = contact
       self.createdAt = createdAt
       self.updatedAt = updatedAt
        self.hostedEventID = hostedEventID
   }

    var type: GiftRecordType {
        get { GiftRecordType(rawValue: typeRawValue) ?? .received }
        set { typeRawValue = newValue.rawValue }
    }

    var eventType: GiftEventType {
        get { GiftEventType(rawValue: eventTypeRawValue) ?? .other }
        set { eventTypeRawValue = newValue.rawValue }
    }

    var relationship: RelationshipType {
        get { RelationshipType(rawValue: relationshipRawValue) ?? .other }
        set { relationshipRawValue = newValue.rawValue }
    }

    var needsReturn: Bool {
        type == .received && !isReturned
    }
}
