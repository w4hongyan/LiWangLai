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

        let personID = try resolvePersonID(for: draft, in: context)

        let supportsReturn = draft.type == .received
        let reminderDate = supportsReturn && draft.isReturned ? nil : draft.returnReminderDate
        let record = GiftRecord(
            personName: draft.personName.trimmingCharacters(in: .whitespacesAndNewlines),
            type: draft.type,
            amountYuan: draft.amountFen / 100,
            amountFen: draft.amountFen,
            personID: personID,
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
        record.personID = draft.personID ?? record.personID
        record.type = draft.type
        record.setAmount(fen: draft.amountFen)
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
        let persistedGroups = Dictionary(grouping: records.filter { $0.personID != nil }) {
            $0.personID!
        }
        let persistedPeople = persistedGroups.map { personID, groupedRecords in
            makePersonSummary(
                id: personID.uuidString,
                records: groupedRecords,
                identityHint: groupedRecords.compactMap { PersonIdentity.maskedContact($0.contact) }.first
            )
        }
        let legacyPeople = legacyPeople(from: records.filter { $0.personID == nil })
        return (persistedPeople + legacyPeople)
            .sorted {
                ($0.latestRecord?.date ?? .distantPast) > ($1.latestRecord?.date ?? .distantPast)
            }
    }

    private static func legacyPeople(from records: [GiftRecord]) -> [PersonSummary] {
        Dictionary(grouping: records, by: { PersonIdentity.normalizedName($0.personName) })
            .flatMap { normalizedName, sameNameRecords -> [PersonSummary] in
                let contacts = Set(sameNameRecords
                    .map { PersonIdentity.normalizedContact($0.contact) }
                    .filter { !$0.isEmpty })

                if contacts.count <= 1 {
                    return [makePersonSummary(
                        id: normalizedName,
                        records: sameNameRecords,
                        identityHint: contacts.first.flatMap(PersonIdentity.maskedContact)
                    )]
                }

                return Dictionary(grouping: sameNameRecords) { record in
                    let contact = PersonIdentity.normalizedContact(record.contact)
                    return contact.isEmpty ? "no-contact" : contact
                }
                .map { contactKey, groupedRecords in
                    makePersonSummary(
                        id: "\(normalizedName)|\(contactKey)",
                        records: groupedRecords,
                        identityHint: contactKey == "no-contact" ? "联系方式待补充" : PersonIdentity.maskedContact(contactKey)
                    )
                }
            }
    }

    @MainActor
    @discardableResult
    static func backfillPersonIDs(records: [GiftRecord], in context: ModelContext) throws -> Int {
        let legacyRecords = records.filter { $0.personID == nil }
        guard !legacyRecords.isEmpty else { return 0 }
        var count = 0
        for summary in legacyPeople(from: legacyRecords) {
            let personID = UUID()
            for record in summary.records {
                record.personID = personID
                record.updatedAt = .now
                count += 1
            }
        }
        do {
            try context.save()
            return count
        } catch {
            context.rollback()
            throw error
        }
    }

    private static func makePersonSummary(
        id: String,
        records: [GiftRecord],
        identityHint: String?
    ) -> PersonSummary {
        let sorted = records.sorted { $0.date > $1.date }
        let latest = sorted.first
        return PersonSummary(
            id: id,
            name: latest?.personName ?? "",
            relationship: latest?.relationship ?? .other,
            records: records,
            identityHint: identityHint
        )
    }

    @MainActor
    private static func resolvePersonID(for draft: GiftRecordDraft, in context: ModelContext) throws -> UUID {
        if let personID = draft.personID { return personID }
        let records = try context.fetch(FetchDescriptor<GiftRecord>())
        let matches = records.filter {
            PersonIdentity.matches($0, name: draft.personName, contact: draft.contact)
        }
        let existingIDs = Set(matches.compactMap(\.personID))
        if existingIDs.count == 1, let existing = existingIDs.first { return existing }
        let newID = UUID()
        if existingIDs.isEmpty {
            for record in matches {
                record.personID = newID
                record.updatedAt = .now
            }
        }
        return newID
    }
}

struct GiftRecordDraft: Equatable {
    var personName = ""
    var type: GiftRecordType = .received
    var amountText = ""
    var eventType: GiftEventType = .other
    var relationship: RelationshipType = .other
    var date = Date()
    var note = ""
    var isReturned = false
    var returnReminderDate: Date?
    var location = ""
    var giftName = ""
    var contact = ""
    var personID: UUID?
    var hostedEventID: UUID?
    var hostedEventTitle = ""
    var createsHostedEvent = false

    var amountFen: Int {
        MoneyAmount.parseFen(amountText) ?? 0
    }

    var amountYuan: Decimal {
        Decimal(amountFen) / 100
    }

    var isValid: Bool {
        !personName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && amountFen > 0
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
            self.amountText = MoneyAmount.inputText(fromFen: record.amountFenValue)
            self.eventType = record.eventType
            self.relationship = record.relationship
            self.date = record.date
            self.note = record.note
            self.isReturned = record.isReturned
            self.returnReminderDate = record.returnReminderDate
            self.location = record.location
            self.giftName = record.giftName
            self.contact = record.contact
            self.personID = record.personID
            self.hostedEventID = record.hostedEventID
            self.createsHostedEvent = false
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
            self.createsHostedEvent = !hostedEventTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }
}
