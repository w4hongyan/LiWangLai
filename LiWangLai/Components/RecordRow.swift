import SwiftUI

struct RecordRow: View {
    let record: GiftRecord
    var showChevron = true
    var showsReturnStatus = true

    var body: some View {
        HStack(spacing: 8) {
            recordBadge
            VStack(alignment: .leading, spacing: 3) {
                Text("\(record.personName) · \(record.eventType.title)")
                    .font(.bodyKai(15))
                    .foregroundStyle(LWColors.ink)
                    .lineLimit(1)
                Text(record.date.lwDualDateText)
                    .font(.bodySong(11))
                    .foregroundStyle(LWColors.muted)
                    .lineLimit(1)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(record.amountYuan.yuanText)
                    .font(.amountKai(13))
                    .foregroundStyle(record.type == .received ? LWColors.cinnabar : LWColors.ink)
                if showsReturnStatus {
                    Text(record.isReturned ? "已回" : (record.type == .received ? "未回" : "已记"))
                        .font(.bodySong(11))
                        .foregroundStyle(record.isReturned ? LWColors.muted : LWColors.cinnabar)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1)
                        .overlay(
                            RoundedRectangle(cornerRadius: 3)
                                .stroke((record.isReturned ? LWColors.muted : LWColors.cinnabar).opacity(0.65), lineWidth: 0.8)
                        )
                }
            }
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(LWColors.muted.opacity(0.65))
            }
        }
        .frame(minHeight: 36)
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private var recordBadge: some View {
        if record.type == .received {
            Image("lwl_badge_receive")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
        } else {
            Image("lwl_badge_give")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
        }
    }
}
