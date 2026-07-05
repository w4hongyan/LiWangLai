import Foundation

struct GiftEvent: Identifiable {
    var id: String { "\(title)-\(monthKey)" }
    let title: String
    let monthKey: String
    let records: [GiftRecord]

    var totalAmount: Int {
        records.reduce(0) { $0 + $1.amountYuan }
    }
}
