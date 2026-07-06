import SwiftData
import SwiftUI

struct RecordDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let record: GiftRecord

    @State private var showEdit = false
    @State private var showDeleteConfirm = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(record.personName)
                            .font(.titleSong(30))
                            .foregroundStyle(LWColors.ink)
                        Text("\(record.relationship.title) · \(record.type.title)")
                            .font(.bodySong(13))
                            .foregroundStyle(LWColors.warmGold)
                    }
                    Spacer()
                    SealStamp(text: record.type.shortTitle, size: 44, color: record.type.accentColor)
                }

                PaperCard(padding: 12, spacing: 8) {
                    detailLine("金额", value: record.amountYuan.yuanText, isAmount: true)
                    GoldLineDivider()
                    detailLine("事件", value: record.eventType.title)
                    GoldLineDivider()
                    detailLine("日期", value: record.date.lwDayText)
                    GoldLineDivider()
                    detailLine("回礼", value: record.isReturned ? "已回礼" : (record.type == .received ? "未回礼" : "已记录"))
                    if let reminder = record.returnReminderDate {
                        GoldLineDivider()
                        detailLine("提醒", value: reminder.lwDayText)
                    }
                    if !record.note.isEmpty {
                        GoldLineDivider()
                        detailLine("备注", value: record.note)
                    }
                }

                PaperCard(padding: 12, spacing: 8) {
                    Label("回礼建议", systemImage: "gift")
                        .font(.titleSong(16))
                        .foregroundStyle(LWColors.ink)
                    Text("可参考这笔往来的金额与关系亲疏，保持心意周到即可。")
                        .font(.bodySong(13))
                        .foregroundStyle(LWColors.inkSoft)
                    Text("\(record.amountYuan.yuanText) 左右较稳妥")
                        .font(.titleSong(17))
                        .foregroundStyle(LWColors.cinnabar)
                }

                HStack(spacing: 8) {
                    SealButton(title: "编辑", systemImage: "pencil", fontSize: 14, verticalPadding: 10, cornerRadius: 12) {
                        showEdit = true
                    }
                    Button(role: .destructive) {
                        showDeleteConfirm = true
                    } label: {
                        Label("删除", systemImage: "trash")
                            .font(.bodySong(14).weight(.semibold))
                            .foregroundStyle(LWColors.cinnabar)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.58))
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(LWColors.cinnabar.opacity(0.35)))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, LWSpacing.page)
            .padding(.top, 10)
            .padding(.bottom, 18)
        }
        .background(PaperTexture())
        .navigationTitle("往来详情")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showEdit) {
            NavigationStack {
                AddRecordView(editingRecord: record)
            }
        }
        .confirmationDialog("确认删除这条往来记录？", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("删除记录", role: .destructive) {
                RecordService.delete(record, in: modelContext)
                dismiss()
            }
            Button("取消", role: .cancel) {}
        }
    }

    private func detailLine(_ title: String, value: String, isAmount: Bool = false) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.titleSong(14))
                .foregroundStyle(LWColors.ink)
            Spacer()
            Text(value)
                .font(isAmount ? .system(size: 20, weight: .semibold, design: .serif) : .bodySong(13))
                .foregroundStyle(isAmount ? LWColors.cinnabar : LWColors.inkSoft)
        }
    }
}
