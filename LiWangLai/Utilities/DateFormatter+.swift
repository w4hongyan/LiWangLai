import Foundation

extension Date {
    var lwDayText: String {
        DateFormatter.lwDay.string(from: self)
    }

    var lwMonthText: String {
        DateFormatter.lwMonth.string(from: self)
    }

    var lwCompactMonthText: String {
        DateFormatter.lwCompactMonth.string(from: self)
    }
}

extension DateFormatter {
    static let lwDay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy年M月d日"
        return formatter
    }()

    static let lwMonth: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy年M月"
        return formatter
    }()

    static let lwCompactMonth: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy年M月"
        return formatter
    }()
}
