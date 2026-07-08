import SwiftUI

struct PaperCard<Content: View>: View {
    var padding: CGFloat = LWSpacing.card
    var spacing: CGFloat = 10
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            content
        }
        .padding(padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: LWRadius.card, style: .continuous)
                .fill(LWColors.card.opacity(0.82))
                .overlay(
                    RoundedRectangle(cornerRadius: LWRadius.card, style: .continuous)
                        .stroke(LWColors.cardStroke.opacity(0.35), lineWidth: 0.8)
                )
                .shadow(color: LWColors.ink.opacity(0.05), radius: 6, x: 0, y: 3)
        }
    }
}
