import SwiftUI

struct SearchField: View {
    let placeholder: String
    @Binding var text: String
    var fontSize: CGFloat = 16
    var iconSize: CGFloat = 21
    var verticalPadding: CGFloat = 12

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: iconSize))
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
                        .foregroundStyle(LWColors.muted.opacity(0.8))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, verticalPadding)
        .background(
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .fill(Color.white.opacity(0.70))
                .overlay(
                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                        .stroke(LWColors.cardStroke.opacity(0.45), lineWidth: 0.8)
                )
        )
    }
}
