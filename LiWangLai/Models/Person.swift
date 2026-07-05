import Foundation

struct PersonSummary: Identifiable {
    var id: String { name }
    let name: String
    let relationship: RelationshipType
    let records: [GiftRecord]

    var totalReceived: Int {
        records.filter { $0.type == .received }.reduce(0) { $0 + $1.amountYuan }
    }

    var totalGiven: Int {
        records.filter { $0.type == .given }.reduce(0) { $0 + $1.amountYuan }
    }

    var netAmount: Int {
        totalReceived - totalGiven
    }

    var pendingReturnCount: Int {
        records.filter(\.needsReturn).count
    }

    var latestRecord: GiftRecord? {
        records.sorted { $0.date > $1.date }.first
    }

    var statusText: String {
        if pendingReturnCount > 0 {
            "记得回礼"
        } else if abs(netAmount) <= 200 {
            "往来平衡"
        } else if netAmount > 0 {
            "下次可回"
        } else {
            "我方多礼"
        }
    }
}
