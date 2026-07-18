import SwiftUI

private enum DateCalendarMode: String, CaseIterable, Identifiable {
    case gregorian = "公历"
    case lunar = "农历"

    var id: Self { self }
}

struct ChineseDatePickerButton: View {
    var title: String?
    var includesTime = false
    @Binding var date: Date

    @State private var showPicker = false
    @State private var draftDate = Date()
    @State private var calendarMode: DateCalendarMode = .gregorian

    var body: some View {
        Button {
            draftDate = date
            showPicker = true
            HapticsManager.lightTap()
        } label: {
            HStack(spacing: 8) {
                if let title {
                    Text(title)
                        .font(.titleSong(14))
                        .foregroundStyle(LWColors.ink)
                }
                Spacer(minLength: 8)
                VStack(alignment: .trailing, spacing: 2) {
                    Text(date.lwDayText)
                        .font(.bodySong(13))
                        .foregroundStyle(LWColors.ink)
                    Text(date.lwLunarText)
                        .font(.bodySong(10))
                        .foregroundStyle(LWColors.warmGold)
                    if includesTime {
                        Text(date.lwTimeText)
                            .font(.bodySong(10))
                            .foregroundStyle(LWColors.cinnabar)
                    }
                }
                Image(systemName: "calendar")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(LWColors.warmGold)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showPicker) {
            ChineseDatePickerSheet(
                title: title ?? "选择日期",
                date: $draftDate,
                includesTime: includesTime,
                calendarMode: $calendarMode
            ) {
                date = draftDate
                showPicker = false
            }
            .presentationDetents([.height(includesTime ? 440 : 390)])
        }
    }
}

private struct ChineseDatePickerSheet: View {
    let title: String
    @Binding var date: Date
    let includesTime: Bool
    @Binding var calendarMode: DateCalendarMode
    let onConfirm: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Text(title)
                    .font(.titleSong(18))
                    .foregroundStyle(LWColors.ink)
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(LWColors.muted)
                }
                .buttonStyle(.plain)
            }

            Picker("历法", selection: $calendarMode) {
                ForEach(DateCalendarMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .tint(LWColors.cinnabar)

            Group {
                if calendarMode == .gregorian {
                    DatePicker("", selection: $date, displayedComponents: includesTime ? [.date, .hourAndMinute] : .date)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .environment(\.locale, Locale(identifier: "zh_Hans_CN"))
                        .environment(\.calendar, Calendar(identifier: .gregorian))
                } else {
                    VStack(spacing: 0) {
                        LunarDateWheelPicker(date: $date)

                        if includesTime {
                            DatePicker("时间", selection: $date, displayedComponents: .hourAndMinute)
                                .datePickerStyle(.wheel)
                                .labelsHidden()
                                .environment(\.locale, Locale(identifier: "zh_Hans_CN"))
                                .frame(height: 90)
                                .clipped()
                        }
                    }
                }
            }
            .tint(LWColors.cinnabar)
            .frame(maxWidth: .infinity)

            if includesTime {
                Text("将在 \(date.lwDateTimeText) 提醒")
                    .font(.bodySong(11))
                    .foregroundStyle(LWColors.muted)
            }

            SealButton(title: "确定", systemImage: "checkmark", fontSize: 14, verticalPadding: 10, cornerRadius: 12) {
                onConfirm()
            }
        }
        .padding(20)
        .background(PaperTexture())
    }
}

private struct LunarDateWheelPicker: View {
    @Binding private var date: Date

    @State private var year: Int
    @State private var month: LunarMonthOption
    @State private var day: Int

    private let years = Array(1901...2099)

    init(date: Binding<Date>) {
        _date = date
        let selection = LunarCalendarData.selection(for: date.wrappedValue)
        _year = State(initialValue: selection.year)
        _month = State(initialValue: selection.month)
        _day = State(initialValue: selection.day)
    }

    var body: some View {
        let months = LunarCalendarData.months(in: year)
        let dayCount = LunarCalendarData.dayCount(in: year, month: month)

        HStack(spacing: 0) {
            Picker("农历年份", selection: $year) {
                ForEach(years, id: \.self) { value in
                    Text(verbatim: "\(value)年").tag(value)
                }
            }
            .frame(maxWidth: .infinity)

            Picker("农历月份", selection: $month) {
                ForEach(months) { value in
                    Text(value.title).tag(value)
                }
            }
            .frame(maxWidth: .infinity)

            Picker("农历日期", selection: $day) {
                ForEach(1...max(dayCount, 1), id: \.self) { value in
                    Text(LunarCalendarData.dayTitle(value)).tag(value)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .pickerStyle(.wheel)
        .frame(height: 170)
        .clipped()
        .onChange(of: year) { _, _ in
            let updatedMonths = LunarCalendarData.months(in: year)
            if !updatedMonths.contains(month) {
                month = updatedMonths.first(where: {
                    $0.month == month.month && !$0.isLeapMonth
                }) ?? updatedMonths.first ?? month
            }
            clampDayAndCommit()
        }
        .onChange(of: month) { _, _ in
            clampDayAndCommit()
        }
        .onChange(of: day) { _, _ in
            commitSelection()
        }
    }

    private func clampDayAndCommit() {
        day = min(day, max(LunarCalendarData.dayCount(in: year, month: month), 1))
        commitSelection()
    }

    private func commitSelection() {
        guard let selectedDate = LunarCalendarData.date(
            year: year,
            month: month,
            day: day,
            preservingTimeFrom: date
        ) else { return }
        date = selectedDate
    }
}

private struct LunarDateSelection {
    let year: Int
    let month: LunarMonthOption
    let day: Int
}

private struct LunarMonthOption: Hashable, Identifiable {
    let month: Int
    let isLeapMonth: Bool

    var id: String { "\(month)-\(isLeapMonth)" }

    var title: String {
        LunarCalendarData.monthTitle(month, isLeapMonth: isLeapMonth)
    }
}

private enum LunarCalendarData {
    private static let monthNames = [
        "正月", "二月", "三月", "四月", "五月", "六月",
        "七月", "八月", "九月", "十月", "冬月", "腊月"
    ]

    private static let dayNames = [
        "初一", "初二", "初三", "初四", "初五", "初六", "初七", "初八", "初九", "初十",
        "十一", "十二", "十三", "十四", "十五", "十六", "十七", "十八", "十九", "二十",
        "廿一", "廿二", "廿三", "廿四", "廿五", "廿六", "廿七", "廿八", "廿九", "三十"
    ]

    static func selection(for date: Date) -> LunarDateSelection {
        let components = chineseCalendar.dateComponents([.month, .day], from: date)
        return LunarDateSelection(
            year: lunarYear(containing: date),
            month: LunarMonthOption(
                month: components.month ?? 1,
                isLeapMonth: components.isLeapMonth == true
            ),
            day: components.day ?? 1
        )
    }

    static func months(in year: Int) -> [LunarMonthOption] {
        guard let start = newYearDate(for: year),
              let end = newYearDate(for: year + 1) else { return [] }

        var result: [LunarMonthOption] = []
        var seen = Set<LunarMonthOption>()
        var candidate = start
        while candidate < end {
            let components = chineseCalendar.dateComponents([.month], from: candidate)
            if let month = components.month {
                let option = LunarMonthOption(
                    month: month,
                    isLeapMonth: components.isLeapMonth == true
                )
                if seen.insert(option).inserted {
                    result.append(option)
                }
            }
            guard let next = gregorianCalendar.date(byAdding: .day, value: 1, to: candidate) else { break }
            candidate = next
        }
        return result
    }

    static func dayCount(in year: Int, month: LunarMonthOption) -> Int {
        guard let start = newYearDate(for: year),
              let end = newYearDate(for: year + 1) else { return 30 }

        var maximumDay = 0
        var candidate = start
        while candidate < end {
            let components = chineseCalendar.dateComponents([.month, .day], from: candidate)
            if components.month == month.month,
               components.isLeapMonth == month.isLeapMonth {
                maximumDay = max(maximumDay, components.day ?? 0)
            }
            guard let next = gregorianCalendar.date(byAdding: .day, value: 1, to: candidate) else { break }
            candidate = next
        }
        return maximumDay
    }

    static func date(
        year: Int,
        month: LunarMonthOption,
        day: Int,
        preservingTimeFrom sourceDate: Date
    ) -> Date? {
        guard let start = newYearDate(for: year),
              let end = newYearDate(for: year + 1) else { return nil }

        var candidate = start
        while candidate < end {
            let components = chineseCalendar.dateComponents([.month, .day], from: candidate)
            if components.month == month.month,
               components.isLeapMonth == month.isLeapMonth,
               components.day == day {
                var dateComponents = gregorianCalendar.dateComponents([.year, .month, .day], from: candidate)
                let timeComponents = gregorianCalendar.dateComponents([.hour, .minute, .second, .nanosecond], from: sourceDate)
                dateComponents.hour = timeComponents.hour
                dateComponents.minute = timeComponents.minute
                dateComponents.second = timeComponents.second
                dateComponents.nanosecond = timeComponents.nanosecond
                return gregorianCalendar.date(from: dateComponents)
            }
            guard let next = gregorianCalendar.date(byAdding: .day, value: 1, to: candidate) else { break }
            candidate = next
        }
        return nil
    }

    static func monthTitle(_ month: Int, isLeapMonth: Bool) -> String {
        guard monthNames.indices.contains(month - 1) else { return "\(month)月" }
        return (isLeapMonth ? "闰" : "") + monthNames[month - 1]
    }

    static func dayTitle(_ day: Int) -> String {
        guard dayNames.indices.contains(day - 1) else { return "\(day)日" }
        return dayNames[day - 1]
    }

    private static func lunarYear(containing date: Date) -> Int {
        var candidate = gregorianCalendar.startOfDay(for: date)
        for _ in 0..<400 {
            let components = chineseCalendar.dateComponents([.month, .day], from: candidate)
            if components.month == 1,
               components.day == 1,
               components.isLeapMonth != true {
                return gregorianCalendar.component(.year, from: candidate)
            }
            guard let previous = gregorianCalendar.date(byAdding: .day, value: -1, to: candidate) else { break }
            candidate = previous
        }
        return gregorianCalendar.component(.year, from: date)
    }

    private static func newYearDate(for year: Int) -> Date? {
        var components = DateComponents()
        components.year = year
        components.month = 1
        components.day = 15
        components.hour = 12
        guard var candidate = gregorianCalendar.date(from: components) else { return nil }

        for _ in 0..<50 {
            let lunarComponents = chineseCalendar.dateComponents([.month, .day], from: candidate)
            if lunarComponents.month == 1,
               lunarComponents.day == 1,
               lunarComponents.isLeapMonth != true {
                return gregorianCalendar.startOfDay(for: candidate)
            }
            guard let next = gregorianCalendar.date(byAdding: .day, value: 1, to: candidate) else { break }
            candidate = next
        }
        return nil
    }

    private static var gregorianCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        return calendar
    }

    private static var chineseCalendar: Calendar {
        var calendar = Calendar(identifier: .chinese)
        calendar.locale = Locale(identifier: "zh_Hans_CN")
        calendar.timeZone = .current
        return calendar
    }
}
