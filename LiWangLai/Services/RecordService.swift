import Foundation
import SwiftData

enum RecordService {
    enum RecordError: LocalizedError, Equatable {
        case invalidDraft
        case invalidReturnGift
        case notReturnable

        var errorDescription: String? {
            switch self {
            case .invalidDraft:
                "姓名和金额填写不完整。"
            case .invalidReturnGift:
                "回礼记录必须是送出类型。"
            case .notReturnable:
                "只有待回礼的收礼记录可以标记已回。"
            }
        }
    }

    @discardableResult
    @MainActor
    static func insert(
        _ inputDraft: GiftRecordDraft,
        returning originalRecord: GiftRecord? = nil,
        in context: ModelContext
    ) throws -> GiftRecord {
        guard inputDraft.isValid else { throw RecordError.invalidDraft }
        var draft = inputDraft
        if let originalRecord {
            guard draft.type == .given else { throw RecordError.invalidReturnGift }
            guard originalRecord.needsReturn else { throw RecordError.notReturnable }
        }

        if let hostedEvent = try HostedEventService.resolveEvent(for: draft, in: context) {
            draft.hostedEventID = hostedEvent.id
            draft.eventType = hostedEvent.eventType
            draft.date = hostedEvent.date
        } else {
            draft.hostedEventID = nil
        }

        let supportsReturn = draft.type == .received
        let reminderDate = supportsReturn && draft.isReturned ? nil : draft.returnReminderDate
        let record = GiftRecord(
            personName: draft.personName.trimmingCharacters(in: .whitespacesAndNewlines),
            type: draft.type,
            amountYuan: draft.amountYuan,
            eventType: draft.eventType,
            relationship: draft.relationship,
            date: draft.date,
            note: draft.note.trimmingCharacters(in: .whitespacesAndNewlines),
            isReturned: supportsReturn ? draft.isReturned : false,
            returnReminderDate: reminderDate,
            location: draft.location.trimmingCharacters(in: .whitespacesAndNewlines),
            giftName: draft.giftName.trimmingCharacters(in: .whitespacesAndNewlines),
            contact: draft.contact.trimmingCharacters(in: .whitespacesAndNewlines),
            hostedEventID: draft.hostedEventID
        )
        context.insert(record)
        if let originalRecord {
            originalRecord.isReturned = true
            originalRecord.returnReminderDate = nil
            originalRecord.updatedAt = .now
        }
        do {
            try context.save()
            return record
        } catch {
            context.rollback()
            throw error
        }
    }

    @MainActor
    static func update(_ record: GiftRecord, with inputDraft: GiftRecordDraft, in context: ModelContext) throws {
        guard inputDraft.isValid else { throw RecordError.invalidDraft }
        var draft = inputDraft
        if let hostedEvent = try HostedEventService.resolveEvent(for: draft, in: context) {
            draft.hostedEventID = hostedEvent.id
            draft.eventType = hostedEvent.eventType
            draft.date = hostedEvent.date
        } else {
            draft.hostedEventID = nil
        }
        let supportsReturn = draft.type == .received
        let reminderDate = supportsReturn && draft.isReturned ? nil : draft.returnReminderDate
        record.personName = draft.personName.trimmingCharacters(in: .whitespacesAndNewlines)
        record.type = draft.type
        record.amountYuan = draft.amountYuan
        record.eventType = draft.eventType
        record.relationship = draft.relationship
        record.date = draft.date
        record.note = draft.note.trimmingCharacters(in: .whitespacesAndNewlines)
        record.isReturned = supportsReturn ? draft.isReturned : false
        record.returnReminderDate = reminderDate
        record.location = draft.location.trimmingCharacters(in: .whitespacesAndNewlines)
        record.giftName = draft.giftName.trimmingCharacters(in: .whitespacesAndNewlines)
        record.contact = draft.contact.trimmingCharacters(in: .whitespacesAndNewlines)
        record.hostedEventID = draft.hostedEventID
        record.updatedAt = .now
        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }

    static func delete(_ record: GiftRecord, in context: ModelContext) throws {
        context.delete(record)
        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }

    static func markReturned(_ record: GiftRecord, in context: ModelContext) throws {
        guard record.needsReturn else { throw RecordError.notReturnable }
        record.isReturned = true
        record.returnReminderDate = nil
        record.updatedAt = .now
        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }

    static func completeReminder(_ record: GiftRecord, in context: ModelContext) throws {
        if record.type == .received {
            try markReturned(record, in: context)
            return
        }
        record.returnReminderDate = nil
        record.updatedAt = .now
        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
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
    var hostedEventTitle = ""

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
        hostedEventID: UUID? = nil,
        hostedEventTitle: String = ""
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
            self.hostedEventTitle = hostedEventTitle
        }
    }
}
