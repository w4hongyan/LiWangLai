import SwiftUI

struct ChineseDatePickerButton: View {
    var title: String?
    @Binding var date: Date

    @State private var showPicker = false
    @State private var draftDate = Date()

    var body: some View {
        Button {
            draftDate = date
            showPicker = true
            HapticsManager.lightTap()
        } label: {
            HStack(spacing: 8) {
                if let title {
                    Text(title)
                        .font(.titleSong(14))
                        .foregroundStyle(LWColors.ink)
                }
                Spacer(minLength: 8)
                Text(date.lwDayText)
                    .font(.bodySong(13))
                    .foregroundStyle(LWColors.ink)
                Image(systemName: "calendar")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(LWColors.warmGold)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showPicker) {
            ChineseDatePickerSheet(title: title ?? "选择日期", date: $draftDate) {
                date = draftDate
                showPicker = false
            }
            .presentationDetents([.height(340)])
        }
    }
}

private struct ChineseDatePickerSheet: View {
    let title: String
    @Binding var date: Date
    let onConfirm: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Text(title)
                    .font(.titleSong(18))
                    .foregroundStyle(LWColors.ink)
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(LWColors.muted)
                }
                .buttonStyle(.plain)
            }

            DatePicker("", selection: $date, displayedComponents: .date)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .environment(\.locale, Locale(identifier: "zh_Hans_CN"))
                .environment(\.calendar, Calendar(identifier: .gregorian))
                .tint(LWColors.cinnabar)
                .frame(maxWidth: .infinity)

            SealButton(title: "确定", systemImage: "checkmark", fontSize: 14, verticalPadding: 10, cornerRadius: 12) {
                onConfirm()
            }
        }
        .padding(20)
        .background(PaperTexture())
    }
}

