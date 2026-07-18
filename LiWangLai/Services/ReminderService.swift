import Foundation

enum ReminderService {
    static func reminders(from records: [GiftRecord]) -> [ReminderItem] {
        records
            .filter { record in
                if record.type == .received {
                    return !record.isReturned
                }
                return record.returnReminderDate != nil
            }
            .sorted { ($0.returnReminderDate ?? $0.date) < ($1.returnReminderDate ?? $1.date) }
            .map { record in
                let action = record.type == .received ? "回礼" : "送礼"
                let title = "\(record.personName) · \(record.eventType.title)\(action) \(record.amountYuan.yuanText)"
                let subtitle: String
                if let reminderDate = record.returnReminderDate {
                    subtitle = "计划于 \(reminderDate.lwDualDateText) 前安排\(action)"
                } else {
                    subtitle = "可参考上次往来，近期安排回礼"
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
