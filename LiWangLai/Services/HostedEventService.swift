import Foundation
import SwiftData

enum HostedEventService {
    static func defaultTitle(for eventType: GiftEventType) -> String {
        switch eventType {
        case .wedding: "我家婚礼"
        case .baby: "我家满月酒"
        case .housewarming: "我家乔迁"
        case .birthday: "我家生日宴"
        case .funeral: "我家白事"
        case .school: "我家升学宴"
        case .festival: "我家节礼"
        case .other: "我家一场事"
        }
    }

    @MainActor
    static func resolveEvent(
        for draft: GiftRecordDraft,
        in context: ModelContext
    ) throws -> HostedGiftEvent? {
        guard draft.type == .received else { return nil }

        if let selectedID = draft.hostedEventID {
            let events = try context.fetch(FetchDescriptor<HostedGiftEvent>())
            if let selectedEvent = events.first(where: { $0.id == selectedID }) {
                return selectedEvent
            }
        }

        let customTitle = draft.hostedEventTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard draft.createsHostedEvent || !customTitle.isEmpty else { return nil }
        let event = HostedGiftEvent(
            title: customTitle.isEmpty ? defaultTitle(for: draft.eventType) : customTitle,
            eventType: draft.eventType,
            date: draft.date
        )
        context.insert(event)
        return event
    }

    static func records(for event: HostedGiftEvent, from records: [GiftRecord]) -> [GiftRecord] {
        records.filter { record in
            record.type == .received && record.hostedEventID == event.id
        }
    }

    @MainActor
    static func update(
        _ event: HostedGiftEvent,
        title: String,
        eventType: GiftEventType,
        date: Date,
        note: String,
        linkedRecords: [GiftRecord],
        in context: ModelContext
    ) throws {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        event.title = trimmedTitle.isEmpty ? defaultTitle(for: eventType) : trimmedTitle
        event.eventType = eventType
        event.date = date
        event.note = note.trimmingCharacters(in: .whitespacesAndNewlines)
        event.updatedAt = .now

        // 内部自取全量关联记录，避免调用方传入被过滤的 linkedRecords 时漏同步
        for record in try allLinkedRecords(for: event.id, in: context) {
            record.eventType = eventType
            record.date = date
            record.updatedAt = .now
        }

        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }

    @MainActor
    static func delete(
        _ event: HostedGiftEvent,
        linkedRecords: [GiftRecord],
        in context: ModelContext
    ) throws {
        // 内部自取全量关联记录，避免调用方传入被过滤的 linkedRecords 时漏解绑
        for record in try allLinkedRecords(for: event.id, in: context) {
            record.hostedEventID = nil
            record.updatedAt = .now
        }
        context.delete(event)

        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }

    /// 按 hostedEventID 从上下文中自取全量关联收礼记录（保持 records(for:from:) 的口径）
    @MainActor
    private static func allLinkedRecords(for eventID: UUID, in context: ModelContext) throws -> [GiftRecord] {
        let descriptor = FetchDescriptor<GiftRecord>(
            predicate: #Predicate { $0.hostedEventID == eventID }
        )
        return try context.fetch(descriptor).filter { $0.type == .received }
    }

    /// 本场收礼人的历史「我方送礼」合计：按本场收礼人的规范化姓名集合，
    /// 统计 type == .given 的记录总额，并排除归属本场的记录避免自洽循环
    static func givenTotalFenForGuests(
        of eventRecords: [GiftRecord],
        excludingHostedEventID: UUID?,
        in allRecords: [GiftRecord]
    ) -> Int {
        let guestNames = Set(eventRecords.map { PersonIdentity.normalizedName($0.personName) })
        guard !guestNames.isEmpty else { return 0 }
        return allRecords
            .filter { record in
                guard record.type == .given else { return false }
                if let excludingHostedEventID, record.hostedEventID == excludingHostedEventID {
                    return false
                }
                return guestNames.contains(PersonIdentity.normalizedName(record.personName))
            }
            .reduce(0) { $0 + $1.amountFenValue }
    }

    static func givenTotalForGuests(
        of eventRecords: [GiftRecord],
        excludingHostedEventID: UUID?,
        in allRecords: [GiftRecord]
    ) -> Int {
        givenTotalFenForGuests(
            of: eventRecords,
            excludingHostedEventID: excludingHostedEventID,
            in: allRecords
        ) / 100
    }

    static func giftEvents(
        from events: [HostedGiftEvent],
        records: [GiftRecord]
    ) -> [GiftEvent] {
        let eventsByID = Dictionary(grouping: events, by: \.id)
        let linkedRecords = records.filter {
            $0.type == .received && $0.hostedEventID != nil
        }

        return Dictionary(grouping: linkedRecords, by: \GiftRecord.hostedEventID)
            .compactMap { eventID, records -> GiftEvent? in
                guard let eventID,
                      let matchingEvents = eventsByID[eventID],
                      matchingEvents.count == 1,
                      let event = matchingEvents.first else { return nil }
                let sortedRecords = records.sorted { $0.date > $1.date }
                return GiftEvent(
                    title: event.title,
                    monthKey: event.date.lwDayText,
                    eventType: event.eventType,
                    date: event.date,
                    records: sortedRecords,
                    hostedEventID: event.id,
                    hostedEvent: event
                )
            }
            .sorted { ($0.date ?? .distantPast) > ($1.date ?? .distantPast) }
    }

    @MainActor
    @discardableResult
    static func backfillUnambiguousLinks(
        events: [HostedGiftEvent],
        records: [GiftRecord],
        in context: ModelContext
    ) throws -> Int {
        var changedCount = 0
        let calendar = Calendar.current
        let eventsByKey = Dictionary(grouping: events) { event in
            EventMatchKey(
                eventTypeRawValue: event.eventTypeRawValue,
                day: calendar.startOfDay(for: event.date)
            )
        }

        for record in records where record.type == .received && record.hostedEventID == nil {
            let key = EventMatchKey(
                eventTypeRawValue: record.eventTypeRawValue,
                day: calendar.startOfDay(for: record.date)
            )
            let candidates = eventsByKey[key] ?? []
            guard candidates.count == 1, let event = candidates.first else { continue }
            record.hostedEventID = event.id
            record.updatedAt = .now
            changedCount += 1
        }

        guard changedCount > 0 else { return 0 }
        do {
            try context.save()
            return changedCount
        } catch {
            context.rollback()
            throw error
        }
    }
}

private struct EventMatchKey: Hashable {
    let eventTypeRawValue: String
    let day: Date
}
