import Foundation
import SwiftData

enum SampleData {
    static func seedIfEmpty(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<GiftRecord>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        guard (try? modelContext.fetch(descriptor))?.isEmpty == true else { return }

        let calendar = Calendar.current
        let now = Date()
        let records: [(String, GiftRecordType, Int, GiftEventType, RelationshipType, String, Int)] = [
            ("王建国", .received, 2000, .wedding, .relative, "二舅家儿子结婚随礼", -120),
            ("李明华", .given, 600, .baby, .colleague, "送满月红包", -90),
            ("张秀英", .received, 1000, .housewarming, .friend, "乔迁新居", -60),
            ("刘志强", .given, 500, .birthday, .classmate, "老同学生日聚会", -45),
            ("陈美玲", .received, 800, .baby, .relative, "表姐生二胎满月酒", -30),
            ("周文博", .given, 300, .wedding, .colleague, "同事婚礼份子钱", -15),
            ("赵秀兰", .received, 1500, .funeral, .friend, "白事随礼", -10),
            ("吴俊杰", .given, 200, .festival, .classmate, "中秋送礼", -5),
            ("宋雨晴", .received, 600, .birthday, .colleague, "小宋生日聚餐", -2),
        ]

        for (name, type, amount, event, relationship, note, daysAgo) in records {
            let date = calendar.date(byAdding: .day, value: daysAgo, to: now) ?? now
            let record = GiftRecord(
                personName: name,
                type: type,
                amountYuan: amount,
                eventType: event,
                relationship: relationship,
                date: date,
                note: note,
                isReturned: type == .given
            )
            modelContext.insert(record)
        }

        try? modelContext.save()
    }
}
