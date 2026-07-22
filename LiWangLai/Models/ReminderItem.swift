import Foundation

enum ReminderKind: Equatable {
    case returnGift
    case sendGift
}

struct ReminderItem: Identifiable {
    let id: UUID
    let record: GiftRecord
    let kind: ReminderKind
    let title: String
    let subtitle: String
    let date: Date?

    var isDateReminder: Bool {
        date != nil
    }

    var isOverdue: Bool {
        guard let date else { return false }
        return date < Calendar.current.startOfDay(for: .now)
    }

    var overdueDayCount: Int {
        guard let date, isOverdue else { return 0 }
        let calendar = Calendar.current
        let dueDay = calendar.startOfDay(for: date)
        let today = calendar.startOfDay(for: .now)
        return max(1, calendar.dateComponents([.day], from: dueDay, to: today).day ?? 0)
    }
}
