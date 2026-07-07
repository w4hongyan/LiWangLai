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
}
