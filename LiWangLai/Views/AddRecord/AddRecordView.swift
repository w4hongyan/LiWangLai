import SwiftData
import SwiftUI

struct AddRecordView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState

    var editingRecord: GiftRecord?
    var presetName: String = ""
    var presetType: GiftRecordType = .received

    @State private var draft: GiftRecordDraft
    @State private var showMore = false
    @State private var showSavedSeal = false

    init(editingRecord: GiftRecord? = nil, presetName: String = "", presetType: GiftRecordType = .received) {
        self.editingRecord = editingRecord
        self.presetName = presetName
        self.presetType = presetType
        _draft = State(initialValue: GiftRecordDraft(record: editingRecord, personName: presetName, type: presetType))
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

            if showSavedSeal {
                savedOverlay
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
                    DatePicker("", selection: $draft.date, displayedComponents: .date)
                        .labelsHidden()
                        .tint(LWColors.cinnabar)
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
                    TextField("可后续补全", text: $draft.location)
                        .font(.bodySong(12))
                }
                Toggle(isOn: $draft.isReturned) {
                    Text("是否已回礼")
                        .font(.titleSong(13))
                        .foregroundStyle(LWColors.ink)
                }
                .tint(LWColors.cinnabar)
                DatePicker("回礼提醒", selection: Binding(
                    get: { draft.returnReminderDate ?? Date() },
                    set: { draft.returnReminderDate = $0 }
                ), displayedComponents: .date)
                .font(.titleSong(13))
                .tint(LWColors.cinnabar)

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

    private var suggestionCard: some View {
        PaperCard(padding: 12) {
            HStack(alignment: .top, spacing: 10) {
                SealStamp(text: "礼", size: 36, color: LWColors.warmGold)
                VStack(alignment: .leading, spacing: 4) {
                    Text("保存后可在往来详情里查看历史与回礼参考。")
                        .font(.bodySong(13))
                        .foregroundStyle(LWColors.inkSoft)
                    Text("建议：下次回礼可参考 \(draft.amountYuan.yuanText) 左右。")
                        .font(.bodySong(13))
                        .foregroundStyle(LWColors.cinnabar)
                }
            }
        }
    }

    private var savedOverlay: some View {
        VStack(spacing: 12) {
            SealStamp(text: "已", size: 92)
                .scaleEffect(showSavedSeal ? 1 : 0.7)
            Text("已入簿")
                .font(.titleSong(22))
                .foregroundStyle(LWColors.ink)
            Text("\(draft.personName) · \(draft.eventType.title) · \(draft.type.title) \(draft.amountYuan.yuanText)")
                .font(.bodySong(13))
                .foregroundStyle(LWColors.inkSoft)
        }
        .padding(28)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .transition(.scale.combined(with: .opacity))
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
                showSavedSeal = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                withAnimation(.easeOut(duration: 0.16)) {
                    showSavedSeal = false
                }
                draft = GiftRecordDraft(type: draft.type)
                appState.selectedTab = .ledger
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
