import Foundation
import SwiftData

enum HostedEventService {
    static func records(for event: HostedGiftEvent, from records: [GiftRecord]) -> [GiftRecord] {
        records.filter { record in
            record.type == .received && record.hostedEventID == event.id
        }
    }

    @MainActor
    @discardableResult
    static func backfillUnambiguousLinks(
        events: [HostedGiftEvent],
        records: [GiftRecord],
        in context: ModelContext
    ) throws -> Int {
        var changedCount = 0

        for record in records where record.type == .received && record.hostedEventID == nil {
            let candidates = events.filter { event in
                event.eventType == record.eventType
                    && Calendar.current.isDate(event.date, inSameDayAs: record.date)
            }
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
