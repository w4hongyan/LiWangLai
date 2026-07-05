import SwiftUI

struct AmountTextField: View {
    @Binding var amountText: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text("¥")
                .font(.titleSong(28))
            TextField("0", text: $amountText)
                .keyboardType(.numberPad)
                .font(.system(size: 44, weight: .semibold, design: .serif))
                .foregroundStyle(LWColors.ink)
                .onChange(of: amountText) { _, newValue in
                    let filtered = String(newValue.filter(\.isNumber).prefix(7))
                    if filtered != newValue {
                        amountText = filtered
                    }
                }
        }
    }
}
