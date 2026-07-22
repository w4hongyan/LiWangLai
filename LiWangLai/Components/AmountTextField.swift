import SwiftUI

enum RecordInputField: Hashable {
    case name
    case amount
}

struct AmountTextField: View {
    @Binding var amountText: String
    var currencySize: CGFloat = 24
    var amountSize: CGFloat = 36
    var focusedField: FocusState<RecordInputField?>.Binding?

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text("¥")
                .font(.titleSong(currencySize))
                .foregroundStyle(LWColors.warmGold)
            amountField
        }
    }

    @ViewBuilder
    private var amountField: some View {
        if let focusedField {
            configuredField
                .focused(focusedField, equals: .amount)
        } else {
            configuredField
        }
    }

    private var configuredField: some View {
        TextField("请输入金额", text: $amountText)
            .keyboardType(.decimalPad)
            .font(.amountKai(amountSize))
            .foregroundStyle(LWColors.ink)
    }
}
