import SwiftUI

enum LWColors {
    static let paper = Color(red: 0.976, green: 0.953, blue: 0.902)
    static let paperDeep = Color(red: 0.946, green: 0.902, blue: 0.824)
    static let card = Color(red: 1.0, green: 0.986, blue: 0.95)
    static let cardStroke = Color(red: 0.858, green: 0.792, blue: 0.684)
    static let cinnabar = Color(red: 0.72, green: 0.14, blue: 0.09)
    static let cinnabarDark = Color(red: 0.55, green: 0.08, blue: 0.06)
    static let ink = Color(red: 0.12, green: 0.11, blue: 0.10)
    static let inkSoft = Color(red: 0.42, green: 0.38, blue: 0.32)
    static let muted = Color(red: 0.60, green: 0.55, blue: 0.49)
    static let warmGold = Color(red: 0.70, green: 0.52, blue: 0.30)
    static let goldPale = Color(red: 0.86, green: 0.73, blue: 0.52)
    static let jade = Color(red: 0.12, green: 0.30, blue: 0.29)
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
        .custom("SourceHanSerifSC-SemiBold", size: size)
    }

    static func bodySong(_ size: CGFloat) -> Font {
        .custom("SourceHanSerifSC-Regular", size: size)
    }
}

struct PaperTexture: View {
    var body: some View {
        ZStack {
            LWColors.paper
            LinearGradient(
                colors: [
                    Color.white.opacity(0.42),
                    LWColors.paperDeep.opacity(0.16),
                    Color.white.opacity(0.16)
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
                        .font(.titleSong(46))
                        .foregroundStyle(LWColors.ink)
                    if let subtitle {
                        Text(subtitle)
                            .font(.bodySong(19))
                            .foregroundStyle(LWColors.warmGold)
                    }
                }
                Spacer()
                if let trailing {
                    trailing
                }
            }
            MountainDecoration()
                .frame(height: 76)
                .padding(.top, -24)
        }
    }
}

struct MountainDecoration: View {
    var body: some View {
        Canvas { context, size in
            let baseY = size.height * 0.76
            let mountains: [[CGPoint]] = [
                [
                    CGPoint(x: size.width * 0.36, y: baseY),
                    CGPoint(x: size.width * 0.48, y: size.height * 0.42),
                    CGPoint(x: size.width * 0.58, y: baseY)
                ],
                [
                    CGPoint(x: size.width * 0.52, y: baseY),
                    CGPoint(x: size.width * 0.70, y: size.height * 0.26),
                    CGPoint(x: size.width * 0.88, y: baseY)
                ],
                [
                    CGPoint(x: size.width * 0.64, y: baseY),
                    CGPoint(x: size.width * 0.78, y: size.height * 0.50),
                    CGPoint(x: size.width * 1.02, y: baseY)
                ]
            ]

            for mountain in mountains {
                var path = Path()
                path.move(to: mountain[0])
                path.addLine(to: mountain[1])
                path.addLine(to: mountain[2])
                context.stroke(path, with: .color(LWColors.goldPale.opacity(0.45)), lineWidth: 1)
            }

            for offset in stride(from: 0, through: 60, by: 12) {
                var cloud = Path()
                cloud.move(to: CGPoint(x: size.width * 0.50 + CGFloat(offset), y: size.height * 0.18))
                cloud.addCurve(
                    to: CGPoint(x: size.width * 0.58 + CGFloat(offset), y: size.height * 0.18),
                    control1: CGPoint(x: size.width * 0.52 + CGFloat(offset), y: size.height * 0.10),
                    control2: CGPoint(x: size.width * 0.55 + CGFloat(offset), y: size.height * 0.25)
                )
                context.stroke(cloud, with: .color(LWColors.goldPale.opacity(0.45)), lineWidth: 1)
            }

            var branch = Path()
            branch.move(to: CGPoint(x: size.width * 0.86, y: 0))
            branch.addCurve(
                to: CGPoint(x: size.width, y: size.height * 0.1),
                control1: CGPoint(x: size.width * 0.90, y: size.height * 0.12),
                control2: CGPoint(x: size.width * 0.95, y: size.height * 0.02)
            )
            context.stroke(branch, with: .color(LWColors.inkSoft.opacity(0.65)), lineWidth: 2)

            for index in 0..<5 {
                let x = size.width * (0.86 + CGFloat(index) * 0.028)
                let y = size.height * (0.12 + CGFloat(index % 2) * 0.16)
                var blossom = Path()
                blossom.addEllipse(in: CGRect(x: x, y: y, width: 7, height: 7))
                context.fill(blossom, with: .color(LWColors.cinnabar.opacity(0.85)))
            }
        }
    }
}
