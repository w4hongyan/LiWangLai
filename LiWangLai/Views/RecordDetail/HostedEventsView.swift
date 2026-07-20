import SwiftData
import SwiftUI

struct HostedEventsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @Query(sort: \HostedGiftEvent.date, order: .reverse) private var hostedEvents: [HostedGiftEvent]
    @Query(sort: \GiftRecord.date, order: .reverse) private var records: [GiftRecord]

    @State private var presentedSheet: HostedEventSheetDestination?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 11) {
                header

                if hostedEvents.isEmpty {
                    EmptyStateView(
                        title: "还没有我家办的事",
                        message: "先建一场婚礼、满月或乔迁，再从这场事里连续入簿。",
                        buttonTitle: "新建一场事"
                    ) {
                        presentedSheet = .create
                    }
                } else {
                    ForEach(hostedEvents) { hostedEvent in
                        if UIDevice.current.userInterfaceIdiom == .pad {
                            ipadHostedEventCard(hostedEvent)
                        } else {
                            NavigationLink {
                                EventDetailView(event: giftEvent(from: hostedEvent))
                            } label: {
                                hostedEventCard(hostedEvent)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(.horizontal, LWSpacing.page)
            .padding(.top, -4)
            .padding(.bottom, 18)
        }
        .background(PaperTexture())
        .navigationTitle("一场事")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    presentedSheet = .create
                } label: {
                    Label("新建", systemImage: "plus")
                }
                .foregroundStyle(LWColors.cinnabar)
            }
        }
        .sheet(item: $presentedSheet) { destination in
            switch destination {
            case .create:
                HostedEventEditorSheet(event: nil, linkedRecords: records)
            case .edit(let event):
                HostedEventEditorSheet(event: event, linkedRecords: records)
            }
        }
    }

    private var header: some View {
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
                    Text("一场事")
                        .font(.titleSong(40))
                        .foregroundStyle(LWColors.ink)
                    Text("我家办事，集中入簿")
                        .font(.bodySong(17))
                        .foregroundStyle(LWColors.warmGold)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 18)
            }
        }
        .frame(height: 124)
    }

    private func ipadHostedEventCard(_ hostedEvent: HostedGiftEvent) -> some View {
        PaperCard(padding: 12) {
            hostedEventSummary(hostedEvent, showsChevron: false)
            GoldLineDivider()
            HStack(spacing: 10) {
                NavigationLink {
                    EventDetailView(event: giftEvent(from: hostedEvent))
                } label: {
                    Label("默认模式", systemImage: "rectangle.portrait")
                        .font(.titleSong(13))
                        .foregroundStyle(LWColors.inkSoft)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(
                            RoundedRectangle(cornerRadius: 9)
                                .fill(Color.white.opacity(0.30))
                                .overlay(RoundedRectangle(cornerRadius: 9).stroke(LWColors.cardStroke.opacity(0.55)))
                        )
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("hostedEvent.openDefault.\(hostedEvent.id.uuidString)")

                Button {
                    appState.ipadDeskRequest = IPadDeskRequest(hostedEventID: hostedEvent.id)
                    HapticsManager.lightTap()
                } label: {
                    Label("礼台模式", systemImage: "rectangle.landscape.rotate")
                        .font(.titleSong(13))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(LWColors.cinnabar, in: RoundedRectangle(cornerRadius: 9))
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("hostedEvent.openDesk.\(hostedEvent.id.uuidString)")
            }
        }
    }

    private func hostedEventCard(_ hostedEvent: HostedGiftEvent) -> some View {
        PaperCard(padding: 12) {
            hostedEventSummary(hostedEvent, showsChevron: true)
        }
    }

    private func hostedEventSummary(_ hostedEvent: HostedGiftEvent, showsChevron: Bool) -> some View {
        let event = giftEvent(from: hostedEvent)
        return HStack(spacing: 12) {
            SealStamp(text: hostedEvent.eventType == .wedding ? "囍" : "事", size: 46, color: LWColors.cinnabar)
            VStack(alignment: .leading, spacing: 5) {
                Text(hostedEvent.title)
                    .font(.bodyKai(19))
                    .foregroundStyle(LWColors.ink)
                Text("\(hostedEvent.date.lwDualDateText) · \(hostedEvent.eventType.title)")
                    .font(.bodySong(12))
                    .foregroundStyle(LWColors.muted)
                Text("收礼 \(event.records.count) 笔 · 合计 \(event.totalAmount.yuanText)")
                    .font(.bodySong(13))
                    .foregroundStyle(LWColors.cinnabar)
            }
            Spacer()
            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(LWColors.muted.opacity(0.7))
            }
        }
    }

    private func giftEvent(from hostedEvent: HostedGiftEvent) -> GiftEvent {
        let eventRecords = HostedEventService.records(for: hostedEvent, from: records)
        return GiftEvent(
            title: hostedEvent.title,
            monthKey: hostedEvent.date.lwDayText,
            eventType: hostedEvent.eventType,
            date: hostedEvent.date,
            records: eventRecords,
            hostedEventID: hostedEvent.id,
            hostedEvent: hostedEvent
        )
    }
}

enum HostedEventSheetDestination: Identifiable {
    case create
    case edit(HostedGiftEvent)

    var id: String {
        switch self {
        case .create: "create"
        case .edit(let event): "edit-\(event.id.uuidString)"
        }
    }
}

struct HostedEventEditorSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let event: HostedGiftEvent?
    let linkedRecords: [GiftRecord]
    let onSaved: ((HostedGiftEvent) -> Void)?

    @State private var title: String
    @State private var eventType: GiftEventType
    @State private var date: Date
    @State private var note: String
    @State private var saveErrorMessage: String?

    init(
        event: HostedGiftEvent?,
        linkedRecords: [GiftRecord],
        onSaved: ((HostedGiftEvent) -> Void)? = nil
    ) {
        self.event = event
        self.linkedRecords = linkedRecords
        self.onSaved = onSaved
        _title = State(initialValue: event?.title ?? "")
        _eventType = State(initialValue: event?.eventType ?? .wedding)
        _date = State(initialValue: event?.date ?? .now)
        _note = State(initialValue: event?.note ?? "")
    }

    private var effectiveTitle: String {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            return trimmed
        }
        return HostedEventService.defaultTitle(for: eventType)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(event == nil ? "新建一场事" : "编辑一场事")
                    .font(.titleSong(24))
                    .foregroundStyle(LWColors.ink)
                Spacer()
                Button("取消") {
                    dismiss()
                }
                .font(.bodySong(13))
                .foregroundStyle(LWColors.muted)
            }

            PaperCard(padding: 12, spacing: 10) {
                fieldRow("名称") {
                    TextField(effectiveTitle, text: $title)
                        .font(.bodySong(13))
                }
                GoldLineDivider()
                VStack(alignment: .leading, spacing: 8) {
                    Text("类型")
                        .font(.titleSong(13))
                        .foregroundStyle(LWColors.ink)
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 52), spacing: 6)], spacing: 6) {
                        ForEach(GiftEventType.allCases) { type in
                            Button {
                                eventType = type
                            } label: {
                                Text(type.title)
                                    .font(.bodySong(12))
                                    .foregroundStyle(eventType == type ? .white : LWColors.ink)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(
                                        Capsule()
                                            .fill(eventType == type ? LWColors.cinnabar : Color.white.opacity(0.62))
                                            .overlay(Capsule().stroke(LWColors.cardStroke.opacity(0.35)))
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                GoldLineDivider()
                ChineseDatePickerButton(title: "日期", date: $date)
                GoldLineDivider()
                fieldRow("备注") {
                    TextField("可选填", text: $note)
                        .font(.bodySong(13))
                }
            }

            SealButton(title: event == nil ? "保存一场事" : "保存修改", systemImage: "checkmark.seal", fontSize: 14, verticalPadding: 10, cornerRadius: 12) {
                save()
            }
        }
        .padding(20)
        .background(PaperTexture())
        .presentationDetents([.height(470), .large])
        .presentationDragIndicator(.visible)
        .alert("保存失败", isPresented: Binding(
            get: { saveErrorMessage != nil },
            set: { if !$0 { saveErrorMessage = nil } }
        )) {
            Button("知道了", role: .cancel) {}
        } message: {
            Text(saveErrorMessage ?? "请稍后再试。")
        }
    }

    private func save() {
        do {
            if let event {
                try HostedEventService.update(
                    event,
                    title: effectiveTitle,
                    eventType: eventType,
                    date: date,
                    note: note,
                    linkedRecords: linkedRecords,
                    in: modelContext
                )
                onSaved?(event)
            } else {
                let newEvent = HostedGiftEvent(
                    title: effectiveTitle,
                    eventType: eventType,
                    date: date,
                    note: note.trimmingCharacters(in: .whitespacesAndNewlines)
                )
                modelContext.insert(newEvent)
                try modelContext.save()
                onSaved?(newEvent)
            }
            HapticsManager.success()
            dismiss()
        } catch {
            modelContext.rollback()
            saveErrorMessage = error.localizedDescription
        }
    }

    private func fieldRow<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        HStack(spacing: 10) {
            Text(title)
                .font(.titleSong(13))
                .foregroundStyle(LWColors.ink)
                .frame(width: 42, alignment: .leading)
            content()
        }
    }
}
