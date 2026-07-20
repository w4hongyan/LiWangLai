import Testing
import Foundation
import SwiftData
@testable import LiWangLai

@Suite(.serialized)
struct RecordServiceTests {
    @Test func peopleGroupsByName() {
        let records = [
            GiftRecord(personName: "张三", type: .received, amountYuan: 600, eventType: .wedding, relationship: .friend, date: Date(timeIntervalSince1970: 3_000_000)),
            GiftRecord(personName: "张三", type: .given, amountYuan: 800, eventType: .baby, relationship: .friend, date: Date(timeIntervalSince1970: 2_000_000)),
            GiftRecord(personName: "李四", type: .received, amountYuan: 1000, eventType: .housewarming, relationship: .friend, date: Date(timeIntervalSince1970: 1_000_000))
        ]
        let people = RecordService.people(from: records)
        #expect(people.count == 2)
    }

    @Test func peopleSortsByLatestRecordDate() {
        let recent = GiftRecord(personName: "张三", type: .received, amountYuan: 600, eventType: .wedding, relationship: .friend, date: Date(timeIntervalSince1970: 3_000_000))
        let older = GiftRecord(personName: "李四", type: .given, amountYuan: 800, eventType: .baby, relationship: .relative, date: Date(timeIntervalSince1970: 1_000_000))
        let people = RecordService.people(from: [older, recent])
        #expect(people.count == 2)
        #expect(people.first?.name == "张三")
        #expect(people.last?.name == "李四")
    }

    @Test func peopleComputesCorrectTotals() {
        let records = [
            GiftRecord(personName: "张三", type: .received, amountYuan: 600, eventType: .wedding, relationship: .friend, date: Date(timeIntervalSince1970: 3_000_000)),
            GiftRecord(personName: "张三", type: .received, amountYuan: 200, eventType: .baby, relationship: .friend, date: Date(timeIntervalSince1970: 2_000_000)),
            GiftRecord(personName: "张三", type: .given, amountYuan: 800, eventType: .housewarming, relationship: .friend, date: Date(timeIntervalSince1970: 1_000_000))
        ]
        let people = RecordService.people(from: records)
        #expect(people.count == 1)
        #expect(people.first?.totalReceived == 800)
        #expect(people.first?.totalGiven == 800)
        #expect(people.first?.netAmount == 0)
    }

    @Test func peoplePendingReturnCount() {
        let records = [
            GiftRecord(personName: "张三", type: .received, amountYuan: 600, eventType: .wedding, relationship: .friend, isReturned: false),
            GiftRecord(personName: "张三", type: .received, amountYuan: 200, eventType: .baby, relationship: .friend, isReturned: true),
            GiftRecord(personName: "张三", type: .given, amountYuan: 800, eventType: .housewarming, relationship: .friend)
        ]
        let people = RecordService.people(from: records)
        #expect(people.first?.pendingReturnCount == 1)
    }

    @Test func peopleUsesMostRecentRecordForRelationship() {
        let records = [
            GiftRecord(personName: "张三", type: .received, amountYuan: 600, eventType: .wedding, relationship: .friend, date: Date(timeIntervalSince1970: 1_000_000)),
            GiftRecord(personName: "张三", type: .given, amountYuan: 800, eventType: .baby, relationship: .relative, date: Date(timeIntervalSince1970: 3_000_000))
        ]
        let people = RecordService.people(from: records)
        #expect(people.first?.relationship == .relative)
    }

    @Test func emptyRecordsReturnsEmpty() {
        let people = RecordService.people(from: [])
        #expect(people.isEmpty)
    }

    @Test func statusTextReflectsPendingReturn() {
        let records = [
            GiftRecord(personName: "张三", type: .received, amountYuan: 600, eventType: .wedding, relationship: .friend, isReturned: false)
        ]
        let people = RecordService.people(from: records)
        #expect(people.first?.statusText == "记得回礼")
    }

    @Test func statusTextReflectsBalance() {
        let records = [
            GiftRecord(personName: "张三", type: .received, amountYuan: 600, eventType: .wedding, relationship: .friend, isReturned: true),
            GiftRecord(personName: "张三", type: .given, amountYuan: 600, eventType: .baby, relationship: .friend)
        ]
        let people = RecordService.people(from: records)
        #expect(people.first?.statusText == "往来平衡")
    }

    @Test func balanceThresholdConstantIsPositive() {
        #expect(PersonSummary.balanceThreshold > 0)
    }

    @MainActor
    @Test func insertPersistsAndTrimsUserInput() throws {
        let container = try makeContainer()
        var draft = GiftRecordDraft()
        draft.personName = "  张三  "
        draft.amountText = "800"
        draft.location = "  锦江礼堂  "
        draft.giftName = "  茶具  "
        draft.contact = "  13800138000  "

        let record = try RecordService.insert(draft, in: container.mainContext)
        let records = try container.mainContext.fetch(FetchDescriptor<GiftRecord>())

        #expect(records.count == 1)
        #expect(record.personName == "张三")
        #expect(record.location == "锦江礼堂")
        #expect(record.giftName == "茶具")
        #expect(record.contact == "13800138000")
    }

    @MainActor
    @Test func receivedRecordAutomaticallyCreatesAndLinksHostedEvent() throws {
        let container = try makeContainer()
        let date = Date(timeIntervalSince1970: 2_000_000)
        var draft = GiftRecordDraft(personName: "自动建场", type: .received, eventType: .wedding, date: date)
        draft.amountText = "800"

        let record = try RecordService.insert(draft, in: container.mainContext)
        let events = try container.mainContext.fetch(FetchDescriptor<HostedGiftEvent>())

        #expect(events.count == 1)
        #expect(events.first?.title == "我家婚礼")
        #expect(events.first?.eventType == .wedding)
        #expect(events.first?.date == date)
        #expect(record.hostedEventID == events.first?.id)
    }

    @MainActor
    @Test func receivedRecordCanSelectExistingHostedEvent() throws {
        let container = try makeContainer()
        let eventDate = Date(timeIntervalSince1970: 3_000_000)
        let event = HostedGiftEvent(title: "已建乔迁宴", eventType: .housewarming, date: eventDate)
        container.mainContext.insert(event)
        try container.mainContext.save()

        var draft = GiftRecordDraft(personName: "选择已有场", type: .received, eventType: .baby)
        draft.amountText = "1000"
        draft.hostedEventID = event.id

        let record = try RecordService.insert(draft, in: container.mainContext)
        let events = try container.mainContext.fetch(FetchDescriptor<HostedGiftEvent>())

        #expect(events.count == 1)
        #expect(record.hostedEventID == event.id)
        #expect(record.eventType == .housewarming)
        #expect(record.date == eventDate)
    }

    @MainActor
    @Test func receivedRecordCanRenameAutomaticallyCreatedHostedEvent() throws {
        let container = try makeContainer()
        var draft = GiftRecordDraft(personName: "自定义场次", type: .received, eventType: .birthday)
        draft.amountText = "600"
        draft.hostedEventTitle = "  爸爸六十大寿  "

        let record = try RecordService.insert(draft, in: container.mainContext)
        let events = try container.mainContext.fetch(FetchDescriptor<HostedGiftEvent>())

        #expect(events.count == 1)
        #expect(events.first?.title == "爸爸六十大寿")
        #expect(record.hostedEventID == events.first?.id)
    }

    @MainActor
    @Test func givenRecordNeverCreatesOrKeepsHostedEventLink() throws {
        let container = try makeContainer()
        var draft = GiftRecordDraft(personName: "送礼用户", type: .given)
        draft.amountText = "600"
        draft.hostedEventID = UUID()

        let record = try RecordService.insert(draft, in: container.mainContext)

        #expect(record.hostedEventID == nil)
        #expect(try container.mainContext.fetch(FetchDescriptor<HostedGiftEvent>()).isEmpty)
    }

    @MainActor
    @Test func invalidDraftIsRejected() throws {
        let container = try makeContainer()
        var draft = GiftRecordDraft()
        draft.personName = "   "

        #expect(throws: RecordService.RecordError.invalidDraft) {
            try RecordService.insert(draft, in: container.mainContext)
        }
        #expect(try container.mainContext.fetch(FetchDescriptor<GiftRecord>()).isEmpty)
        #expect(try container.mainContext.fetch(FetchDescriptor<HostedGiftEvent>()).isEmpty)
    }

    @MainActor
    @Test func updatePersistsChangesAndKeepsGivenReminder() throws {
        let container = try makeContainer()
        let record = GiftRecord(
            personName: "旧姓名",
            type: .received,
            amountYuan: 600,
            eventType: .wedding,
            relationship: .friend,
            returnReminderDate: .now
        )
        container.mainContext.insert(record)
        try container.mainContext.save()

        var draft = GiftRecordDraft(record: record)
        draft.personName = "新姓名"
        draft.type = .given
        draft.amountText = "1000"
        draft.isReturned = true
        try RecordService.update(record, with: draft, in: container.mainContext)

        #expect(record.personName == "新姓名")
        #expect(record.amountYuan == 1000)
        #expect(record.type == .given)
        #expect(record.isReturned == false)
        #expect(record.returnReminderDate != nil)
        #expect(record.hostedEventID == nil)
    }

    @MainActor
    @Test func deleteRemovesPersistedRecord() throws {
        let container = try makeContainer()
        let record = GiftRecord(
            personName: "待删除",
            type: .given,
            amountYuan: 200,
            eventType: .festival,
            relationship: .other
        )
        container.mainContext.insert(record)
        try container.mainContext.save()

        try RecordService.delete(record, in: container.mainContext)

        #expect(try container.mainContext.fetch(FetchDescriptor<GiftRecord>()).isEmpty)
    }

    @MainActor
    @Test func insertingReturnGiftClearsOriginalReminderInSameOperation() throws {
        let container = try makeContainer()
        let original = GiftRecord(
            personName: "张三",
            type: .received,
            amountYuan: 600,
            eventType: .wedding,
            relationship: .friend,
            returnReminderDate: .now
        )
        container.mainContext.insert(original)
        try container.mainContext.save()

        var draft = GiftRecordDraft(personName: "张三", type: .given)
        draft.amountText = "800"
        let returnedGift = try RecordService.insert(
            draft,
            returning: original,
            in: container.mainContext
        )

        #expect(returnedGift.type == .given)
        #expect(original.isReturned)
        #expect(original.returnReminderDate == nil)
        #expect(ReminderService.reminders(from: [original]).isEmpty)
    }

    @MainActor
    @Test func givenRecordCannotBeMarkedReturned() throws {
        let container = try makeContainer()
        let record = GiftRecord(
            personName: "李四",
            type: .given,
            amountYuan: 800,
            eventType: .baby,
            relationship: .relative
        )
        container.mainContext.insert(record)
        try container.mainContext.save()

        #expect(throws: RecordService.RecordError.notReturnable) {
            try RecordService.markReturned(record, in: container.mainContext)
        }
        #expect(record.isReturned == false)
    }

    @MainActor
    @Test func returningOperationRejectsReceivedDraft() throws {
        let container = try makeContainer()
        let original = GiftRecord(
            personName: "王五",
            type: .received,
            amountYuan: 500,
            eventType: .wedding,
            relationship: .friend
        )
        container.mainContext.insert(original)
        try container.mainContext.save()

        var draft = GiftRecordDraft(personName: "王五", type: .received)
        draft.amountText = "600"

        #expect(throws: RecordService.RecordError.invalidReturnGift) {
            try RecordService.insert(draft, returning: original, in: container.mainContext)
        }
        #expect(original.isReturned == false)
    }

    @MainActor
    @Test func returningOperationRejectsCompletedOriginalWithoutInserting() throws {
        let container = try makeContainer()
        let original = GiftRecord(
            personName: "已回礼用户",
            type: .received,
            amountYuan: 500,
            eventType: .wedding,
            relationship: .friend,
            isReturned: true
        )
        container.mainContext.insert(original)
        try container.mainContext.save()

        var draft = GiftRecordDraft(personName: original.personName, type: .given)
        draft.amountText = "600"

        #expect(throws: RecordService.RecordError.notReturnable) {
            try RecordService.insert(draft, returning: original, in: container.mainContext)
        }
        #expect(try container.mainContext.fetch(FetchDescriptor<GiftRecord>()).count == 1)
    }

    @MainActor
    @Test func invalidUpdateLeavesPersistedRecordUntouched() throws {
        let container = try makeContainer()
        let record = GiftRecord(
            personName: "原姓名",
            type: .received,
            amountYuan: 500,
            eventType: .wedding,
            relationship: .friend
        )
        container.mainContext.insert(record)
        try container.mainContext.save()

        var draft = GiftRecordDraft(record: record)
        draft.personName = "   "

        #expect(throws: RecordService.RecordError.invalidDraft) {
            try RecordService.update(record, with: draft, in: container.mainContext)
        }
        #expect(record.personName == "原姓名")
        #expect(record.amountYuan == 500)
    }

    @MainActor
    private func makeContainer() throws -> ModelContainer {
        let schema = Schema([HostedGiftEvent.self, GiftRecord.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}
