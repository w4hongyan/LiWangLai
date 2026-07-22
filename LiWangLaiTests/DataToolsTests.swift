import Foundation
import SwiftData
import Testing
@testable import LiWangLai

struct DataToolsTests {
    @Test func duplicateDetectionNormalizesWhitespaceAndFullWidthNames() {
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let first = GiftRecord(
            personName: "张 三",
            type: .received,
            amountYuan: 600,
            eventType: .wedding,
            relationship: .friend,
            date: date
        )
        let second = GiftRecord(
            personName: "张三 ",
            type: .received,
            amountYuan: 600,
            eventType: .wedding,
            relationship: .friend,
            date: date.addingTimeInterval(3_600)
        )

        let groups = DuplicateMergeService.groups(in: [first, second])
        #expect(groups.count == 1)
        #expect(groups.first?.duplicateCount == 1)
    }

    @Test func duplicateDetectionDoesNotMergeDifferentBusinessFacts() {
        let first = GiftRecord(personName: "张三", type: .received, amountYuan: 600, eventType: .wedding, relationship: .friend)
        let second = GiftRecord(personName: "张三", type: .received, amountYuan: 800, eventType: .wedding, relationship: .friend)
        let third = GiftRecord(personName: "张三", type: .given, amountYuan: 600, eventType: .wedding, relationship: .friend)
        #expect(DuplicateMergeService.groups(in: [first, second, third]).isEmpty)
    }

    @MainActor
    @Test func mergePreservesRicherFieldsAndDeletesOnlyDuplicates() throws {
        let container = try makeContainer()
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let sparse = GiftRecord(personName: "王五", type: .received, amountYuan: 800, eventType: .baby, relationship: .friend, date: date)
        let rich = GiftRecord(
            personName: "王五",
            type: .received,
            amountYuan: 800,
            eventType: .baby,
            relationship: .relative,
            date: date,
            note: "孩子满月",
            location: "锦江饭店",
            contact: "13800138000"
        )
        let unrelated = GiftRecord(personName: "李四", type: .given, amountYuan: 200, eventType: .festival, relationship: .friend)
        [sparse, rich, unrelated].forEach(container.mainContext.insert)
        try container.mainContext.save()

        let groups = DuplicateMergeService.groups(in: [sparse, rich, unrelated])
        let summary = try DuplicateMergeService.merge(groups, in: container.mainContext)
        let remaining = try container.mainContext.fetch(FetchDescriptor<GiftRecord>())

        #expect(summary == .init(groupCount: 1, removedRecordCount: 1))
        #expect(remaining.count == 2)
        let merged = remaining.first { $0.personName == "王五" }
        #expect(merged?.note == "孩子满月")
        #expect(merged?.location == "锦江饭店")
        #expect(merged?.contact == "13800138000")
    }

    @MainActor
    @Test func excelTablePreviewSkipsExistingAndReportsInvalidRows() throws {
        let existing = GiftRecord(
            personName: "张三",
            type: .received,
            amountYuan: 600,
            eventType: .wedding,
            relationship: .friend,
            date: date(2026, 7, 17)
        )
        let table = [
            ["姓名", "类型", "金额", "事件", "关系", "公历日期", "备注", "提醒日期"],
            ["张三", "收礼", "600", "婚礼", "朋友", "2026年7月17日", "重复", ""],
            ["李四", "送礼", "800", "满月", "亲戚", "2026-07-18", "新记录", "2026-07-20 09:30"],
            ["无金额", "收礼", "-", "其他", "其他", "2026-07-18", "", ""]
        ]

        let prepared = try ExcelImportService.prepare(table: table, existingRecords: [existing])
        #expect(prepared.summary == .init(totalRowCount: 3, importableCount: 1, duplicateCount: 1, invalidCount: 1))
        #expect(prepared.issues.first?.rowNumber == 4)
    }

    @MainActor
    @Test func exportedWorkbookCanBeImportedAndCommitted() throws {
        let original = GiftRecord(
            personName: "赵六",
            type: .given,
            amountYuan: 1_000,
            eventType: .housewarming,
            relationship: .classmate,
            date: date(2026, 8, 1),
            note: "乔迁礼",
            returnReminderDate: date(2026, 7, 31, hour: 9)
        )
        let url = try ExportService.writeExcel(from: [original])
        let prepared = try ExcelImportService.prepare(from: Data(contentsOf: url), existingRecords: [])
        let container = try makeContainer()

        #expect(prepared.summary.importableCount == 1)
        #expect(try ExcelImportService.commit(prepared, in: container.mainContext) == 1)
        let imported = try container.mainContext.fetch(FetchDescriptor<GiftRecord>()).first
        #expect(imported?.personName == "赵六")
        #expect(imported?.amountYuan == 1_000)
        #expect(imported?.type == .given)
        #expect(imported?.returnReminderDate?.lwTimeText == original.returnReminderDate?.lwTimeText)
    }

    @MainActor
    @Test func standardDeflatedWorkbookCanBeImported() throws {
        let base64 = "UEsDBBQAAAAIAIB78VxcjIhePAEAAAADAAAYAAAAeGwvd29ya3NoZWV0cy9zaGVldDEueG1sdZLdSsMwGIZvpeR8S9eDTiTNULfegHoBpYtrsU1HEjpvQDwo/qEiyFQQRXYkMtyB2+WsrbsL0yFlQnKWfMmTN3nyoc5JHBkpYTxMqANaTRMYhPpJP6QDBxweuI0t0MFolLBjHhAiDLmdcgcEQgy3IeR+QGKPN5MhoXLlKGGxJ+SUDSAfMuL111AcQcs0bRh7IQUYrWtdT3gYsWRkMBkrq3412GkBQzggpFFIyb5gsh5yjATO32/yq3MEBUawqkD/j9jVEeXnPH/KFMSejlidXa9eHhVEV0csv7PlfKYgetp3nE7L6VxBuDqiuH8rxs//CSi91fKsWp6lC73IysWk+Mp+Pu5UCnVccTsrXxcqhVVmim3bRjDdFKW9weRBfVJPmz3O8kvV97k6wjItu2G2G622Shbc6DpYtzP+BVBLAQIUAxQAAAAIAIB78VxcjIhePAEAAAADAAAYAAAAAAAAAAAAAACAAQAAAAB4bC93b3Jrc2hlZXRzL3NoZWV0MS54bWxQSwUGAAAAAAEAAQBGAAAAcgEAAAAA"
        let data = try #require(Data(base64Encoded: base64))
        let prepared = try ExcelImportService.prepare(from: data, existingRecords: [])

        #expect(prepared.summary.importableCount == 1)
        #expect(prepared.summary.invalidCount == 0)
    }

    @Test func missingExcelColumnsAreRejected() async {
        await #expect(throws: ExcelImportService.ImportError.missingColumns(["类型", "金额", "日期"])) {
            try await MainActor.run {
                try ExcelImportService.prepare(table: [["姓名"], ["张三"]], existingRecords: [])
            }
        }
    }

    @MainActor
    @Test func excelAmountAcceptsCentsAndRejectsHugeValues() throws {
        let table = [
            ["姓名", "类型", "金额", "日期"],
            ["正常", "收礼", "600", "2026-07-18"],
            ["小数", "收礼", "100.5", "2026-07-18"],
            ["超大", "收礼", "1e19", "2026-07-18"],
            ["边界", "收礼", "9007199254740993", "2026-07-18"]
        ]

        let prepared = try ExcelImportService.prepare(table: table, existingRecords: [])
        #expect(prepared.summary == .init(totalRowCount: 4, importableCount: 2, duplicateCount: 0, invalidCount: 2))
    }

    @MainActor
    @Test func excelSerialDateOutOfRangeIsRejected() throws {
        let table = [
            ["姓名", "类型", "金额", "日期"],
            ["年份误写", "收礼", "600", "2025"],
            ["序列日", "收礼", "600", "46201"],
            ["超界序列", "收礼", "600", "90000"]
        ]

        let prepared = try ExcelImportService.prepare(table: table, existingRecords: [])
        #expect(prepared.summary == .init(totalRowCount: 3, importableCount: 1, duplicateCount: 0, invalidCount: 2))
    }

    @MainActor
    @Test func worksheetCellsWithoutReferenceUseSequentialColumns() throws {
        let worksheet = """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
          <sheetData>
            <row r="1">
              <c r="A1" t="inlineStr"><is><t>姓名</t></is></c>
              <c t="inlineStr"><is><t>类型</t></is></c>
              <c t="inlineStr"><is><t>金额</t></is></c>
              <c t="inlineStr"><is><t>日期</t></is></c>
            </row>
            <row r="2">
              <c r="A2" t="inlineStr"><is><t>张三</t></is></c>
              <c t="inlineStr"><is><t>收礼</t></is></c>
              <c><v>600</v></c>
              <c t="inlineStr"><is><t>2026-07-18</t></is></c>
            </row>
          </sheetData>
        </worksheet>
        """
        let data = makeStoredZip([("xl/worksheets/sheet1.xml", Data(worksheet.utf8))])

        let prepared = try ExcelImportService.prepare(from: data, existingRecords: [])
        #expect(prepared.summary.importableCount == 1)
        #expect(prepared.summary.invalidCount == 0)
    }

    @MainActor
    @Test func firstWorksheetFollowsWorkbookDeclarationOrder() throws {
        let workbook = """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
          <sheets>
            <sheet name="第一场" sheetId="1" r:id="rId1"/>
            <sheet name="第二场" sheetId="2" r:id="rId2"/>
          </sheets>
        </workbook>
        """
        let relationships = """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
          <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet2.xml"/>
          <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet10.xml"/>
        </Relationships>
        """
        // 字典序 sheet10 < sheet2，但用户看到的第一个工作表是 sheet2。
        let data = makeStoredZip([
            ("xl/workbook.xml", Data(workbook.utf8)),
            ("xl/_rels/workbook.xml.rels", Data(relationships.utf8)),
            ("xl/worksheets/sheet2.xml", Data(Self.singleRowWorksheetXML(personName: "第一场用户").utf8)),
            ("xl/worksheets/sheet10.xml", Data(Self.singleRowWorksheetXML(personName: "第二场用户").utf8))
        ])

        let prepared = try ExcelImportService.prepare(from: data, existingRecords: [])
        let container = try makeContainer()
        #expect(prepared.summary.importableCount == 1)
        #expect(try ExcelImportService.commit(prepared, in: container.mainContext) == 1)
        let imported = try container.mainContext.fetch(FetchDescriptor<GiftRecord>())
        #expect(imported.first?.personName == "第一场用户")
    }

    @MainActor
    @Test func sharedStringsPhoneticTextIsExcluded() throws {
        let sharedStrings = """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <sst xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" count="1" uniqueCount="1">
          <si><r><t>张三</t></r><rPh sb="0" eb="2"><t>zhangsan</t></rPh></si>
        </sst>
        """
        let worksheet = """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
          <sheetData>
            <row r="1">
              <c r="A1" t="inlineStr"><is><t>姓名</t></is></c>
              <c r="B1" t="inlineStr"><is><t>类型</t></is></c>
              <c r="C1" t="inlineStr"><is><t>金额</t></is></c>
              <c r="D1" t="inlineStr"><is><t>日期</t></is></c>
            </row>
            <row r="2">
              <c r="A2" t="s"><v>0</v></c>
              <c r="B2" t="inlineStr"><is><t>收礼</t></is></c>
              <c r="C2"><v>600</v></c>
              <c r="D2" t="inlineStr"><is><t>2026-07-18</t></is></c>
            </row>
          </sheetData>
        </worksheet>
        """
        let data = makeStoredZip([
            ("xl/sharedStrings.xml", Data(sharedStrings.utf8)),
            ("xl/worksheets/sheet1.xml", Data(worksheet.utf8))
        ])

        let prepared = try ExcelImportService.prepare(from: data, existingRecords: [])
        let container = try makeContainer()
        #expect(prepared.summary.importableCount == 1)
        #expect(try ExcelImportService.commit(prepared, in: container.mainContext) == 1)
        let imported = try container.mainContext.fetch(FetchDescriptor<GiftRecord>())
        #expect(imported.first?.personName == "张三")
    }

    @MainActor
    @Test func zipCommentContainingEOCDSignatureIsIgnored() throws {
        let worksheet = Self.singleRowWorksheetXML(personName: "张三")
        // 注释里嵌入 EOCD 签名字节，定位时必须校验注释长度字段。
        var comment = Data([0x50, 0x4B, 0x05, 0x06])
        comment.append(Data(repeating: 0x41, count: 26))
        let data = makeStoredZip([("xl/worksheets/sheet1.xml", Data(worksheet.utf8))], comment: comment)

        let prepared = try ExcelImportService.prepare(from: data, existingRecords: [])
        #expect(prepared.summary.importableCount == 1)
    }

    @MainActor
    @Test func exportImportRoundTripRestoresHostedEvent() throws {
        let event = HostedGiftEvent(title: "我家婚礼", eventType: .wedding)
        let original = GiftRecord(
            personName: "赵六",
            type: .received,
            amountYuan: 600,
            eventType: .wedding,
            relationship: .friend,
            date: date(2026, 8, 1),
            hostedEventID: event.id
        )
        let url = try ExportService.writeExcel(from: [original], events: [event])
        let prepared = try ExcelImportService.prepare(from: Data(contentsOf: url), existingRecords: [], existingEvents: [event])
        let container = try makeContainer()

        #expect(prepared.summary.importableCount == 1)
        #expect(try ExcelImportService.commit(prepared, in: container.mainContext) == 1)
        let imported = try container.mainContext.fetch(FetchDescriptor<GiftRecord>()).first
        #expect(imported?.hostedEventID == event.id)
    }

    @MainActor
    @Test func importLeavesUnknownHostedEventUnassigned() throws {
        let event = HostedGiftEvent(title: "我家婚礼", eventType: .wedding)
        let original = GiftRecord(
            personName: "赵六",
            type: .received,
            amountYuan: 600,
            eventType: .wedding,
            relationship: .friend,
            date: date(2026, 8, 1),
            hostedEventID: event.id
        )
        let url = try ExportService.writeExcel(from: [original], events: [event])
        // 不传入已有场次：场次列匹配不到，记录保留但不归属任何场次。
        let prepared = try ExcelImportService.prepare(from: Data(contentsOf: url), existingRecords: [])
        let container = try makeContainer()

        #expect(prepared.summary.importableCount == 1)
        #expect(try ExcelImportService.commit(prepared, in: container.mainContext) == 1)
        let imported = try container.mainContext.fetch(FetchDescriptor<GiftRecord>()).first
        #expect(imported?.hostedEventID == nil)
        #expect(imported?.personName == "赵六")
    }

    @Test func localNotificationPlansCoverSendAndReturnGift() {
        let now = date(2026, 7, 17, hour: 8)
        let received = GiftRecord(
            personName: "张三",
            type: .received,
            amountYuan: 600,
            eventType: .wedding,
            relationship: .friend,
            returnReminderDate: date(2026, 7, 18, hour: 9)
        )
        let given = GiftRecord(
            personName: "李四",
            type: .given,
            amountYuan: 800,
            eventType: .baby,
            relationship: .relative,
            returnReminderDate: date(2026, 7, 19, hour: 10)
        )
        let returned = GiftRecord(
            personName: "王五",
            type: .received,
            amountYuan: 1_000,
            eventType: .birthday,
            relationship: .friend,
            isReturned: true,
            returnReminderDate: date(2026, 7, 20, hour: 10)
        )

        let plans = LocalNotificationService.plans(from: [returned, given, received], now: now)
        #expect(plans.count == 2)
        #expect(plans[0].title.contains("回礼"))
        #expect(plans[1].title.contains("送礼"))
        #expect(plans.allSatisfy { $0.id.hasPrefix("liwanglai.gift-reminder.") })
    }

    @MainActor
    private func makeContainer() throws -> ModelContainer {
        let schema = Schema([HostedGiftEvent.self, GiftRecord.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [configuration])
    }

    private static func singleRowWorksheetXML(personName: String) -> String {
        """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
          <sheetData>
            <row r="1">
              <c r="A1" t="inlineStr"><is><t>姓名</t></is></c>
              <c r="B1" t="inlineStr"><is><t>类型</t></is></c>
              <c r="C1" t="inlineStr"><is><t>金额</t></is></c>
              <c r="D1" t="inlineStr"><is><t>日期</t></is></c>
            </row>
            <row r="2">
              <c r="A2" t="inlineStr"><is><t>\(personName)</t></is></c>
              <c r="B2" t="inlineStr"><is><t>收礼</t></is></c>
              <c r="C2"><v>600</v></c>
              <c r="D2" t="inlineStr"><is><t>2026-07-18</t></is></c>
            </row>
          </sheetData>
        </worksheet>
        """
    }

    private func date(_ year: Int, _ month: Int, _ day: Int, hour: Int = 12) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
    }
}

/// 构造未压缩（stored）的 zip 包，用于测试 Excel 导入的底层解析。
private func makeStoredZip(_ entries: [(path: String, data: Data)], comment: Data = Data()) -> Data {
    var archive = Data()
    var centralDirectory = Data()
    var offset: UInt32 = 0

    for entry in entries {
        let name = Data(entry.path.utf8)
        let crc = zipTestCRC32(entry.data)
        let size = UInt32(entry.data.count)

        var localHeader = Data()
        localHeader.appendZipUInt32(0x04034b50)
        localHeader.appendZipUInt16(20)
        localHeader.appendZipUInt16(0)
        localHeader.appendZipUInt16(0)
        localHeader.appendZipUInt16(0)
        localHeader.appendZipUInt16(0)
        localHeader.appendZipUInt32(crc)
        localHeader.appendZipUInt32(size)
        localHeader.appendZipUInt32(size)
        localHeader.appendZipUInt16(UInt16(name.count))
        localHeader.appendZipUInt16(0)
        localHeader.append(name)

        archive.append(localHeader)
        archive.append(entry.data)

        var centralHeader = Data()
        centralHeader.appendZipUInt32(0x02014b50)
        centralHeader.appendZipUInt16(20)
        centralHeader.appendZipUInt16(20)
        centralHeader.appendZipUInt16(0)
        centralHeader.appendZipUInt16(0)
        centralHeader.appendZipUInt16(0)
        centralHeader.appendZipUInt16(0)
        centralHeader.appendZipUInt32(crc)
        centralHeader.appendZipUInt32(size)
        centralHeader.appendZipUInt32(size)
        centralHeader.appendZipUInt16(UInt16(name.count))
        centralHeader.appendZipUInt16(0)
        centralHeader.appendZipUInt16(0)
        centralHeader.appendZipUInt16(0)
        centralHeader.appendZipUInt16(0)
        centralHeader.appendZipUInt32(0)
        centralHeader.appendZipUInt32(offset)
        centralHeader.append(name)
        centralDirectory.append(centralHeader)

        offset += UInt32(localHeader.count) + size
    }

    let centralOffset = UInt32(archive.count)
    archive.append(centralDirectory)

    var end = Data()
    end.appendZipUInt32(0x06054b50)
    end.appendZipUInt16(0)
    end.appendZipUInt16(0)
    end.appendZipUInt16(UInt16(entries.count))
    end.appendZipUInt16(UInt16(entries.count))
    end.appendZipUInt32(UInt32(centralDirectory.count))
    end.appendZipUInt32(centralOffset)
    end.appendZipUInt16(UInt16(comment.count))
    end.append(comment)
    archive.append(end)

    return archive
}

private func zipTestCRC32(_ data: Data) -> UInt32 {
    var crc: UInt32 = 0xffffffff
    for byte in data {
        crc ^= UInt32(byte)
        for _ in 0..<8 {
            crc = crc & 1 == 1 ? (crc >> 1) ^ 0xedb88320 : crc >> 1
        }
    }
    return crc ^ 0xffffffff
}

private extension Data {
    mutating func appendZipUInt16(_ value: UInt16) {
        append(UInt8(value & 0xff))
        append(UInt8((value >> 8) & 0xff))
    }

    mutating func appendZipUInt32(_ value: UInt32) {
        append(UInt8(value & 0xff))
        append(UInt8((value >> 8) & 0xff))
        append(UInt8((value >> 16) & 0xff))
        append(UInt8((value >> 24) & 0xff))
    }
}
