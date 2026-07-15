import Foundation
import Testing
@testable import LiWangLai

struct HostedEventServiceTests {
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
}
