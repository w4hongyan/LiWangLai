import SwiftUI

struct GoldLineDivider: View {
    var body: some View {
        Rectangle()
            .fill(LWColors.goldPale.opacity(0.35))
            .frame(height: 0.8)
    }
}
