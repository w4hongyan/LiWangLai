import SwiftUI

enum GiftRecordType: String, Codable, CaseIterable, Identifiable {
    case received
    case given

    var id: String { rawValue }

    var title: String {
        switch self {
        case .received: "收礼"
        case .given: "送礼"
        }
    }

    var shortTitle: String {
        switch self {
        case .received: "收"
        case .given: "送"
        }
    }

    var narrativeTitle: String {
        switch self {
        case .received: "他送礼"
        case .given: "我送礼"
        }
    }

    var accentColor: Color {
        switch self {
        case .received: LWColors.cinnabar
        case .given: LWColors.warmGold
        }
    }
}
