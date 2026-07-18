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

    private func date(_ year: Int, _ month: Int, _ day: Int, hour: Int = 12) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
    }
}
