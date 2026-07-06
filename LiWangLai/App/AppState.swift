import Foundation
import Observation

@Observable
final class AppState {
    var selectedTab: AppTab = .home
    var homeSearchText = ""
    var ledgerSearchText = ""
    var peopleSearchText = ""
    var faceIDEnabled = false
    var selectedTheme: AppTheme = .paper {
        didSet {
            UserDefaults.standard.set(selectedTheme.rawValue, forKey: Self.themeKey)
            LWThemeStore.current = selectedTheme
        }
    }

    private static let themeKey = "liwanglai.selectedTheme"

    init() {
        if let rawValue = UserDefaults.standard.string(forKey: Self.themeKey),
           let storedTheme = AppTheme(rawValue: rawValue) {
            selectedTheme = storedTheme
        }
        LWThemeStore.current = selectedTheme
    }
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
