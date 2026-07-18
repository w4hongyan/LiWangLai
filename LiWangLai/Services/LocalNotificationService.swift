import Foundation
import UserNotifications

enum LocalNotificationService {
    static let enabledKey = "liwanglai.giftNotificationsEnabled"
    private static let identifierPrefix = "liwanglai.gift-reminder."

    struct Plan: Equatable, Identifiable {
        let recordID: UUID
        let date: Date
        let title: String
        let body: String

        var id: String { identifierPrefix + recordID.uuidString }
    }

    static var isEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: enabledKey) }
        set { UserDefaults.standard.set(newValue, forKey: enabledKey) }
    }

    static func plans(from records: [GiftRecord], now: Date = .now) -> [Plan] {
        records.compactMap { record in
            guard let reminderDate = record.returnReminderDate,
                  reminderDate > now,
                  !(record.type == .received && record.isReturned) else { return nil }
            let action = record.type == .received ? "回礼" : "送礼"
            return Plan(
                recordID: record.id,
                date: reminderDate,
                title: "\(action)提醒 · \(record.personName)",
                body: "别忘了准备\(record.eventType.title)\(action)，心意按时送达。"
            )
        }
        .sorted { $0.date < $1.date }
    }

    @MainActor
    static func requestAndEnable(records: [GiftRecord]) async throws -> Bool {
        let center = UNUserNotificationCenter.current()
        let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
        isEnabled = granted
        if granted {
            try await reconcile(records: records)
        } else {
            await removeGiftNotifications()
        }
        return granted
    }

    @MainActor
    static func disable() async {
        isEnabled = false
        await removeGiftNotifications()
    }

    @MainActor
    static func reconcile(records: [GiftRecord], now: Date = .now) async throws {
        guard isEnabled else { return }
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else {
            isEnabled = false
            return
        }

        await removeGiftNotifications()
        for plan in plans(from: records, now: now) {
            let content = UNMutableNotificationContent()
            content.title = plan.title
            content.body = plan.body
            content.sound = .default
            content.userInfo = ["recordID": plan.recordID.uuidString]
            let components = Calendar.current.dateComponents(
                [.calendar, .timeZone, .year, .month, .day, .hour, .minute, .second],
                from: plan.date
            )
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            try await center.add(UNNotificationRequest(identifier: plan.id, content: content, trigger: trigger))
        }
    }

    @MainActor
    static func authorizationDescription() async -> String {
        let status = await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
        return switch status {
        case .notDetermined: "尚未开启"
        case .denied: "已在系统中关闭"
        case .authorized: "已开启"
        case .provisional: "静默通知已开启"
        case .ephemeral: "临时允许"
        @unknown default: "状态未知"
        }
    }

    @MainActor
    private static func removeGiftNotifications() async {
        let center = UNUserNotificationCenter.current()
        let identifiers = await center.pendingNotificationRequests()
            .map(\.identifier)
            .filter { $0.hasPrefix(identifierPrefix) }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
}
