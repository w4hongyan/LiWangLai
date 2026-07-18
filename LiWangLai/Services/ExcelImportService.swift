import Compression
import Foundation
import SwiftData

enum ExcelImportService {
    enum ImportError: LocalizedError, Equatable {
        case emptyFile
        case unsupportedFile
        case invalidWorkbook
        case missingColumns([String])
        case noUsableRows

        var errorDescription: String? {
            switch self {
            case .emptyFile:
                "这个 Excel 文件没有内容。"
            case .unsupportedFile:
                "目前仅支持 .xlsx 格式，请先在 Excel 中另存为 .xlsx。"
            case .invalidWorkbook:
                "无法读取这个 Excel 文件，请确认文件没有损坏。"
            case .missingColumns(let columns):
                "Excel 缺少必要列：\(columns.joined(separator: "、"))。"
            case .noUsableRows:
                "没有找到可以导入的有效往来记录。"
            }
        }
    }

    struct Summary: Equatable {
        let totalRowCount: Int
        let importableCount: Int
        let duplicateCount: Int
        let invalidCount: Int
    }

    struct RowIssue: Identifiable, Equatable {
        let rowNumber: Int
        let message: String
        var id: Int { rowNumber }
    }

    struct PreparedImport: Identifiable {
        let id = UUID()
        let summary: Summary
        let issues: [RowIssue]
        fileprivate let rows: [ImportedRecord]
    }

    @MainActor
    static func prepare(from data: Data, existingRecords: [GiftRecord]) throws -> PreparedImport {
        guard !data.isEmpty else { throw ImportError.emptyFile }
        let entries: [String: Data]
        do {
            entries = try ZipReader.entries(from: data)
        } catch let error as ImportError {
            throw error
        } catch {
            throw ImportError.invalidWorkbook
        }
        guard let worksheet = entries
            .filter({ $0.key.hasPrefix("xl/worksheets/") && $0.key.hasSuffix(".xml") })
            .sorted(by: { $0.key < $1.key })
            .first?.value else {
            throw ImportError.invalidWorkbook
        }

        let sharedStrings: [String]
        if let sharedStringsData = entries["xl/sharedStrings.xml"] {
            sharedStrings = try SharedStringsParser.parse(sharedStringsData)
        } else {
            sharedStrings = []
        }
        let table = try WorksheetParser.parse(worksheet, sharedStrings: sharedStrings)
        return try prepare(table: table, existingRecords: existingRecords)
    }

    @MainActor
    static func prepare(table: [[String]], existingRecords: [GiftRecord]) throws -> PreparedImport {
        guard let headerRow = table.first, !headerRow.isEmpty else { throw ImportError.emptyFile }
        var headers: [String: Int] = [:]
        for (index, header) in headerRow.enumerated() where headers[header.normalizedHeader] == nil {
            headers[header.normalizedHeader] = index
        }
        let required = ["姓名", "类型", "金额", "日期"]
        let missing = required.filter { columnIndex(for: $0, in: headers) == nil }
        guard missing.isEmpty else { throw ImportError.missingColumns(missing) }

        var identities = Set(existingRecords.map { DuplicateMergeService.identity(for: $0) })
        var importable: [ImportedRecord] = []
        var issues: [RowIssue] = []
        var duplicateCount = 0
        var nonemptyRowCount = 0

        for (offset, row) in table.dropFirst().enumerated() {
            let rowNumber = offset + 2
            guard row.contains(where: { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) else { continue }
            nonemptyRowCount += 1
            do {
                let imported = try ImportedRecord(row: row, headers: headers)
                let identity = imported.identity
                if identities.contains(identity) {
                    duplicateCount += 1
                } else {
                    identities.insert(identity)
                    importable.append(imported)
                }
            } catch {
                issues.append(RowIssue(rowNumber: rowNumber, message: error.localizedDescription))
            }
        }

        guard nonemptyRowCount > 0 else { throw ImportError.noUsableRows }
        let summary = Summary(
            totalRowCount: nonemptyRowCount,
            importableCount: importable.count,
            duplicateCount: duplicateCount,
            invalidCount: issues.count
        )
        return PreparedImport(summary: summary, issues: issues, rows: importable)
    }

    @MainActor
    @discardableResult
    static func commit(_ prepared: PreparedImport, in context: ModelContext) throws -> Int {
        for row in prepared.rows {
            context.insert(row.model)
        }
        do {
            try context.save()
            return prepared.rows.count
        } catch {
            context.rollback()
            throw error
        }
    }
}

private extension ExcelImportService {
    enum RowError: LocalizedError {
        case missingName
        case invalidType
        case invalidAmount
        case invalidDate

        var errorDescription: String? {
            switch self {
            case .missingName: "姓名为空"
            case .invalidType: "收礼/送礼类型无法识别"
            case .invalidAmount: "金额不是有效的正整数"
            case .invalidDate: "日期格式无法识别"
            }
        }
    }

    struct ImportedRecord {
        let personName: String
        let type: GiftRecordType
        let amountYuan: Int
        let eventType: GiftEventType
        let relationship: RelationshipType
        let date: Date
        let note: String
        let location: String
        let giftName: String
        let contact: String
        let isReturned: Bool
        let reminderDate: Date?

        init(row: [String], headers: [String: Int]) throws {
            personName = Self.value("姓名", row: row, headers: headers).trimmingCharacters(in: .whitespacesAndNewlines)
            guard !personName.isEmpty else { throw RowError.missingName }
            guard let parsedType = Self.recordType(Self.value("类型", row: row, headers: headers)) else {
                throw RowError.invalidType
            }
            type = parsedType
            guard let parsedAmount = Self.amount(Self.value("金额", row: row, headers: headers)), parsedAmount > 0 else {
                throw RowError.invalidAmount
            }
            amountYuan = parsedAmount
            guard let parsedDate = Self.date(Self.value("日期", row: row, headers: headers)) else {
                throw RowError.invalidDate
            }
            date = parsedDate
            eventType = Self.eventType(Self.value("事件", row: row, headers: headers)) ?? .other
            relationship = Self.relationship(Self.value("关系", row: row, headers: headers)) ?? .other
            note = Self.value("备注", row: row, headers: headers).trimmed
            location = Self.value("地点", row: row, headers: headers).trimmed
            giftName = Self.value("礼品", row: row, headers: headers).trimmed
            contact = Self.value("联系方式", row: row, headers: headers).trimmed
            isReturned = type == .received && Self.bool(Self.value("是否回礼", row: row, headers: headers))
            reminderDate = isReturned ? nil : Self.date(Self.value("提醒日期", row: row, headers: headers))
        }

        var identity: DuplicateMergeService.RecordIdentity {
            DuplicateMergeService.identity(
                personName: personName,
                type: type,
                amountYuan: amountYuan,
                eventType: eventType,
                date: date
            )
        }

        var model: GiftRecord {
            GiftRecord(
                personName: personName,
                type: type,
                amountYuan: amountYuan,
                eventType: eventType,
                relationship: relationship,
                date: date,
                note: note,
                isReturned: isReturned,
                returnReminderDate: reminderDate,
                location: location,
                giftName: giftName,
                contact: contact
            )
        }

        private static func value(_ canonicalHeader: String, row: [String], headers: [String: Int]) -> String {
            guard let index = columnIndex(for: canonicalHeader, in: headers), row.indices.contains(index) else { return "" }
            return row[index]
        }

        private static func recordType(_ value: String) -> GiftRecordType? {
            let value = value.normalizedCell
            if ["收礼", "收", "收到", "received"].contains(value) { return .received }
            if ["送礼", "送", "送出", "given"].contains(value) { return .given }
            return GiftRecordType(rawValue: value)
        }

        private static func amount(_ value: String) -> Int? {
            let cleaned = value
                .replacingOccurrences(of: "¥", with: "")
                .replacingOccurrences(of: "￥", with: "")
                .replacingOccurrences(of: ",", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            guard let number = Double(cleaned), number.isFinite else { return nil }
            return Int(number.rounded())
        }

        private static func date(_ value: String) -> Date? {
            let value = value.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !value.isEmpty else { return nil }
            if let serial = Double(value), serial > 0 {
                var calendar = Calendar(identifier: .gregorian)
                calendar.timeZone = .current
                let origin = calendar.date(from: DateComponents(year: 1899, month: 12, day: 30))!
                return calendar.date(byAdding: .second, value: Int(serial * 86_400), to: origin)
            }
            let formats = ["yyyy年M月d日 HH:mm", "yyyy-M-d HH:mm", "yyyy/M/d HH:mm", "yyyy年M月d日", "yyyy-M-d", "yyyy/M/d", "yyyy.MM.dd", "M/d/yyyy"]
            for format in formats {
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "zh_Hans_CN")
                formatter.timeZone = .current
                formatter.dateFormat = format
                formatter.isLenient = false
                if let date = formatter.date(from: value) { return date }
            }
            return nil
        }

        private static func eventType(_ value: String) -> GiftEventType? {
            GiftEventType.allCases.first { $0.title == value.trimmed || $0.rawValue == value.normalizedCell }
        }

        private static func relationship(_ value: String) -> RelationshipType? {
            RelationshipType.allCases.first { $0.title == value.trimmed || $0.rawValue == value.normalizedCell }
        }

        private static func bool(_ value: String) -> Bool {
            ["是", "已回礼", "true", "1", "yes"].contains(value.normalizedCell)
        }
    }

    static func columnIndex(for canonicalHeader: String, in headers: [String: Int]) -> Int? {
        let aliases: [String: [String]] = [
            "姓名": ["姓名", "名字", "联系人", "人员"],
            "类型": ["类型", "方向", "收送", "收礼送礼"],
            "金额": ["金额", "礼金", "金额元", "礼金元"],
            "事件": ["事件", "事由", "场合"],
            "关系": ["关系", "人情关系"],
            "日期": ["日期", "公历日期", "公历", "时间"],
            "备注": ["备注", "说明"],
            "地点": ["地点", "地址"],
            "礼品": ["礼品", "礼物"],
            "联系方式": ["联系方式", "电话", "手机号", "联系"],
            "是否回礼": ["是否回礼", "已回礼", "回礼状态"],
            "提醒日期": ["提醒日期", "送礼提醒", "回礼提醒", "通知日期"]
        ]
        return aliases[canonicalHeader]?.compactMap { headers[$0.normalizedHeader] }.first
    }
}

private extension String {
    var normalizedHeader: String {
        normalizedCell
            .replacingOccurrences(of: "（", with: "")
            .replacingOccurrences(of: "）", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
    }

    var normalizedCell: String {
        trimmed.lowercased().replacingOccurrences(of: " ", with: "")
    }

    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
}

private enum ZipReader {
    enum ZipError: Error { case invalid }
    private static let maxEntrySize = 32 * 1_024 * 1_024

    static func entries(from archive: Data) throws -> [String: Data] {
        guard archive.count >= 22,
              let endOffset = findSignature(0x06054b50, in: archive, range: max(0, archive.count - 65_557)..<archive.count) else {
            throw ExcelImportService.ImportError.unsupportedFile
        }
        let entryCount = Int(try archive.uint16(at: endOffset + 10))
        var cursor = Int(try archive.uint32(at: endOffset + 16))
        guard entryCount <= 1_000 else { throw ZipError.invalid }
        var result: [String: Data] = [:]

        for _ in 0..<entryCount {
            guard try archive.uint32(at: cursor) == 0x02014b50 else { throw ZipError.invalid }
            let method = try archive.uint16(at: cursor + 10)
            let compressedSize = Int(try archive.uint32(at: cursor + 20))
            let uncompressedSize = Int(try archive.uint32(at: cursor + 24))
            let nameLength = Int(try archive.uint16(at: cursor + 28))
            let extraLength = Int(try archive.uint16(at: cursor + 30))
            let commentLength = Int(try archive.uint16(at: cursor + 32))
            let localOffset = Int(try archive.uint32(at: cursor + 42))
            guard uncompressedSize <= maxEntrySize,
                  let name = String(data: try archive.slice(cursor + 46, count: nameLength), encoding: .utf8),
                  try archive.uint32(at: localOffset) == 0x04034b50 else {
                throw ZipError.invalid
            }
            let localNameLength = Int(try archive.uint16(at: localOffset + 26))
            let localExtraLength = Int(try archive.uint16(at: localOffset + 28))
            let payloadOffset = localOffset + 30 + localNameLength + localExtraLength
            let compressed = try archive.slice(payloadOffset, count: compressedSize)
            switch method {
            case 0:
                result[name] = compressed
            case 8:
                result[name] = try inflate(compressed, expectedSize: uncompressedSize)
            default:
                throw ZipError.invalid
            }
            cursor += 46 + nameLength + extraLength + commentLength
        }
        return result
    }

    private static func inflate(_ data: Data, expectedSize: Int) throws -> Data {
        guard expectedSize >= 0 else { throw ZipError.invalid }
        if expectedSize == 0 { return Data() }
        var output = Data(count: expectedSize)
        let decoded = output.withUnsafeMutableBytes { destination in
            data.withUnsafeBytes { source in
                compression_decode_buffer(
                    destination.bindMemory(to: UInt8.self).baseAddress!,
                    expectedSize,
                    source.bindMemory(to: UInt8.self).baseAddress!,
                    data.count,
                    nil,
                    COMPRESSION_ZLIB
                )
            }
        }
        guard decoded == expectedSize else { throw ZipError.invalid }
        return output
    }

    private static func findSignature(_ signature: UInt32, in data: Data, range: Range<Int>) -> Int? {
        guard range.count >= 4 else { return nil }
        for offset in stride(from: range.upperBound - 4, through: range.lowerBound, by: -1) {
            if (try? data.uint32(at: offset)) == signature { return offset }
        }
        return nil
    }
}

private extension Data {
    func uint16(at offset: Int) throws -> UInt16 {
        guard offset >= 0, offset + 2 <= count else { throw ZipReader.ZipError.invalid }
        return UInt16(self[index(startIndex, offsetBy: offset)])
            | UInt16(self[index(startIndex, offsetBy: offset + 1)]) << 8
    }

    func uint32(at offset: Int) throws -> UInt32 {
        guard offset >= 0, offset + 4 <= count else { throw ZipReader.ZipError.invalid }
        return UInt32(self[index(startIndex, offsetBy: offset)])
            | UInt32(self[index(startIndex, offsetBy: offset + 1)]) << 8
            | UInt32(self[index(startIndex, offsetBy: offset + 2)]) << 16
            | UInt32(self[index(startIndex, offsetBy: offset + 3)]) << 24
    }

    func slice(_ offset: Int, count length: Int) throws -> Data {
        guard offset >= 0, length >= 0, offset + length <= count else { throw ZipReader.ZipError.invalid }
        return subdata(in: offset..<(offset + length))
    }
}

private final class SharedStringsParser: NSObject, XMLParserDelegate {
    private var strings: [String] = []
    private var current = ""
    private var text = ""
    private var insideItem = false

    static func parse(_ data: Data) throws -> [String] {
        let delegate = SharedStringsParser()
        let parser = XMLParser(data: data)
        parser.delegate = delegate
        guard parser.parse() else { throw ExcelImportService.ImportError.invalidWorkbook }
        return delegate.strings
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        if elementName == "si" { insideItem = true; current = "" }
        if elementName == "t" { text = "" }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) { text += string }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "t", insideItem { current += text }
        if elementName == "si" { strings.append(current); insideItem = false }
    }
}

private final class WorksheetParser: NSObject, XMLParserDelegate {
    private let sharedStrings: [String]
    private var rows: [[String]] = []
    private var currentRow: [Int: String] = [:]
    private var currentColumn = 0
    private var currentType = ""
    private var value = ""
    private var inlineText = ""
    private var textBuffer = ""
    private var activeTextElement: String?

    init(sharedStrings: [String]) { self.sharedStrings = sharedStrings }

    static func parse(_ data: Data, sharedStrings: [String]) throws -> [[String]] {
        let delegate = WorksheetParser(sharedStrings: sharedStrings)
        let parser = XMLParser(data: data)
        parser.delegate = delegate
        guard parser.parse() else { throw ExcelImportService.ImportError.invalidWorkbook }
        return delegate.rows
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        switch elementName {
        case "row": currentRow = [:]
        case "c":
            currentColumn = Self.columnIndex(from: attributeDict["r"] ?? "")
            currentType = attributeDict["t"] ?? ""
            value = ""
            inlineText = ""
        case "v", "t":
            activeTextElement = elementName
            textBuffer = ""
        default: break
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if activeTextElement != nil { textBuffer += string }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        case "v":
            value += textBuffer
            activeTextElement = nil
        case "t":
            inlineText += textBuffer
            activeTextElement = nil
        case "c":
            let resolved: String
            if currentType == "s", let index = Int(value.trimmingCharacters(in: .whitespacesAndNewlines)), sharedStrings.indices.contains(index) {
                resolved = sharedStrings[index]
            } else if currentType == "inlineStr" {
                resolved = inlineText
            } else {
                resolved = value
            }
            currentRow[currentColumn] = resolved
        case "row":
            let maxColumn = currentRow.keys.max() ?? -1
            rows.append(maxColumn < 0 ? [] : (0...maxColumn).map { currentRow[$0] ?? "" })
        default: break
        }
    }

    private static func columnIndex(from reference: String) -> Int {
        var result = 0
        for scalar in reference.uppercased().unicodeScalars where scalar.value >= 65 && scalar.value <= 90 {
            result = result * 26 + Int(scalar.value - 64)
        }
        return max(0, result - 1)
    }
}
