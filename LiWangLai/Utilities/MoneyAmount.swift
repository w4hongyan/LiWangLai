import Foundation

/// 金额统一以「分」做整数运算，避免 Double 浮点误差。
enum MoneyAmount {
    static let maximumFen = 900_000_000_000_000_000

    static func parseFen(_ text: String) -> Int? {
        let normalized = text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "¥", with: "")
            .replacingOccurrences(of: "￥", with: "")
            .replacingOccurrences(of: ",", with: "")

        guard !normalized.isEmpty else { return nil }
        let parts = normalized.split(separator: ".", omittingEmptySubsequences: false)
        guard parts.count <= 2,
              let integerPart = parts.first,
              !integerPart.isEmpty,
              integerPart.allSatisfy(\.isNumber) else { return nil }

        let fractionalPart = parts.count == 2 ? parts[1] : Substring()
        guard fractionalPart.count <= 2,
              fractionalPart.allSatisfy(\.isNumber) else { return nil }

        let integerDigits = String(integerPart)
        let paddedFraction = String(fractionalPart) + String(repeating: "0", count: 2 - fractionalPart.count)
        guard let yuan = Int(integerDigits),
              let cents = Int(paddedFraction),
              yuan <= (maximumFen - cents) / 100 else { return nil }
        return yuan * 100 + cents
    }

    static func inputText(fromFen fen: Int) -> String {
        let sign = fen < 0 ? "-" : ""
        let magnitude = fen.magnitude
        let yuan = magnitude / 100
        let cents = magnitude % 100
        guard cents != 0 else { return "\(sign)\(yuan)" }
        if cents % 10 == 0 {
            return "\(sign)\(yuan).\(cents / 10)"
        }
        return "\(sign)\(yuan).\(String(format: "%02llu", cents))"
    }

    static func validationMessage(for text: String) -> String? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        guard let fen = parseFen(trimmed), fen > 0 else {
            return "请输入有效金额，最多保留两位小数。"
        }
        return nil
    }
}

extension Int {
    /// 将当前整数按「分」格式化为人民币文本。
    var fenCurrencyText: String {
        FenCurrencyFormatter.shared.string(from: decimalYuanNumber) ?? "¥\(MoneyAmount.inputText(fromFen: self))"
    }

    private var decimalYuanNumber: NSDecimalNumber {
        NSDecimalNumber(value: self).dividing(by: NSDecimalNumber(value: 100))
    }
}

private enum FenCurrencyFormatter {
    static let shared: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.numberStyle = .currency
        formatter.currencySymbol = "¥"
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}
