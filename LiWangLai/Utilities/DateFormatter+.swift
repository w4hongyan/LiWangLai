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

    var lwLunarText: String {
        LunarDateFormatter.string(from: self)
    }

    var lwDualDateText: String {
        "\(lwDayText) · \(lwLunarText)"
    }

    var lwTimeText: String {
        DateFormatter.lwTime.string(from: self)
    }

    var lwDateTimeText: String {
        "\(lwDualDateText) \(lwTimeText)"
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

    static let lwCompactMonth = lwMonth

    static let lwTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
}

enum LunarDateFormatter {
    private static let monthNames = [
        "正月", "二月", "三月", "四月", "五月", "六月",
        "七月", "八月", "九月", "十月", "冬月", "腊月"
    ]

    private static let dayNames = [
        "初一", "初二", "初三", "初四", "初五", "初六", "初七", "初八", "初九", "初十",
        "十一", "十二", "十三", "十四", "十五", "十六", "十七", "十八", "十九", "二十",
        "廿一", "廿二", "廿三", "廿四", "廿五", "廿六", "廿七", "廿八", "廿九", "三十"
    ]

    static func string(from date: Date, timeZone: TimeZone = .current) -> String {
        var calendar = Calendar(identifier: .chinese)
        calendar.locale = Locale(identifier: "zh_Hans_CN")
        calendar.timeZone = timeZone
        let components = calendar.dateComponents([.month, .day], from: date)

        guard let month = components.month,
              monthNames.indices.contains(month - 1),
              let day = components.day,
              dayNames.indices.contains(day - 1) else {
            return "农历日期未知"
        }

        let leapPrefix = components.isLeapMonth == true ? "闰" : ""
        return "农历\(leapPrefix)\(monthNames[month - 1])\(dayNames[day - 1])"
    }
}
