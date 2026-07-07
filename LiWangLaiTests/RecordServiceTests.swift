import Testing
import Foundation
@testable import LiWangLai

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
}
