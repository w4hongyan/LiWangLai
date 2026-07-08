import SwiftUI

struct SearchField: View {
    let placeholder: String
    @Binding var text: String
    var fontSize: CGFloat = 14
    var iconSize: CGFloat = 18
    var verticalPadding: CGFloat = 9

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: iconSize, weight: .medium))
                .foregroundStyle(LWColors.muted)
            TextField(placeholder, text: $text)
                .textInputAutocapitalization(.never)
                .font(.bodySong(fontSize))
                .foregroundStyle(LWColors.ink)
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(LWColors.muted.opacity(0.7))
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, verticalPadding)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white.opacity(0.72))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(LWColors.cardStroke.opacity(0.42), lineWidth: 0.8)
                )
        )
    }
}
