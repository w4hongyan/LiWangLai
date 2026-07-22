import SwiftData
import SwiftUI
import Testing
import UIKit
@testable import LiWangLai

struct FurtherCoverageTests {
    @Test func modelFallbacksAndSettersAreStable() {
        let record = GiftRecord(
            personName: "测试用户",
            type: .received,
            amountYuan: 600,
            eventType: .wedding,
            relationship: .friend
        )
        record.typeRawValue = "unknown-type"
        record.eventTypeRawValue = "unknown-event"
        record.relationshipRawValue = "unknown-relationship"

        #expect(record.type == .received)
        #expect(record.eventType == .other)
        #expect(record.relationship == .other)

        record.type = .given
        record.eventType = .school
        record.relationship = .client

        #expect(record.typeRawValue == GiftRecordType.given.rawValue)
        #expect(record.eventTypeRawValue == GiftEventType.school.rawValue)
        #expect(record.relationshipRawValue == RelationshipType.client.rawValue)
        #expect(record.needsReturn == false)
    }

    @Test func hostedEventFallbackAndGiftEventTotalsAreStable() {
        let hostedEvent = HostedGiftEvent(title: "测试活动", eventType: .wedding)
        hostedEvent.eventTypeRawValue = "unknown-event"
        #expect(hostedEvent.eventType == .other)

        hostedEvent.eventType = .baby
        #expect(hostedEvent.eventTypeRawValue == GiftEventType.baby.rawValue)

        let records = [
            GiftRecord(personName: "甲", type: .received, amountYuan: 600, eventType: .baby, relationship: .friend),
            GiftRecord(personName: "乙", type: .received, amountYuan: 800, eventType: .baby, relationship: .relative)
        ]
        let fallbackEvent = GiftEvent(title: "满月", monthKey: "2026年7月", records: records)
        let linkedEvent = GiftEvent(
            title: hostedEvent.title,
            monthKey: "2026年7月",
            records: records,
            hostedEventID: hostedEvent.id
        )

        #expect(fallbackEvent.id == "满月-2026年7月")
        #expect(linkedEvent.id == hostedEvent.id.uuidString)
        #expect(linkedEvent.totalAmount == 1400)
    }

    @Test func enumPresentationValuesCoverEveryCase() {
        for type in GiftRecordType.allCases {
            #expect(type.id == type.rawValue)
            #expect(!type.title.isEmpty)
            #expect(!type.shortTitle.isEmpty)
            #expect(!type.narrativeTitle.isEmpty)
            _ = type.accentColor
        }
        for eventType in GiftEventType.allCases {
            #expect(eventType.id == eventType.rawValue)
            #expect(!eventType.title.isEmpty)
            #expect(!eventType.notePlaceholder.isEmpty)
            _ = eventType.icon
        }
        for relationship in RelationshipType.allCases {
            #expect(relationship.id == relationship.rawValue)
            #expect(!relationship.title.isEmpty)
        }
        for theme in AppTheme.allCases {
            #expect(theme.id == theme.rawValue)
            #expect(!theme.title.isEmpty)
            _ = theme.palette
        }
    }

    @Test func dateFormattersUseExpectedChineseOutput() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let date = calendar.date(from: DateComponents(year: 2026, month: 7, day: 17))!

        #expect(date.lwDayText == "2026年7月17日")
        #expect(date.lwMonthText == "2026年7月")
        #expect(date.lwCompactMonthText == "2026年7月")
        #expect(LunarDateFormatter.string(from: date, timeZone: calendar.timeZone) == "农历六月初四")
        #expect(date.lwLunarText.hasPrefix("农历"))
        #expect(date.lwDualDateText.contains(" · 农历"))
        #expect(DateFormatter.lwCompactMonth === DateFormatter.lwMonth)
    }

    @Test func lunarFormatterSupportsLeapMonths() {
        var chineseCalendar = Calendar(identifier: .chinese)
        chineseCalendar.timeZone = TimeZone(secondsFromGMT: 0)!
        var components = DateComponents()
        components.calendar = chineseCalendar
        components.timeZone = chineseCalendar.timeZone
        components.year = 42
        components.month = 6
        components.day = 1
        components.isLeapMonth = true
        let leapMonthDate = chineseCalendar.date(from: components)!

        #expect(LunarDateFormatter.string(from: leapMonthDate, timeZone: chineseCalendar.timeZone) == "农历闰六月初一")
    }

    @Test func quickDateSelectionIsMutuallyExclusive() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let now = calendar.date(from: DateComponents(year: 2026, month: 7, day: 17, hour: 12))!
        let laterToday = calendar.date(from: DateComponents(year: 2026, month: 7, day: 17, hour: 23))!
        let yesterday = calendar.date(from: DateComponents(year: 2026, month: 7, day: 16, hour: 8))!
        let custom = calendar.date(from: DateComponents(year: 2026, month: 7, day: 10))!

        #expect(QuickDateSelection.selection(for: laterToday, relativeTo: now, calendar: calendar) == .today)
        #expect(QuickDateSelection.selection(for: yesterday, relativeTo: now, calendar: calendar) == .yesterday)
        #expect(QuickDateSelection.selection(for: custom, relativeTo: now, calendar: calendar) == .custom)
    }

    @Test func biometricPresentationValuesAreAlwaysUsable() {
        #expect(BiometricService.AuthError.notAvailable.errorDescription == "设备未设置可用的身份验证方式")
        #expect(BiometricService.AuthError.cancelled.errorDescription == "已取消验证")
        #expect(BiometricService.AuthError.failed.errorDescription == "验证失败，请重试")
        #expect(!BiometricService.biometricTypeName.isEmpty)
        _ = BiometricService.isAvailable
        _ = BiometricService.hasBiometrics
    }

    @Test func staticSystemSymbolsExist() {
        let symbols = [
            "arrow.up.left",
            "calendar",
            "chevron.right",
            "ellipsis",
            "faceid",
            "gift",
            "magnifyingglass",
            "rectangle.stack",
            "scroll",
            "star.fill",
            "xmark.circle.fill",
            "yensign.circle"
        ]

        for symbol in symbols {
            #expect(UIImage(systemName: symbol) != nil, "无效的 SF Symbol：\(symbol)")
        }
    }

    @MainActor
    @Test func sampleDataSeedsOnce() throws {
        let container = try makeContainer()

        SampleData.seedIfEmpty(modelContext: container.mainContext)
        let firstSeed = try container.mainContext.fetch(FetchDescriptor<GiftRecord>())
        SampleData.seedIfEmpty(modelContext: container.mainContext)
        let secondSeed = try container.mainContext.fetch(FetchDescriptor<GiftRecord>())

        #expect(firstSeed.count == 9)
        #expect(secondSeed.count == 9)
        #expect(firstSeed.contains(where: { $0.type == .received }))
        #expect(firstSeed.contains(where: { $0.type == .given }))
    }

    @MainActor
    @Test func emptyStateScreensRender() throws {
        let container = try makeContainer()
        let appState = AppState()
        let importPreview = try ExcelImportService.prepare(
            table: [
                ["姓名", "类型", "金额", "日期"],
                ["预览用户", "送礼", "600", "2026-07-17"]
            ],
            existingRecords: []
        )
        let screens: [AnyView] = [
            AnyView(AddRecordView()),
            AnyView(LedgerView(records: [])),
            AnyView(PeopleView(records: [])),
            AnyView(ReminderListView(records: [])),
            AnyView(SettingsView(records: [])),
            AnyView(HostedEventsView()),
            AnyView(PersonDetailView(summary: nil)),
            AnyView(IPadQuickDeskView(records: [], hostedEvents: [], openSettings: {})),
            AnyView(DuplicateMergeView(records: [])),
            AnyView(ExcelImportPreviewView(prepared: importPreview))
        ]

        for screen in screens {
            #expect(render(screen, appState: appState, container: container))
        }
    }

    @MainActor
    @Test func populatedStateScreensRender() throws {
        let container = try makeContainer()
        let event = HostedGiftEvent(
            title: "我家婚礼",
            eventType: .wedding,
            date: .now,
            note: "锦江礼堂"
        )
        let received = GiftRecord(
            personName: "张三",
            type: .received,
            amountYuan: 800,
            eventType: .wedding,
            relationship: .friend,
            date: .now,
            note: "婚礼随礼",
            returnReminderDate: .now,
            location: "锦江礼堂",
            giftName: "红包",
            contact: "13800138000",
            hostedEventID: event.id
        )
        let given = GiftRecord(
            personName: "张三",
            type: .given,
            amountYuan: 600,
            eventType: .baby,
            relationship: .friend,
            date: Calendar.current.date(byAdding: .day, value: -10, to: .now) ?? .now,
            note: "满月礼"
        )
        let other = GiftRecord(
            personName: "李四",
            type: .received,
            amountYuan: 1000,
            eventType: .housewarming,
            relationship: .relative,
            date: Calendar.current.date(byAdding: .day, value: -20, to: .now) ?? .now,
            isReturned: true
        )
        container.mainContext.insert(event)
        [received, given, other].forEach(container.mainContext.insert)
        try container.mainContext.save()

        let records = [received, given, other]
        let appState = AppState()
        appState.homeSearchText = "张三"
        appState.ledgerSearchText = "礼"
        appState.peopleSearchText = "张"
        let summary = RecordService.people(from: records).first { $0.name == "张三" }!
        let giftEvent = GiftEvent(
            title: event.title,
            monthKey: event.date.lwDayText,
            eventType: event.eventType,
            date: event.date,
            records: [received],
            hostedEventID: event.id
        )
        let duplicate = GiftRecord(
            personName: received.personName,
            type: received.type,
            amountYuan: received.amountYuan,
            eventType: received.eventType,
            relationship: received.relationship,
            date: received.date,
            note: "重复预览"
        )
        let importPreview = try ExcelImportService.prepare(
            table: [
                ["姓名", "类型", "金额", "事件", "关系", "日期"],
                ["导入用户", "送礼", "888", "生日", "朋友", "2026-07-18"],
                ["坏数据", "未知", "-", "其他", "其他", "错误日期"]
            ],
            existingRecords: records
        )
        let screens: [AnyView] = [
            AnyView(HomeView(records: records)),
            AnyView(LedgerView(records: records)),
            AnyView(PeopleView(records: records)),
            AnyView(ReminderListView(records: records)),
            AnyView(SettingsView(records: records)),
            AnyView(HostedEventsView()),
            AnyView(RecordDetailView(record: received)),
            AnyView(PersonDetailView(summary: summary)),
            AnyView(EventDetailView(event: giftEvent)),
            AnyView(AddRecordView(presetName: "张", presetType: .given)),
            AnyView(AddRecordView(
                presetName: "王五",
                presetType: .received,
                presetEventType: event.eventType,
                presetDate: event.date,
                presetEventID: event.id
            )),
            AnyView(DuplicateMergeView(records: records + [duplicate])),
            AnyView(ExcelImportPreviewView(prepared: importPreview))
        ]

        for screen in screens {
            #expect(render(screen, appState: appState, container: container))
        }
        #expect(render(
            AnyView(IPadQuickDeskView(records: records, hostedEvents: [event], openSettings: {})),
            appState: appState,
            container: container,
            width: 844,
            height: 390
        ))
    }

    @MainActor
    private func render(
        _ view: AnyView,
        appState: AppState,
        container: ModelContainer,
        width: CGFloat = 390,
        height: CGFloat = 844
    ) -> Bool {
        let content = NavigationStack { view }
            .environment(appState)
            .environment(PurchaseManager(defaults: UserDefaults(suiteName: "LiWangLaiTests.Purchases")!))
            .environment(\.locale, Locale(identifier: "zh_Hans_CN"))
            .modelContainer(container)
            .frame(width: width, height: height)
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        let controller = UIHostingController(rootView: content)
        controller.loadViewIfNeeded()
        controller.view.frame = frame
        controller.view.setNeedsLayout()
        controller.view.layoutIfNeeded()

        var didDraw = false
        let renderer = UIGraphicsImageRenderer(size: frame.size)
        let image = renderer.image { _ in
            didDraw = controller.view.drawHierarchy(in: frame, afterScreenUpdates: true)
        }
        return didDraw && image.size == frame.size
    }

    @Test func contactIdentityRequiresPhoneLikeValue() {
        // 微信号含字母、桌号过短：不具备身份区分力
        #expect(PersonIdentity.normalizedContact("abc123") == "")
        #expect(PersonIdentity.normalizedContact("wxid_8888") == "")
        #expect(PersonIdentity.normalizedContact("5") == "")
        #expect(PersonIdentity.normalizedContact("138-0013") == "")
        // 类手机号（trim 后纯数字且 ≥ 5 位）仍作为拆分依据
        #expect(PersonIdentity.normalizedContact("13800138000") == "13800138000")
        #expect(PersonIdentity.normalizedContact("  13911112222  ") == "13911112222")
        // 脱敏同步适配：非类手机号不再生成身份提示
        #expect(PersonIdentity.maskedContact("abc123") == nil)
        #expect(PersonIdentity.maskedContact("13800138000") == "138••••8000")
    }

    @Test func wechatAndTableNumberContactsDoNotSplitSameNamePeople() {
        let wechat = GiftRecord(
            personName: "张三",
            type: .received,
            amountYuan: 600,
            eventType: .wedding,
            relationship: .friend,
            contact: "abc123"
        )
        let tableNumber = GiftRecord(
            personName: "张三",
            type: .given,
            amountYuan: 500,
            eventType: .baby,
            relationship: .friend,
            contact: "5"
        )

        let people = RecordService.people(from: [wechat, tableNumber])

        #expect(people.count == 1)
        #expect(people.first?.records.count == 2)
    }

    @Test func distinctPhoneNumbersStillSplitSameNamePeople() {
        let first = GiftRecord(
            personName: "张三",
            type: .received,
            amountYuan: 600,
            eventType: .wedding,
            relationship: .friend,
            contact: "13800138000"
        )
        let second = GiftRecord(
            personName: "张三",
            type: .received,
            amountYuan: 800,
            eventType: .wedding,
            relationship: .friend,
            contact: "13911112222"
        )

        let people = RecordService.people(from: [first, second])

        #expect(people.count == 2)
        #expect(Set(people.map(\.records.count)) == [1])
    }

    @MainActor
    @Test func mergeKeepsKeeperHostedEventLink() throws {
        let container = try makeContainer()
        let keeperEventID = UUID()
        let date = Date(timeIntervalSince1970: 2_000_000)
        let keeper = GiftRecord(
            personName: "张三",
            type: .received,
            amountYuan: 600,
            eventType: .wedding,
            relationship: .friend,
            date: date,
            hostedEventID: keeperEventID
        )
        let duplicate = GiftRecord(
            personName: "张 三",
            type: .received,
            amountYuan: 600,
            eventType: .wedding,
            relationship: .friend,
            date: date
        )
        container.mainContext.insert(keeper)
        container.mainContext.insert(duplicate)
        try container.mainContext.save()

        let groups = DuplicateMergeService.groups(in: [keeper, duplicate])
        #expect(groups.count == 1)
        // 「张 三」与「张三」按统一规范化口径识别为重复
        #expect(groups.first?.records.first === keeper)

        try DuplicateMergeService.merge(groups, in: container.mainContext)

        // keeper 已有关联场次时，保留 keeper 的归属而不是依赖数组排序
        #expect(keeper.hostedEventID == keeperEventID)
    }

    @MainActor
    private func makeContainer() throws -> ModelContainer {
        let schema = Schema([HostedGiftEvent.self, GiftRecord.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}
