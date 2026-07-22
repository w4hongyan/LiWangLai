import Foundation

enum ReminderService {
    static func reminders(from records: [GiftRecord]) -> [ReminderItem] {
        records
            .filter { record in
                if record.type == .received {
                    return record.needsReturn
                }
                return record.returnReminderDate != nil
            }
            .sorted { ($0.returnReminderDate ?? $0.date) < ($1.returnReminderDate ?? $1.date) }
            .compactMap { record -> ReminderItem? in
                // filter 已保证 reminderDate 非 nil（收礼走 needsReturn，送礼直接判非 nil）
                guard let reminderDate = record.returnReminderDate else { return nil }
                let action = record.type == .received ? "回礼" : "送礼"
                let title = "\(record.personName) · \(record.eventType.title)\(action) \(record.amountFenValue.fenCurrencyText)"
                return ReminderItem(
                    id: record.id,
                    record: record,
                    kind: record.type == .received ? .returnGift : .sendGift,
                    title: title,
                    subtitle: "计划于 \(reminderDate.lwDualDateText) 前安排\(action)",
                    date: reminderDate
                )
            }
    }
}
