import SwiftUI

struct AmountTextField: View {
    @Binding var amountText: String
    var currencySize: CGFloat = 28
    var amountSize: CGFloat = 44

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text("¥")
                .font(.titleSong(currencySize))
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
