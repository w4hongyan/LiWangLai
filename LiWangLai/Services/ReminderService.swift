import Foundation

enum ReminderService {
    static func reminders(from records: [GiftRecord]) -> [ReminderItem] {
        records
            .filter { $0.needsReturn || $0.returnReminderDate != nil }
            .sorted { ($0.returnReminderDate ?? $0.date) < ($1.returnReminderDate ?? $1.date) }
            .map { record in
                let title: String
                let subtitle: String
                if record.needsReturn {
                    title = "\(record.personName) · \(record.eventType.title)收礼 \(record.amountYuan.yuanText)"
                    subtitle = "可参考上次往来，近期安排回礼"
                } else {
                    title = "\(record.personName) · \(record.eventType.title)"
                    subtitle = record.returnReminderDate?.lwDayText ?? "自定义提醒"
                }
                return ReminderItem(
                    id: record.id,
                    record: record,
                    title: title,
                    subtitle: subtitle,
                    date: record.returnReminderDate
                )
            }
    }
}
