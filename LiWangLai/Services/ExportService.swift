import Foundation

enum ExportService {
    static func csvString(from records: [GiftRecord]) -> String {
        let header = "姓名,类型,金额,事件,关系,日期,备注,是否回礼\n"
        let rows = records
            .sorted { $0.date > $1.date }
            .map { record in
                [
                    record.personName,
                    record.type.title,
                    "\(record.amountYuan)",
                    record.eventType.title,
                    record.relationship.title,
                    record.date.lwDayText,
                    record.note,
                    record.isReturned ? "是" : "否"
                ]
                .map(escape)
                .joined(separator: ",")
            }
            .joined(separator: "\n")
        return header + rows
    }

    static func writeCSV(from records: [GiftRecord]) throws -> URL {
        let fileName = "礼往来-\(Date().timeIntervalSince1970).csv"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        try csvString(from: records).write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    private static func escape(_ text: String) -> String {
        let escaped = text.replacingOccurrences(of: "\"", with: "\"\"")
        if escaped.contains(",") || escaped.contains("\n") {
            return "\"\(escaped)\""
        }
        return escaped
    }
}
