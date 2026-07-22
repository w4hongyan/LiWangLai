import Testing
import Foundation
@testable import LiWangLai

struct ExportServiceTests {

    @Test func emptyRecordsThrowsError() {
        do {
            _ = try ExportService.writeExcel(from: [])
            Issue.record("Expected error for empty records")
        } catch {
            #expect((error as? ExportService.ExportError) == ExportService.ExportError.emptyRecords)
        }
    }

    @Test func excelStringContainsHeaderRow() {
        let record = GiftRecord(
            personName: "测试",
            type: .received,
            amountYuan: 600,
            eventType: .wedding,
            relationship: .friend
        )
        let xml = ExportService.excelString(from: [record])
        #expect(xml.contains("姓名"), "Should contain column header 姓名")
        #expect(xml.contains("金额"), "Should contain column header 金额")
        #expect(xml.contains("公历日期"))
        #expect(xml.contains("农历日期"))
    }

    @Test func excelStringContainsRecordData() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let date = calendar.date(from: DateComponents(year: 2026, month: 7, day: 17))!
        let record = GiftRecord(
            personName: "张三",
            type: .received,
            amountYuan: 888,
            eventType: .wedding,
            relationship: .friend,
            date: date
        )
        let xml = ExportService.excelString(from: [record])
        #expect(xml.contains("张三"), "Should contain person name")
        #expect(xml.contains("888"), "Should contain amount")
        #expect(xml.contains("农历六月初四"))
    }

    @Test func writeExcelReturnsURL() throws {
        let record = GiftRecord(
            personName: "张三",
            type: .received,
            amountYuan: 600,
            eventType: .wedding,
            relationship: .friend
        )
        let url = try ExportService.writeExcel(from: [record])
        #expect(url.pathExtension == "xlsx", "Should generate xlsx file")
        #expect(url.lastPathComponent.contains("礼往来"), "Filename should contain app name")
    }

    @Test func xmlEscapesSpecialCharacters() {
        let record = GiftRecord(
            personName: "张<三>",
            type: .received,
            amountYuan: 600,
            eventType: .wedding,
            relationship: .friend,
            note: "礼物&红包"
        )
        let xml = ExportService.excelString(from: [record])
        #expect(!xml.contains("<三>"), "Should escape angle brackets")
        #expect(!xml.contains("&红包"), "Should escape ampersand")
    }

    @Test func multipleRecordsGenerateMultipleRows() {
        let r1 = GiftRecord(personName: "张三", type: .received, amountYuan: 600, eventType: .wedding, relationship: .friend)
        let r2 = GiftRecord(personName: "李四", type: .given, amountYuan: 800, eventType: .baby, relationship: .relative)
        let xml = ExportService.excelString(from: [r1, r2])
        #expect(xml.contains("张三"), "Should contain first person")
        #expect(xml.contains("李四"), "Should contain second person")
    }

    @Test func recordsSortedByDateDescending() {
        let older = GiftRecord(personName: "早的人", type: .received, amountYuan: 600, eventType: .wedding, relationship: .friend, date: Date(timeIntervalSince1970: 1_000_000))
        let newer = GiftRecord(personName: "晚的人", type: .received, amountYuan: 800, eventType: .baby, relationship: .relative, date: Date(timeIntervalSince1970: 3_000_000))
        let xml = ExportService.excelString(from: [older, newer])
        let earlyIndex = xml.range(of: "早的人")!.lowerBound
        let lateIndex = xml.range(of: "晚的人")!.lowerBound
        #expect(lateIndex < earlyIndex, "Newer record should appear first (sorted by date descending)")
    }

    @Test func excelStringIncludesHostedEventColumn() {
        let event = HostedGiftEvent(title: "我家婚礼", eventType: .wedding)
        let linked = GiftRecord(
            personName: "张三",
            type: .received,
            amountYuan: 600,
            eventType: .wedding,
            relationship: .friend,
            hostedEventID: event.id
        )
        let xml = ExportService.excelString(from: [linked], events: [event])
        #expect(xml.contains("场次"), "Should contain column header 场次")
        #expect(xml.contains("我家婚礼"), "Should contain hosted event title")
    }

    @Test func excelStringLeavesHostedEventEmptyWhenUnlinkedOrUnknown() {
        let unlinked = GiftRecord(personName: "张三", type: .received, amountYuan: 600, eventType: .wedding, relationship: .friend)
        let unknown = GiftRecord(
            personName: "李四",
            type: .given,
            amountYuan: 800,
            eventType: .baby,
            relationship: .relative,
            hostedEventID: UUID()
        )
        let other = HostedGiftEvent(title: "别家满月", eventType: .baby)
        let xml = ExportService.excelString(from: [unlinked, unknown], events: [other])
        #expect(xml.contains("场次"), "Should contain column header 场次")
        #expect(!xml.contains("别家满月"), "Records not belonging to the event should leave 场次 empty")
    }

    @Test func yuanTextUsesGroupedWholeYuanFormat() {
        let text = 1_234_567.yuanText
        #expect(text.contains("¥"))
        #expect(text.contains("1,234,567"))
        #expect(!text.contains(".00"))
    }
}
