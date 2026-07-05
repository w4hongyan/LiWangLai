import Foundation
import SwiftData

@MainActor
enum MockData {
    static let records: [GiftRecord] = [
        GiftRecord(personName: "李明", type: .received, amountYuan: 500, eventType: .baby, relationship: .colleague, date: daysAgo(2), note: "满月酒", isReturned: false),
        GiftRecord(personName: "张华", type: .given, amountYuan: 600, eventType: .housewarming, relationship: .friend, date: daysAgo(7), note: "乔迁", isReturned: true),
        GiftRecord(personName: "陈伟", type: .received, amountYuan: 800, eventType: .birthday, relationship: .friend, date: daysAgo(10), note: "生日", isReturned: false),
        GiftRecord(personName: "王强", type: .given, amountYuan: 1200, eventType: .wedding, relationship: .relative, date: daysAgo(34), note: "结婚", isReturned: true),
        GiftRecord(personName: "刘芳", type: .received, amountYuan: 600, eventType: .housewarming, relationship: .classmate, date: daysAgo(41), note: "乔迁", isReturned: false)
    ]

    static func seedIfNeeded(context: ModelContext, existingCount: Int) {
        guard existingCount == 0 else { return }
        for record in records {
            context.insert(record)
        }
        try? context.save()
    }

    private static func daysAgo(_ value: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -value, to: .now) ?? .now
    }
}
