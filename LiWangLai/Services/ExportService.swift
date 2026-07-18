import Foundation

enum ExportService {
    enum ExportError: LocalizedError {
        case emptyRecords

        var errorDescription: String? {
            switch self {
            case .emptyRecords:
                "还没有可以导出的往来记录。"
            }
        }
    }

    private static let columns = ["姓名", "类型", "金额", "事件", "关系", "公历日期", "农历日期", "备注", "地点", "礼品", "联系方式", "是否回礼", "提醒日期"]

    static func excelString(from records: [GiftRecord]) -> String {
        worksheetXML(from: records)
    }

    static func writeExcel(from records: [GiftRecord]) throws -> URL {
        guard !records.isEmpty else {
            throw ExportError.emptyRecords
        }
        let fileName = "礼往来-\(Int(Date().timeIntervalSince1970)).xlsx"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        let package = xlsxPackage(from: records)
        let archive = ZipArchive.makeArchive(files: package)
        try archive.write(to: url, options: .atomic)
        return url
    }

    private static func rowValues(for record: GiftRecord) -> [(text: String, type: String)] {
        [
            (record.personName, "String"),
            (record.type.title, "String"),
            ("\(record.amountYuan)", "Number"),
            (record.eventType.title, "String"),
            (record.relationship.title, "String"),
            (record.date.lwDayText, "String"),
            (record.date.lwLunarText, "String"),
            (record.note, "String"),
            (record.location, "String"),
            (record.giftName, "String"),
            (record.contact, "String"),
            (record.isReturned ? "是" : "否", "String"),
            (record.returnReminderDate.map { "\($0.lwDayText) \($0.lwTimeText)" } ?? "", "String")
        ]
    }

    private static func xlsxPackage(from records: [GiftRecord]) -> [(path: String, data: Data)] {
        [
            ("[Content_Types].xml", data(contentTypesXML)),
            ("_rels/.rels", data(rootRelationshipsXML)),
            ("xl/workbook.xml", data(workbookXML)),
            ("xl/_rels/workbook.xml.rels", data(workbookRelationshipsXML)),
            ("xl/styles.xml", data(stylesXML)),
            ("xl/worksheets/sheet1.xml", data(worksheetXML(from: records)))
        ]
    }

    private static func worksheetXML(from records: [GiftRecord]) -> String {
        let header = rowXML(values: columns.map { ($0, "String") }, rowIndex: 1, style: 1)
        let rows = records
            .sorted { $0.date > $1.date }
            .enumerated()
            .map { index, record in
                rowXML(values: rowValues(for: record), rowIndex: index + 2, style: nil)
            }
            .joined()

        return """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
          <sheetViews>
            <sheetView workbookViewId="0">
              <pane ySplit="1" topLeftCell="A2" activePane="bottomLeft" state="frozen"/>
            </sheetView>
          </sheetViews>
          <cols>
            <col min="1" max="1" width="14" customWidth="1"/>
            <col min="2" max="5" width="10" customWidth="1"/>
            <col min="6" max="6" width="16" customWidth="1"/>
            <col min="7" max="7" width="16" customWidth="1"/>
            <col min="8" max="13" width="18" customWidth="1"/>
          </cols>
          <sheetData>
            \(header)
            \(rows)
          </sheetData>
        </worksheet>
        """
    }

    private static func rowXML(values: [(text: String, type: String)], rowIndex: Int, style: Int?) -> String {
        let cells = values.enumerated()
            .map { columnIndex, value in
                cellXML(value.text, type: value.type, reference: cellReference(column: columnIndex + 1, row: rowIndex), style: style)
            }
            .joined()
        return "<row r=\"\(rowIndex)\">\(cells)</row>"
    }

    private static func cellXML(_ text: String, type: String, reference: String, style: Int?) -> String {
        let styleAttribute = style.map { " s=\"\($0)\"" } ?? ""
        if type == "Number" {
            return "<c r=\"\(reference)\"\(styleAttribute)><v>\(escapeXML(text))</v></c>"
        }
        return "<c r=\"\(reference)\" t=\"inlineStr\"\(styleAttribute)><is><t>\(escapeXML(text))</t></is></c>"
    }

    private static func cellReference(column: Int, row: Int) -> String {
        var column = column
        var letters = ""
        while column > 0 {
            let remainder = (column - 1) % 26
            letters.insert(Character(UnicodeScalar(65 + remainder)!), at: letters.startIndex)
            column = (column - 1) / 26
        }
        return "\(letters)\(row)"
    }

    private static func escapeXML(_ text: String) -> String {
        text
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&apos;")
    }

    private static func data(_ string: String) -> Data {
        Data(string.utf8)
    }

    private static let contentTypesXML = """
    <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
    <Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
      <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
      <Default Extension="xml" ContentType="application/xml"/>
      <Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>
      <Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>
      <Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>
    </Types>
    """

    private static let rootRelationshipsXML = """
    <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
    <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
      <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>
    </Relationships>
    """

    private static let workbookXML = """
    <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
    <workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
      <sheets>
        <sheet name="礼往来" sheetId="1" r:id="rId1"/>
      </sheets>
    </workbook>
    """

    private static let workbookRelationshipsXML = """
    <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
    <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
      <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>
      <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
    </Relationships>
    """

    private static let stylesXML = """
    <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
    <styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
      <fonts count="2">
        <font><sz val="11"/><name val="Songti SC"/></font>
        <font><b/><sz val="11"/><name val="Songti SC"/></font>
      </fonts>
      <fills count="3">
        <fill><patternFill patternType="none"/></fill>
        <fill><patternFill patternType="gray125"/></fill>
        <fill><patternFill patternType="solid"><fgColor rgb="FFF2E4C8"/><bgColor indexed="64"/></patternFill></fill>
      </fills>
      <borders count="1"><border><left/><right/><top/><bottom/><diagonal/></border></borders>
      <cellStyleXfs count="1"><xf numFmtId="0" fontId="0" fillId="0" borderId="0"/></cellStyleXfs>
      <cellXfs count="2">
        <xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/>
        <xf numFmtId="0" fontId="1" fillId="2" borderId="0" xfId="0" applyFont="1" applyFill="1"/>
      </cellXfs>
      <cellStyles count="1"><cellStyle name="Normal" xfId="0" builtinId="0"/></cellStyles>
    </styleSheet>
    """
}

private enum ZipArchive {
    static func makeArchive(files: [(path: String, data: Data)]) -> Data {
        var archive = Data()
        var centralDirectory = Data()
        var offset: UInt32 = 0

        for file in files {
            let name = Data(file.path.utf8)
            let crc = CRC32.checksum(file.data)
            let size = UInt32(file.data.count)

            var localHeader = Data()
            localHeader.appendUInt32(0x04034b50)
            localHeader.appendUInt16(20)
            localHeader.appendUInt16(0)
            localHeader.appendUInt16(0)
            localHeader.appendUInt16(0)
            localHeader.appendUInt16(0)
            localHeader.appendUInt32(crc)
            localHeader.appendUInt32(size)
            localHeader.appendUInt32(size)
            localHeader.appendUInt16(UInt16(name.count))
            localHeader.appendUInt16(0)
            localHeader.append(name)

            archive.append(localHeader)
            archive.append(file.data)

            var centralHeader = Data()
            centralHeader.appendUInt32(0x02014b50)
            centralHeader.appendUInt16(20)
            centralHeader.appendUInt16(20)
            centralHeader.appendUInt16(0)
            centralHeader.appendUInt16(0)
            centralHeader.appendUInt16(0)
            centralHeader.appendUInt16(0)
            centralHeader.appendUInt32(crc)
            centralHeader.appendUInt32(size)
            centralHeader.appendUInt32(size)
            centralHeader.appendUInt16(UInt16(name.count))
            centralHeader.appendUInt16(0)
            centralHeader.appendUInt16(0)
            centralHeader.appendUInt16(0)
            centralHeader.appendUInt16(0)
            centralHeader.appendUInt32(0)
            centralHeader.appendUInt32(offset)
            centralHeader.append(name)
            centralDirectory.append(centralHeader)

            offset += UInt32(localHeader.count) + size
        }

        let centralOffset = UInt32(archive.count)
        archive.append(centralDirectory)

        var end = Data()
        end.appendUInt32(0x06054b50)
        end.appendUInt16(0)
        end.appendUInt16(0)
        end.appendUInt16(UInt16(files.count))
        end.appendUInt16(UInt16(files.count))
        end.appendUInt32(UInt32(centralDirectory.count))
        end.appendUInt32(centralOffset)
        end.appendUInt16(0)
        archive.append(end)

        return archive
    }
}

private enum CRC32 {
    static func checksum(_ data: Data) -> UInt32 {
        var crc: UInt32 = 0xffffffff
        for byte in data {
            crc ^= UInt32(byte)
            for _ in 0..<8 {
                if crc & 1 == 1 {
                    crc = (crc >> 1) ^ 0xedb88320
                } else {
                    crc >>= 1
                }
            }
        }
        return crc ^ 0xffffffff
    }
}

private extension Data {
    mutating func appendUInt16(_ value: UInt16) {
        append(UInt8(value & 0xff))
        append(UInt8((value >> 8) & 0xff))
    }

    mutating func appendUInt32(_ value: UInt32) {
        append(UInt8(value & 0xff))
        append(UInt8((value >> 8) & 0xff))
        append(UInt8((value >> 16) & 0xff))
        append(UInt8((value >> 24) & 0xff))
    }
}
