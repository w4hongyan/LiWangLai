import SwiftData
import SwiftUI

struct HostedEventsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \HostedGiftEvent.date, order: .reverse) private var hostedEvents: [HostedGiftEvent]
    @Query(sort: \GiftRecord.date, order: .reverse) private var records: [GiftRecord]

    @State private var showCreate = false

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
                        showCreate = true
                    }
                } else {
                    ForEach(hostedEvents) { hostedEvent in
                        NavigationLink {
                            EventDetailView(event: giftEvent(from: hostedEvent))
                        } label: {
                            hostedEventCard(hostedEvent)
                        }
                        .buttonStyle(.plain)
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
                    showCreate = true
                } label: {
                    Label("新建", systemImage: "plus")
                }
                .foregroundStyle(LWColors.cinnabar)
            }
        }
        .sheet(isPresented: $showCreate) {
            NewHostedEventSheet()
                .presentationDetents([.height(430)])
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

    private func hostedEventCard(_ hostedEvent: HostedGiftEvent) -> some View {
        let event = giftEvent(from: hostedEvent)
        return PaperCard(padding: 12) {
            HStack(spacing: 12) {
                SealStamp(text: hostedEvent.eventType == .wedding ? "囍" : "事", size: 46, color: LWColors.cinnabar)
                VStack(alignment: .leading, spacing: 5) {
                    Text(hostedEvent.title)
                        .font(.bodyKai(19))
                        .foregroundStyle(LWColors.ink)
                    Text("\(hostedEvent.date.lwDayText) · \(hostedEvent.eventType.title)")
                        .font(.bodySong(12))
                        .foregroundStyle(LWColors.muted)
                    Text("收礼 \(event.records.count) 笔 · 合计 \(event.totalAmount.yuanText)")
                        .font(.bodySong(13))
                        .foregroundStyle(LWColors.cinnabar)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(LWColors.muted.opacity(0.7))
            }
        }
    }

   private func giftEvent(from hostedEvent: HostedGiftEvent) -> GiftEvent {
       let eventRecords = records.filter { record in
           record.type == .received
               && record.eventType == hostedEvent.eventType
               && Calendar.current.isDate(record.date, inSameDayAs: hostedEvent.date)
       }
       return GiftEvent(
           title: hostedEvent.title,
           monthKey: hostedEvent.date.lwDayText,
           eventType: hostedEvent.eventType,
           date: hostedEvent.date,
            records: eventRecords,
            hostedEventID: hostedEvent.id
       )
   }
}

private struct NewHostedEventSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var eventType: GiftEventType = .wedding
    @State private var date = Date()
    @State private var note = ""

    private var effectiveTitle: String {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            return trimmed
        }
        switch eventType {
        case .wedding: return "我家婚礼"
        case .baby: return "我家满月酒"
        case .housewarming: return "我家乔迁"
        case .birthday: return "我家生日宴"
        case .funeral: return "我家白事"
        case .school: return "我家升学宴"
        case .festival: return "我家节礼"
        case .other: return "我家一场事"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("新建一场事")
                .font(.titleSong(24))
                .foregroundStyle(LWColors.ink)

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

            SealButton(title: "保存一场事", systemImage: "checkmark.seal", fontSize: 14, verticalPadding: 10, cornerRadius: 12) {
                let event = HostedGiftEvent(
                    title: effectiveTitle,
                    eventType: eventType,
                    date: date,
                    note: note.trimmingCharacters(in: .whitespacesAndNewlines)
                )
                modelContext.insert(event)
                try? modelContext.save()
                HapticsManager.success()
                dismiss()
            }
        }
        .padding(20)
        .background(PaperTexture())
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
