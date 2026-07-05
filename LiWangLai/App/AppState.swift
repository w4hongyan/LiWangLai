import Foundation
import Observation

@Observable
final class AppState {
    var selectedTab: AppTab = .home
    var homeSearchText = ""
    var ledgerSearchText = ""
    var peopleSearchText = ""
    var prefersHiddenAmounts = false
    var faceIDEnabled = false
    var selectedTheme: AppTheme = .paper
}

enum AppTab: Hashable {
    case home
    case ledger
    case add
    case people
    case settings
}

enum AppTheme: String, CaseIterable, Identifiable {
    case paper
    case cinnabar
    case inkGreen
    case warmGold

    var id: String { rawValue }

    var title: String {
        switch self {
        case .paper: "素宣"
        case .cinnabar: "朱砂"
        case .inkGreen: "墨青"
        case .warmGold: "暖金"
        }
    }
}
