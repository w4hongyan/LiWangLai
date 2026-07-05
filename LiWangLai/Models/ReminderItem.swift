import Foundation

struct ReminderItem: Identifiable {
    let id: UUID
    let record: GiftRecord
    let title: String
    let subtitle: String
    let date: Date?

    var isDateReminder: Bool {
        date != nil
    }
}
