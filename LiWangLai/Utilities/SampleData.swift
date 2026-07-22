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
            let reminderDate: Date? = switch name {
            case "宋雨晴": calendar.date(byAdding: .day, value: 14, to: now)
            case "赵秀兰": calendar.date(byAdding: .day, value: 7, to: now)
            case "陈美玲": calendar.date(byAdding: .day, value: 21, to: now)
            case "吴俊杰": calendar.date(byAdding: .day, value: 5, to: now)
            default: nil
            }
            let record = GiftRecord(
                personName: name,
                type: type,
                amountYuan: amount,
                eventType: event,
                relationship: relationship,
                date: date,
                note: note,
                isReturned: type == .given,
                returnReminderDate: reminderDate
            )
            modelContext.insert(record)
        }

        try? modelContext.save()
    }

#if DEBUG
    @MainActor
    static func seedIPadPreviewIfRequested(modelContext: ModelContext) {
        guard ProcessInfo.processInfo.arguments.contains("-liwanglaiSeedIPadPreview") else { return }
        let descriptor = FetchDescriptor<GiftRecord>()
        guard (try? modelContext.fetchCount(descriptor)) == 0 else { return }

        let event = HostedGiftEvent(
            title: "张晓明婚礼",
            eventType: .wedding,
            date: .now,
            note: "iPad 横屏礼台模式演示数据"
        )
        modelContext.insert(event)

        let guests: [(String, Int, RelationshipType, String)] = [
            ("王建国", 1200, .relative, "二舅家，现场祝福"),
            ("李美玲", 600, .colleague, "新娘同事"),
            ("张志强", 800, .friend, "新郎好友"),
            ("陈小雨", 500, .classmate, "高中同学"),
            ("刘伟", 1000, .relative, "表哥"),
            ("赵敏", 300, .colleague, "公司同事"),
            ("孙浩", 1600, .friend, "多年好友"),
            ("周婷", 500, .neighbor, "邻居"),
            ("吴磊", 200, .classmate, "大学同学"),
            ("郑凯", 800, .client, "合作伙伴")
        ]

        for (index, guest) in guests.enumerated() {
            let createdAt = Calendar.current.date(byAdding: .minute, value: -index, to: .now) ?? .now
            modelContext.insert(GiftRecord(
                personName: guest.0,
                type: .received,
                amountYuan: guest.1,
                eventType: .wedding,
                relationship: guest.2,
                date: .now,
                note: guest.3,
                createdAt: createdAt,
                updatedAt: createdAt,
                hostedEventID: event.id
            ))
        }

        let calendar = Calendar.current
        let history: [(String, GiftRecordType, Int, GiftEventType, RelationshipType, Int)] = [
            ("张晓明", .received, 1200, .wedding, .friend, -18),
            ("李建国", .received, 800, .wedding, .colleague, -24),
            ("王丽丽", .received, 600, .wedding, .relative, -30),
            ("陈志强", .given, 1000, .wedding, .friend, -42),
            ("刘芳", .received, 300, .birthday, .classmate, -50),
            ("赵敏", .received, 500, .wedding, .colleague, -78),
            ("孙浩", .received, 1600, .wedding, .friend, -81),
            ("周婷", .given, 500, .funeral, .neighbor, -96),
            ("吴磊", .received, 200, .birthday, .classmate, -115),
            ("郑凯", .received, 800, .wedding, .client, -119),
            ("张晓明", .given, 800, .baby, .friend, -380),
            ("张晓明", .received, 300, .birthday, .friend, -930)
        ]

        for item in history {
            let date = calendar.date(byAdding: .day, value: item.5, to: .now) ?? .now
            modelContext.insert(GiftRecord(
                personName: item.0,
                type: item.1,
                amountYuan: item.2,
                eventType: item.3,
                relationship: item.4,
                date: date,
                note: "往来记录",
                createdAt: date,
                updatedAt: date
            ))
        }

        try? modelContext.save()
    }
#endif
}
