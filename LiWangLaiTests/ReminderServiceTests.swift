import Testing
import Foundation
@testable import LiWangLai

struct ReminderServiceTests {
    private let baseRecord = GiftRecord(
        personName: "张三",
        type: .received,
        amountYuan: 600,
        eventType: .wedding,
        relationship: .friend,
        date: Date(timeIntervalSince1970: 1_000_000)
    )

    @Test func receivedUnreturnedRecordAppearsInReminders() {
        let record = baseRecord
        let reminders = ReminderService.reminders(from: [record])
        #expect(reminders.count == 1)
        #expect(reminders.first?.record.personName == "张三")
    }

    @Test func givenRecordDoesNotAppearInReminders() {
        let record = GiftRecord(
            personName: "李四",
            type: .given,
            amountYuan: 800,
            eventType: .baby,
            relationship: .relative
        )
        let reminders = ReminderService.reminders(from: [record])
        #expect(reminders.isEmpty)
    }

    @Test func returnedRecordDoesNotAppearInReminders() {
        let record = GiftRecord(
            personName: "王五",
            type: .received,
            amountYuan: 1000,
            eventType: .housewarming,
            relationship: .classmate,
            isReturned: true
        )
        let reminders = ReminderService.reminders(from: [record])
        #expect(reminders.isEmpty)
    }

    @Test func recordWithReturnReminderDateAppears() {
        let record = GiftRecord(
            personName: "赵六",
            type: .received,
            amountYuan: 500,
            eventType: .birthday,
            relationship: .friend,
            returnReminderDate: Date(timeIntervalSince1970: 2_000_000)
        )
        let reminders = ReminderService.reminders(from: [record])
        #expect(reminders.count == 1)
        #expect(reminders.first?.isDateReminder == true)
    }

    @Test func multipleRemindersAreSortedByDate() {
        let early = GiftRecord(
            personName: "早的人",
            type: .received,
            amountYuan: 600,
            eventType: .wedding,
            relationship: .friend,
            date: Date(timeIntervalSince1970: 1_000_000)
        )
        let late = GiftRecord(
            personName: "晚的人",
            type: .received,
            amountYuan: 800,
            eventType: .baby,
            relationship: .relative,
            date: Date(timeIntervalSince1970: 3_000_000)
        )
        let reminders = ReminderService.reminders(from: [late, early])
        #expect(reminders.count == 2)
        #expect(reminders.first?.record.personName == "早的人")
        #expect(reminders.last?.record.personName == "晚的人")
    }

    @Test func emptyRecordsReturnsEmpty() {
        let reminders = ReminderService.reminders(from: [])
        #expect(reminders.isEmpty)
    }
}
