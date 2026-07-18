import Foundation

extension Int {
    var yuanText: String {
        YuanFormatter.shared.string(from: NSNumber(value: self)) ?? "¥\(self)"
    }
}

private enum YuanFormatter {
    static let shared: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.numberStyle = .currency
        formatter.currencySymbol = "¥"
        formatter.maximumFractionDigits = 0
        return formatter
    }()
}
