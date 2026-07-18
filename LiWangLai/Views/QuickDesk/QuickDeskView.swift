import SwiftData
import SwiftUI

struct QuickDeskView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \GiftRecord.createdAt, order: .reverse) private var records: [GiftRecord]
    @Query(sort: \HostedGiftEvent.date, order: .reverse) private var hostedEvents: [HostedGiftEvent]

    @State private var name = ""
    @State private var amount = "600"
    @State private var note = ""
    @State private var eventType: GiftEventType = .baby
    @State private var selectedHostedEventID: UUID?
    @State private var newHostedEventTitle = ""
    @State private var saveErrorMessage: String?

    private var todayRecords: [GiftRecord] {
        records.filter { Calendar.current.isDateInToday($0.createdAt) }
    }

    var body: some View {
        GeometryReader { geometry in
            if geometry.size.width > geometry.size.height {
                landscapeBody
            } else {
                portraitHint
            }
        }
        .background(PaperTexture())
        .navigationTitle("横屏记账台")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: selectedHostedEventID) { _, eventID in
            guard let eventID,
                  let event = hostedEvents.first(where: { $0.id == eventID }) else { return }
            newHostedEventTitle = ""
            eventType = event.eventType
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

    private var landscapeBody: some View {
        HStack(spacing: 22) {
            VStack(alignment: .leading, spacing: 18) {
                PageHeader(title: "记账台", subtitle: "现场连续入簿")
                PaperCard {
                    TextField("姓名", text: $name)
                        .font(.titleSong(32))
                        .textFieldStyle(.plain)
                    GoldLineDivider()
                    AmountTextField(amountText: $amount)
                    chipEvents
                    hostedEventSelection
                    TextField("临时备注", text: $note)
                        .font(.bodySong(18))
                    SealButton(title: "保存并继续", systemImage: "plus.circle") {
                        saveAndContinue()
                    }
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)

            VStack(alignment: .leading, spacing: 14) {
                Text("今日已录 \(todayRecords.count) 笔 · 合计 \(todayRecords.reduce(0) { $0 + $1.amountYuan }.yuanText)")
                    .font(.titleSong(24))
                    .foregroundStyle(LWColors.ink)
                PaperCard {
                    ForEach(todayRecords.prefix(12)) { record in
                        RecordRow(record: record, showChevron: false)
                        if record.id != todayRecords.prefix(12).last?.id {
                            GoldLineDivider()
                        }
                    }
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .padding(24)
    }

    private var portraitHint: some View {
        VStack(spacing: 18) {
            SealStamp(text: "台", size: 82)
            Text("横屏记账台")
                .font(.titleSong(30))
                .foregroundStyle(LWColors.ink)
            Text("请横屏使用。现场记账时会提供更大的姓名和金额输入框。")
                .font(.bodySong(17))
                .foregroundStyle(LWColors.muted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 36)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var chipEvents: some View {
        HStack {
            ForEach([GiftEventType.wedding, .baby, .housewarming, .birthday, .funeral], id: \.id) { event in
                Button {
                    if hostedEvents.first(where: { $0.id == selectedHostedEventID })?.eventType != event {
                        selectedHostedEventID = nil
                    }
                    eventType = event
                } label: {
                    RelationshipTag(title: event.title, isSelected: eventType == event)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var hostedEventSelection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Text("一场事")
                    .font(.titleSong(15))
                    .foregroundStyle(LWColors.ink)
                Picker("一场事", selection: $selectedHostedEventID) {
                    Text("自动新建 · \(HostedEventService.defaultTitle(for: eventType))")
                        .tag(nil as UUID?)
                    ForEach(hostedEvents) { event in
                        Text("\(event.title) · \(event.date.lwDayText)")
                            .tag(event.id as UUID?)
                    }
                }
                .labelsHidden()
                .tint(LWColors.cinnabar)
                Spacer()
            }
            if selectedHostedEventID == nil {
                TextField(
                    "场次名称（默认：\(HostedEventService.defaultTitle(for: eventType))）",
                    text: $newHostedEventTitle
                )
                .font(.bodySong(14))
                .textInputAutocapitalization(.never)
            }
        }
    }

    private func saveAndContinue() {
        let draft = GiftRecordDraft(personName: name, type: .received)
        var finalDraft = draft
        finalDraft.amountText = amount
        finalDraft.note = note
        finalDraft.eventType = eventType
        finalDraft.hostedEventID = selectedHostedEventID
        finalDraft.hostedEventTitle = newHostedEventTitle
        guard finalDraft.isValid else { return }
        do {
            let record = try RecordService.insert(finalDraft, in: modelContext)
            selectedHostedEventID = record.hostedEventID
            newHostedEventTitle = ""
            eventType = record.eventType
            name = ""
            amount = "600"
            note = ""
            HapticsManager.success()
        } catch {
            saveErrorMessage = error.localizedDescription
        }
    }
}
