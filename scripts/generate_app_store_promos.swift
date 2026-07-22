import AppKit
import CoreText
import Foundation
import ImageIO

struct Promo {
    let input: String
    let output: String
    let title: String
    let subtitle: String
    let accent: NSColor
    let tint: NSColor
}

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let raw = root.appendingPathComponent("AppStoreScreenshots/1320x2868/raw-latest")
let output = root.appendingPathComponent("AppStoreScreenshots/1320x2868/promotional")
try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)

let promos = [
    Promo(input: "01-home.png", output: "01-home.png", title: "人情有数，往来有度", subtitle: "年度收送一目了然，重要心意从容安排", accent: .init(red: 0.72, green: 0.13, blue: 0.09, alpha: 1), tint: .init(red: 0.98, green: 0.91, blue: 0.86, alpha: 1)),
    Promo(input: "03-add-record.png", output: "02-add-record.png", title: "三秒入簿，简单完整", subtitle: "金额、关系、日期与提醒，一次记好", accent: .init(red: 0.74, green: 0.17, blue: 0.10, alpha: 1), tint: .init(red: 1.00, green: 0.92, blue: 0.82, alpha: 1)),
    Promo(input: "02-ledger.png", output: "03-ledger.png", title: "一本礼簿，记清往来", subtitle: "按月查看收礼送礼，每一笔都有来处", accent: .init(red: 0.57, green: 0.32, blue: 0.15, alpha: 1), tint: .init(red: 0.96, green: 0.91, blue: 0.78, alpha: 1)),
    Promo(input: "04-people.png", output: "04-people.png", title: "按人整理，关系更清楚", subtitle: "往来历史、收送差额与回礼状态随时查看", accent: .init(red: 0.18, green: 0.35, blue: 0.31, alpha: 1), tint: .init(red: 0.86, green: 0.94, blue: 0.88, alpha: 1)),
    Promo(input: "06-reminders.png", output: "05-reminders.png", title: "送礼回礼，不再忘记", subtitle: "集中查看待办时间，重要心意及时安排", accent: .init(red: 0.72, green: 0.13, blue: 0.09, alpha: 1), tint: .init(red: 0.98, green: 0.87, blue: 0.84, alpha: 1)),
    Promo(input: "05-settings.png", output: "06-settings.png", title: "本机保存，安心好用", subtitle: "Excel 导入导出、完整备份与隐私解锁", accent: .init(red: 0.40, green: 0.31, blue: 0.24, alpha: 1), tint: .init(red: 0.91, green: 0.90, blue: 0.87, alpha: 1)),
]

func registerFont(_ relativePath: String) -> String? {
    let url = root.appendingPathComponent(relativePath) as CFURL
    guard let provider = CGDataProvider(url: url), let cgFont = CGFont(provider) else { return nil }
    var error: Unmanaged<CFError>?
    CTFontManagerRegisterGraphicsFont(cgFont, &error)
    return cgFont.postScriptName as String?
}

let semiboldName = registerFont("LiWangLai/Resources/Fonts/SourceHanSerifSC-SemiBold.otf")
let regularName = registerFont("LiWangLai/Resources/Fonts/SourceHanSerifSC-Regular.otf")

func font(_ name: String?, size: CGFloat, weight: NSFont.Weight = .regular) -> NSFont {
    if let name, let font = NSFont(name: name, size: size) { return font }
    return NSFont.systemFont(ofSize: size, weight: weight)
}

func stripAlpha(from url: URL, width: Int, height: Int) throws {
    guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
          let sourceImage = CGImageSourceCreateImageAtIndex(source, 0, nil),
          let colorSpace = CGColorSpace(name: CGColorSpace.sRGB),
          let context = CGContext(
              data: nil,
              width: width,
              height: height,
              bitsPerComponent: 8,
              bytesPerRow: width * 4,
              space: colorSpace,
              bitmapInfo: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.noneSkipLast.rawValue
          ) else {
        fatalError("Unable to prepare RGB image for \(url.lastPathComponent)")
    }

    context.interpolationQuality = .high
    context.draw(sourceImage, in: CGRect(x: 0, y: 0, width: width, height: height))
    guard let destinationImage = context.makeImage() else {
        fatalError("Unable to render RGB image for \(url.lastPathComponent)")
    }

    let temporaryURL = url.deletingLastPathComponent()
        .appendingPathComponent(".\(url.lastPathComponent).rgb.png")
    guard let destination = CGImageDestinationCreateWithURL(
        temporaryURL as CFURL,
        "public.png" as CFString,
        1,
        nil
    ) else {
        fatalError("Unable to create RGB destination for \(url.lastPathComponent)")
    }
    CGImageDestinationAddImage(destination, destinationImage, nil)
    guard CGImageDestinationFinalize(destination) else {
        fatalError("Unable to finalize RGB image for \(url.lastPathComponent)")
    }
    _ = try FileManager.default.replaceItemAt(url, withItemAt: temporaryURL)
}

let canvasSize = NSSize(width: 1320, height: 2868)
let paragraph = NSMutableParagraphStyle()
paragraph.lineBreakMode = .byTruncatingTail

for (index, promo) in promos.enumerated() {
    guard let screenshot = NSImage(contentsOf: raw.appendingPathComponent(promo.input)) else {
        fatalError("Missing screenshot: \(promo.input)")
    }

    let image = NSImage(size: canvasSize)
    image.lockFocus()
    guard let context = NSGraphicsContext.current else { fatalError("Missing graphics context") }
    context.imageInterpolation = .high

    let full = NSRect(origin: .zero, size: canvasSize)
    let paper = NSColor(red: 0.985, green: 0.972, blue: 0.938, alpha: 1)
    NSGradient(starting: paper, ending: promo.tint)?.draw(in: full, angle: 90)

    // Restrained Chinese-paper decoration; all text and product UI remain unobstructed.
    promo.accent.withAlphaComponent(0.055).setFill()
    NSBezierPath(ovalIn: NSRect(x: -180, y: 2330, width: 620, height: 620)).fill()
    NSBezierPath(ovalIn: NSRect(x: 1020, y: 2520, width: 360, height: 360)).fill()

    if let plum = NSImage(contentsOf: root.appendingPathComponent("LiWangLai/Resources/Assets.xcassets/prototype_plum_branch_corner.imageset/prototype_plum_branch_corner.png")) {
        plum.draw(in: NSRect(x: 1030, y: 2580, width: 300, height: 250), from: .zero, operation: .sourceOver, fraction: 0.28)
    }

    let brandAttributes: [NSAttributedString.Key: Any] = [
        .font: font(semiboldName, size: 34, weight: .semibold),
        .foregroundColor: promo.accent,
        .kern: 4.0,
    ]
    ("礼往来  ·  APP STORE" as NSString).draw(at: NSPoint(x: 92, y: 2740), withAttributes: brandAttributes)

    let numberRect = NSRect(x: 1120, y: 2708, width: 106, height: 106)
    promo.accent.setFill()
    NSBezierPath(roundedRect: numberRect, xRadius: 28, yRadius: 28).fill()
    let number = String(format: "%02d", index + 1) as NSString
    let numberAttributes: [NSAttributedString.Key: Any] = [
        .font: NSFont.monospacedDigitSystemFont(ofSize: 39, weight: .bold),
        .foregroundColor: NSColor.white,
    ]
    let numberSize = number.size(withAttributes: numberAttributes)
    number.draw(at: NSPoint(x: numberRect.midX - numberSize.width / 2, y: numberRect.midY - numberSize.height / 2 + 1), withAttributes: numberAttributes)

    let titleAttributes: [NSAttributedString.Key: Any] = [
        .font: font(semiboldName, size: 88, weight: .bold),
        .foregroundColor: NSColor(red: 0.10, green: 0.085, blue: 0.07, alpha: 1),
        .paragraphStyle: paragraph,
    ]
    (promo.title as NSString).draw(in: NSRect(x: 88, y: 2530, width: 1145, height: 130), withAttributes: titleAttributes)

    let subtitleAttributes: [NSAttributedString.Key: Any] = [
        .font: font(regularName, size: 38),
        .foregroundColor: NSColor(red: 0.37, green: 0.31, blue: 0.25, alpha: 1),
        .paragraphStyle: paragraph,
    ]
    (promo.subtitle as NSString).draw(in: NSRect(x: 92, y: 2442, width: 1135, height: 62), withAttributes: subtitleAttributes)

    // Screenshot is proportionally scaled and clipped only below the canvas.
    let screenRect = NSRect(x: 104, y: -30, width: 1112, height: 2417)
    NSGraphicsContext.saveGraphicsState()
    let shadow = NSShadow()
    shadow.shadowColor = NSColor.black.withAlphaComponent(0.22)
    shadow.shadowBlurRadius = 34
    shadow.shadowOffset = NSSize(width: 0, height: -12)
    shadow.set()
    NSColor.black.withAlphaComponent(0.10).setFill()
    NSBezierPath(roundedRect: screenRect.insetBy(dx: -9, dy: -9), xRadius: 70, yRadius: 70).fill()
    NSGraphicsContext.restoreGraphicsState()

    NSGraphicsContext.saveGraphicsState()
    NSBezierPath(roundedRect: screenRect, xRadius: 62, yRadius: 62).addClip()
    screenshot.draw(in: screenRect, from: .zero, operation: .copy, fraction: 1)
    NSGraphicsContext.restoreGraphicsState()

    promo.accent.withAlphaComponent(0.34).setStroke()
    let border = NSBezierPath(roundedRect: screenRect, xRadius: 62, yRadius: 62)
    border.lineWidth = 4
    border.stroke()

    image.unlockFocus()
    guard let tiff = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiff),
          let png = bitmap.representation(using: .png, properties: [.compressionFactor: 1.0]) else {
        fatalError("Unable to encode \(promo.output)")
    }
    let outputURL = output.appendingPathComponent(promo.output)
    try png.write(to: outputURL, options: .atomic)

    // NSImage renders at the Mac backing scale. Normalize the final artifact to
    // App Store Connect's exact iPhone 6.9-inch requirement: 1320 × 2868 pixels.
    let resize = Process()
    resize.executableURL = URL(fileURLWithPath: "/usr/bin/sips")
    resize.arguments = ["-z", "2868", "1320", outputURL.path]
    resize.standardOutput = FileHandle.nullDevice
    resize.standardError = FileHandle.nullDevice
    try resize.run()
    resize.waitUntilExit()
    guard resize.terminationStatus == 0 else {
        fatalError("Unable to resize \(promo.output)")
    }
    try stripAlpha(from: outputURL, width: 1320, height: 2868)
    print("Wrote \(promo.output)")
}
