import SwiftData
import SwiftUI
import UIKit

struct IPadRootView: View {
    let records: [GiftRecord]
    let hostedEvents: [HostedGiftEvent]

    var body: some View {
        IPadQuickDeskView(records: records, hostedEvents: hostedEvents, openSettings: {})
            .background(PaperTexture())
    }
}

struct DeskPortraitPrompt: View {
    var onExit: (() -> Void)?

    init(onExit: (() -> Void)? = nil) {
        self.onExit = onExit
    }

    var body: some View {
        VStack(spacing: 18) {
            Image("ceremony_table_badge")
                .resizable()
                .scaledToFit()
                .frame(width: 86, height: 86)
            Text("横过来，更好记")
                .font(.titleSong(30))
                .foregroundStyle(LWColors.ink)
            Text("手机与 iPad 礼台模式均为横屏现场登记设计")
                .font(.bodySong(16))
                .foregroundStyle(LWColors.muted)
            if let onExit {
                Button("返回普通模式", action: onExit)
                    .font(.bodySong(14).weight(.semibold))
                    .foregroundStyle(LWColors.cinnabar)
                    .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(PaperTexture())
    }
}

struct IPadQuickDeskView: View {
    @Environment(\.modelContext) private var modelContext

    let records: [GiftRecord]
    let hostedEvents: [HostedGiftEvent]
    let initialHostedEventID: UUID?
    let openSettings: () -> Void

    @State private var name = ""
    @State private var amount = "600"
    @State private var note = ""
    @State private var eventType: GiftEventType = .wedding
    @State private var selectedHostedEventID: UUID?
    @State private var saveErrorMessage: String?
    @State private var showSaved = false
    @State private var showCreateEvent = false
    @State private var toastText = "已记入礼簿"
    @State private var reminderDate = Calendar.current.date(byAdding: .day, value: 30, to: .now) ?? .now
    @FocusState private var nameFocused: Bool

    init(
        records: [GiftRecord],
        hostedEvents: [HostedGiftEvent],
        initialHostedEventID: UUID? = nil,
        openSettings: @escaping () -> Void
    ) {
        self.records = records
        self.hostedEvents = hostedEvents
        self.initialHostedEventID = initialHostedEventID
        self.openSettings = openSettings
        _selectedHostedEventID = State(initialValue: initialHostedEventID)
    }

    private var currentEvent: HostedGiftEvent? {
        hostedEvents.first { $0.id == selectedHostedEventID }
    }

    private var currentEventRecords: [GiftRecord] {
        guard let selectedHostedEventID else { return [] }
        return records
            .filter { $0.hostedEventID == selectedHostedEventID && $0.type == .received }
            .sorted { $0.createdAt > $1.createdAt }
    }

    private var todayRecords: [GiftRecord] {
        guard let selectedHostedEventID else { return [] }
        return records.filter {
            $0.hostedEventID == selectedHostedEventID && Calendar.current.isDateInToday($0.createdAt)
        }
    }

    private var recentRecords: [GiftRecord] {
        guard currentEvent != nil else { return [] }
        return Array(currentEventRecords.prefix(10))
    }

    /// 当前场次未回礼收礼记录中最近使用的提醒日期，作为新登记记录的继承值。
    private var eventReminderDate: Date? {
        currentEventRecords.first { !$0.isReturned && $0.returnReminderDate != nil }?.returnReminderDate
    }

    private var reminderCoveredCount: Int {
        currentEventRecords.filter { !$0.isReturned && $0.returnReminderDate != nil }.count
    }

    private var reminderStatusText: String {
        if let eventReminderDate {
            return "已设 \(eventReminderDate.lwDualDateText) · 覆盖 \(reminderCoveredCount) 笔"
        }
        return "未设置 · 新登记暂不提醒"
    }

    private var uniquePeople: [GiftRecord] {
        var names = Set<String>()
        return records
            .sorted { $0.date > $1.date }
            .filter { names.insert($0.personName).inserted }
            .prefix(12)
            .map { $0 }
    }

    var body: some View {
        GeometryReader { geometry in
            let phone = geometry.size.width < 1000
            let compact = geometry.size.height < 760 || phone
            VStack(spacing: 0) {
                IPadBrandHeader(
                    style: .desk,
                    searchText: nil,
                    openSettings: openSettings
                )
                .frame(height: phone ? 76 : (compact ? 116 : 150))

                if phone {
                    HStack(spacing: 8) {
                        phoneSceneColumn
                            .frame(width: geometry.size.width * 0.22)
                        phoneEntryColumn
                            .disabled(currentEvent == nil)
                            .opacity(currentEvent == nil ? 0.30 : 1)
                        .overlay {
                            if currentEvent == nil {
                                eventRequiredOverlay(compact: true)
                                    .scaleEffect(0.82)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        recentColumn(compact: true)
                            .frame(width: geometry.size.width * 0.255)
                    }
                    .padding(.horizontal, 8)
                    .padding(.bottom, 7)
                } else {
                    HStack(spacing: compact ? 10 : 14) {
                        sceneColumn(compact: compact)
                            .frame(width: geometry.size.width * 0.255)
                        ZStack {
                            entryColumn(compact: compact)
                                .disabled(currentEvent == nil)
                                .opacity(currentEvent == nil ? 0.30 : 1)

                            if currentEvent == nil {
                                eventRequiredOverlay(compact: compact)
                            }
                        }
                            .frame(maxWidth: .infinity)
                        recentColumn(compact: compact)
                            .frame(width: geometry.size.width * 0.295)
                    }
                    .padding(.horizontal, compact ? 16 : 22)
                    .padding(.bottom, compact ? 10 : 14)
                }
            }
        }
        .alert("保存失败", isPresented: Binding(
            get: { saveErrorMessage != nil },
            set: { if !$0 { saveErrorMessage = nil } }
        )) {
            Button("知道了", role: .cancel) {}
        } message: {
            Text(saveErrorMessage ?? "请稍后再试。")
        }
        .sheet(isPresented: $showCreateEvent) {
            HostedEventEditorSheet(event: nil, linkedRecords: records) { event in
                selectedHostedEventID = event.id
                eventType = event.eventType
            }
        }
        .overlay(alignment: .top) {
            if showSaved {
                Label(toastText, systemImage: "checkmark.seal.fill")
                    .font(.bodySong(14).weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 9)
                    .background(LWColors.jade, in: Capsule())
                    .shadow(radius: 8)
                    .padding(.top, 92)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .onAppear {
            if let initialHostedEventID,
               let event = hostedEvents.first(where: { $0.id == initialHostedEventID }) {
                selectedHostedEventID = event.id
                eventType = event.eventType
            } else if initialHostedEventID != nil {
                // 初始场次已被删除时回到待选择状态，避免悬空 eventID。
                selectedHostedEventID = nil
            }
            syncReminderDateWithEvent()
        }
        .onChange(of: hostedEvents.map(\.id)) { _, eventIDs in
            guard let selectedHostedEventID else { return }
            if !eventIDs.contains(selectedHostedEventID) {
                self.selectedHostedEventID = nil
                syncReminderDateWithEvent()
            }
        }
        .onChange(of: selectedHostedEventID) { _, eventID in
            if let eventID,
               let event = hostedEvents.first(where: { $0.id == eventID }) {
                eventType = event.eventType
            }
            syncReminderDateWithEvent()
        }
    }

    private var phoneSceneColumn: some View {
        IPadPanel(padding: 9, fillsHeight: true) {
            Text("当前场次")
                .font(.titleSong(14))
                .foregroundStyle(LWColors.ink)

            Menu {
                Button {
                    showCreateEvent = true
                } label: {
                    Label("新建一场事", systemImage: "plus")
                }
                ForEach(hostedEvents) { event in
                    Button("\(event.title) · \(event.date.lwDayText)") {
                        selectedHostedEventID = event.id
                    }
                }
            } label: {
                VStack(alignment: .leading, spacing: 3) {
                    Text(currentEvent?.title ?? "请选择一场事")
                        .font(.titleSong(13))
                        .foregroundStyle(LWColors.ink)
                        .lineLimit(1)
                    Text(currentEvent == nil ? "选择或新建" : "今日 \(todayRecords.count) 笔")
                        .font(.bodySong(9))
                        .foregroundStyle(LWColors.muted)
                    Image(systemName: "chevron.down")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(LWColors.warmGold)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(9)
                .background(fieldBackground)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 6) {
                Text("现场统计")
                    .font(.titleSong(12))
                    .foregroundStyle(LWColors.ink)
                phoneStat("今日登记", value: "\(todayRecords.count) 笔")
                phoneStat("今日收礼", value: todayReceivedAmountFen.fenCurrencyText)
                phoneStat("本场合计", value: currentEventRecords.reduce(0) { $0 + $1.amountFenValue }.fenCurrencyText)
            }
            .padding(9)
            .background(fieldBackground)

            VStack(alignment: .leading, spacing: 5) {
                Text("回礼提醒")
                    .font(.titleSong(11))
                    .foregroundStyle(LWColors.ink)
                DatePicker("", selection: $reminderDate, displayedComponents: .date)
                    .labelsHidden()
                    .tint(LWColors.cinnabar)
                Text(reminderStatusText)
                    .font(.bodySong(8))
                    .foregroundStyle(LWColors.muted)
                    .lineLimit(2)
                Button {
                    applyReturnReminder()
                } label: {
                    Text("一键设置")
                        .font(.titleSong(10))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 26)
                        .background(LWColors.cinnabar, in: RoundedRectangle(cornerRadius: 7))
                }
                .buttonStyle(.plain)
                .disabled(currentEvent == nil)
                .opacity(currentEvent == nil ? 0.5 : 1)
            }
            .padding(9)
            .background(fieldBackground)

            Spacer(minLength: 0)

            Button {
                showCreateEvent = true
            } label: {
                Label("新建场次", systemImage: "plus.circle")
                    .font(.titleSong(11))
                    .foregroundStyle(LWColors.cinnabar)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.plain)
        }
    }

    private var phoneEntryColumn: some View {
        IPadPanel(padding: 10, fillsHeight: true) {
            HStack {
                Text("礼台 · 快速登记")
                    .font(.titleSong(16))
                    .foregroundStyle(LWColors.ink)
                Spacer()
                Text("保存后继续下一位")
                    .font(.bodySong(8))
                    .foregroundStyle(LWColors.muted)
            }

            HStack(spacing: 8) {
                TextField("来宾姓名", text: $name)
                    .font(.bodySong(13))
                    .textInputAutocapitalization(.never)
                    .focused($nameFocused)
                    .padding(.horizontal, 10)
                    .frame(maxWidth: .infinity)
                    .frame(height: 38)
                    .background(fieldBackground)

                HStack(spacing: 4) {
                    TextField("金额", text: $amount)
                        .keyboardType(.decimalPad)
                        .font(.amountKai(16))
                    Text("元")
                        .font(.titleSong(10))
                        .foregroundStyle(LWColors.inkSoft)
                }
                .padding(.horizontal, 10)
                .frame(width: 116, height: 38)
                .background(fieldBackground)
            }

            HStack(spacing: 6) {
                ForEach([200, 500, 600, 1000], id: \.self) { value in
                    Button {
                        amount = "\(value)"
                        HapticsManager.lightTap()
                    } label: {
                        Text(value.formatted())
                            .font(.amountKai(13))
                            .foregroundStyle(amount == "\(value)" ? LWColors.cinnabar : LWColors.ink)
                            .frame(maxWidth: .infinity)
                            .frame(height: 30)
                            .background(
                                RoundedRectangle(cornerRadius: 7)
                                    .fill(LWColors.card.opacity(0.62))
                                    .overlay(RoundedRectangle(cornerRadius: 7).stroke(amount == "\(value)" ? LWColors.cinnabar.opacity(0.7) : LWColors.cardStroke.opacity(0.6)))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }

            TextField("备注（选填）：关系、桌号等", text: $note)
                .font(.bodySong(11))
                .onChange(of: note) { _, value in
                    if value.count > 50 { note = String(value.prefix(50)) }
                }
                .padding(.horizontal, 10)
                .frame(height: 34)
                .background(fieldBackground)

            Spacer(minLength: 0)

            Button {
                saveAndContinue()
            } label: {
                Label("记入并继续", systemImage: "checkmark.seal.fill")
                    .font(.titleSong(15))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 42)
                    .background(LWColors.cinnabar, in: RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
            .disabled(!canSaveDraft)
            .opacity(canSaveDraft ? 1 : 0.55)
        }
    }

    private func phoneStat(_ title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.bodySong(9))
                .foregroundStyle(LWColors.inkSoft)
            Spacer(minLength: 3)
            Text(value)
                .font(.amountKai(11))
                .foregroundStyle(LWColors.cinnabar)
                .lineLimit(1)
                .minimumScaleFactor(0.65)
        }
    }

    private func sceneColumn(compact: Bool) -> some View {
        IPadPanel(padding: compact ? 11 : 14, fillsHeight: true) {
            Text("当前场景")
                .font(.titleSong(compact ? 15 : 17))
                .foregroundStyle(LWColors.ink)

            VStack(alignment: .leading, spacing: compact ? 7 : 9) {
                Menu {
                    Button {
                        showCreateEvent = true
                    } label: {
                        Label("新建一场事", systemImage: "plus")
                    }
                    ForEach(hostedEvents) { event in
                        Button {
                            selectedHostedEventID = event.id
                        } label: {
                            Text("\(event.title) · \(event.date.lwDayText)")
                        }
                    }
                } label: {
                    HStack(spacing: 11) {
                        Image("ledger_book_badge")
                            .resizable()
                            .scaledToFit()
                            .frame(width: compact ? 38 : 46, height: compact ? 38 : 46)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(currentEvent?.title ?? "请选择一场事")
                                .font(.titleSong(compact ? 15 : 17))
                                .foregroundStyle(LWColors.ink)
                                .lineLimit(1)
                            Text(currentEvent == nil ? "选择或新建后才能录入" : "共 \(currentEventRecords.count) 笔")
                                .font(.bodySong(compact ? 10 : 12))
                                .foregroundStyle(LWColors.muted)
                        }
                        Spacer(minLength: 4)
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(LWColors.warmGold)
                    }
                }
                .buttonStyle(.plain)
                .frame(height: compact ? 46 : 54)

                GoldLineDivider()
                sceneInfoRow(
                    "事件类型",
                    value: currentEvent?.eventType.title ?? "未选择",
                    image: currentEvent?.eventType == .wedding ? "double_happiness_badge" : nil,
                    compact: compact
                )
                GoldLineDivider()
                sceneInfoRow("当前模式", value: "礼台模式", image: "ceremony_table_badge", compact: compact)
                GoldLineDivider()
                sceneInfoRow("礼台编号", value: "1 号礼台", image: nil, compact: compact)
            }
            .padding(compact ? 10 : 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.24))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(LWColors.cardStroke.opacity(0.40)))
            )

            GoldLineDivider()
            Text("今日统计")
                .font(.titleSong(compact ? 15 : 17))
                .foregroundStyle(LWColors.ink)

            HStack(spacing: 0) {
                statItem(icon: "doc.text", title: "今日登记", value: "\(todayRecords.count) 份", compact: compact)
                Divider()
                    .overlay(LWColors.cardStroke.opacity(0.38))
                    .frame(height: compact ? 54 : 64)
                statItem(icon: "tray.and.arrow.down", title: "今日收礼", value: todayReceivedAmountFen.fenCurrencyText, compact: compact)
                Divider()
                    .overlay(LWColors.cardStroke.opacity(0.38))
                    .frame(height: compact ? 54 : 64)
                statItem(icon: "person.2", title: "来宾人数", value: "\(Set(todayRecords.map(\.personName)).count) 人", compact: compact)
            }
            .padding(.vertical, compact ? 8 : 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.20))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(LWColors.cardStroke.opacity(0.34)))
            )

            GoldLineDivider()
            Text("回礼提醒")
                .font(.titleSong(compact ? 15 : 17))
                .foregroundStyle(LWColors.ink)

            VStack(alignment: .leading, spacing: compact ? 6 : 8) {
                DatePicker("提醒日期", selection: $reminderDate, displayedComponents: .date)
                    .font(.bodySong(compact ? 11 : 13))
                    .foregroundStyle(LWColors.inkSoft)
                    .tint(LWColors.cinnabar)
                HStack(spacing: 8) {
                    Text(reminderStatusText)
                        .font(.bodySong(compact ? 9 : 10))
                        .foregroundStyle(LWColors.muted)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    Spacer(minLength: 4)
                    Button {
                        applyReturnReminder()
                    } label: {
                        Text("一键设置")
                            .font(.titleSong(compact ? 11 : 13))
                            .foregroundStyle(.white)
                            .padding(.horizontal, compact ? 11 : 15)
                            .frame(height: compact ? 28 : 32)
                            .background(LWColors.cinnabar, in: RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                    .disabled(currentEvent == nil)
                    .opacity(currentEvent == nil ? 0.5 : 1)
                }
            }
            .padding(compact ? 10 : 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.20))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(LWColors.cardStroke.opacity(0.34)))
            )

            Spacer(minLength: 0)

            totalPanel(compact: compact)
        }
    }

    private func eventRequiredOverlay(compact: Bool) -> some View {
        VStack(spacing: compact ? 10 : 14) {
            Image("ledger_book_badge")
                .resizable()
                .scaledToFit()
                .frame(width: compact ? 48 : 60, height: compact ? 48 : 60)

            Text("先选择一场事")
                .font(.titleSong(compact ? 20 : 24))
                .foregroundStyle(LWColors.ink)

            Text("每笔现场收礼都要归入明确的场次\n选择已有场次，或先新建一场事")
                .font(.bodySong(compact ? 11 : 13))
                .foregroundStyle(LWColors.muted)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Menu {
                ForEach(hostedEvents) { event in
                    Button {
                        selectedHostedEventID = event.id
                    } label: {
                        Text("\(event.title) · \(event.date.lwDayText)")
                    }
                }
            } label: {
                HStack {
                    Image(systemName: "list.bullet.rectangle")
                    Text(hostedEvents.isEmpty ? "暂无可选场次" : "选择已有场次")
                    Spacer()
                    Image(systemName: "chevron.down")
                }
                .font(.titleSong(compact ? 12 : 14))
                .foregroundStyle(LWColors.ink)
                .padding(.horizontal, 14)
                .frame(width: compact ? 250 : 290, height: compact ? 38 : 44)
                .background(fieldBackground)
            }
            .buttonStyle(.plain)
            .disabled(hostedEvents.isEmpty)

            Button {
                showCreateEvent = true
            } label: {
                Label("新建一场事", systemImage: "plus.circle.fill")
                    .font(.titleSong(compact ? 13 : 15))
                    .foregroundStyle(.white)
                    .frame(width: compact ? 250 : 290, height: compact ? 40 : 46)
                    .background(LWColors.cinnabar, in: RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
        }
        .padding(compact ? 18 : 24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(LWColors.card.opacity(0.96))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(LWColors.cardStroke.opacity(0.75)))
                .shadow(color: LWColors.ink.opacity(0.10), radius: 18, y: 8)
        )
    }

    private func entryColumn(compact: Bool) -> some View {
        IPadPanel(padding: compact ? 14 : 20, fillsHeight: true) {
            VStack(spacing: 2) {
                Text("礼台 · 快速登记")
                    .font(.titleSong(compact ? 21 : 24))
                    .foregroundStyle(LWColors.ink)
                Text("主礼台快速录入，有时有心")
                    .font(.bodySong(compact ? 10 : 12))
                    .foregroundStyle(LWColors.muted)
            }
            .frame(maxWidth: .infinity)

            Spacer(minLength: compact ? 2 : 6)

            fieldTitle("来宾姓名", compact: compact)
            HStack(spacing: 0) {
                TextField("请输入来宾姓名", text: $name)
                    .font(.bodySong(compact ? 15 : 17))
                    .foregroundStyle(LWColors.ink)
                    .textInputAutocapitalization(.never)
                    .focused($nameFocused)
                    .padding(.horizontal, 14)
                Divider().overlay(LWColors.cardStroke.opacity(0.5))
                Menu {
                    ForEach(uniquePeople) { record in
                        Button(record.personName) {
                            name = record.personName
                        }
                    }
                } label: {
                    VStack(spacing: 2) {
                        Image(systemName: "person.crop.circle.badge.checkmark")
                            .font(.system(size: compact ? 17 : 20))
                        Text("通讯录")
                            .font(.bodySong(9))
                    }
                    .foregroundStyle(LWColors.warmGold)
                    .frame(width: compact ? 64 : 76)
                }
            }
            .frame(height: compact ? 42 : 48)
            .background(fieldBackground)

            Spacer(minLength: compact ? 2 : 6)

            fieldTitle("礼金金额", compact: compact)
            HStack(alignment: .firstTextBaseline, spacing: 7) {
                TextField("请输入礼金金额", text: $amount)
                    .keyboardType(.decimalPad)
                    .font(.amountKai(compact ? 19 : 22))
                    .foregroundStyle(LWColors.ink)
                Text("元")
                    .font(.titleSong(compact ? 13 : 15))
                    .foregroundStyle(LWColors.inkSoft)
            }
            .padding(.horizontal, 14)
            .frame(height: compact ? 42 : 48)
            .background(fieldBackground)

            Spacer(minLength: compact ? 2 : 6)

            HStack {
                fieldTitle("常用金额", compact: compact)
                Spacer()
                Text("点选后仍可修改")
                    .font(.bodySong(9))
                    .foregroundStyle(LWColors.muted)
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: compact ? 8 : 10), count: 4), spacing: compact ? 7 : 9) {
                ForEach([200, 300, 500, 600, 800, 1000, 1200, 1600], id: \.self) { value in
                    Button {
                        amount = "\(value)"
                        HapticsManager.lightTap()
                    } label: {
                        Text(value.formatted())
                            .font(.amountKai(compact ? 16 : 19))
                            .foregroundStyle(amount == "\(value)" ? LWColors.cinnabar : LWColors.ink)
                            .frame(maxWidth: .infinity)
                            .frame(height: compact ? 34 : 40)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(LWColors.card.opacity(0.62))
                                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(amount == "\(value)" ? LWColors.cinnabar.opacity(0.7) : LWColors.cardStroke.opacity(0.6)))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }

            Spacer(minLength: compact ? 2 : 6)

            fieldTitle("备注（选填）", compact: compact)
            HStack(alignment: .bottom) {
                TextField("如：关系、桌号、备注等", text: $note, axis: .vertical)
                    .font(.bodySong(compact ? 12 : 14))
                    .lineLimit(1...2)
                    .onChange(of: note) { _, value in
                        if value.count > 50 { note = String(value.prefix(50)) }
                    }
                Text("\(note.count)/50")
                    .font(.bodySong(9))
                    .foregroundStyle(LWColors.muted)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, compact ? 8 : 10)
            .background(fieldBackground)

            Spacer(minLength: 0)

            Button {
                saveAndContinue()
            } label: {
                HStack(spacing: 14) {
                    Text("记入并继续")
                        .font(.titleSong(compact ? 18 : 21))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: compact ? 46 : 54)
                .background(
                    Image("red_button_texture")
                        .resizable()
                        .scaledToFill()
                        .overlay(LWColors.cinnabar.opacity(0.48))
                )
                .clipShape(RoundedRectangle(cornerRadius: 11))
                .overlay(RoundedRectangle(cornerRadius: 11).stroke(LWColors.warmGold.opacity(0.75), lineWidth: 1.2))
            }
            .buttonStyle(.plain)
            .disabled(!canSaveDraft)
            .opacity(canSaveDraft ? 1 : 0.55)

            Label("保存后自动清空，继续登记下一位", systemImage: "checkmark.square.fill")
                .font(.bodySong(compact ? 9 : 10))
                .foregroundStyle(LWColors.warmGold)
                .frame(maxWidth: .infinity)
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }

    private func recentColumn(compact: Bool) -> some View {
        IPadPanel(padding: 0) {
            HStack {
                Text("最近记录")
                    .font(.titleSong(compact ? 15 : 17))
                    .foregroundStyle(LWColors.ink)
                Spacer()
                Text("共 \(currentEventRecords.count) 笔")
                    .font(.bodySong(compact ? 10 : 11))
                    .foregroundStyle(LWColors.muted)
            }
            .padding(.horizontal, compact ? 13 : 16)
            .padding(.top, compact ? 12 : 15)
            .padding(.bottom, compact ? 7 : 9)

            if recentRecords.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "book.pages")
                        .font(.system(size: 30, weight: .light))
                    Text(currentEvent == nil ? "选择一场事后显示现场记录" : "第一位来宾登记后会显示在这里")
                        .font(.bodySong(12))
                }
                .foregroundStyle(LWColors.muted)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(recentRecords) { record in
                            HStack(spacing: 8) {
                                Text(record.personName)
                                    .font(.titleSong(compact ? 13 : 15))
                                    .foregroundStyle(LWColors.ink)
                                    .lineLimit(1)
                                Spacer(minLength: 4)
                                Text(record.amountFenValue.fenCurrencyText)
                                    .font(.amountKai(compact ? 14 : 16))
                                    .foregroundStyle(record.type.accentColor)
                                Text(record.createdAt.lwTimeText)
                                    .font(.bodySong(compact ? 9 : 10))
                                    .foregroundStyle(LWColors.muted)
                                    .frame(width: compact ? 34 : 40)
                                Text(record.relationship.title)
                                    .font(.bodySong(9))
                                    .foregroundStyle(LWColors.warmGold)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(LWColors.goldPale.opacity(0.20), in: RoundedRectangle(cornerRadius: 5))
                            }
                            .padding(.horizontal, compact ? 13 : 16)
                            .frame(height: compact ? 42 : 48)
                            Divider()
                                .overlay(LWColors.cardStroke.opacity(0.35))
                                .padding(.horizontal, compact ? 13 : 16)
                        }
                    }
                }
            }
        }
        .frame(maxHeight: .infinity)
    }

    private var fieldBackground: some View {
        RoundedRectangle(cornerRadius: 9)
            .fill(Color.white.opacity(0.38))
            .overlay(RoundedRectangle(cornerRadius: 9).stroke(LWColors.cardStroke.opacity(0.55)))
    }

    private func fieldTitle(_ title: String, compact: Bool) -> some View {
        Text(title)
            .font(.titleSong(compact ? 12 : 14))
            .foregroundStyle(LWColors.ink)
    }

    private func sceneInfoRow(_ title: String, value: String, image: String?, compact: Bool) -> some View {
        HStack(spacing: compact ? 7 : 9) {
            Text(title)
                .font(.bodySong(compact ? 11 : 13))
                .foregroundStyle(LWColors.ink)
                .frame(width: compact ? 60 : 70, alignment: .leading)
            Text(value)
                .font(.bodySong(compact ? 11 : 13))
                .foregroundStyle(LWColors.inkSoft)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .lineLimit(1)
            if let image {
                Image(image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: compact ? 22 : 26, height: compact ? 22 : 26)
            } else {
                Color.clear
                    .frame(width: compact ? 22 : 26, height: compact ? 22 : 26)
            }
        }
        .frame(height: compact ? 24 : 28)
    }

    private func statItem(icon: String, title: String, value: String, compact: Bool) -> some View {
        VStack(spacing: compact ? 3 : 5) {
            Image(systemName: icon)
                .font(.system(size: compact ? 14 : 17, weight: .light))
                .foregroundStyle(LWColors.warmGold)
                .frame(width: compact ? 32 : 38, height: compact ? 32 : 38)
                .overlay(Circle().stroke(LWColors.warmGold.opacity(0.65)))
            Text(title)
                .font(.bodySong(compact ? 8 : 9))
                .foregroundStyle(LWColors.inkSoft)
            Text(value)
                .font(.amountKai(compact ? 12 : 14))
                .foregroundStyle(LWColors.cinnabar)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
    }

    private func totalPanel(compact: Bool) -> some View {
        VStack(alignment: .leading, spacing: compact ? 7 : 10) {
            Text("总计数据")
                .font(.titleSong(compact ? 14 : 16))
            HStack(spacing: 0) {
                totalItem("总收礼", value: receivedAmount, compact: compact)
                Divider().overlay(Color.white.opacity(0.32))
                totalItem("总送礼", value: givenAmount, compact: compact)
                Divider().overlay(Color.white.opacity(0.32))
                totalItem("往来结余", value: receivedAmount - givenAmount, compact: compact)
            }
        }
        .foregroundStyle(.white)
        .padding(compact ? 11 : 14)
        .background(
            Image("red_ledger_texture")
                .resizable()
                .scaledToFill()
                .overlay(LWColors.cinnabarDark.opacity(0.36))
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(LWColors.warmGold.opacity(0.65)))
        .frame(height: compact ? 112 : 128)
    }

    private func totalItem(_ title: String, value: Int, compact: Bool) -> some View {
        VStack(spacing: 2) {
            Text(title).font(.bodySong(compact ? 8 : 9))
            Text(value.fenCurrencyText)
                .font(.amountKai(compact ? 12 : 15))
                .lineLimit(1)
                .minimumScaleFactor(0.65)
        }
        .frame(maxWidth: .infinity)
    }

    private var todayReceivedAmountFen: Int {
        todayRecords.filter { $0.type == .received }.reduce(0) { $0 + $1.amountFenValue }
    }

    private var receivedAmount: Int {
        records.filter { $0.type == .received }.reduce(0) { $0 + $1.amountFenValue }
    }

    private var givenAmount: Int {
        records.filter { $0.type == .given }.reduce(0) { $0 + $1.amountFenValue }
    }

    private var canSaveDraft: Bool {
        currentEvent != nil
            && !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && (MoneyAmount.parseFen(amount) ?? 0) > 0
    }

    private func saveAndContinue() {
        guard let currentEvent else { return }
        var draft = GiftRecordDraft(personName: name, type: .received)
        draft.amountText = amount
        draft.note = note
        draft.eventType = currentEvent.eventType
        draft.relationship = inheritedRelationship(for: name)
        draft.returnReminderDate = eventReminderDate
        draft.hostedEventID = currentEvent.id
        guard draft.isValid else { return }

        do {
            let record = try RecordService.insert(draft, in: modelContext)
            selectedHostedEventID = record.hostedEventID
            eventType = record.eventType
            name = ""
            note = ""
            toastText = "已记入礼簿"
            showSaved = true
            nameFocused = true
            HapticsManager.success()
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(1.2))
                withAnimation { showSaved = false }
            }
        } catch {
            saveErrorMessage = error.localizedDescription
        }
    }

    /// 按规范化姓名匹配最近一条历史记录并继承其关系（“张 三”与“张三”视为同一人）。
    private func inheritedRelationship(for personName: String) -> RelationshipType {
        let normalized = PersonIdentity.normalizedName(personName)
        return records
            .filter { PersonIdentity.normalizedName($0.personName) == normalized }
            .max { $0.date < $1.date }?
            .relationship ?? .friend
    }

    /// 一键为当前场次所有「收礼且未回礼」的记录设置回礼提醒日期。
    private func applyReturnReminder() {
        guard let currentEvent else { return }
        do {
            let count = try QuickDeskReminderService.setReturnReminder(
                forEventID: currentEvent.id,
                date: reminderDate,
                in: modelContext
            )
            toastText = count > 0 ? "已为 \(count) 笔收礼设置回礼提醒" : "本场暂无待回礼的收礼"
            showSaved = true
            HapticsManager.success()
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(1.6))
                withAnimation { showSaved = false }
            }
        } catch {
            saveErrorMessage = error.localizedDescription
        }
    }

    /// 切换/进入场次时，将日期选择器对齐到该场次已设提醒日期，缺省为 30 天后。
    private func syncReminderDateWithEvent() {
        reminderDate = eventReminderDate
            ?? Calendar.current.date(byAdding: .day, value: 30, to: .now)
            ?? .now
    }
}

private struct IPadLedgerView: View {
    @Environment(\.modelContext) private var modelContext

    let records: [GiftRecord]
    let hostedEvents: [HostedGiftEvent]
    let startsSearching: Bool
    let openSettings: () -> Void

    @State private var searchText = ""
    @State private var filter: IPadLedgerFilter = .all
    @State private var selectedRecordID: UUID?
    @State private var editingRecord: GiftRecord?
    @State private var newRecordRequest: IPadNewRecordRequest?
    @State private var pendingDelete: GiftRecord?
    @State private var exportURL: URL?
    @State private var errorMessage: String?
    @FocusState private var searchFocused: Bool

    private var filteredRecords: [GiftRecord] {
        SearchService.filter(records, query: searchText)
            .filter(filter.includes)
            .sorted { $0.date > $1.date }
    }

    private var groupedRecords: [(String, [GiftRecord])] {
        Dictionary(grouping: filteredRecords, by: { $0.date.lwMonthText })
            .map { month, records in (month, records.sorted { $0.date > $1.date }) }
            .sorted { ($0.1.first?.date ?? .distantPast) > ($1.1.first?.date ?? .distantPast) }
    }

    private var selectedRecord: GiftRecord? {
        if let selectedRecordID, let match = records.first(where: { $0.id == selectedRecordID }) {
            return match
        }
        return filteredRecords.first
    }

    var body: some View {
        GeometryReader { geometry in
            let compact = geometry.size.height < 760
            VStack(spacing: 0) {
                IPadBrandHeader(
                    style: .ledger,
                    searchText: $searchText,
                    openSettings: openSettings
                )
                .focused($searchFocused)
                .frame(height: compact ? 116 : 150)

                HStack(spacing: compact ? 10 : 14) {
                    filtersColumn(compact: compact)
                        .frame(width: geometry.size.width * 0.245)
                    recordsColumn(compact: compact)
                        .frame(width: geometry.size.width * 0.37)
                    detailColumn(compact: compact)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, compact ? 16 : 22)
                .padding(.bottom, compact ? 10 : 14)
            }
        }
        .onAppear {
            selectedRecordID = selectedRecordID ?? filteredRecords.first?.id
            if startsSearching {
                Task { @MainActor in
                    try? await Task.sleep(for: .milliseconds(250))
                    searchFocused = true
                }
            }
        }
        .onChange(of: filteredRecords.map(\.id)) { _, ids in
            if selectedRecordID == nil || !ids.contains(selectedRecordID!) {
                selectedRecordID = ids.first
            }
        }
        .sheet(item: $editingRecord) { record in
            NavigationStack { AddRecordView(editingRecord: record) }
                .presentationDetents([.large])
        }
        .sheet(item: $newRecordRequest) { request in
            NavigationStack {
                AddRecordView(presetName: request.name, presetType: .received)
            }
            .presentationDetents([.large])
        }
        .sheet(item: $exportURL) { url in
            IPadShareSheet(items: [url])
        }
        .confirmationDialog("确认删除这条往来记录？", isPresented: Binding(
            get: { pendingDelete != nil },
            set: { if !$0 { pendingDelete = nil } }
        ), titleVisibility: .visible) {
            Button("删除记录", role: .destructive) { deletePendingRecord() }
            Button("取消", role: .cancel) { pendingDelete = nil }
        } message: {
            Text("删除后无法恢复，但同一人的其他往来记录会继续保留。")
        }
        .alert("操作失败", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("知道了", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "请稍后再试。")
        }
    }

    private func filtersColumn(compact: Bool) -> some View {
        IPadPanel(padding: compact ? 11 : 14) {
            HStack {
                Text("账本与筛选")
                    .font(.titleSong(compact ? 14 : 16))
                Spacer()
                Button {
                    filter = .all
                    searchText = ""
                } label: {
                    Label("重置", systemImage: "arrow.counterclockwise")
                        .font(.bodySong(compact ? 9 : 10))
                }
                .buttonStyle(.plain)
                .foregroundStyle(LWColors.cinnabar)
            }

            ledgerSourceRow(
                image: "ledger_book_badge",
                title: "礼往来总礼簿",
                subtitle: "共 \(records.count) 条",
                selected: filter == .all,
                compact: compact
            ) { filter = .all }

            ledgerSourceRow(
                systemImage: "rectangle.stack",
                title: "我家办事",
                subtitle: "共 \(hostedEvents.count) 场",
                selected: false,
                compact: compact
            ) { filter = .received }

            ledgerSourceRow(
                systemImage: "arrow.up.right.circle",
                title: "送礼往来",
                subtitle: "共 \(records.filter { $0.type == .given }.count) 条",
                selected: filter == .given,
                compact: compact
            ) { filter = .given }

            GoldLineDivider()
            Text("筛选分类")
                .font(.titleSong(compact ? 13 : 15))
                .padding(.top, 2)

            ForEach(IPadLedgerFilter.allCases) { item in
                Button {
                    filter = item
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: item.icon)
                            .font(.system(size: compact ? 12 : 14))
                            .frame(width: 20)
                        Text(item.title)
                            .font(.bodySong(compact ? 11 : 13))
                        Spacer()
                        Text("\(records.filter(item.includes).count)")
                            .font(.bodySong(compact ? 10 : 11))
                    }
                    .foregroundStyle(filter == item ? .white : LWColors.inkSoft)
                    .padding(.horizontal, 12)
                    .frame(height: compact ? 34 : 40)
                    .background(filter == item ? LWColors.cinnabar : Color.clear, in: RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }

            Spacer(minLength: 0)
            Button {
                searchFocused = true
            } label: {
                Label("筛选条件", systemImage: "line.3.horizontal.decrease")
                    .font(.bodySong(compact ? 11 : 12))
                    .foregroundStyle(LWColors.inkSoft)
                    .frame(maxWidth: .infinity)
                    .frame(height: compact ? 36 : 42)
                    .background(fieldBackground)
            }
            .buttonStyle(.plain)
        }
        .frame(maxHeight: .infinity)
    }

    private func recordsColumn(compact: Bool) -> some View {
        VStack(spacing: compact ? 8 : 10) {
            HStack {
                Text("往来记录（\(filteredRecords.count)）")
                    .font(.titleSong(compact ? 14 : 16))
                Spacer()
                Button { } label: {
                    Label("按日期", systemImage: "line.3.horizontal.decrease")
                }
                .buttonStyle(.plain)
                Button { exportRecords() } label: {
                    Label("导出", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(.plain)
            }
            .font(.bodySong(compact ? 9 : 10))
            .foregroundStyle(LWColors.inkSoft)
            .padding(.horizontal, 6)

            ScrollView {
                LazyVStack(spacing: compact ? 7 : 9) {
                    if groupedRecords.isEmpty {
                        VStack(spacing: 10) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 30, weight: .light))
                            Text("没有符合条件的记录")
                                .font(.bodySong(13))
                        }
                        .foregroundStyle(LWColors.muted)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 80)
                    }

                    ForEach(groupedRecords, id: \.0) { month, monthRecords in
                        IPadPanel(padding: 0) {
                            HStack {
                                Text(month)
                                    .font(.titleSong(compact ? 12 : 14))
                                Spacer()
                                Text("收礼 \(monthRecords.filter { $0.type == .received }.count) ｜ 送礼 \(monthRecords.filter { $0.type == .given }.count)")
                                    .font(.bodySong(compact ? 8 : 9))
                                    .foregroundStyle(LWColors.muted)
                            }
                            .padding(.horizontal, 12)
                            .frame(height: compact ? 31 : 36)

                            ForEach(monthRecords.prefix(compact ? 5 : 7)) { record in
                                Button {
                                    selectedRecordID = record.id
                                } label: {
                                    recordListRow(record, selected: selectedRecordID == record.id, compact: compact)
                                }
                                .buttonStyle(.plain)
                            }

                            if monthRecords.count > (compact ? 5 : 7) {
                                Text("本月另有 \(monthRecords.count - (compact ? 5 : 7)) 条记录")
                                    .font(.bodySong(9))
                                    .foregroundStyle(LWColors.muted)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 26)
                            }
                        }
                    }
                }
            }
        }
        .frame(maxHeight: .infinity)
    }

    private func detailColumn(compact: Bool) -> some View {
        IPadPanel(padding: compact ? 13 : 17) {
            if let record = selectedRecord {
                Text("\(record.type.title)记录")
                    .font(.bodySong(compact ? 9 : 10))
                    .foregroundStyle(LWColors.warmGold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(LWColors.goldPale.opacity(0.18), in: RoundedRectangle(cornerRadius: 5))

                HStack(alignment: .firstTextBaseline) {
                    Text(record.personName)
                        .font(.titleSong(compact ? 22 : 27))
                        .foregroundStyle(LWColors.ink)
                    Text(record.relationship.title)
                        .font(.bodySong(compact ? 9 : 10))
                        .foregroundStyle(LWColors.warmGold)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(LWColors.goldPale.opacity(0.20), in: RoundedRectangle(cornerRadius: 5))
                    Spacer()
                    Text(signedAmount(record))
                        .font(.amountKai(compact ? 20 : 25))
                        .foregroundStyle(record.type.accentColor)
                }

                GoldLineDivider()
                detailRow("事件类型", value: record.eventType.title, compact: compact)
                detailRow("往来类型", value: record.type.title, compact: compact)
                detailRow("日期时间", value: "\(record.date.lwDayText)  \(record.date.lwTimeText)", compact: compact)
                detailRow("礼金金额", value: record.amountFenValue.fenCurrencyText, valueColor: record.type.accentColor, compact: compact)
                detailRow("关系", value: record.relationship.title, compact: compact)

                VStack(alignment: .leading, spacing: 6) {
                    Text("备注")
                        .font(.titleSong(compact ? 11 : 13))
                    Text(record.note.isEmpty ? "暂无备注" : record.note)
                        .font(.bodySong(compact ? 10 : 12))
                        .foregroundStyle(record.note.isEmpty ? LWColors.muted : LWColors.inkSoft)
                        .lineLimit(compact ? 2 : 3)
                }
                .padding(.vertical, 4)

                GoldLineDivider()
                HStack {
                    Text("往来历史")
                        .font(.titleSong(compact ? 12 : 14))
                    Spacer()
                    Text("共 \(records.filter { $0.personName == record.personName }.count) 条记录")
                        .font(.bodySong(compact ? 9 : 10))
                        .foregroundStyle(LWColors.muted)
                }

                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(records.filter { $0.personName == record.personName }.sorted { $0.date > $1.date }.prefix(compact ? 3 : 4)) { history in
                            HStack(spacing: 8) {
                                Text(history.type.shortTitle)
                                    .font(.titleSong(10))
                                    .foregroundStyle(.white)
                                    .frame(width: 24, height: 24)
                                    .background(history.type.accentColor, in: Circle())
                                Text(history.date.lwDayText)
                                    .font(.bodySong(compact ? 9 : 10))
                                    .foregroundStyle(LWColors.muted)
                                Text(history.eventType.title)
                                    .font(.bodySong(compact ? 9 : 10))
                                    .foregroundStyle(LWColors.inkSoft)
                                Spacer()
                                Text(signedAmount(history))
                                    .font(.amountKai(compact ? 11 : 13))
                                    .foregroundStyle(history.type.accentColor)
                            }
                            .frame(height: compact ? 33 : 38)
                            Divider().overlay(LWColors.cardStroke.opacity(0.3))
                        }
                    }
                }
                .frame(maxHeight: compact ? 104 : 160)

                Spacer(minLength: 2)
                HStack(spacing: compact ? 8 : 10) {
                    detailAction("编辑", icon: "pencil", compact: compact) {
                        editingRecord = record
                    }
                    detailAction("再记一笔", icon: "plus.circle", prominent: true, compact: compact) {
                        newRecordRequest = IPadNewRecordRequest(name: record.personName)
                    }
                    detailAction("删除", icon: "trash", destructive: true, compact: compact) {
                        pendingDelete = record
                    }
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "book.closed")
                        .font(.system(size: 34, weight: .light))
                    Text(records.isEmpty ? "还没有往来记录" : "请选择一条记录")
                        .font(.bodySong(14))
                }
                .foregroundStyle(LWColors.muted)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(maxHeight: .infinity)
    }

    private var fieldBackground: some View {
        RoundedRectangle(cornerRadius: 9)
            .fill(Color.white.opacity(0.34))
            .overlay(RoundedRectangle(cornerRadius: 9).stroke(LWColors.cardStroke.opacity(0.48)))
    }

    private func ledgerSourceRow(
        image: String? = nil,
        systemImage: String? = nil,
        title: String,
        subtitle: String,
        selected: Bool,
        compact: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let image {
                    Image(image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: compact ? 34 : 40, height: compact ? 34 : 40)
                } else if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: compact ? 20 : 23, weight: .light))
                        .foregroundStyle(LWColors.inkSoft)
                        .frame(width: compact ? 34 : 40)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.titleSong(compact ? 11 : 13))
                        .foregroundStyle(LWColors.ink)
                    Text(subtitle)
                        .font(.bodySong(compact ? 8 : 9))
                        .foregroundStyle(LWColors.muted)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(LWColors.warmGold)
            }
            .padding(.horizontal, 9)
            .frame(height: compact ? 48 : 55)
            .background(selected ? LWColors.cinnabar.opacity(0.08) : Color.clear, in: RoundedRectangle(cornerRadius: 8))
            .overlay(alignment: .leading) {
                if selected {
                    RoundedRectangle(cornerRadius: 2).fill(LWColors.cinnabar).frame(width: 3)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func recordListRow(_ record: GiftRecord, selected: Bool, compact: Bool) -> some View {
        HStack(spacing: compact ? 6 : 8) {
            Text(String(record.personName.prefix(1)))
                .font(.titleSong(compact ? 10 : 11))
                .foregroundStyle(.white)
                .frame(width: compact ? 23 : 27, height: compact ? 23 : 27)
                .background(LWColors.inkSoft, in: Circle())
            Text(record.personName)
                .font(.titleSong(compact ? 11 : 13))
                .foregroundStyle(LWColors.ink)
                .lineLimit(1)
            Text(record.relationship.title)
                .font(.bodySong(compact ? 8 : 9))
                .foregroundStyle(LWColors.warmGold)
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
                .background(LWColors.goldPale.opacity(0.16), in: RoundedRectangle(cornerRadius: 4))
            Spacer(minLength: 4)
            Text(record.eventType.title)
                .font(.bodySong(compact ? 8 : 9))
                .foregroundStyle(LWColors.muted)
            Text(record.date.formatted(.dateTime.month().day()))
                .font(.bodySong(compact ? 8 : 9))
                .foregroundStyle(LWColors.muted)
                .frame(width: compact ? 33 : 39)
            Text(signedAmount(record))
                .font(.amountKai(compact ? 11 : 13))
                .foregroundStyle(record.type.accentColor)
                .frame(width: compact ? 57 : 68, alignment: .trailing)
        }
        .padding(.horizontal, 10)
        .frame(height: compact ? 37 : 42)
        .background(selected ? LWColors.cinnabar.opacity(0.07) : Color.clear)
        .overlay {
            if selected {
                RoundedRectangle(cornerRadius: 7)
                    .stroke(LWColors.cinnabar.opacity(0.75), lineWidth: 1)
                    .padding(.horizontal, 3)
            }
        }
    }

    private func detailRow(_ title: String, value: String, valueColor: Color = LWColors.inkSoft, compact: Bool) -> some View {
        HStack {
            Text(title)
                .font(.titleSong(compact ? 10 : 12))
                .foregroundStyle(LWColors.ink)
            Spacer()
            Text(value)
                .font(.bodySong(compact ? 10 : 12))
                .foregroundStyle(valueColor)
                .lineLimit(1)
        }
        .frame(height: compact ? 27 : 33)
        .overlay(alignment: .bottom) {
            Divider().overlay(LWColors.cardStroke.opacity(0.3))
        }
    }

    private func detailAction(
        _ title: String,
        icon: String,
        prominent: Bool = false,
        destructive: Bool = false,
        compact: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.titleSong(compact ? 10 : 12))
                .foregroundStyle(prominent ? .white : (destructive ? LWColors.cinnabar : LWColors.inkSoft))
                .frame(maxWidth: .infinity)
                .frame(height: compact ? 38 : 45)
                .background(prominent ? LWColors.cinnabar : Color.white.opacity(0.24), in: RoundedRectangle(cornerRadius: 9))
                .overlay(RoundedRectangle(cornerRadius: 9).stroke(prominent ? LWColors.warmGold.opacity(0.55) : LWColors.cardStroke.opacity(0.5)))
        }
        .buttonStyle(.plain)
    }

    private func signedAmount(_ record: GiftRecord) -> String {
        "\(record.type == .received ? "+" : "−")\(MoneyAmount.inputText(fromFen: record.amountFenValue)) 元"
    }

    private func exportRecords() {
        do {
            exportURL = try ExportService.writeExcel(from: filteredRecords)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func deletePendingRecord() {
        guard let record = pendingDelete else { return }
        do {
            try RecordService.delete(record, in: modelContext)
            if selectedRecordID == record.id {
                selectedRecordID = filteredRecords.first(where: { $0.id != record.id })?.id
            }
            pendingDelete = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

private struct IPadBrandHeader: View {
    enum Style { case desk, ledger }

    let style: Style
    let searchText: Binding<String>?
    let openSettings: () -> Void

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.clear, LWColors.goldPale.opacity(0.07), .clear],
                startPoint: .leading,
                endPoint: .trailing
            )
            .allowsHitTesting(false)

            Image("prototype_header_mountain_plum")
                .resizable()
                .scaledToFit()
                .frame(width: 236)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .offset(x: 24, y: 8)
                .opacity(0.88)
                .allowsHitTesting(false)

            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    Text("礼往来")
                        .font(.titleSong(38))
                        .foregroundStyle(LWColors.ink)
                    SealStamp(text: "礼", size: 30, color: LWColors.cinnabar)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("礼往来")
                HStack(spacing: 9) {
                    Rectangle().fill(LWColors.warmGold.opacity(0.55)).frame(width: 22, height: 1)
                    Text(style == .desk ? "礼有往来，情有分寸" : "人情往来礼簿")
                        .font(.bodySong(12))
                        .foregroundStyle(LWColors.inkSoft)
                    Rectangle().fill(LWColors.warmGold.opacity(0.55)).frame(width: 22, height: 1)
                }
            }
            .padding(.top, 4)

            HStack {
                if style == .desk {
                    Label("礼台模式", systemImage: "rectangle.landscape.rotate")
                        .font(.titleSong(12))
                        .foregroundStyle(LWColors.inkSoft)
                        .padding(.horizontal, 13)
                        .padding(.vertical, 8)
                        .background(headerPill)
                } else {
                    Label("礼往来总礼簿", systemImage: "books.vertical")
                        .font(.titleSong(12))
                        .foregroundStyle(LWColors.inkSoft)
                        .padding(.horizontal, 13)
                        .padding(.vertical, 8)
                        .background(headerPill)
                }

                Spacer()

                if let searchText {
                    HStack(spacing: 8) {
                        TextField("搜索姓名、关系或备注", text: searchText)
                            .font(.bodySong(11))
                            .textInputAutocapitalization(.never)
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 13))
                            .foregroundStyle(LWColors.warmGold)
                    }
                    .padding(.horizontal, 12)
                    .frame(width: 245, height: 36)
                    .background(headerPill)
                }

                Button(action: openSettings) {
                    Label("设置", systemImage: "gearshape")
                        .font(.titleSong(12))
                        .foregroundStyle(LWColors.inkSoft)
                        .padding(.horizontal, 13)
                        .padding(.vertical, 8)
                        .background(headerPill)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 22)
            .padding(.top, 4)

            Rectangle()
                .fill(LWColors.warmGold.opacity(0.18))
                .frame(height: 1)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(.horizontal, 22)
        }
    }

    private var headerPill: some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(LWColors.card.opacity(0.62))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(LWColors.cardStroke.opacity(0.42)))
    }
}

private struct IPadPanel<Content: View>: View {
    var padding: CGFloat = 14
    var fillsHeight = false
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            content
        }
        .padding(padding)
        .frame(
            maxWidth: .infinity,
            maxHeight: fillsHeight ? .infinity : nil,
            alignment: .topLeading
        )
        .background(
            RoundedRectangle(cornerRadius: 13)
                .fill(LWColors.card.opacity(0.58))
                .overlay(RoundedRectangle(cornerRadius: 13).stroke(LWColors.cardStroke.opacity(0.42), lineWidth: 0.8))
        )
    }
}

private enum IPadLedgerFilter: String, CaseIterable, Identifiable {
    case all
    case received
    case given
    case wedding
    case funeral

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: "全部"
        case .received: "收礼"
        case .given: "送礼"
        case .wedding: "喜事"
        case .funeral: "白事"
        }
    }

    var icon: String {
        switch self {
        case .all: "gift"
        case .received: "arrow.down.circle"
        case .given: "arrow.up.circle"
        case .wedding: "heart.circle"
        case .funeral: "leaf.circle"
        }
    }

    func includes(_ record: GiftRecord) -> Bool {
        switch self {
        case .all: true
        case .received: record.type == .received
        case .given: record.type == .given
        case .wedding: record.eventType == .wedding
        case .funeral: record.eventType == .funeral
        }
    }
}

private struct IPadNewRecordRequest: Identifiable {
    let id = UUID()
    let name: String
}

private struct IPadShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview("iPad 横屏") {
    IPadRootView(records: [], hostedEvents: [])
        .modelContainer(for: [HostedGiftEvent.self, GiftRecord.self], inMemory: true)
        .environment(AppState())
        .frame(width: 1180, height: 820)
}
