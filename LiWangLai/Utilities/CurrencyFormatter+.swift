import Foundation

extension Int {
    /// 整元金额格式化；新业务金额请优先使用 fenCurrencyText。
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
