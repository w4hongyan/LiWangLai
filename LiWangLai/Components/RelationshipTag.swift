import SwiftUI

struct RelationshipTag: View {
    let title: String
    var isSelected = false

    var body: some View {
        Text(title)
            .font(.bodySong(13))
            .foregroundStyle(isSelected ? .white : LWColors.ink)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? LWColors.cinnabar : LWColors.card.opacity(0.82))
                    .overlay(Capsule().stroke(isSelected ? LWColors.cinnabarDark.opacity(0.2) : LWColors.cardStroke.opacity(0.45), lineWidth: 0.8))
            )
    }
}
