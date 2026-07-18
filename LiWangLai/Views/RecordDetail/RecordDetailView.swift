import SwiftData
import SwiftUI

struct RecordDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let record: GiftRecord

    @State private var showEdit = false
    @State private var showDeleteConfirm = false
    @State private var dataErrorMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
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
                            Text(record.personName)
                                .font(.titleSong(40))
                                .foregroundStyle(LWColors.ink)
                            Text("\(record.relationship.title) · \(record.type.title)")
                                .font(.bodySong(17))
                                .foregroundStyle(LWColors.warmGold)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 18)
                    }
                }
                .frame(height: 124)

                PaperCard(padding: 14, spacing: 10) {
                    detailLine("金额", value: record.amountYuan.yuanText, isAmount: true)
                    GoldLineDivider()
                    detailLine("事件", value: record.eventType.title)
                    GoldLineDivider()
                    detailLine("日期", value: record.date.lwDualDateText)
                    GoldLineDivider()
                    detailLine("回礼", value: record.isReturned ? "已回礼" : (record.type == .received ? "未回礼" : "已记录"))
                    if let reminder = record.returnReminderDate {
                        GoldLineDivider()
                        detailLine(record.type == .received ? "回礼提醒" : "送礼提醒", value: reminder.lwDateTimeText)
                    }
                    if !record.note.isEmpty {
                        GoldLineDivider()
                        detailLine("备注", value: record.note)
                    }
                }

                PaperCard(padding: 14, spacing: 10) {
                    HStack {
                        Image(systemName: "gift")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(LWColors.warmGold)
                        Text("回礼建议")
                            .font(.titleSong(16))
                            .foregroundStyle(LWColors.ink)
                        Spacer()
                        Image("prototype_gold_clouds")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50)
                            .opacity(0.6)
                    }
                    Text("可参考这笔往来的金额与关系亲疏，保持心意周到即可。")
                        .font(.bodySong(13))
                        .foregroundStyle(LWColors.inkSoft)
                    HStack {
                        Image(systemName: "star.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(LWColors.warmGold)
                        Text("\(record.amountYuan.yuanText) 左右较稳妥")
                            .font(.titleSong(16))
                            .foregroundStyle(LWColors.cinnabar)
                    }
                }

                HStack(spacing: 10) {
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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showEdit = true
                } label: {
                    Label("编辑", systemImage: "pencil")
                }
                .foregroundStyle(LWColors.cinnabar)
            }
        }
        .sheet(isPresented: $showEdit) {
            NavigationStack {
                AddRecordView(editingRecord: record)
            }
        }
        .confirmationDialog("确认删除这条往来记录？", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("删除记录", role: .destructive) {
                do {
                    try RecordService.delete(record, in: modelContext)
                    dismiss()
                } catch {
                    dataErrorMessage = error.localizedDescription
                }
            }
            Button("取消", role: .cancel) {}
        }
        .alert("删除失败", isPresented: Binding(
            get: { dataErrorMessage != nil },
            set: { if !$0 { dataErrorMessage = nil } }
        )) {
            Button("知道了", role: .cancel) {}
        } message: {
            Text(dataErrorMessage ?? "请稍后再试。")
        }
    }

    private func detailLine(_ title: String, value: String, isAmount: Bool = false) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.titleSong(14))
                .foregroundStyle(LWColors.ink)
            Spacer()
            Text(value)
                .font(isAmount ? .amountKai(20) : .bodySong(13))
                .foregroundStyle(isAmount ? LWColors.cinnabar : LWColors.inkSoft)
        }
    }
}
