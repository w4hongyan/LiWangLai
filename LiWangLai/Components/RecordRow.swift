import SwiftUI

struct RecordRow: View {
    let record: GiftRecord
    var showChevron = true

    var body: some View {
        HStack(spacing: 8) {
            SealStamp(text: record.type.shortTitle, size: 30, color: record.type.accentColor)
            VStack(alignment: .leading, spacing: 2) {
                Text("\(record.personName) · \(record.eventType.title)")
                    .font(.bodySong(14).weight(.semibold))
                    .foregroundStyle(LWColors.ink)
                Text(record.date.lwDayText)
                    .font(.bodySong(11))
                    .foregroundStyle(LWColors.muted)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(record.amountYuan.yuanText)
                    .font(.system(size: 14, weight: .semibold, design: .serif))
                    .foregroundStyle(record.type == .received ? LWColors.cinnabar : LWColors.ink)
                Text(record.isReturned ? "已回" : (record.type == .received ? "未回" : "已记"))
                    .font(.bodySong(10))
                    .foregroundStyle(record.isReturned ? LWColors.muted : LWColors.cinnabar)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 1)
                    .overlay(
                        RoundedRectangle(cornerRadius: 3)
                            .stroke((record.isReturned ? LWColors.muted : LWColors.cinnabar).opacity(0.65), lineWidth: 0.8)
                    )
            }
            if showChevron {
                Image(systemName: "chevron.right")
                    .foregroundStyle(LWColors.muted.opacity(0.65))
            }
        }
        .contentShape(Rectangle())
    }
}
