import Foundation

enum SearchService {
    /// 所有字段统一走 PersonIdentity.normalizedName 口径：
    /// 兼容全角字符、大小写与姓名中的空格（如「张 三」可被「张三」搜到）
    static func filter(_ records: [GiftRecord], query: String) -> [GiftRecord] {
        let normalizedQuery = PersonIdentity.normalizedName(query)
        guard !normalizedQuery.isEmpty else { return records }
        return records.filter { record in
            PersonIdentity.normalizedName(record.personName).contains(normalizedQuery)
            || PersonIdentity.normalizedName(record.eventType.title).contains(normalizedQuery)
            || PersonIdentity.normalizedName(record.relationship.title).contains(normalizedQuery)
            || PersonIdentity.normalizedName(record.note).contains(normalizedQuery)
            || PersonIdentity.normalizedName(record.location).contains(normalizedQuery)
            || PersonIdentity.normalizedName(record.giftName).contains(normalizedQuery)
            || PersonIdentity.normalizedName(record.contact).contains(normalizedQuery)
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
