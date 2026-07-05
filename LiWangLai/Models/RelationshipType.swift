import Foundation

enum RelationshipType: String, Codable, CaseIterable, Identifiable {
    case relative
    case friend
    case colleague
    case classmate
    case neighbor
    case client
    case other

    var id: String { rawValue }

    var title: String {
        switch self {
        case .relative: "亲戚"
        case .friend: "朋友"
        case .colleague: "同事"
        case .classmate: "同学"
        case .neighbor: "邻里"
        case .client: "客户"
        case .other: "其他"
        }
    }
}
