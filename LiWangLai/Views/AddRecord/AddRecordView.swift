import SwiftData
import SwiftUI

struct AddRecordView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState

    var editingRecord: GiftRecord?
    var presetName: String = ""
    var presetType: GiftRecordType = .received
    var presetEventType: GiftEventType?
    var presetDate: Date?
    var presetNote: String = ""
    var presetEventID: UUID? = nil
    var returningRecord: GiftRecord?

    @State private var draft: GiftRecordDraft
    @State private var showMore = false
    @State private var showPostSave = false
    @State private var previousRecordBeforeSave: GiftRecord?
    @State private var saveErrorMessage: String?
    @Query(sort: \GiftRecord.date, order: .reverse) private var allRecords: [GiftRecord]
    @Query(sort: \HostedGiftEvent.date, order: .reverse) private var hostedEvents: [HostedGiftEvent]

    private var lastRecordForPerson: GiftRecord? {
        allRecords
            .filter {
                $0.personName == draft.personName
                    && $0.personName != ""
                    && $0.id != editingRecord?.id
            }
            .sorted { $0.date > $1.date }
            .first
    }

    init(
        editingRecord: GiftRecord? = nil,
        presetName: String = "",
        presetType: GiftRecordType = .received,
        presetEventType: GiftEventType? = nil,
        presetDate: Date? = nil,
        presetNote: String = "",
        presetEventID: UUID? = nil,
        returningRecord: GiftRecord? = nil
    ) {
        self.editingRecord = editingRecord
        self.presetName = presetName
        self.presetType = presetType
        self.presetEventType = presetEventType
        self.presetDate = presetDate
        self.presetNote = presetNote
        self.presetEventID = presetEventID
        self.returningRecord = returningRecord
        _draft = State(initialValue: GiftRecordDraft(
            record: editingRecord,
            personName: presetName,
            type: presetType,
            eventType: presetEventType,
            date: presetDate,
            note: presetNote,
            hostedEventID: presetEventID
        ))
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 11) {
                    addHeader
                    typePicker
                    mainForm
                    moreInfo

                    // 上次往来提示卡片
                    if let lastRecordForPerson, draft.personName.count >= 1 {
                        lastRecordHint(lastRecordForPerson)
                    }

                    SealButton(
                        title: editingRecord == nil ? "保存入簿" : "保存修改",
                        systemImage: "checkmark.seal",
                        isDisabled: !draft.isValid,
                        fontSize: 15,
                        verticalPadding: 10,
                        cornerRadius: 14
                    ) {
                        save()
                    }
                    .padding(.bottom, 10)
                }
                .padding(.horizontal, LWSpacing.page)
                .padding(.top, -4)
                .padding(.bottom, 4)
            }

            if showPostSave {
                postSaveCard
            }
        }
        .background(PaperTexture())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if editingRecord != nil {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                    .foregroundStyle(LWColors.cinnabar)
                }
            }
        }
        .onChange(of: draft.type) { _, type in
            if type == .given {
                draft.isReturned = false
                draft.hostedEventID = nil
                draft.hostedEventTitle = ""
            }
        }
        .onChange(of: draft.isReturned) { _, isReturned in
            if isReturned {
                draft.returnReminderDate = nil
            }
        }
        .onChange(of: draft.hostedEventID) { _, eventID in
            applyHostedEvent(eventID)
        }
        .alert("保存失败", isPresented: Binding(
            get: { saveErrorMessage != nil },
            set: { if !$0 { saveErrorMessage = nil } }
        )) {
            Button("知道了", role: .cancel) {}
        } message: {
            Text(saveErrorMessage ?? "请稍后再试。")
        }
    }

    private var addHeader: some View {
        ZStack(alignment: .topTrailing) {
            Image("prototype_header_mountain_plum")
                .resizable()
                .scaledToFit()
                .frame(width: 236)
                .offset(x: 24, y: 8)
                .opacity(0.88)
                .allowsHitTesting(false)

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(editingRecord == nil ? "入簿" : "改一笔")
                        .font(.titleSong(40))
                        .foregroundStyle(LWColors.ink)
                    Text("三秒记一笔")
                        .font(.bodySong(17))
                        .foregroundStyle(LWColors.warmGold)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 18)
            }
        }
        .frame(height: 124)
    }

    private var typePicker: some View {
        HStack(spacing: 0) {
            ForEach(GiftRecordType.allCases) { type in
                Button {
                    draft.type = type
                } label: {
                    Text(type.title)
                        .font(.bodySong(12).weight(.semibold))
                        .foregroundStyle(draft.type == type ? .white : LWColors.ink)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 7)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(draft.type == type ? type.accentColor : Color.clear)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(3)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white.opacity(0.58))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(LWColors.cardStroke.opacity(0.4)))
        )
    }

    private var mainForm: some View {
        PaperCard(padding: 14, spacing: 10) {
            // 姓名输入
            VStack(alignment: .leading, spacing: 6) {
                fieldRow(title: "姓名", icon: "person") {
                    TextField("请输入姓名", text: $draft.personName)
                        .font(.bodyKai(14))
                        .foregroundStyle(LWColors.ink)
                    .textInputAutocapitalization(.never)
                }
                nameSuggestions
            }

            GoldLineDivider()

            // 金额输入 - 大字号 + 快捷按钮
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("金额")
                        .font(.titleSong(15))
                        .foregroundStyle(LWColors.ink)
                    Spacer()
                    Image(systemName: "yensign.circle")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(LWColors.warmGold)
                }
                AmountTextField(amountText: $draft.amountText, currencySize: 24, amountSize: 36)
                amountChips
            }

            GoldLineDivider()

            // 事件选择 - 横向标签
            VStack(alignment: .leading, spacing: 8) {
                Text("事件")
                    .font(.titleSong(15))
                    .foregroundStyle(LWColors.ink)
                eventChipWrap
            }

            if draft.type == .received {
                GoldLineDivider()
                hostedEventSelection
            }

            GoldLineDivider()

            // 日期选择
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("日期")
                        .font(.titleSong(15))
                        .foregroundStyle(LWColors.ink)
                    Spacer()
                    ChineseDatePickerButton(date: Binding(
                        get: { draft.date },
                        set: { date in
                            draft.hostedEventID = nil
                            draft.date = date
                        }
                    ))
                }
                quickDateButtons
            }
        }
    }

    private var eventChipWrap: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 52), spacing: 8)], alignment: .leading, spacing: 8) {
            ForEach(GiftEventType.allCases) { event in
                Button {
                    if hostedEvents.first(where: { $0.id == draft.hostedEventID })?.eventType != event {
                        draft.hostedEventID = nil
                    }
                    draft.eventType = event
                } label: {
                    Text(event.title)
                        .font(.bodySong(12))
                        .foregroundStyle(draft.eventType == event ? .white : LWColors.ink)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(draft.eventType == event ? LWColors.cinnabar : LWColors.card.opacity(0.85))
                                .overlay(Capsule().stroke(draft.eventType == event ? LWColors.cinnabarDark.opacity(0.2) : LWColors.cardStroke.opacity(0.4), lineWidth: 0.8))
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var hostedEventSelection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .center, spacing: 10) {
                Image(systemName: "rectangle.stack")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(LWColors.warmGold)
                Text("归属一场事")
                    .font(.titleSong(14))
                    .foregroundStyle(LWColors.ink)
                    .fixedSize(horizontal: true, vertical: false)
                Spacer(minLength: 12)
                Menu {
                    Button {
                        draft.hostedEventID = nil
                    } label: {
                        hostedEventMenuItem(
                            "自动新建 · \(HostedEventService.defaultTitle(for: draft.eventType))",
                            isSelected: draft.hostedEventID == nil
                        )
                    }
                    ForEach(hostedEvents) { event in
                        Button {
                            draft.hostedEventID = event.id
                        } label: {
                            hostedEventMenuItem(
                                "\(event.title) · \(event.date.lwDayText)",
                                isSelected: draft.hostedEventID == event.id
                            )
                        }
                    }
                } label: {
                    HStack(spacing: 5) {
                        Text(selectedHostedEventLabel)
                            .font(.bodySong(13))
                            .lineLimit(1)
                            .truncationMode(.tail)
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.system(size: 9, weight: .semibold))
                    }
                    .foregroundStyle(LWColors.cinnabar)
                    .frame(maxWidth: .infinity, minHeight: 24, alignment: .trailing)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("归属一场事")
                .accessibilityValue(selectedHostedEventLabel)
            }
            if draft.hostedEventID == nil {
                HStack(spacing: 10) {
                    Text("场次名称")
                        .font(.titleSong(13))
                        .foregroundStyle(LWColors.ink)
                        .frame(width: 66, alignment: .leading)
                    TextField(
                        HostedEventService.defaultTitle(for: draft.eventType),
                        text: $draft.hostedEventTitle
                    )
                    .font(.bodySong(13))
                    .textInputAutocapitalization(.never)
                }
            }
            Text(draft.hostedEventID == nil ? "名称可修改；留空则使用上方默认名称。" : "已选择已有场次，事件类型和日期将跟随该场次。")
                .font(.bodySong(11))
                .foregroundStyle(LWColors.muted)
        }
    }

    private var selectedHostedEventLabel: String {
        guard let eventID = draft.hostedEventID,
              let event = hostedEvents.first(where: { $0.id == eventID }) else {
            return "自动新建 · \(HostedEventService.defaultTitle(for: draft.eventType))"
        }
        return "\(event.title) · \(event.date.lwDayText)"
    }

    private func hostedEventMenuItem(_ title: String, isSelected: Bool) -> some View {
        HStack {
            Text(title)
            if isSelected {
                Image(systemName: "checkmark")
            }
        }
    }

    private var amountChips: some View {
        HStack(spacing: 8) {
            ForEach([200, 300, 500, 600, 800, 1000], id: \.self) { amount in
                Button {
                    draft.amountText = "\(amount)"
                } label: {
                    Text("\(amount)")
                        .font(.bodySong(13))
                        .foregroundStyle(draft.amountYuan == amount ? .white : LWColors.ink)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 7)
                        .background(
                            Capsule()
                                .fill(draft.amountYuan == amount ? LWColors.cinnabar : Color.white.opacity(0.65))
                                .overlay(Capsule().stroke(LWColors.cardStroke.opacity(0.4)))
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var moreInfo: some View {
        PaperCard(padding: 12, spacing: 8) {
            Button {
                withAnimation(.easeInOut(duration: 0.18)) {
                    showMore.toggle()
                }
            } label: {
                HStack {
                    Text("更多信息")
                        .font(.titleSong(14))
                        .foregroundStyle(LWColors.ink)
                    Spacer()
                    Image(systemName: showMore ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(LWColors.muted)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if showMore {
                GoldLineDivider()
                VStack(alignment: .leading, spacing: 6) {
                    Text("关系")
                        .font(.titleSong(14))
                    chipWrap(RelationshipType.allCases, selected: draft.relationship) { relationship in
                        draft.relationship = relationship
                    }
                }
                fieldRow(title: "备注", icon: "note.text") {
                    TextField(draft.eventType.notePlaceholder, text: $draft.note, axis: .vertical)
                        .lineLimit(1...2)
                        .font(.bodySong(12))
                }
                fieldRow(title: "地点", icon: "mappin") {
                    TextField("可选填", text: $draft.location)
                        .font(.bodySong(12))
                }
                if draft.type == .received {
                    Toggle(isOn: $draft.isReturned) {
                        Text("是否已回礼")
                            .font(.titleSong(13))
                            .foregroundStyle(LWColors.ink)
                    }
                    .tint(LWColors.cinnabar)
                }
                if !draft.isReturned {
                    Toggle(isOn: Binding(
                        get: { draft.returnReminderDate != nil },
                        set: { enabled in
                            draft.returnReminderDate = enabled ? defaultReminderDate() : nil
                        }
                    )) {
                        Text(draft.type == .received ? "设置回礼提醒" : "设置送礼提醒")
                            .font(.titleSong(13))
                            .foregroundStyle(LWColors.ink)
                    }
                    .tint(LWColors.cinnabar)

                    if draft.returnReminderDate != nil {
                        ChineseDatePickerButton(title: "提醒时间", includesTime: true, date: Binding(
                            get: { draft.returnReminderDate ?? defaultReminderDate() },
                            set: { draft.returnReminderDate = $0 }
                        ))
                        Text("开启“我的 → 系统通知”后，iPhone 会按此时间提醒。")
                            .font(.bodySong(10))
                            .foregroundStyle(LWColors.muted)
                    }
                }
            }
        }
   }


    private var postSaveCard: some View {
        let lastRecord = previousRecordBeforeSave
        let suggestionBase = max(100, (lastRecord?.amountYuan ?? draft.amountYuan) / 100 * 100)

        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                SealStamp(text: "已", size: 40)
                VStack(alignment: .leading, spacing: 3) {
                    Text("已入簿")
                        .font(.custom("SourceHanSerifSC-SemiBold", size: 20))
                        .foregroundStyle(LWColors.ink)
                    Text("\(draft.personName) · \(draft.eventType.title) · \(draft.type.title)")
                        .font(.custom("SourceHanSerifSC-Regular", size: 14))
                        .foregroundStyle(LWColors.inkSoft)
                    Text(draft.date.lwDualDateText)
                        .font(.bodySong(11))
                        .foregroundStyle(LWColors.warmGold)
                }
                Spacer()
                Text(draft.amountYuan.yuanText)
                    .font(.custom("SourceHanSerifSC-Regular", size: 26))
                    .foregroundStyle(LWColors.cinnabar)
            }

            if let lastRecord {
                GoldLineDivider()
                VStack(alignment: .leading, spacing: 4) {
                    Text("上次往来")
                        .font(.custom("SourceHanSerifSC-Regular", size: 12))
                        .foregroundStyle(LWColors.muted)
                    Text("\(lastRecord.date.lwCompactMonthText) \(lastRecord.eventType.title) · \(lastRecord.type.narrativeTitle) \(lastRecord.amountYuan.yuanText)")
                        .font(.custom("SourceHanSerifSC-Regular", size: 14))
                        .foregroundStyle(LWColors.ink)
                    Text("建议：下次回礼可参考 \(suggestionBase.yuanText) - \((suggestionBase + 200).yuanText)")
                        .font(.custom("SourceHanSerifSC-Regular", size: 14))
                        .foregroundStyle(LWColors.cinnabar)
                }
            }

            HStack(spacing: 8) {
                Button {
                    withAnimation(.easeOut(duration: 0.16)) {
                        showPostSave = false
                    }
                    draft = GiftRecordDraft(
                        type: draft.type,
                        eventType: draft.eventType,
                        date: draft.date,
                        hostedEventID: draft.hostedEventID
                    )
                } label: {
                    Label("再记一笔", systemImage: "pencil")
                        .font(.custom("SourceHanSerifSC-Regular", size: 13).weight(.semibold))
                        .foregroundStyle(LWColors.cinnabar)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.52))
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(LWColors.cinnabar.opacity(0.35)))
                        )
                }
                .buttonStyle(.plain)

                Button {
                    showPostSave = false
                    appState.peopleSearchText = draft.personName
                    appState.selectedTab = .people
                } label: {
                    Label("查看此人", systemImage: "person.text.rectangle")
                        .font(.custom("SourceHanSerifSC-Regular", size: 13).weight(.semibold))
                        .foregroundStyle(LWColors.warmGold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.52))
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(LWColors.warmGold.opacity(0.35)))
                        )
                }
                .buttonStyle(.plain)

                Button {
                    showPostSave = false
                    appState.selectedTab = .home
                } label: {
                    Label("返回首页", systemImage: "house")
                        .font(.custom("SourceHanSerifSC-Regular", size: 13).weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(LWColors.cinnabar, in: RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 8)
        )
        .padding(.horizontal, 16)
        .transition(.scale.combined(with: .opacity))
    }

    @ViewBuilder
    private var nameSuggestions: some View {
        let trimmed = draft.personName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            let uniqueNames = suggestedNames(matching: trimmed)
            if !uniqueNames.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(uniqueNames, id: \.self) { name in
                        if let matchingRecord = allRecords.first(where: { $0.personName == name }) {
                            Button {
                                draft.personName = name
                                draft.relationship = matchingRecord.relationship
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(name)
                                            .font(.custom("SourceHanSerifSC-Regular", size: 14))
                                            .foregroundStyle(LWColors.ink)
                                        Text("上次：\(matchingRecord.date.lwCompactMonthText) \(matchingRecord.eventType.title) · \(matchingRecord.type.title) \(matchingRecord.amountYuan.yuanText)")
                                            .font(.custom("SourceHanSerifSC-Regular", size: 11))
                                            .foregroundStyle(LWColors.muted)
                                            .lineLimit(1)
                                    }
                                    Spacer()
                                    Image(systemName: "arrow.up.left")
                                        .font(.system(size: 10))
                                        .foregroundStyle(LWColors.muted)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                            }
                            .buttonStyle(.plain)
                            if name != uniqueNames.last {
                                GoldLineDivider()
                            }
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.white.opacity(0.92))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(LWColors.cardStroke.opacity(0.3)))
                )
            }
        }
    }

    private func suggestedNames(matching query: String) -> [String] {
        var seen = Set<String>()
        return Array(allRecords.lazy
            .map(\.personName)
            .filter { name in
                name != query
                    && name.localizedCaseInsensitiveContains(query)
                    && seen.insert(name).inserted
            }
            .prefix(3))
    }

    private func fieldRow<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.titleSong(13))
                .foregroundStyle(LWColors.ink)
                .frame(width: 42, alignment: .leading)
            content()
            Image(systemName: icon)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(LWColors.warmGold)
        }
    }

    private var quickDateButtons: some View {
        let now = Date.now
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now) ?? now
        let selection = QuickDateSelection.selection(for: draft.date, relativeTo: now)

        return HStack(spacing: 8) {
            quickDate("今天", date: now, selection: selection == .today)
            quickDate("昨天", date: yesterday, selection: selection == .yesterday)
            quickDate("自定义", date: nil, selection: selection == .custom)
        }
    }

    private func quickDate(_ title: String, date: Date?, selection: Bool) -> some View {
        Button {
            if let date {
                draft.hostedEventID = nil
                draft.date = date
            }
        } label: {
            Text(title)
                .font(.bodySong(12))
                .foregroundStyle(selection ? LWColors.cinnabar : LWColors.ink)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(selection ? LWColors.cinnabar.opacity(0.1) : Color.white.opacity(0.6))
                        .overlay(Capsule().stroke(selection ? LWColors.cinnabar : LWColors.cardStroke.opacity(0.4)))
                )
        }
        .buttonStyle(.plain)
    }

    private func lastRecordHint(_ record: GiftRecord) -> some View {
        let suggestionBase = max(100, record.amountYuan / 100 * 100)

        return PaperCard(padding: 12) {
            HStack(spacing: 10) {
                Image(systemName: "gift")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(LWColors.warmGold)
                    .frame(width: 24)
                VStack(alignment: .leading, spacing: 4) {
                    Text("上次往来：\(record.date.lwCompactMonthText) \(record.type.title) \(record.amountYuan.yuanText)")
                        .font(.bodySong(13))
                        .foregroundStyle(LWColors.ink)
                    Text("建议：下次回礼可参考 \(suggestionBase.yuanText) - \((suggestionBase + 200).yuanText)")
                        .font(.bodySong(13))
                        .foregroundStyle(LWColors.cinnabar)
                }
            }
        }
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    private func chipWrap<T: Identifiable & CaseIterable & Equatable>(_ values: T.AllCases, selected: T, action: @escaping (T) -> Void) -> some View where T.AllCases: RandomAccessCollection, T: TitleProviding {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 40), spacing: 5)], alignment: .leading, spacing: 5) {
            ForEach(values) { value in
                Button {
                    action(value)
                } label: {
                    addChipTag(value.title, isSelected: value == selected)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func addChipTag(_ title: String, isSelected: Bool) -> some View {
        Text(title)
            .font(.bodySong(11))
            .foregroundStyle(isSelected ? .white : LWColors.ink)
            .padding(.horizontal, 7)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(isSelected ? LWColors.cinnabar : LWColors.card.opacity(0.78))
                    .overlay(Capsule().stroke(LWColors.cardStroke.opacity(0.55), lineWidth: 0.8))
            )
    }

    private func applyHostedEvent(_ eventID: UUID?) {
        guard let eventID,
              let event = hostedEvents.first(where: { $0.id == eventID }) else { return }
        draft.hostedEventTitle = ""
        draft.eventType = event.eventType
        draft.date = event.date
    }

    private func defaultReminderDate(now: Date = .now) -> Date {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: now) ?? now
        return Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: tomorrow) ?? tomorrow
    }

    private func save() {
        guard draft.isValid else { return }
        do {
            if let editingRecord {
                try RecordService.update(editingRecord, with: draft, in: modelContext)
                draft.hostedEventID = editingRecord.hostedEventID
                draft.eventType = editingRecord.eventType
                draft.date = editingRecord.date
                HapticsManager.success()
                dismiss()
            } else {
                previousRecordBeforeSave = lastRecordForPerson
                let record = try RecordService.insert(draft, returning: returningRecord, in: modelContext)
                draft.hostedEventID = record.hostedEventID
                draft.eventType = record.eventType
                draft.date = record.date
                HapticsManager.success()
                withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                    showPostSave = true
                }
            }
        } catch {
            saveErrorMessage = error.localizedDescription
        }
    }
}

protocol TitleProviding {
    var title: String { get }
}

extension GiftEventType: TitleProviding {}
extension RelationshipType: TitleProviding {}

enum QuickDateSelection: Equatable {
    case today
    case yesterday
    case custom

    static func selection(
        for date: Date,
        relativeTo now: Date = .now,
        calendar: Calendar = .current
    ) -> QuickDateSelection {
        if calendar.isDate(date, inSameDayAs: now) {
            return .today
        }
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: now),
           calendar.isDate(date, inSameDayAs: yesterday) {
            return .yesterday
        }
        return .custom
    }
}

#Preview {
    NavigationStack {
        AddRecordView()
    }
    .modelContainer(for: [GiftRecord.self, HostedGiftEvent.self], inMemory: true)
    .environment(AppState())
}
