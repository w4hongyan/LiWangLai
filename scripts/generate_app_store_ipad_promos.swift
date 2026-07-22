import AppKit
import CoreText
import Foundation
import ImageIO

struct Promo {
    let input: String
    let output: String
    let title: String
    let subtitle: String
}

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let raw = root.appendingPathComponent("AppStoreScreenshots/2064x2752/raw-latest")
let output = root.appendingPathComponent("AppStoreScreenshots/2064x2752/promotional")
try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)

let promos = [
    Promo(input: "01-home.png", output: "01-home.png", title: "大屏总览，往来更清楚", subtitle: "年度收送、待回礼与最近入簿一屏掌握"),
    Promo(input: "03-add-record.png", output: "02-add-record.png", title: "现场入簿，快而不乱", subtitle: "大屏表单连续登记，宴席现场更从容"),
    Promo(input: "02-ledger.png", output: "03-ledger.png", title: "礼簿展开，每笔都有来处", subtitle: "按月查看收礼送礼，金额与关系一目了然"),
    Promo(input: "04-people.png", output: "04-people.png", title: "按人整理，关系脉络清晰", subtitle: "往来历史、收送差额与回礼状态随时查看"),
    Promo(input: "05-settings.png", output: "05-settings.png", title: "数据在本机，备份更安心", subtitle: "Excel 导入导出、完整备份与隐私解锁"),
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
          ) else { fatalError("Unable to prepare RGB image") }
    context.interpolationQuality = .high
    context.draw(sourceImage, in: CGRect(x: 0, y: 0, width: width, height: height))
    guard let image = context.makeImage() else { fatalError("Unable to render RGB image") }
    let temporaryURL = url.deletingLastPathComponent().appendingPathComponent(".\(url.lastPathComponent).rgb.png")
    guard let destination = CGImageDestinationCreateWithURL(temporaryURL as CFURL, "public.png" as CFString, 1, nil) else {
        fatalError("Unable to create RGB destination")
    }
    CGImageDestinationAddImage(destination, image, nil)
    guard CGImageDestinationFinalize(destination) else { fatalError("Unable to finalize RGB image") }
    _ = try FileManager.default.replaceItemAt(url, withItemAt: temporaryURL)
}

let canvas = NSSize(width: 2064, height: 2752)
let accent = NSColor(red: 0.72, green: 0.13, blue: 0.09, alpha: 1)

for (index, promo) in promos.enumerated() {
    guard let screenshot = NSImage(contentsOf: raw.appendingPathComponent(promo.input)) else {
        fatalError("Missing screenshot: \(promo.input)")
    }
    let image = NSImage(size: canvas)
    image.lockFocus()
    guard let context = NSGraphicsContext.current else { fatalError("Missing graphics context") }
    context.imageInterpolation = .high

    let full = NSRect(origin: .zero, size: canvas)
    NSGradient(
        starting: NSColor(red: 0.99, green: 0.97, blue: 0.93, alpha: 1),
        ending: NSColor(red: 0.97, green: 0.89, blue: 0.84, alpha: 1)
    )?.draw(in: full, angle: 90)
    accent.withAlphaComponent(0.05).setFill()
    NSBezierPath(ovalIn: NSRect(x: -240, y: 2240, width: 760, height: 760)).fill()
    NSBezierPath(ovalIn: NSRect(x: 1640, y: 2400, width: 520, height: 520)).fill()

    let brandAttrs: [NSAttributedString.Key: Any] = [
        .font: font(semiboldName, size: 35, weight: .semibold),
        .foregroundColor: accent,
        .kern: 4.0,
    ]
    ("礼往来  ·  iPAD" as NSString).draw(at: NSPoint(x: 140, y: 2640), withAttributes: brandAttrs)

    let badge = NSRect(x: 1780, y: 2590, width: 132, height: 100)
    accent.setFill()
    NSBezierPath(roundedRect: badge, xRadius: 26, yRadius: 26).fill()
    let number = String(format: "%02d", index + 1) as NSString
    let numberAttrs: [NSAttributedString.Key: Any] = [.font: NSFont.monospacedDigitSystemFont(ofSize: 40, weight: .bold), .foregroundColor: NSColor.white]
    let numberSize = number.size(withAttributes: numberAttrs)
    number.draw(at: NSPoint(x: badge.midX - numberSize.width / 2, y: badge.midY - numberSize.height / 2), withAttributes: numberAttrs)

    let titleAttrs: [NSAttributedString.Key: Any] = [
        .font: font(semiboldName, size: 86, weight: .bold),
        .foregroundColor: NSColor(red: 0.10, green: 0.085, blue: 0.07, alpha: 1),
    ]
    (promo.title as NSString).draw(in: NSRect(x: 140, y: 2415, width: 1720, height: 125), withAttributes: titleAttrs)
    let subtitleAttrs: [NSAttributedString.Key: Any] = [
        .font: font(regularName, size: 38),
        .foregroundColor: NSColor(red: 0.37, green: 0.31, blue: 0.25, alpha: 1),
    ]
    (promo.subtitle as NSString).draw(in: NSRect(x: 144, y: 2328, width: 1720, height: 60), withAttributes: subtitleAttrs)

    let screenRect = NSRect(x: 172, y: -70, width: 1720, height: 2293)
    NSGraphicsContext.saveGraphicsState()
    let shadow = NSShadow()
    shadow.shadowColor = NSColor.black.withAlphaComponent(0.22)
    shadow.shadowBlurRadius = 40
    shadow.shadowOffset = NSSize(width: 0, height: -12)
    shadow.set()
    NSColor.black.withAlphaComponent(0.10).setFill()
    NSBezierPath(roundedRect: screenRect.insetBy(dx: -10, dy: -10), xRadius: 60, yRadius: 60).fill()
    NSGraphicsContext.restoreGraphicsState()

    NSGraphicsContext.saveGraphicsState()
    NSBezierPath(roundedRect: screenRect, xRadius: 52, yRadius: 52).addClip()
    screenshot.draw(in: screenRect, from: .zero, operation: .copy, fraction: 1)
    NSGraphicsContext.restoreGraphicsState()
    accent.withAlphaComponent(0.30).setStroke()
    let border = NSBezierPath(roundedRect: screenRect, xRadius: 52, yRadius: 52)
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
    let resize = Process()
    resize.executableURL = URL(fileURLWithPath: "/usr/bin/sips")
    resize.arguments = ["-z", "2752", "2064", outputURL.path]
    resize.standardOutput = FileHandle.nullDevice
    resize.standardError = FileHandle.nullDevice
    try resize.run()
    resize.waitUntilExit()
    guard resize.terminationStatus == 0 else { fatalError("Unable to resize \(promo.output)") }
    try stripAlpha(from: outputURL, width: 2064, height: 2752)
    print("Wrote \(promo.output)")
}
