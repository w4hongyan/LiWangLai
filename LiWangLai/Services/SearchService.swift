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
        }
    }
}
