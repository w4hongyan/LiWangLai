import Foundation
import SwiftData

enum DuplicateMergeService {
    struct RecordIdentity: Hashable {
        let personName: String
        let type: GiftRecordType
        let amountFen: Int
        let eventType: GiftEventType
        let day: Date
    }

    struct DuplicateGroup: Identifiable {
        let identity: RecordIdentity
        let records: [GiftRecord]

        var id: String {
            "\(identity.personName)-\(identity.type.rawValue)-\(identity.amountFen)-\(identity.eventType.rawValue)-\(identity.day.timeIntervalSinceReferenceDate)"
        }

        var displayName: String { records.first?.personName ?? identity.personName }
        var duplicateCount: Int { max(0, records.count - 1) }
        var summary: String {
            guard let record = records.first else { return "" }
            return "\(record.date.lwDayText) · \(record.eventType.title) · \(record.type.title) \(record.amountFenValue.fenCurrencyText)"
        }
    }

    struct MergeSummary: Equatable {
        let groupCount: Int
        let removedRecordCount: Int
    }

    static func normalizedPersonName(_ name: String) -> String {
        PersonIdentity.normalizedName(name)
    }

    static func identity(
        personName: String,
        type: GiftRecordType,
        amountFen: Int,
        eventType: GiftEventType,
        date: Date,
        calendar: Calendar = .current
    ) -> RecordIdentity {
        RecordIdentity(
            personName: normalizedPersonName(personName),
            type: type,
            amountFen: amountFen,
            eventType: eventType,
            day: calendar.startOfDay(for: date)
        )
    }

    static func identity(
        personName: String,
        type: GiftRecordType,
        amountYuan: Int,
        eventType: GiftEventType,
        date: Date,
        calendar: Calendar = .current
    ) -> RecordIdentity {
        identity(
            personName: personName,
            type: type,
            amountFen: amountYuan * 100,
            eventType: eventType,
            date: date,
            calendar: calendar
        )
    }

    static func identity(for record: GiftRecord, calendar: Calendar = .current) -> RecordIdentity {
        identity(
            personName: record.personName,
            type: record.type,
            amountFen: record.amountFenValue,
            eventType: record.eventType,
            date: record.date,
            calendar: calendar
        )
    }

    static func groups(in records: [GiftRecord], calendar: Calendar = .current) -> [DuplicateGroup] {
        Dictionary(grouping: records) { identity(for: $0, calendar: calendar) }
            .compactMap { identity, groupedRecords in
                guard groupedRecords.count > 1 else { return nil }
                return DuplicateGroup(
                    identity: identity,
                    records: groupedRecords.sorted { preferredScore($0) > preferredScore($1) }
                )
            }
            .sorted {
                let lhsDate = $0.records.first?.date ?? .distantPast
                let rhsDate = $1.records.first?.date ?? .distantPast
                return lhsDate > rhsDate
            }
    }

    @MainActor
    @discardableResult
    static func merge(_ groups: [DuplicateGroup], in context: ModelContext) throws -> MergeSummary {
        var removedCount = 0

        for group in groups where group.records.count > 1 {
            let keeper = group.records[0]
            let duplicates = Array(group.records.dropFirst())
            mergeDetails(from: duplicates, into: keeper)
            duplicates.forEach(context.delete)
            removedCount += duplicates.count
        }

        do {
            try context.save()
            return MergeSummary(groupCount: groups.count, removedRecordCount: removedCount)
        } catch {
            context.rollback()
            throw error
        }
    }
}

private extension DuplicateMergeService {
    static func preferredScore(_ record: GiftRecord) -> Int {
        let filledFields = [record.note, record.location, record.giftName, record.contact]
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .count
        return filledFields * 10 + (record.hostedEventID == nil ? 0 : 3) + (record.isReturned ? 1 : 0)
    }

    static func mergeDetails(from duplicates: [GiftRecord], into keeper: GiftRecord) {
        let allRecords = [keeper] + duplicates
        keeper.personName = bestText(allRecords.map(\.personName), fallback: keeper.personName)
        keeper.note = bestText(allRecords.map(\.note), fallback: keeper.note)
        keeper.location = bestText(allRecords.map(\.location), fallback: keeper.location)
        keeper.giftName = bestText(allRecords.map(\.giftName), fallback: keeper.giftName)
        keeper.contact = bestText(allRecords.map(\.contact), fallback: keeper.contact)
        keeper.relationship = allRecords.max(by: { $0.updatedAt < $1.updatedAt })?.relationship ?? keeper.relationship
        keeper.isReturned = allRecords.contains(where: \.isReturned)
        keeper.hostedEventID = keeper.hostedEventID ?? duplicates.compactMap(\.hostedEventID).first
        keeper.createdAt = allRecords.map(\.createdAt).min() ?? keeper.createdAt
        keeper.updatedAt = .now

        if keeper.type == .received, keeper.isReturned {
            keeper.returnReminderDate = nil
        } else {
            keeper.returnReminderDate = allRecords.compactMap(\.returnReminderDate).min()
        }
    }

    static func bestText(_ values: [String], fallback: String) -> String {
        values
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .max(by: { $0.count < $1.count }) ?? fallback
    }
}
