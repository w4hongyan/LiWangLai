import SwiftData
import SwiftUI

struct AddRecordView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState

    var editingRecord: GiftRecord?
    var presetName: String = ""
    var presetContact: String = ""
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
    @State private var notificationNotice: String?
    @State private var showsPersonPicker = false
    @FocusState private var focusedField: RecordInputField?
    @Query(sort: \GiftRecord.date, order: .reverse) private var allRecords: [GiftRecord]
    @Query(sort: \HostedGiftEvent.date, order: .reverse) private var hostedEvents: [HostedGiftEvent]

    /// 当前归属的一场事；非 nil 时日期与事件类型以场次为准，表单锁定
    private var attachedHostedEvent: HostedGiftEvent? {
        guard let eventID = draft.hostedEventID else { return nil }
        return hostedEvents.first(where: { $0.id == eventID })
    }

    private var isHostedEventLocked: Bool {
        attachedHostedEvent != nil
    }

    private var lastRecordForPerson: GiftRecord? {
        allRecords
            .filter {
                PersonIdentity.matches($0, name: draft.personName, contact: draft.contact)
                    && $0.personName != ""
                    && $0.id != editingRecord?.id
            }
            .sorted { $0.date > $1.date }
            .first
    }

    init(
        editingRecord: GiftRecord? = nil,
        presetName: String = "",
        presetContact: String = "",
        presetPersonID: UUID? = nil,
        presetType: GiftRecordType = .received,
        presetEventType: GiftEventType? = nil,
        presetDate: Date? = nil,
        presetNote: String = "",
        presetEventID: UUID? = nil,
        returningRecord: GiftRecord? = nil
    ) {
        self.editingRecord = editingRecord
        self.presetName = presetName
        self.presetContact = presetContact
        self.presetType = presetType
        self.presetEventType = presetEventType
        self.presetDate = presetDate
        self.presetNote = presetNote
        self.presetEventID = presetEventID
        self.returningRecord = returningRecord
        var initialDraft = GiftRecordDraft(
            record: editingRecord,
            personName: presetName,
            type: presetType,
            eventType: presetEventType,
            date: presetDate,
            note: presetNote,
            hostedEventID: presetEventID
        )
        if editingRecord == nil, !presetContact.isEmpty {
            initialDraft.contact = presetContact
        }
        if editingRecord == nil {
            initialDraft.personID = presetPersonID
        }
        if editingRecord == nil, let returningRecord {
            initialDraft.personID = returningRecord.personID
            initialDraft.eventType = presetEventType ?? returningRecord.eventType
            initialDraft.relationship = returningRecord.relationship
            if initialDraft.contact.isEmpty {
                initialDraft.contact = returningRecord.contact
            }
        }
        _draft = State(initialValue: initialDraft)
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
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("完成") {
                    focusedField = nil
                }
            }
        }
        .onChange(of: draft.type) { _, type in
            if type == .given {
                draft.isReturned = false
                draft.hostedEventID = nil
                draft.hostedEventTitle = ""
                draft.createsHostedEvent = false
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
        .sheet(isPresented: $showsPersonPicker) {
            PersonPickerSheet { person in
                selectPerson(person)
                showsPersonPicker = false
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .alert("保存失败", isPresented: Binding(
            get: { saveErrorMessage != nil },
            set: { if !$0 { saveErrorMessage = nil } }
        )) {
            Button("知道了", role: .cancel) {}
        } message: {
            Text(saveErrorMessage ?? "请稍后再试。")
        }
        .alert("通知未开启", isPresented: Binding(
            get: { notificationNotice != nil },
            set: { if !$0 { notificationNotice = nil } }
        )) {
            Button("知道了", role: .cancel) {}
        } message: {
            Text(notificationNotice ?? "仍会保留 App 内提醒。")
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
        .frame(minHeight: 124, alignment: .top)
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
        // 已归属场次时先由“归属一场事”菜单显式解除，再允许切换收/送类型，
        // 避免类型变化时静默清掉 hostedEventID。
        .disabled(isHostedEventLocked)
        .opacity(isHostedEventLocked ? 0.72 : 1)
        .accessibilityHint(isHostedEventLocked ? "请先解除一场事归属，再修改收送类型" : "")
    }

    private var mainForm: some View {
        PaperCard(padding: 14, spacing: 10) {
            // 姓名输入
            VStack(alignment: .leading, spacing: 6) {
                fieldRow(title: "姓名", icon: "person.crop.circle", iconAction: {
                    focusedField = nil
                    showsPersonPicker = true
                }) {
                    TextField("请输入姓名", text: $draft.personName)
                        .font(.bodyKai(14))
                        .foregroundStyle(LWColors.ink)
                        .textInputAutocapitalization(.never)
                        .submitLabel(.next)
                        .focused($focusedField, equals: .name)
                        .onSubmit { focusedField = .amount }
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
                AmountTextField(
                    amountText: $draft.amountText,
                    currencySize: 24,
                    amountSize: 36,
                    focusedField: $focusedField
                )
                if let amountError = MoneyAmount.validationMessage(for: draft.amountText) {
                    Label(amountError, systemImage: "exclamationmark.circle")
                        .font(.bodySong(11))
                        .foregroundStyle(LWColors.cinnabar)
                }
                amountChips
            }

            GoldLineDivider()

            // 事件选择 - 横向标签
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 5) {
                    Text("事件")
                        .font(.titleSong(15))
                        .foregroundStyle(LWColors.ink)
                    if isHostedEventLocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(LWColors.muted)
                    }
                }
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
                    if isHostedEventLocked {
                        // 归属场次：日期以一场事为准，锁定展示
                        HStack(spacing: 6) {
                            VStack(alignment: .trailing, spacing: 2) {
                                Text(draft.date.lwDayText)
                                    .font(.bodySong(13))
                                    .foregroundStyle(LWColors.ink)
                                Text(draft.date.lwLunarText)
                                    .font(.bodySong(10))
                                    .foregroundStyle(LWColors.warmGold)
                            }
                            Image(systemName: "lock.fill")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(LWColors.muted)
                        }
                    } else {
                        ChineseDatePickerButton(date: $draft.date)
                    }
                }
                if !isHostedEventLocked {
                    quickDateButtons
                }
            }
        }
    }

    private var eventChipWrap: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 52), spacing: 8)], alignment: .leading, spacing: 8) {
            ForEach(GiftEventType.allCases) { event in
                Button {
                    guard !isHostedEventLocked else { return }
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
                        .opacity(isHostedEventLocked && draft.eventType != event ? 0.45 : 1)
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
                        draft.hostedEventTitle = ""
                        draft.createsHostedEvent = false
                    } label: {
                        hostedEventMenuItem(
                            "不归属一场事",
                            isSelected: draft.hostedEventID == nil && !draft.createsHostedEvent
                        )
                    }
                    Button {
                        draft.hostedEventID = nil
                        draft.createsHostedEvent = true
                    } label: {
                        hostedEventMenuItem(
                            "新建 · \(HostedEventService.defaultTitle(for: draft.eventType))",
                            isSelected: draft.hostedEventID == nil && draft.createsHostedEvent
                        )
                    }
                    ForEach(hostedEvents) { event in
                        Button {
                            draft.hostedEventID = event.id
                            draft.createsHostedEvent = false
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
            if draft.hostedEventID == nil && draft.createsHostedEvent {
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
            Text(hostedEventHelpText)
                .font(.bodySong(11))
                .foregroundStyle(LWColors.muted)
        }
    }

    private var selectedHostedEventLabel: String {
        guard let eventID = draft.hostedEventID,
              let event = hostedEvents.first(where: { $0.id == eventID }) else {
            return draft.createsHostedEvent
                ? "新建 · \(HostedEventService.defaultTitle(for: draft.eventType))"
                : "不归属一场事"
        }
        return "\(event.title) · \(event.date.lwDayText)"
    }

    private var hostedEventHelpText: String {
        if let event = attachedHostedEvent {
            return "归属「\(event.title)」，日期与类型以一场事为准；如需修改请先到一场事中调整，或在上方选择「不归属一场事」。"
        }
        if draft.hostedEventID != nil {
            return "已选择已有场次，事件类型和日期将跟随该场次。"
        }
        if draft.createsHostedEvent {
            return "名称可修改；留空则使用默认名称。"
        }
        return "普通往来不会自动新建场次，需要时可从上方选择。"
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
                        .foregroundStyle(draft.amountFen == amount * 100 ? .white : LWColors.ink)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 7)
                        .background(
                            Capsule()
                                .fill(draft.amountFen == amount * 100 ? LWColors.cinnabar : Color.white.opacity(0.65))
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
                if !draft.isReturned {
                    Toggle(isOn: Binding(
                        get: { draft.returnReminderDate != nil },
                        set: { enabled in
                            updateReminder(enabled)
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
        let suggestionBaseFen = max(100 * 100, (lastRecord?.amountFenValue ?? draft.amountFen) / 10_000 * 10_000)

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
                Text(draft.amountFen.fenCurrencyText)
                    .font(.custom("SourceHanSerifSC-Regular", size: 26))
                    .foregroundStyle(LWColors.cinnabar)
            }

            if let lastRecord {
                GoldLineDivider()
                VStack(alignment: .leading, spacing: 4) {
                    Text("上次往来")
                        .font(.custom("SourceHanSerifSC-Regular", size: 12))
                        .foregroundStyle(LWColors.muted)
                    Text("\(lastRecord.date.lwDayText) \(lastRecord.eventType.title) · \(lastRecord.type.narrativeTitle) \(lastRecord.amountFenValue.fenCurrencyText)")
                        .font(.custom("SourceHanSerifSC-Regular", size: 14))
                        .foregroundStyle(LWColors.ink)
                    Text("按上次金额参考：\(suggestionBaseFen.fenCurrencyText) - \((suggestionBaseFen + 200 * 100).fenCurrencyText)")
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
                        hostedEventID: draft.hostedEventID,
                        hostedEventTitle: ""
                    )
                    draft.createsHostedEvent = false
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
            let people = suggestedPeople(matching: trimmed)
            if !people.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(people.enumerated()), id: \.element.id) { index, person in
                        if let matchingRecord = person.latestRecord {
                            Button {
                                selectPerson(person)
                                focusedField = .amount
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        HStack(spacing: 6) {
                                            Text(person.name)
                                            if let hint = person.identityHint {
                                                Text(hint)
                                                    .font(.bodySong(10))
                                                    .foregroundStyle(LWColors.warmGold)
                                            }
                                        }
                                            .font(.custom("SourceHanSerifSC-Regular", size: 14))
                                            .foregroundStyle(LWColors.ink)
                                        Text("上次：\(matchingRecord.date.lwDayText) \(matchingRecord.eventType.title) · \(matchingRecord.type.title) \(matchingRecord.amountFenValue.fenCurrencyText)")
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
                            if index < people.count - 1 {
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

    private func suggestedPeople(matching query: String) -> [PersonSummary] {
        Array(RecordService.people(from: allRecords)
            .filter {
                PersonIdentity.normalizedName($0.name)
                    .localizedCaseInsensitiveContains(PersonIdentity.normalizedName(query))
            }
            .prefix(3))
    }

    private func selectPerson(_ person: PersonSummary) {
        draft.personName = person.name
        draft.relationship = person.relationship
        draft.contact = person.primaryContact
        draft.personID = person.personID
    }

    private func fieldRow<Content: View>(
        title: String,
        icon: String,
        iconAction: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) -> some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.titleSong(13))
                .foregroundStyle(LWColors.ink)
                .frame(width: 42, alignment: .leading)
            content()
            if let iconAction {
                Button(action: iconAction) {
                    Image(systemName: icon)
                        .font(.system(size: 19, weight: .medium))
                        .foregroundStyle(LWColors.cinnabar)
                        .frame(width: 34, height: 34)
                        .background(LWColors.cinnabar.opacity(0.08), in: Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("选择往来人")
                .accessibilityHint("打开姓名搜索列表，选择后自动填入")
            } else {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(LWColors.warmGold)
            }
        }
    }

    private var quickDateButtons: some View {
        let now = Date.now
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now) ?? now
        let selection = QuickDateSelection.selection(for: draft.date, relativeTo: now)

        return HStack(spacing: 8) {
            quickDate("今天", date: now, selection: selection == .today)
            quickDate("昨天", date: yesterday, selection: selection == .yesterday)
            Text("点右侧日期可自定义")
                .font(.bodySong(11))
                .foregroundStyle(selection == .custom ? LWColors.cinnabar : LWColors.muted)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }

    private func quickDate(_ title: String, date: Date?, selection: Bool) -> some View {
        Button {
            if let date {
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
        let suggestionBaseFen = max(100 * 100, record.amountFenValue / 10_000 * 10_000)

        return PaperCard(padding: 12) {
            HStack(spacing: 10) {
                Image(systemName: "gift")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(LWColors.warmGold)
                    .frame(width: 24)
                VStack(alignment: .leading, spacing: 4) {
                    Text("上次往来：\(record.date.lwDayText) \(record.type.title) \(record.amountFenValue.fenCurrencyText)")
                        .font(.bodySong(13))
                        .foregroundStyle(LWColors.ink)
                    Text("按上次金额参考：\(suggestionBaseFen.fenCurrencyText) - \((suggestionBaseFen + 200 * 100).fenCurrencyText)")
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
        draft.createsHostedEvent = false
        draft.eventType = event.eventType
        draft.date = event.date
    }

    private func defaultReminderDate(now: Date = .now) -> Date {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: now) ?? now
        return Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: tomorrow) ?? tomorrow
    }

    private func updateReminder(_ enabled: Bool) {
        guard enabled else {
            draft.returnReminderDate = nil
            return
        }
        draft.returnReminderDate = defaultReminderDate()
        guard !LocalNotificationService.isEnabled else { return }
        Task { @MainActor in
            do {
                let granted = try await LocalNotificationService.requestAndEnable(records: allRecords)
                if !granted {
                    notificationNotice = "提醒已保存在 App 内，但系统通知权限未开启。可稍后前往“我的 → 系统通知”开启。"
                }
            } catch {
                notificationNotice = "提醒已保存在 App 内，但暂时无法开启系统通知。可稍后前往“我的 → 系统通知”重试。"
            }
        }
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

private struct PersonPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \GiftRecord.date, order: .reverse) private var records: [GiftRecord]
    @State private var searchText = ""

    let onSelect: (PersonSummary) -> Void

    private var people: [PersonSummary] {
        let nameQuery = PersonIdentity.normalizedName(searchText)
        let plainQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return RecordService.people(from: records).filter { person in
            guard !nameQuery.isEmpty else { return true }
            return PersonIdentity.normalizedName(person.name).contains(nameQuery)
                || person.primaryContact.localizedCaseInsensitiveContains(plainQuery)
                || (person.identityHint?.localizedCaseInsensitiveContains(plainQuery) ?? false)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PaperTexture()
                VStack(spacing: 12) {
                    SearchField(
                        placeholder: "搜索姓名或联系方式",
                        text: $searchText,
                        fontSize: 14,
                        iconSize: 17,
                        verticalPadding: 10
                    )

                    if people.isEmpty {
                        Spacer()
                        EmptyStateView(
                            title: records.isEmpty ? "还没有往来人" : "没有找到这个人",
                            message: records.isEmpty ? "先手动填写姓名并保存一笔，下次就能直接选择。" : "换个姓名或联系方式再试。"
                        )
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 9) {
                                ForEach(people) { person in
                                    personRow(person)
                                }
                            }
                            .padding(.bottom, 12)
                        }
                    }
                }
                .padding(.horizontal, LWSpacing.page)
                .padding(.top, 12)
            }
            .navigationTitle("选择往来人")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("取消") { dismiss() }
                        .foregroundStyle(LWColors.cinnabar)
                }
            }
        }
    }

    private func personRow(_ person: PersonSummary) -> some View {
        Button {
            onSelect(person)
            dismiss()
        } label: {
            PaperCard(padding: 12) {
                HStack(spacing: 11) {
                    SealStamp(
                        text: String(person.name.prefix(1)),
                        size: 42,
                        color: person.pendingReturnCount > 0 ? LWColors.cinnabar : LWColors.warmGold
                    )
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 7) {
                            Text(person.name)
                                .font(.bodyKai(16))
                                .foregroundStyle(LWColors.ink)
                            Text(person.relationship.title)
                                .font(.bodySong(10))
                                .foregroundStyle(LWColors.warmGold)
                        }
                        if let latest = person.latestRecord {
                            Text("上次：\(latest.date.lwDayText) · \(latest.eventType.title) · \(latest.amountFenValue.fenCurrencyText)")
                                .font(.bodySong(11))
                                .foregroundStyle(LWColors.muted)
                                .lineLimit(1)
                        }
                        if !person.primaryContact.isEmpty {
                            Text(person.primaryContact)
                                .font(.bodySong(10))
                                .foregroundStyle(LWColors.inkSoft)
                                .lineLimit(1)
                        }
                    }
                    Spacer(minLength: 0)
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(LWColors.cinnabar)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("选择\(person.name)")
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
