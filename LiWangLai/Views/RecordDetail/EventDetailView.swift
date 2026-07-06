import SwiftData
import SwiftUI

struct EventDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let event: GiftEvent

    @State private var editingRecord: GiftRecord?
    @State private var showAddRecord = false
    @State private var pendingDelete: GiftRecord?
    @State private var showDeleteConfirm = false

    private var records: [GiftRecord] {
        event.records.sorted { $0.date > $1.date }
    }

    private var totalReceived: Int {
        records.filter { $0.type == .received }.reduce(0) { $0 + $1.amountYuan }
    }

    private var pendingReturnCount: Int {
        records.filter(\.needsReturn).count
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                detailHeader
                overviewCard
                recordsCard
                addRecordButton
            }
            .padding(.horizontal, LWSpacing.page)
            .padding(.top, 10)
            .padding(.bottom, 18)
        }
        .background(PaperTexture())
        .navigationTitle("我家一场事")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $editingRecord) { record in
            NavigationStack {
                AddRecordView(editingRecord: record)
            }
        }
        .sheet(isPresented: $showAddRecord) {
            NavigationStack {
                AddRecordView(
                    presetType: .received,
                    presetEventType: event.eventType,
                    presetDate: event.date,
                    presetNote: event.title
                )
            }
        }
        .confirmationDialog("确认删除这条往来记录？", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("删除记录", role: .destructive) {
                if let pendingDelete {
                    RecordService.delete(pendingDelete, in: modelContext)
                    if records.count <= 1 {
                        dismiss()
                    }
                }
                pendingDelete = nil
            }
            Button("取消", role: .cancel) {
                pendingDelete = nil
            }
        } message: {
            Text("删除后将无法在这场事和礼簿中查看这笔记录。")
        }
    }

    private var detailHeader: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text(event.title)
                    .font(.titleSong(30))
                    .foregroundStyle(LWColors.ink)
                Text("\(event.monthKey) · 我家办的事")
                    .font(.bodySong(13))
                    .foregroundStyle(LWColors.warmGold)
            }
            Spacer()
            SealStamp(text: "事", size: 44, color: LWColors.cinnabar)
        }
    }

    private var overviewCard: some View {
        PaperCard(padding: 12, spacing: 8) {
            HStack {
                Label("收礼总览", systemImage: "scroll")
                    .font(.titleSong(16))
                    .foregroundStyle(LWColors.ink)
                Spacer()
                MountainDecoration()
                    .frame(width: 58, height: 20)
                    .opacity(0.72)
            }
            overviewRow(title: "记录", value: "\(records.count) 笔", color: LWColors.ink)
            GoldLineDivider()
            overviewRow(title: "收礼", value: totalReceived.yuanText, color: LWColors.cinnabar)
            GoldLineDivider()
            overviewRow(title: "未回礼", value: "\(pendingReturnCount) 笔", color: pendingReturnCount > 0 ? LWColors.cinnabar : LWColors.muted)
        }
    }

    private func overviewRow(title: String, value: String, color: Color) -> some View {
        HStack {
            Text(title)
                .font(.titleSong(14))
                .foregroundStyle(LWColors.ink)
            Spacer()
            Text(value)
                .font(.amountKai(14))
                .foregroundStyle(color)
        }
    }

    private var recordsCard: some View {
        PaperCard(padding: 12, spacing: 8) {
            Text("来随礼的人")
                .font(.titleSong(16))
                .foregroundStyle(LWColors.ink)

            if records.isEmpty {
                Text("还没有收礼记录，从这场事里新增一笔吧。")
                    .font(.bodySong(13))
                    .foregroundStyle(LWColors.muted)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 6)
            } else {
                ForEach(records) { record in
                    NavigationLink {
                        RecordDetailView(record: record)
                    } label: {
                        RecordRow(record: record)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button("编辑") {
                            editingRecord = record
                        }
                        if record.needsReturn {
                            Button("标记已回") {
                                RecordService.markReturned(record, in: modelContext)
                            }
                        }
                        Button("删除", role: .destructive) {
                            pendingDelete = record
                            showDeleteConfirm = true
                        }
                    }

                    if record.id != records.last?.id {
                        GoldLineDivider()
                    }
                }
            }
        }
    }

    private var addRecordButton: some View {
        SealButton(title: "新增一笔", systemImage: "plus.circle", fontSize: 15, verticalPadding: 11, cornerRadius: 18) {
            showAddRecord = true
        }
    }
}
