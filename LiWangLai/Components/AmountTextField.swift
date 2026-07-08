import SwiftUI

struct AmountTextField: View {
    @Binding var amountText: String
    var currencySize: CGFloat = 24
    var amountSize: CGFloat = 36

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text("¥")
                .font(.titleSong(currencySize))
                .foregroundStyle(LWColors.warmGold)
            TextField("0", text: $amountText)
                .keyboardType(.numberPad)
                .font(.amountKai(amountSize))
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
