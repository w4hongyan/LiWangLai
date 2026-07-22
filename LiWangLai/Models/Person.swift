import Foundation

struct PersonSummary: Identifiable {
    let id: String
    let name: String
    let relationship: RelationshipType
    let records: [GiftRecord]
    let identityHint: String?

    var personID: UUID? {
        let ids = Set(records.compactMap(\.personID))
        return ids.count == 1 ? ids.first : nil
    }

    var primaryContact: String {
        records
            .sorted { $0.date > $1.date }
            .first(where: { !$0.contact.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty })?
            .contact ?? ""
    }

    var totalReceivedFen: Int {
        records.filter { $0.type == .received }.reduce(0) { $0 + $1.amountFenValue }
    }

    var totalGivenFen: Int {
        records.filter { $0.type == .given }.reduce(0) { $0 + $1.amountFenValue }
    }

    var netAmountFen: Int {
        totalReceivedFen - totalGivenFen
    }

    // 兼容既有整元调用；精确统计使用 *Fen 属性。
    var totalReceived: Int { totalReceivedFen / 100 }
    var totalGiven: Int { totalGivenFen / 100 }
    var netAmount: Int { netAmountFen / 100 }

    /// 判断「往来平衡」的金额阈值（净额不超过该值时视为平衡）
    static let balanceThresholdFen = 200 * 100
    static let balanceThreshold = balanceThresholdFen / 100

    var pendingReturnCount: Int {
        records.filter(\.needsReturn).count
    }

    var pendingReturnAmountFen: Int {
        records.filter(\.needsReturn).reduce(0) { $0 + $1.amountFenValue }
    }

    var latestRecord: GiftRecord? {
        records.sorted { $0.date > $1.date }.first
    }

    var statusText: String {
        if pendingReturnCount > 0 {
            "记得回礼"
        } else if abs(netAmountFen) <= PersonSummary.balanceThresholdFen {
            "往来平衡"
        } else if netAmountFen > 0 {
            "下次可回"
        } else {
            "我方多礼"
        }
    }
}

enum PersonIdentity {
    static func normalizedName(_ value: String) -> String {
        value
            .precomposedStringWithCompatibilityMapping
            .lowercased()
            .components(separatedBy: .whitespacesAndNewlines)
            .joined()
    }

    /// 仅「类手机号」（trim 后纯数字且位数 ≥ 5）才具备身份区分力，可作为同名拆分依据；
    /// 微信号、桌号等含字母/符号或过短的联系方式不具备区分力，返回空（归入 no-contact 组）
    static func normalizedContact(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 5, trimmed.allSatisfy(\.isNumber) else { return "" }
        return trimmed
    }

    static func maskedContact(_ value: String) -> String? {
        let digits = normalizedContact(value)
        guard !digits.isEmpty else { return nil }
        if digits.count >= 7 {
            return "\(digits.prefix(3))••••\(digits.suffix(4))"
        }
        return "•••\(digits.suffix(3))"
    }

    static func matches(_ lhs: GiftRecord, name: String, contact: String = "") -> Bool {
        guard normalizedName(lhs.personName) == normalizedName(name) else { return false }
        let targetContact = normalizedContact(contact)
        let recordContact = normalizedContact(lhs.contact)
        return targetContact.isEmpty || recordContact.isEmpty || targetContact == recordContact
    }
}
