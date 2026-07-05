import SwiftUI

struct PaperCard<Content: View>: View {
    var padding: CGFloat = LWSpacing.card
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            content
        }
        .padding(padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: LWRadius.card, style: .continuous)
                .fill(LWColors.card.opacity(0.78))
                .overlay(
                    RoundedRectangle(cornerRadius: LWRadius.card, style: .continuous)
                        .stroke(LWColors.cardStroke.opacity(0.38), lineWidth: 0.8)
                )
                .shadow(color: LWColors.ink.opacity(0.06), radius: 8, x: 0, y: 4)
        }
    }
}
