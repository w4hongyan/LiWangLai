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

   @State private var draft: GiftRecordDraft
   @State private var showMore = false
   @State private var showPostSave = false
    @Query(sort: \GiftRecord.date, order: .reverse) private var allRecords: [GiftRecord]

    init(
        editingRecord: GiftRecord? = nil,
       presetName: String = "",
       presetType: GiftRecordType = .received,
       presetEventType: GiftEventType? = nil,
       presetDate: Date? = nil,
        presetNote: String = "",
        presetEventID: UUID? = nil
   ) {
       self.editingRecord = editingRecord
       self.presetName = presetName
       self.presetType = presetType
       self.presetEventType = presetEventType
       self.presetDate = presetDate
       self.presetNote = presetNote
        self.presetEventID = presetEventID
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
                VStack(alignment: .leading, spacing: 6) {
                    addHeader

                    typePicker
                    mainForm
                    moreInfo
                    SealButton(
                        title: editingRecord == nil ? "保存入簿" : "保存修改",
                        systemImage: "checkmark.seal",
                        isDisabled: !draft.isValid,
                        fontSize: 14,
                        verticalPadding: 9,
                        cornerRadius: 12
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
    }

    private var addHeader: some View {
        ZStack(alignment: .topTrailing) {
            MountainDecoration()
                .frame(width: 180, height: 88)
                .offset(x: 20, y: 0)
                .opacity(0.36)
                .allowsHitTesting(false)

            VStack(alignment: .leading, spacing: 6) {
                Text(editingRecord == nil ? "入簿" : "改一笔")
                    .font(.titleSong(30))
                    .foregroundStyle(LWColors.ink)
                Text("三秒记一笔")
                    .font(.bodySong(13))
                    .foregroundStyle(LWColors.warmGold)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 10)
        }
        .frame(height: 94)
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
        PaperCard(padding: 12, spacing: 8) {
            fieldRow(title: "姓名", icon: "person") {
                TextField("请输入姓名", text: $draft.personName)
                    .font(.bodySong(13))
                    .foregroundStyle(LWColors.ink)

            nameSuggestions
                    .textInputAutocapitalization(.never)
            }

            GoldLineDivider()

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("金额")
                        .font(.titleSong(14))
                    Spacer()
                    Image(systemName: "number.square")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(LWColors.warmGold)
                }
                AmountTextField(amountText: $draft.amountText, currencySize: 20, amountSize: 30)
                amountChips
            }

            GoldLineDivider()

            VStack(alignment: .leading, spacing: 6) {
                Text("事件")
                    .font(.titleSong(14))
                chipWrap(GiftEventType.allCases, selected: draft.eventType) { event in
                    draft.eventType = event
                }
            }

            GoldLineDivider()

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("日期")
                        .font(.titleSong(14))
                    ChineseDatePickerButton(date: $draft.date)
                }
                HStack {
                    quickDate("今天", date: .now)
                    quickDate("昨天", date: Calendar.current.date(byAdding: .day, value: -1, to: .now) ?? .now)
                    quickDate("上周", date: Calendar.current.date(byAdding: .day, value: -7, to: .now) ?? .now)
                }
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
                        .font(.bodySong(12))
                        .foregroundStyle(draft.amountYuan == amount ? .white : LWColors.ink)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(draft.amountYuan == amount ? LWColors.cinnabar : Color.white.opacity(0.62))
                                .overlay(Capsule().stroke(LWColors.cardStroke.opacity(0.35)))
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
                Toggle(isOn: $draft.isReturned) {
                    Text("是否已回礼")
                        .font(.titleSong(13))
                        .foregroundStyle(LWColors.ink)
                }
                .tint(LWColors.cinnabar)
                ChineseDatePickerButton(title: "回礼提醒", date: Binding(
                    get: { draft.returnReminderDate ?? Date() },
                    set: { draft.returnReminderDate = $0 }
                ))

                Button {
                    draft.returnReminderDate = nil
                } label: {
                    Label("不提醒", systemImage: "bell.slash")
                        .font(.bodySong(12))
                        .foregroundStyle(LWColors.muted)
                }
                .buttonStyle(.plain)
            }
        }
   }


    private var postSaveCard: some View {
        let personRecords = allRecords.filter { $0.personName == draft.personName }
        let sortedRecords = personRecords.sorted { $0.date > $1.date }
        let lastRecord = sortedRecords.first
        let suggestionBase = max(100, (lastRecord?.amountYuan ?? draft.amountYuan) / 100 * 100)

        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                SealStamp(text: "已", size: 40)
                VStack(alignment: .leading, spacing: 3) {
                    Text("已入簿")
                        .font(.custom("SourceHanSerifSC-SemiBold", size: 20))
                        .foregroundStyle(LWColors.ink)
                    Text("\(draft.personName) · \(draft.eventType.title) · \(draft.type.title)")
                        .font(.custom("STKaiti", size: 14))
                        .foregroundStyle(LWColors.inkSoft)
                }
                Spacer()
                Text(draft.amountYuan.yuanText)
                    .font(.custom("STKaiti", size: 26))
                    .foregroundStyle(LWColors.cinnabar)
            }

            if let lastRecord {
                GoldLineDivider()
                VStack(alignment: .leading, spacing: 4) {
                    Text("上次往来")
                        .font(.custom("STKaiti", size: 12))
                        .foregroundStyle(LWColors.muted)
                    Text("\(lastRecord.date.lwCompactMonthText) \(lastRecord.eventType.title) · \(lastRecord.type.narrativeTitle) \(lastRecord.amountYuan.yuanText)")
                        .font(.custom("STKaiti", size: 14))
                        .foregroundStyle(LWColors.ink)
                    Text("建议：下次回礼可参考 \(suggestionBase.yuanText) - \((suggestionBase + 200).yuanText)")
                        .font(.custom("STKaiti", size: 14))
                        .foregroundStyle(LWColors.cinnabar)
                }
            }

            HStack(spacing: 8) {
                Button {
                    withAnimation(.easeOut(duration: 0.16)) {
                        showPostSave = false
                    }
                    draft = GiftRecordDraft(type: draft.type, hostedEventID: draft.hostedEventID)
                } label: {
                    Label("再记一笔", systemImage: "pencil")
                        .font(.custom("STKaiti", size: 13).weight(.semibold))
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
                    appState.selectedTab = .people
                } label: {
                    Label("查看详情", systemImage: "person.text.rectangle")
                        .font(.custom("STKaiti", size: 13).weight(.semibold))
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
                        .font(.custom("STKaiti", size: 13).weight(.semibold))
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

    private var nameSuggestions: some View {
        let trimmed = draft.personName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed.count >= 1 else { return AnyView(EmptyView()) }
        let uniqueNames = Array(Set(allRecords.map(\.personName))).filter {
            $0.localizedCaseInsensitiveContains(trimmed) && $0 != trimmed
        }.prefix(3)
        guard !uniqueNames.isEmpty else { return AnyView(EmptyView()) }
        return AnyView(
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
                                        .font(.custom("STKaiti", size: 14))
                                        .foregroundStyle(LWColors.ink)
                                    if let latestRecord = allRecords.first(where: { $0.personName == name }) {
                                        Text("上次：\(latestRecord.date.lwCompactMonthText) \(latestRecord.eventType.title) · \(latestRecord.type.title) \(latestRecord.amountYuan.yuanText)")
                                            .font(.custom("STKaiti", size: 11))
                                            .foregroundStyle(LWColors.muted)
                                            .lineLimit(1)
                                    }
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
        )
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

    private func quickDate(_ title: String, date: Date) -> some View {
        Button {
            draft.date = date
        } label: {
            Text(title)
                .font(.bodySong(12))
                .foregroundStyle(Calendar.current.isDate(draft.date, inSameDayAs: date) ? LWColors.cinnabar : LWColors.ink)
                .padding(.horizontal, 13)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.56))
                        .overlay(Capsule().stroke(Calendar.current.isDate(draft.date, inSameDayAs: date) ? LWColors.cinnabar : LWColors.cardStroke.opacity(0.4)))
                )
        }
        .buttonStyle(.plain)
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

   private func save() {
       guard draft.isValid else { return }
       if let editingRecord {
           RecordService.update(editingRecord, with: draft, in: modelContext)
           HapticsManager.success()
           dismiss()
       } else {
           RecordService.insert(draft, in: modelContext)
           HapticsManager.success()
           withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
               showPostSave = true
           }
       }
   }
}

protocol TitleProviding {
    var title: String { get }
}

extension GiftEventType: TitleProviding {}
extension RelationshipType: TitleProviding {}

#Preview {
    NavigationStack {
        AddRecordView()
    }
    .modelContainer(for: GiftRecord.self, inMemory: true)
    .environment(AppState())
}
