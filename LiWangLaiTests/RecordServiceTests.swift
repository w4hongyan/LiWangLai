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

    @Test func peopleNormalizesWhitespaceAndFullWidthNames() {
        let records = [
            GiftRecord(personName: "张 三", type: .received, amountYuan: 600, eventType: .wedding, relationship: .friend),
            GiftRecord(personName: "张三", type: .given, amountYuan: 800, eventType: .baby, relationship: .friend)
        ]

        let people = RecordService.people(from: records)

        #expect(people.count == 1)
        #expect(people.first?.records.count == 2)
    }

    @Test func sameNameWithDifferentContactsStaysSeparated() {
        let records = [
            GiftRecord(personName: "张伟", type: .received, amountYuan: 600, eventType: .wedding, relationship: .friend, contact: "13800138000"),
            GiftRecord(personName: "张伟", type: .given, amountYuan: 800, eventType: .baby, relationship: .colleague, contact: "13900139000")
        ]

        let people = RecordService.people(from: records)

        #expect(people.count == 2)
        #expect(Set(people.map(\.id)).count == 2)
        #expect(people.allSatisfy { $0.identityHint != nil })
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
            GiftRecord(personName: "张三", type: .received, amountYuan: 600, eventType: .wedding, relationship: .friend, isReturned: false, returnReminderDate: .now),
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
            GiftRecord(personName: "张三", type: .received, amountYuan: 600, eventType: .wedding, relationship: .friend, isReturned: false, returnReminderDate: .now)
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
    @Test func ordinaryReceivedRecordDoesNotCreateHostedEvent() throws {
        let container = try makeContainer()
        let date = Date(timeIntervalSince1970: 2_000_000)
        var draft = GiftRecordDraft(personName: "普通收礼", type: .received, eventType: .wedding, date: date)
        draft.amountText = "800"

        let record = try RecordService.insert(draft, in: container.mainContext)
        let events = try container.mainContext.fetch(FetchDescriptor<HostedGiftEvent>())

        #expect(events.isEmpty)
        #expect(record.hostedEventID == nil)
    }

    @MainActor
    @Test func receivedRecordCreatesHostedEventOnlyWhenRequested() throws {
        let container = try makeContainer()
        var draft = GiftRecordDraft(personName: "主动建场", type: .received, eventType: .wedding)
        draft.amountText = "800"
        draft.createsHostedEvent = true

        let record = try RecordService.insert(draft, in: container.mainContext)
        let events = try container.mainContext.fetch(FetchDescriptor<HostedGiftEvent>())

        #expect(events.count == 1)
        #expect(events.first?.title == "我家婚礼")
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

    @Test func amountTextAcceptsUpToTwoDecimalPlaces() {
        var draft = GiftRecordDraft()
        draft.personName = "张三"
        draft.amountText = "100.5"

        #expect(draft.amountYuan == Decimal(string: "100.5"))
        #expect(draft.amountFen == 10_050)
        #expect(draft.isValid)
    }

    @Test func amountTextRejectsMoreThanTwoDecimalPlaces() {
        var draft = GiftRecordDraft()
        draft.personName = "张三"
        draft.amountText = "100.501"

        #expect(draft.amountFen == 0)
        #expect(!draft.isValid)
    }

    @Test func amountTextParsesThousandsSeparator() {
        var draft = GiftRecordDraft()
        draft.amountText = "1,000"

        #expect(draft.amountYuan == 1000)
    }

    @Test func amountTextOverflowIsRejected() {
        var draft = GiftRecordDraft()
        draft.personName = "张三"
        draft.amountText = "99999999999999999999999999"

        #expect(draft.amountYuan == 0)
        #expect(!draft.isValid)
    }

    @MainActor
    @Test func decimalAmountPersistsExactlyInFen() throws {
        let container = try makeContainer()
        var draft = GiftRecordDraft()
        draft.personName = "小数金额"
        draft.amountText = "100.50"

        let record = try RecordService.insert(draft, in: container.mainContext)

        #expect(record.amountFenValue == 10_050)
        #expect(MoneyAmount.inputText(fromFen: record.amountFenValue) == "100.5")
    }

    @MainActor
    @Test func changingPhoneKeepsRecordsUnderStablePersonIdentity() throws {
        let container = try makeContainer()
        var firstDraft = GiftRecordDraft()
        firstDraft.personName = "张三"
        firstDraft.contact = "13800138000"
        firstDraft.amountText = "600"
        let first = try RecordService.insert(firstDraft, in: container.mainContext)

        var secondDraft = GiftRecordDraft()
        secondDraft.personName = "张三"
        secondDraft.contact = "13800138000"
        secondDraft.amountText = "800"
        let second = try RecordService.insert(secondDraft, in: container.mainContext)
        #expect(first.personID == second.personID)

        var editDraft = GiftRecordDraft(record: second)
        editDraft.contact = "13911112222"
        try RecordService.update(second, with: editDraft, in: container.mainContext)

        #expect(RecordService.people(from: [first, second]).count == 1)
    }

    @MainActor
    @Test func backfillAssignsStablePersonIDsToLegacyGroups() throws {
        let container = try makeContainer()
        let first = GiftRecord(personName: "张 三", type: .received, amountYuan: 600, eventType: .wedding, relationship: .friend)
        let second = GiftRecord(personName: "张三", type: .given, amountYuan: 800, eventType: .baby, relationship: .friend)
        first.personID = nil
        second.personID = nil
        container.mainContext.insert(first)
        container.mainContext.insert(second)
        try container.mainContext.save()

        #expect(try RecordService.backfillPersonIDs(records: [first, second], in: container.mainContext) == 2)
        #expect(first.personID != nil)
        #expect(first.personID == second.personID)
    }

    @MainActor
    private func makeContainer() throws -> ModelContainer {
        let schema = Schema([HostedGiftEvent.self, GiftRecord.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}
