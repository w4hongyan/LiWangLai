import SwiftUI

struct RelationshipTag: View {
    let title: String
    var isSelected = false

    var body: some View {
        Text(title)
            .font(.bodySong(16))
            .foregroundStyle(isSelected ? .white : LWColors.ink)
            .padding(.horizontal, 18)
            .padding(.vertical, 9)
            .background(
                Capsule()
                    .fill(isSelected ? LWColors.cinnabar : LWColors.card.opacity(0.78))
                    .overlay(Capsule().stroke(LWColors.cardStroke.opacity(0.55), lineWidth: 0.8))
            )
    }
}
