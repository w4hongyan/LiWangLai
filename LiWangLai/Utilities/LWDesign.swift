import SwiftUI

struct LWThemePalette {
    let paper: Color
    let paperDeep: Color
    let card: Color
    let cardStroke: Color
    let primary: Color
    let primaryDark: Color
    let ink: Color
    let inkSoft: Color
    let muted: Color
    let secondary: Color
    let secondaryPale: Color
    let jade: Color
}

enum LWThemeStore {
    nonisolated(unsafe) static var current: AppTheme = {
        if let rawValue = UserDefaults.standard.string(forKey: "liwanglai.selectedTheme"),
           let storedTheme = AppTheme(rawValue: rawValue) {
            return storedTheme
        }
        return .paper
    }()

    static var palette: LWThemePalette {
        current.palette
    }
}

enum LWColors {
    static var paper: Color { LWThemeStore.palette.paper }
    static var paperDeep: Color { LWThemeStore.palette.paperDeep }
    static var card: Color { LWThemeStore.palette.card }
    static var cardStroke: Color { LWThemeStore.palette.cardStroke }
    static var cinnabar: Color { LWThemeStore.palette.primary }
    static var cinnabarDark: Color { LWThemeStore.palette.primaryDark }
    static var ink: Color { LWThemeStore.palette.ink }
    static var inkSoft: Color { LWThemeStore.palette.inkSoft }
    static var muted: Color { LWThemeStore.palette.muted }
    static var warmGold: Color { LWThemeStore.palette.secondary }
    static var goldPale: Color { LWThemeStore.palette.secondaryPale }
    static var jade: Color { LWThemeStore.palette.jade }
}

extension AppTheme {
    var palette: LWThemePalette {
        switch self {
        case .paper:
            LWThemePalette(
                paper: Color(red: 0.976, green: 0.953, blue: 0.902),
                paperDeep: Color(red: 0.946, green: 0.902, blue: 0.824),
                card: Color(red: 1.0, green: 0.986, blue: 0.95),
                cardStroke: Color(red: 0.858, green: 0.792, blue: 0.684),
                primary: Color(red: 0.72, green: 0.14, blue: 0.09),
                primaryDark: Color(red: 0.55, green: 0.08, blue: 0.06),
                ink: Color(red: 0.12, green: 0.11, blue: 0.10),
                inkSoft: Color(red: 0.42, green: 0.38, blue: 0.32),
                muted: Color(red: 0.60, green: 0.55, blue: 0.49),
                secondary: Color(red: 0.70, green: 0.52, blue: 0.30),
                secondaryPale: Color(red: 0.86, green: 0.73, blue: 0.52),
                jade: Color(red: 0.12, green: 0.30, blue: 0.29)
            )
        case .cinnabar:
            LWThemePalette(
                paper: Color(red: 0.988, green: 0.938, blue: 0.900),
                paperDeep: Color(red: 0.920, green: 0.790, blue: 0.710),
                card: Color(red: 1.0, green: 0.965, blue: 0.930),
                cardStroke: Color(red: 0.820, green: 0.600, blue: 0.520),
                primary: Color(red: 0.73, green: 0.12, blue: 0.09),
                primaryDark: Color(red: 0.50, green: 0.06, blue: 0.05),
                ink: Color(red: 0.17, green: 0.09, blue: 0.08),
                inkSoft: Color(red: 0.45, green: 0.27, blue: 0.23),
                muted: Color(red: 0.62, green: 0.45, blue: 0.40),
                secondary: Color(red: 0.70, green: 0.45, blue: 0.24),
                secondaryPale: Color(red: 0.88, green: 0.68, blue: 0.48),
                jade: Color(red: 0.16, green: 0.32, blue: 0.28)
            )
        case .inkGreen:
            LWThemePalette(
                paper: Color(red: 0.915, green: 0.948, blue: 0.905),
                paperDeep: Color(red: 0.760, green: 0.840, blue: 0.770),
                card: Color(red: 0.965, green: 0.982, blue: 0.948),
                cardStroke: Color(red: 0.590, green: 0.710, blue: 0.620),
                primary: Color(red: 0.12, green: 0.34, blue: 0.30),
                primaryDark: Color(red: 0.07, green: 0.22, blue: 0.19),
                ink: Color(red: 0.08, green: 0.15, blue: 0.13),
                inkSoft: Color(red: 0.28, green: 0.40, blue: 0.34),
                muted: Color(red: 0.45, green: 0.55, blue: 0.49),
                secondary: Color(red: 0.66, green: 0.52, blue: 0.28),
                secondaryPale: Color(red: 0.78, green: 0.70, blue: 0.46),
                jade: Color(red: 0.10, green: 0.31, blue: 0.28)
            )
        case .warmGold:
            LWThemePalette(
                paper: Color(red: 0.982, green: 0.940, blue: 0.830),
                paperDeep: Color(red: 0.900, green: 0.790, blue: 0.590),
                card: Color(red: 1.0, green: 0.970, blue: 0.880),
                cardStroke: Color(red: 0.800, green: 0.630, blue: 0.360),
                primary: Color(red: 0.62, green: 0.39, blue: 0.15),
                primaryDark: Color(red: 0.42, green: 0.25, blue: 0.08),
                ink: Color(red: 0.15, green: 0.11, blue: 0.06),
                inkSoft: Color(red: 0.42, green: 0.33, blue: 0.19),
                muted: Color(red: 0.58, green: 0.48, blue: 0.32),
                secondary: Color(red: 0.70, green: 0.18, blue: 0.10),
                secondaryPale: Color(red: 0.90, green: 0.70, blue: 0.42),
                jade: Color(red: 0.14, green: 0.30, blue: 0.25)
            )
        }
    }
}

enum LWSpacing {
    static let page: CGFloat = 20
    static let card: CGFloat = 18
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 24
}

enum LWRadius {
    static let card: CGFloat = 14
    static let pill: CGFloat = 999
    static let button: CGFloat = 16
}

extension Font {
    static func titleSong(_ size: CGFloat) -> Font {
        .custom("SourceHanSerifSC-SemiBold", size: size, relativeTo: .title2)
    }

    static func bodySong(_ size: CGFloat) -> Font {
        .custom("SourceHanSerifSC-Regular", size: size, relativeTo: .body)
    }

    static func bodyKai(_ size: CGFloat) -> Font {
        .custom("SourceHanSerifSC-Regular", size: size, relativeTo: .body)
    }

    static func amountKai(_ size: CGFloat) -> Font {
        .custom("SourceHanSerifSC-Regular", size: size, relativeTo: .title3)
    }
}

struct PaperTexture: View {
    var body: some View {
        ZStack {
            LWColors.paper
            LinearGradient(
                colors: [
                    Color.white.opacity(0.40),
                    LWColors.paperDeep.opacity(0.14),
                    Color.white.opacity(0.14)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Canvas { context, size in
                for index in 0..<220 {
                    let x = CGFloat((index * 47) % 997) / 997 * size.width
                    let y = CGFloat((index * 83) % 991) / 991 * size.height
                    let opacity = Double((index % 9) + 1) / 220
                    var path = Path()
                    path.addEllipse(in: CGRect(x: x, y: y, width: 1.1, height: 1.1))
                    context.fill(path, with: .color(LWColors.ink.opacity(opacity)))
                }
            }
        }
        .ignoresSafeArea()
    }
}

struct PageHeader: View {
    let title: String
    let subtitle: String?
    var trailing: AnyView?

    init(title: String, subtitle: String? = nil, trailing: AnyView? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.trailing = trailing
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.titleSong(40))
                        .foregroundStyle(LWColors.ink)
                    if let subtitle {
                        Text(subtitle)
                            .font(.bodySong(17))
                            .foregroundStyle(LWColors.warmGold)
                    }
                }
                Spacer()
                if let trailing {
                    trailing
                }
            }
            MountainDecoration()
                .frame(height: 72)
                .padding(.top, -22)
        }
    }
}

struct MountainDecoration: View {
    var body: some View {
        Image("lwl_header_decoration")
            .resizable()
            .scaledToFit()
    }
}
