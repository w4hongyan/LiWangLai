import Foundation
import SwiftData

enum RecordService {
    static func insert(_ draft: GiftRecordDraft, in context: ModelContext) {
        let record = GiftRecord(
            personName: draft.personName.trimmingCharacters(in: .whitespacesAndNewlines),
            type: draft.type,
            amountYuan: draft.amountYuan,
            eventType: draft.eventType,
            relationship: draft.relationship,
            date: draft.date,
            note: draft.note.trimmingCharacters(in: .whitespacesAndNewlines),
            isReturned: draft.isReturned,
            returnReminderDate: draft.returnReminderDate,
            location: draft.location,
           giftName: draft.giftName,
           contact: draft.contact,
            hostedEventID: draft.hostedEventID,
       )
       context.insert(record)
        try? context.save()
    }

    static func update(_ record: GiftRecord, with draft: GiftRecordDraft, in context: ModelContext) {
        record.personName = draft.personName.trimmingCharacters(in: .whitespacesAndNewlines)
        record.type = draft.type
        record.amountYuan = draft.amountYuan
        record.eventType = draft.eventType
        record.relationship = draft.relationship
        record.date = draft.date
        record.note = draft.note.trimmingCharacters(in: .whitespacesAndNewlines)
        record.isReturned = draft.isReturned
        record.returnReminderDate = draft.returnReminderDate
        record.location = draft.location
        record.giftName = draft.giftName
       record.contact = draft.contact
        record.hostedEventID = draft.hostedEventID
       record.updatedAt = .now
        try? context.save()
    }

    static func delete(_ record: GiftRecord, in context: ModelContext) {
        context.delete(record)
        try? context.save()
    }

    static func markReturned(_ record: GiftRecord, in context: ModelContext) {
        record.isReturned = true
        record.updatedAt = .now
        try? context.save()
    }

    static func people(from records: [GiftRecord]) -> [PersonSummary] {
        Dictionary(grouping: records, by: { $0.personName })
            .map { name, records in
                let relationship = records.sorted { $0.date > $1.date }.first?.relationship ?? .other
                return PersonSummary(name: name, relationship: relationship, records: records)
            }
            .sorted {
                ($0.latestRecord?.date ?? .distantPast) > ($1.latestRecord?.date ?? .distantPast)
            }
    }
}

struct GiftRecordDraft: Equatable {
    var personName = ""
    var type: GiftRecordType = .received
    var amountText = "600"
    var eventType: GiftEventType = .baby
    var relationship: RelationshipType = .friend
    var date = Date()
    var note = ""
    var isReturned = false
    var returnReminderDate: Date?
   var location = ""
   var giftName = ""
   var contact = ""
    var hostedEventID: UUID?

   var amountYuan: Int {
       Int(amountText.filter(\.isNumber)) ?? 0
   }

    var isValid: Bool {
        !personName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && amountYuan > 0
    }

   init(
       record: GiftRecord? = nil,
       personName: String = "",
       type: GiftRecordType = .received,
       eventType: GiftEventType? = nil,
       date: Date? = nil,
        note: String = "",
        hostedEventID: UUID? = nil
   ) {
       if let record {
           self.personName = record.personName
           self.type = record.type
           self.amountText = "\(record.amountYuan)"
           self.eventType = record.eventType
           self.relationship = record.relationship
           self.date = record.date
           self.note = record.note
           self.isReturned = record.isReturned
           self.returnReminderDate = record.returnReminderDate
           self.location = record.location
           self.giftName = record.giftName
           self.contact = record.contact
           self.hostedEventID = record.hostedEventID
       } else {
           self.personName = personName
           self.type = type
           if let eventType {
               self.eventType = eventType
           }
           if let date {
               self.date = date
           }
           self.note = note
            self.hostedEventID = hostedEventID
       }
    }
}
