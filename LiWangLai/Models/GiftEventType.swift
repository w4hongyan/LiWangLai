import Foundation

enum GiftEventType: String, Codable, CaseIterable, Identifiable {
    case wedding
    case funeral
    case baby
    case housewarming
    case birthday
    case school
    case festival
    case other

    var id: String { rawValue }

    var title: String {
        switch self {
        case .wedding: "婚礼"
        case .funeral: "白事"
        case .baby: "满月"
        case .housewarming: "乔迁"
        case .birthday: "生日"
        case .school: "升学"
        case .festival: "节日"
        case .other: "其他"
        }
    }

    var icon: String? {
        switch self {
        case .wedding: "heart.circle"
        case .funeral: nil
        case .baby: "baby.face"
        case .housewarming: "house"
        case .birthday: "gift"
        case .school: "graduationcap"
        case .festival: "star"
        case .other: nil
        }
    }

    var notePlaceholder: String {
        switch self {
        case .wedding: "婚宴地点、同席亲友等"
        case .funeral: "白事慰问、随礼情况等"
        case .baby: "满月酒、孩子姓名等"
        case .housewarming: "新房乔迁，亲友聚餐等"
        case .birthday: "寿宴、生日聚会等"
        case .school: "升学宴、学校信息等"
        case .festival: "春节、中秋等节礼"
        case .other: "补充这笔往来的缘由"
        }
    }
}
