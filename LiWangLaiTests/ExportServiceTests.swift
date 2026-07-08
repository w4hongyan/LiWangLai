import Testing
import Foundation
@testable import LiWangLai

struct ExportServiceTests {

    @Test func emptyRecordsThrowsError() {
        do {
            _ = try ExportService.writeExcel(from: [])
            #expect(false, "Expected error for empty records")
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
    }

    @Test func excelStringContainsRecordData() {
        let record = GiftRecord(
            personName: "张三",
            type: .received,
            amountYuan: 888,
            eventType: .wedding,
            relationship: .friend
        )
        let xml = ExportService.excelString(from: [record])
        #expect(xml.contains("张三"), "Should contain person name")
        #expect(xml.contains("888"), "Should contain amount")
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
}
