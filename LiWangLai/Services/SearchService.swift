import Foundation

enum SearchService {
    static func filter(_ records: [GiftRecord], query: String) -> [GiftRecord] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return records }
        return records.filter { record in
            record.personName.localizedCaseInsensitiveContains(trimmed)
            || record.eventType.title.localizedCaseInsensitiveContains(trimmed)
            || record.relationship.title.localizedCaseInsensitiveContains(trimmed)
            || record.note.localizedCaseInsensitiveContains(trimmed)
            || record.location.localizedCaseInsensitiveContains(trimmed)
            || record.giftName.localizedCaseInsensitiveContains(trimmed)
            || record.contact.localizedCaseInsensitiveContains(trimmed)
        }
    }
}

enum RecordDateRange {
    static func contains(
        _ date: Date,
        start: Date,
        end: Date,
        calendar: Calendar = .current
    ) -> Bool {
        let lowerInput = min(start, end)
        let upperInput = max(start, end)
        let lowerBound = calendar.startOfDay(for: lowerInput)
        let upperDay = calendar.startOfDay(for: upperInput)
        guard let upperBound = calendar.date(byAdding: .day, value: 1, to: upperDay) else {
            return false
        }
        return (lowerBound..<upperBound).contains(date)
    }
}
