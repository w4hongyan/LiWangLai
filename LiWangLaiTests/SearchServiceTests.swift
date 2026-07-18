import Testing
import Foundation
@testable import LiWangLai

struct SearchServiceTests {
    private let records = [
        GiftRecord(personName: "张三", type: .received, amountYuan: 600, eventType: .wedding, relationship: .friend, note: "婚宴在王府酒店"),
        GiftRecord(personName: "李四", type: .given, amountYuan: 800, eventType: .baby, relationship: .relative, note: "满月酒"),
        GiftRecord(personName: "王五", type: .received, amountYuan: 1000, eventType: .housewarming, relationship: .classmate, note: "乔迁大吉")
    ]

    @Test func emptyQueryReturnsAll() {
        let result = SearchService.filter(records, query: "")
        #expect(result.count == 3)
    }

    @Test func filterByName() {
        let result = SearchService.filter(records, query: "张三")
        #expect(result.count == 1)
        #expect(result.first?.personName == "张三")
    }

    @Test func filterByEventType() {
        let result = SearchService.filter(records, query: "婚礼")
        #expect(result.count == 1)
        #expect(result.first?.personName == "张三")
    }

    @Test func filterByRelationship() {
        let result = SearchService.filter(records, query: "亲戚")
        #expect(result.count == 1)
        #expect(result.first?.personName == "李四")
    }

    @Test func filterByNote() {
        let result = SearchService.filter(records, query: "乔迁")
        #expect(result.count == 1)
        #expect(result.first?.personName == "王五")
    }

    @Test func caseInsensitiveSearch() {
        let result = SearchService.filter(records, query: "张三")
        #expect(result.count == 1)
    }

    @Test func noMatchReturnsEmpty() {
        let result = SearchService.filter(records, query: "赵六")
        #expect(result.isEmpty)
    }

    @Test func whitespaceQueryIsTreatedAsEmpty() {
        let result = SearchService.filter(records, query: "   ")
        #expect(result.count == 3)
    }

    @Test func emptyRecordsReturnsEmpty() {
        let result = SearchService.filter([], query: "张三")
        #expect(result.isEmpty)
    }

    @Test func filterByExtendedDetails() {
        let record = GiftRecord(
            personName: "张三",
            type: .received,
            amountYuan: 600,
            eventType: .wedding,
            relationship: .friend,
            location: "锦江礼堂",
            giftName: "茶具",
            contact: "13800138000"
        )

        #expect(SearchService.filter([record], query: "锦江").count == 1)
        #expect(SearchService.filter([record], query: "茶具").count == 1)
        #expect(SearchService.filter([record], query: "1380013").count == 1)
    }

    @Test func dateRangeIncludesEntireEndDay() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let start = Date(timeIntervalSince1970: 1_725_667_200) // 2024-09-07 00:00 UTC
        let end = Date(timeIntervalSince1970: 1_725_753_600) // 2024-09-08 00:00 UTC
        let lateOnEndDay = Date(timeIntervalSince1970: 1_725_839_999) // 2024-09-08 23:59:59 UTC

        #expect(RecordDateRange.contains(lateOnEndDay, start: start, end: end, calendar: calendar))
    }

    @Test func reversedDateRangeIsNormalized() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let earlier = Date(timeIntervalSince1970: 1_725_667_200)
        let later = Date(timeIntervalSince1970: 1_725_753_600)
        let middle = Date(timeIntervalSince1970: 1_725_710_400)

        #expect(RecordDateRange.contains(middle, start: later, end: earlier, calendar: calendar))
    }

    @Test func dateRangeExcludesFollowingDay() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let day = Date(timeIntervalSince1970: 1_725_667_200)
        let nextDay = Date(timeIntervalSince1970: 1_725_753_600)

        #expect(!RecordDateRange.contains(nextDay, start: day, end: day, calendar: calendar))
    }
}
