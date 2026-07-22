import Foundation
import SwiftData
import Testing
@testable import LiWangLai

struct HostedEventServiceTests {
    @Test func defaultTitlesCoverEveryEventType() {
        let expected: [GiftEventType: String] = [
            .wedding: "我家婚礼",
            .baby: "我家满月酒",
            .housewarming: "我家乔迁",
            .birthday: "我家生日宴",
            .funeral: "我家白事",
            .school: "我家升学宴",
            .festival: "我家节礼",
            .other: "我家一场事"
        ]

        for type in GiftEventType.allCases {
            #expect(HostedEventService.defaultTitle(for: type) == expected[type])
        }
    }

    @Test func recordsUseExplicitEventID() {
        let date = Date(timeIntervalSince1970: 2_000_000)
        let firstEvent = HostedGiftEvent(title: "第一场", eventType: .wedding, date: date)
        let secondEvent = HostedGiftEvent(title: "第二场", eventType: .wedding, date: date)
        let firstRecord = GiftRecord(
            personName: "张三",
            type: .received,
            amountYuan: 600,
            eventType: .wedding,
            relationship: .friend,
            date: date,
            hostedEventID: firstEvent.id
        )
        let secondRecord = GiftRecord(
            personName: "李四",
            type: .received,
            amountYuan: 800,
            eventType: .wedding,
            relationship: .relative,
            date: date,
            hostedEventID: secondEvent.id
        )

        let result = HostedEventService.records(for: firstEvent, from: [firstRecord, secondRecord])

        #expect(result.map(\.personName) == ["张三"])
    }

    @Test func recordsWithoutEventIDAreNotGuessedAtReadTime() {
        let date = Date(timeIntervalSince1970: 2_000_000)
        let event = HostedGiftEvent(title: "婚礼", eventType: .wedding, date: date)
        let record = GiftRecord(
            personName: "未关联",
            type: .received,
            amountYuan: 600,
            eventType: .wedding,
            relationship: .friend,
            date: date
        )

        #expect(HostedEventService.records(for: event, from: [record]).isEmpty)
    }

    @Test func giftEventsOnlyUseExplicitLinksAndPreserveEventIdentity() {
        let date = Date(timeIntervalSince1970: 2_000_000)
        let firstEvent = HostedGiftEvent(title: "第一场婚礼", eventType: .wedding, date: date)
        let secondEvent = HostedGiftEvent(title: "第二场婚礼", eventType: .wedding, date: date)
        let firstRecord = GiftRecord(
            personName: "张三",
            type: .received,
            amountYuan: 600,
            eventType: .wedding,
            relationship: .friend,
            date: date,
            hostedEventID: firstEvent.id
        )
        let secondRecord = GiftRecord(
            personName: "李四",
            type: .received,
            amountYuan: 800,
            eventType: .wedding,
            relationship: .relative,
            date: date,
            hostedEventID: secondEvent.id
        )
        let unlinkedRecord = GiftRecord(
            personName: "普通往来",
            type: .received,
            amountYuan: 500,
            eventType: .wedding,
            relationship: .friend,
            date: date
        )

        let result = HostedEventService.giftEvents(
            from: [firstEvent, secondEvent],
            records: [firstRecord, secondRecord, unlinkedRecord]
        )

        #expect(result.count == 2)
        #expect(Set(result.map(\.id)).count == 2)
        #expect(Set(result.map(\.title)) == ["第一场婚礼", "第二场婚礼"])
        #expect(result.flatMap(\.records).contains(where: { $0.personName == "普通往来" }) == false)
    }

    @Test func giftEventsIgnoreMissingEventAndGivenRecords() {
        let event = HostedGiftEvent(title: "我家乔迁", eventType: .housewarming)
        let orphan = GiftRecord(
            personName: "孤立记录",
            type: .received,
            amountYuan: 600,
            eventType: .housewarming,
            relationship: .friend,
            hostedEventID: UUID()
        )
        let given = GiftRecord(
            personName: "送礼记录",
            type: .given,
            amountYuan: 800,
            eventType: .housewarming,
            relationship: .friend,
            hostedEventID: event.id
        )

        #expect(HostedEventService.giftEvents(from: [event], records: [orphan, given]).isEmpty)
    }

    @Test func giftEventsIgnoreAmbiguousDuplicateEventIDs() {
        let duplicateID = UUID()
        let firstEvent = HostedGiftEvent(id: duplicateID, title: "重复活动甲", eventType: .wedding)
        let secondEvent = HostedGiftEvent(id: duplicateID, title: "重复活动乙", eventType: .wedding)
        let record = GiftRecord(
            personName: "张三",
            type: .received,
            amountYuan: 600,
            eventType: .wedding,
            relationship: .friend,
            hostedEventID: duplicateID
        )

        let result = HostedEventService.giftEvents(
            from: [firstEvent, secondEvent],
            records: [record]
        )

        #expect(result.isEmpty)
    }

    @MainActor
    @Test func backfillLinksOnlyUnambiguousReceivedRecords() throws {
        let container = try makeContainer()
        let uniqueDate = Date(timeIntervalSince1970: 2_000_000)
        let ambiguousDate = Date(timeIntervalSince1970: 3_000_000)
        let uniqueEvent = HostedGiftEvent(title: "唯一婚礼", eventType: .wedding, date: uniqueDate)
        let ambiguousEventA = HostedGiftEvent(title: "乔迁甲", eventType: .housewarming, date: ambiguousDate)
        let ambiguousEventB = HostedGiftEvent(title: "乔迁乙", eventType: .housewarming, date: ambiguousDate)
        let uniqueRecord = GiftRecord(
            personName: "应关联",
            type: .received,
            amountYuan: 600,
            eventType: .wedding,
            relationship: .friend,
            date: uniqueDate
        )
        let ambiguousRecord = GiftRecord(
            personName: "不应猜测",
            type: .received,
            amountYuan: 800,
            eventType: .housewarming,
            relationship: .relative,
            date: ambiguousDate
        )
        let givenRecord = GiftRecord(
            personName: "送礼不关联",
            type: .given,
            amountYuan: 500,
            eventType: .wedding,
            relationship: .friend,
            date: uniqueDate
        )
        [uniqueEvent, ambiguousEventA, ambiguousEventB].forEach(container.mainContext.insert)
        [uniqueRecord, ambiguousRecord, givenRecord].forEach(container.mainContext.insert)
        try container.mainContext.save()

        let changed = try HostedEventService.backfillUnambiguousLinks(
            events: [uniqueEvent, ambiguousEventA, ambiguousEventB],
            records: [uniqueRecord, ambiguousRecord, givenRecord],
            in: container.mainContext
        )

        #expect(changed == 1)
        #expect(uniqueRecord.hostedEventID == uniqueEvent.id)
        #expect(ambiguousRecord.hostedEventID == nil)
        #expect(givenRecord.hostedEventID == nil)
    }

    @MainActor
    @Test func backfillWithoutChangesDoesNotSaveOrMutate() throws {
        let container = try makeContainer()
        let event = HostedGiftEvent(title: "婚礼", eventType: .wedding)
        let linked = GiftRecord(
            personName: "已关联",
            type: .received,
            amountYuan: 600,
            eventType: .wedding,
            relationship: .friend,
            hostedEventID: event.id
        )

        let changed = try HostedEventService.backfillUnambiguousLinks(
            events: [event],
            records: [linked],
            in: container.mainContext
        )

        #expect(changed == 0)
        #expect(linked.hostedEventID == event.id)
    }

    @MainActor
    @Test func updateEventAlsoKeepsLinkedRecordsConsistent() throws {
        let container = try makeContainer()
        let event = HostedGiftEvent(title: "旧名称", eventType: .wedding)
        let record = GiftRecord(
            personName: "张三",
            type: .received,
            amountYuan: 600,
            eventType: .wedding,
            relationship: .friend,
            hostedEventID: event.id
        )
        let unrelated = GiftRecord(
            personName: "李四",
            type: .received,
            amountYuan: 800,
            eventType: .wedding,
            relationship: .relative
        )
        container.mainContext.insert(event)
        container.mainContext.insert(record)
        container.mainContext.insert(unrelated)
        try container.mainContext.save()
        let newDate = Date(timeIntervalSince1970: 4_000_000)

        try HostedEventService.update(
            event,
            title: "  新名称  ",
            eventType: .housewarming,
            date: newDate,
            note: "  只请亲友  ",
            linkedRecords: [record, unrelated],
            in: container.mainContext
        )

        #expect(event.title == "新名称")
        #expect(event.eventType == .housewarming)
        #expect(event.note == "只请亲友")
        #expect(record.eventType == .housewarming)
        #expect(record.date == newDate)
        #expect(unrelated.eventType == .wedding)
    }

    @MainActor
    @Test func deleteEventPreservesAndUnlinksItsRecords() throws {
        let container = try makeContainer()
        let event = HostedGiftEvent(title: "我家婚礼", eventType: .wedding)
        let record = GiftRecord(
            personName: "张三",
            type: .received,
            amountYuan: 600,
            eventType: .wedding,
            relationship: .friend,
            hostedEventID: event.id
        )
        container.mainContext.insert(event)
        container.mainContext.insert(record)
        try container.mainContext.save()

        try HostedEventService.delete(
            event,
            linkedRecords: [record],
            in: container.mainContext
        )

        let savedEvents = try container.mainContext.fetch(FetchDescriptor<HostedGiftEvent>())
        let savedRecords = try container.mainContext.fetch(FetchDescriptor<GiftRecord>())
        #expect(savedEvents.isEmpty)
        #expect(savedRecords.map(\.personName) == ["张三"])
        #expect(savedRecords.first?.hostedEventID == nil)
    }

    @MainActor
    @Test func updateSyncsAllLinkedRecordsEvenIfPassedListIsIncomplete() throws {
        let container = try makeContainer()
        let event = HostedGiftEvent(title: "旧婚礼", eventType: .wedding)
        let recordA = GiftRecord(
            personName: "张三",
            type: .received,
            amountYuan: 600,
            eventType: .wedding,
            relationship: .friend,
            hostedEventID: event.id
        )
        let recordB = GiftRecord(
            personName: "李四",
            type: .received,
            amountYuan: 800,
            eventType: .wedding,
            relationship: .relative,
            hostedEventID: event.id
        )
        container.mainContext.insert(event)
        container.mainContext.insert(recordA)
        container.mainContext.insert(recordB)
        try container.mainContext.save()
        let newDate = Date(timeIntervalSince1970: 5_000_000)

        // 故意只传入部分关联记录，未传入的 recordB 也应被同步
        try HostedEventService.update(
            event,
            title: "新生日宴",
            eventType: .birthday,
            date: newDate,
            note: "",
            linkedRecords: [recordA],
            in: container.mainContext
        )

        #expect(recordA.eventType == .birthday)
        #expect(recordA.date == newDate)
        #expect(recordB.eventType == .birthday)
        #expect(recordB.date == newDate)
    }

    @MainActor
    @Test func deleteUnlinksAllLinkedRecordsEvenIfPassedListIsIncomplete() throws {
        let container = try makeContainer()
        let event = HostedGiftEvent(title: "我家婚礼", eventType: .wedding)
        let recordA = GiftRecord(
            personName: "张三",
            type: .received,
            amountYuan: 600,
            eventType: .wedding,
            relationship: .friend,
            hostedEventID: event.id
        )
        let recordB = GiftRecord(
            personName: "李四",
            type: .received,
            amountYuan: 800,
            eventType: .wedding,
            relationship: .relative,
            hostedEventID: event.id
        )
        container.mainContext.insert(event)
        container.mainContext.insert(recordA)
        container.mainContext.insert(recordB)
        try container.mainContext.save()

        // 故意只传入部分关联记录，未传入的 recordB 也应被解绑
        try HostedEventService.delete(
            event,
            linkedRecords: [recordA],
            in: container.mainContext
        )

        #expect(recordA.hostedEventID == nil)
        #expect(recordB.hostedEventID == nil)
        let savedEvents = try container.mainContext.fetch(FetchDescriptor<HostedGiftEvent>())
        #expect(savedEvents.isEmpty)
    }

    @Test func givenTotalForGuestsMatchesNormalizedNamesAndExcludesHostedEvent() {
        let eventID = UUID()
        let received = GiftRecord(
            personName: "张 三",
            type: .received,
            amountYuan: 600,
            eventType: .wedding,
            relationship: .friend,
            hostedEventID: eventID
        )
        let historicalGiven = GiftRecord(
            personName: "张三",
            type: .given,
            amountYuan: 500,
            eventType: .baby,
            relationship: .friend
        )
        let givenInsideEvent = GiftRecord(
            personName: "张三",
            type: .given,
            amountYuan: 900,
            eventType: .wedding,
            relationship: .friend,
            hostedEventID: eventID
        )
        let strangerGiven = GiftRecord(
            personName: "李四",
            type: .given,
            amountYuan: 700,
            eventType: .baby,
            relationship: .friend
        )

        let total = HostedEventService.givenTotalForGuests(
            of: [received],
            excludingHostedEventID: eventID,
            in: [received, historicalGiven, givenInsideEvent, strangerGiven]
        )

        // 规范化姓名命中「张 三」；归属本场的送礼记录被排除；无关宾客不计入
        #expect(total == 500)
    }

    @Test func givenTotalForGuestsIsZeroWithoutGuests() {
        let given = GiftRecord(
            personName: "张三",
            type: .given,
            amountYuan: 500,
            eventType: .baby,
            relationship: .friend
        )

        #expect(HostedEventService.givenTotalForGuests(of: [], excludingHostedEventID: nil, in: [given]) == 0)
    }

    @MainActor
    private func makeContainer() throws -> ModelContainer {
        let schema = Schema([HostedGiftEvent.self, GiftRecord.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}
