import Foundation

enum ExportService {
    private static let columns = ["姓名", "类型", "金额", "事件", "关系", "日期", "备注", "是否回礼"]

    static func csvString(from records: [GiftRecord]) -> String {
        let header = columns.joined(separator: ",") + "\n"
        let rows = records
            .sorted { $0.date > $1.date }
            .map { record in
                rowValues(for: record).map(\.text)
                .map(escape)
                .joined(separator: ",")
            }
            .joined(separator: "\n")
        return header + rows
    }

    static func excelString(from records: [GiftRecord]) -> String {
        let headerCells = columns
            .map { spreadsheetCell($0, type: "String", styleID: "Header") }
            .joined()
        let rows = records
            .sorted { $0.date > $1.date }
            .map { record in
                let cells = rowValues(for: record)
                    .map { value in spreadsheetCell(value.text, type: value.type, styleID: nil) }
                    .joined()
                return "<Row>\(cells)</Row>"
            }
            .joined()

        return """
        <?xml version="1.0" encoding="UTF-8"?>
        <?mso-application progid="Excel.Sheet"?>
        <Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"
          xmlns:o="urn:schemas-microsoft-com:office:office"
          xmlns:x="urn:schemas-microsoft-com:office:excel"
          xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet">
          <Styles>
            <Style ss:ID="Header">
              <Font ss:Bold="1"/>
              <Interior ss:Color="#F2E4C8" ss:Pattern="Solid"/>
            </Style>
          </Styles>
          <Worksheet ss:Name="礼往来">
            <Table>
              <Row>\(headerCells)</Row>
              \(rows)
            </Table>
          </Worksheet>
        </Workbook>
        """
    }

    static func writeCSV(from records: [GiftRecord]) throws -> URL {
        let fileName = "礼往来-\(Date().timeIntervalSince1970).csv"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        try csvString(from: records).write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    static func writeExcel(from records: [GiftRecord]) throws -> URL {
        let fileName = "礼往来-\(Date().timeIntervalSince1970).xls"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        try excelString(from: records).write(to: url, atomically: true, encoding: .utf8)
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
            (record.note, "String"),
            (record.isReturned ? "是" : "否", "String")
        ]
    }

    private static func escape(_ text: String) -> String {
        let escaped = text.replacingOccurrences(of: "\"", with: "\"\"")
        if escaped.contains(",") || escaped.contains("\n") {
            return "\"\(escaped)\""
        }
        return escaped
    }

    private static func spreadsheetCell(_ text: String, type: String, styleID: String?) -> String {
        let styleAttribute = styleID.map { " ss:StyleID=\"\($0)\"" } ?? ""
        return "<Cell\(styleAttribute)><Data ss:Type=\"\(type)\">\(escapeXML(text))</Data></Cell>"
    }

    private static func escapeXML(_ text: String) -> String {
        text
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&apos;")
    }
}
